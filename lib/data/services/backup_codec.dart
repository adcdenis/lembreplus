import 'dart:convert';

import 'package:lembreplus/data/database/app_database.dart';

/// Utilitário para serializar e restaurar dados de backup sem depender de IO.
class BackupCodec {
  static DateTime _dateFromJson(dynamic v) {
    if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (v is String) return DateTime.parse(v);
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
    throw ArgumentError('Unsupported date value: $v');
  }
  /// Retorna verdadeiro se todos os erros forem apenas históricos órfãos.
  static bool isOnlyOrphanHistoryErrors(List<String> errors) {
    if (errors.isEmpty) return false;
    return errors.every((e) =>
        e.contains('history') && e.contains('counterId') && e.contains('não existe em counters'));
  }

  /// Conta quantos itens de histórico referenciam counters inexistentes no próprio backup.
  static int countOrphanHistory(Map<String, dynamic> data) {
    final counters = (data['counters'] as List<dynamic>? ?? []);
    final counterIds = <int>{};
    for (final c in counters) {
      final m = c as Map<String, dynamic>;
      final idVal = m['id'];
      if (idVal is num) counterIds.add(idVal.toInt());
    }
    final history = (data['history'] as List<dynamic>? ?? []);
    var count = 0;
    for (final h in history) {
      final m = h as Map<String, dynamic>;
      final cidVal = m['counterId'];
      final cid = cidVal is num ? cidVal.toInt() : null;
      if (cid == null || !counterIds.contains(cid)) count++;
    }
    return count;
  }
  /// Gera um Map pronto para JSON contendo todas as entidades.
  static Future<Map<String, dynamic>> encode(AppDatabase db) async {
    final counters = await db.getAllCounters();
    final categories = await db.getAllCategories();
    final history = await db.getAllHistory();

    return {
      'version': 1,
      'counters': counters.map((c) => {
        'id': c.id,
        'name': c.name,
        'description': c.description,
        'eventDate': c.eventDate.toIso8601String(),
        'category': c.category,
        'recurrence': c.recurrence,
        'createdAt': c.createdAt.toIso8601String(),
        'updatedAt': c.updatedAt?.toIso8601String(),
      }).toList(),
      'categories': categories.map((c) => {
        'id': c.id,
        'name': c.name,
        'normalized': c.normalized,
      }).toList(),
      'history': history.map((h) => {
        'id': h.id,
        'counterId': h.counterId,
        'snapshot': h.snapshot,
        'operation': h.operation,
        'timestamp': h.timestamp.toIso8601String(),
      }).toList(),
    };
  }

  /// Valida a estrutura e tipos do JSON de backup.
  /// Retorna uma lista de mensagens de erro; vazia se válido.
  static List<String> validate(Map<String, dynamic> data) {
    final errors = <String>[];

    void requireKey<T>(String key, bool Function(dynamic) typeCheck, {String? ctx}) {
      if (!data.containsKey(key)) {
        errors.add('[${ctx ?? 'root'}] chave obrigatória ausente: $key');
        return;
      }
      final v = data[key];
      if (!typeCheck(v)) {
        errors.add('[${ctx ?? 'root'}] tipo inválido para $key: ${v.runtimeType}');
      }
    }

    requireKey<int>('version', (v) => v is int);
    requireKey<List>('counters', (v) => v is List);
    requireKey<List>('categories', (v) => v is List);
    requireKey<List>('history', (v) => v is List);

    // Counters
    final counters = (data['counters'] as List<dynamic>? ?? []);
    final counterIds = <int>{};
    for (var i = 0; i < counters.length; i++) {
      final m = counters[i];
      if (m is! Map<String, dynamic>) {
        errors.add('[counters[$i]] não é um objeto');
        continue;
      }
      if (m['id'] is! num) {
        errors.add('[counters[$i]] id obrigatorio (num)');
      } else {
        counterIds.add((m['id'] as num).toInt());
      }
      if (m['name'] is! String) errors.add('[counters[$i]] name obrigatorio (string)');
      if (m['description'] != null && m['description'] is! String) errors.add('[counters[$i]] description opcional (string)');
      if (m['eventDate'] == null) {
        errors.add('[counters[$i]] eventDate obrigatorio');
      } else {
        try { _dateFromJson(m['eventDate']); } catch (_) { errors.add('[counters[$i]] eventDate inválido'); }
      }
      if (m['category'] != null && m['category'] is! String) errors.add('[counters[$i]] category opcional (string)');
      if (m['recurrence'] != null && m['recurrence'] is! String) errors.add('[counters[$i]] recurrence opcional (string)');
      if (m['createdAt'] == null) {
        errors.add('[counters[$i]] createdAt obrigatorio');
      } else {
        try { _dateFromJson(m['createdAt']); } catch (_) { errors.add('[counters[$i]] createdAt inválido'); }
      }
      if (m['updatedAt'] != null) {
        try { _dateFromJson(m['updatedAt']); } catch (_) { errors.add('[counters[$i]] updatedAt inválido'); }
      }
    }

    // Categories
    final categories = (data['categories'] as List<dynamic>? ?? []);
    for (var i = 0; i < categories.length; i++) {
      final m = categories[i];
      if (m is! Map<String, dynamic>) { errors.add('[categories[$i]] não é um objeto'); continue; }
      if (m['id'] is! num) errors.add('[categories[$i]] id obrigatorio (num)');
      if (m['name'] is! String) errors.add('[categories[$i]] name obrigatorio (string)');
      if (m['normalized'] is! String) errors.add('[categories[$i]] normalized obrigatorio (string)');
    }

    // History
    final history = (data['history'] as List<dynamic>? ?? []);
    for (var i = 0; i < history.length; i++) {
      final m = history[i];
      if (m is! Map<String, dynamic>) { errors.add('[history[$i]] não é um objeto'); continue; }
      if (m['id'] is! num) errors.add('[history[$i]] id obrigatorio (num)');
      if (m['counterId'] is! num) {
        errors.add('[history[$i]] counterId obrigatorio (num)');
      } else {
        final cid = (m['counterId'] as num).toInt();
        if (!counterIds.contains(cid)) {
          errors.add('[history[$i]] counterId "$cid" não existe em counters');
        }
      }
      if (m['snapshot'] is! String) errors.add('[history[$i]] snapshot obrigatorio (string)');
      if (m['operation'] is! String) errors.add('[history[$i]] operation obrigatorio (string)');
      if (m['timestamp'] == null) {
        errors.add('[history[$i]] timestamp obrigatorio');
      } else {
        try { _dateFromJson(m['timestamp']); } catch (_) { errors.add('[history[$i]] timestamp inválido'); }
      }
    }

    return errors;
  }

  /// Restaura dados a partir de um Map JSON.
  static Future<void> restore(AppDatabase db, Map<String, dynamic> data) async {
    // Executa restauração de forma atômica para evitar estados intermediários
    await db.transaction(() async {
      // Restauração completa: limpamos os dados atuais antes de inserir
      // A remoção de counters também remove counter_history via CASCADE
      await db.customStatement('DELETE FROM categories');
      await db.customStatement('DELETE FROM counters');

      // Recria categorias
      final categories = (data['categories'] as List<dynamic>? ?? []);
      for (final cat in categories) {
        final m = cat as Map<String, dynamic>;
        await db.upsertCategoryRaw(
          id: (m['id'] as num).toInt(),
          name: m['name'] as String,
          normalized: m['normalized'] as String,
        );
      }

      // Recria contadores
      final counters = (data['counters'] as List<dynamic>? ?? []);
      for (final c in counters) {
        final m = c as Map<String, dynamic>;
        await db.upsertCounterRaw(
          id: (m['id'] as num).toInt(),
          name: m['name'] as String,
          description: m['description'] as String?,
          eventDate: _dateFromJson(m['eventDate']),
          category: m['category'] as String?,
          recurrence: m['recurrence'] as String?,
          createdAt: _dateFromJson(m['createdAt']),
          updatedAt: m['updatedAt'] != null ? _dateFromJson(m['updatedAt']) : null,
        );
      }

      // Recria histórico (já com os counters existentes)
      final history = (data['history'] as List<dynamic>? ?? []);
      final countersList = (data['counters'] as List<dynamic>? ?? []);
      final validCounterIds = <int>{};
      for (final c in countersList) {
        final m = c as Map<String, dynamic>;
        final idVal = m['id'];
        if (idVal is num) validCounterIds.add(idVal.toInt());
      }
      for (final h in history) {
        final m = h as Map<String, dynamic>;
        final cid = (m['counterId'] as num).toInt();
        // Garante integridade: ignora históricos cujo counterId não consta no backup
        if (!validCounterIds.contains(cid)) {
          continue;
        }
        await db.upsertHistoryRaw(
          id: (m['id'] as num).toInt(),
          counterId: cid,
          snapshot: m['snapshot'] as String,
          operation: m['operation'] as String,
          timestamp: _dateFromJson(m['timestamp']),
        );
      }
    });
  }

  /// Convenience para retornar uma String JSON a partir do banco.
  static Future<String> encodeToJsonString(AppDatabase db) async {
    final map = await encode(db);
    return jsonEncode(map);
  }

  /// Convenience para restaurar a partir de uma String JSON.
  static Future<void> restoreFromJsonString(AppDatabase db, String jsonStr) async {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    await restore(db, data);
  }
}