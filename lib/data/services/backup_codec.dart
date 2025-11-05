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
  /// Gera um Map pronto para JSON contendo todas as entidades.
  static Future<Map<String, dynamic>> encode(AppDatabase db) async {
    final counters = await db.getAllCounters();
    final categories = await db.getAllCategories();
    final history = await db.getAllHistory();

    return {
      'version': 1,
      'counters': counters.map((c) => c.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'history': history.map((h) => h.toJson()).toList(),
    };
  }

  /// Restaura dados a partir de um Map JSON.
  static Future<void> restore(AppDatabase db, Map<String, dynamic> data) async {
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

    final categories = (data['categories'] as List<dynamic>? ?? []);
    for (final cat in categories) {
      final m = cat as Map<String, dynamic>;
      await db.upsertCategoryRaw(
        id: (m['id'] as num).toInt(),
        name: m['name'] as String,
        normalized: m['normalized'] as String,
      );
    }

    final history = (data['history'] as List<dynamic>? ?? []);
    for (final h in history) {
      final m = h as Map<String, dynamic>;
      await db.upsertHistoryRaw(
        id: (m['id'] as num).toInt(),
        counterId: (m['counterId'] as num).toInt(),
        snapshot: m['snapshot'] as String,
        operation: m['operation'] as String,
        timestamp: _dateFromJson(m['timestamp']),
      );
    }
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