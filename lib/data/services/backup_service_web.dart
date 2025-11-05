import 'dart:convert';
import 'dart:async';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:lembreplus/data/database/app_database.dart';

abstract class BackupService {
  Future<String> export();
  Future<String> import();
}

class BackupServiceImpl implements BackupService {
  final AppDatabase db;
  BackupServiceImpl(this.db);

  @override
  Future<String> export() async {
    final counters = await db.getAllCounters();
    final categories = await db.getAllCategories();
    final history = await db.getAllHistory();

    final json = jsonEncode({
      'version': 1,
      'counters': counters
          .map((c) => {
                'id': c.id,
                'name': c.name,
                'description': c.description,
                'eventDate': c.eventDate.toIso8601String(),
                'category': c.category,
                'recurrence': c.recurrence,
                'createdAt': c.createdAt.toIso8601String(),
                'updatedAt': c.updatedAt?.toIso8601String(),
              })
          .toList(),
      'categories': categories
          .map((cat) => {
                'id': cat.id,
                'name': cat.name,
                'normalized': cat.normalized,
              })
          .toList(),
      'history': history
          .map((h) => {
                'id': h.id,
                'counterId': h.counterId,
                'snapshot': h.snapshot,
                'operation': h.operation,
                'timestamp': h.timestamp.toIso8601String(),
              })
          .toList(),
    });

    final bytes = utf8.encode(json);
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..download = 'lembre_backup.json'
      ..click();
    html.Url.revokeObjectUrl(url);
    return 'Download iniciado (lembre_backup.json)';
  }

  @override
  Future<String> import() async {
    final input = html.FileUploadInputElement()..accept = '.json,application/json';
    final completer = Completer<String>();
    input.onChange.listen((event) {
      final file = input.files?.first;
      if (file == null) {
        completer.completeError('Nenhum arquivo selecionado');
        return;
      }
      final reader = html.FileReader();
      reader.onLoadEnd.listen((_) async {
        try {
          final content = reader.result as String;
          final data = jsonDecode(content) as Map<String, dynamic>;
          await _restoreFromJson(data);
          completer.complete('Dados importados com sucesso');
        } catch (e) {
          completer.completeError(e);
        }
      });
      reader.readAsText(file);
    });
    input.click();
    return completer.future;
  }

  Future<void> _restoreFromJson(Map<String, dynamic> data) async {
    final counters = (data['counters'] as List<dynamic>? ?? []);
    for (final c in counters) {
      final m = c as Map<String, dynamic>;
      await db.upsertCounterRaw(
        id: m['id'] as int,
        name: m['name'] as String,
        description: m['description'] as String?,
        eventDate: DateTime.parse(m['eventDate'] as String),
        category: m['category'] as String?,
        recurrence: m['recurrence'] as String?,
        createdAt: DateTime.parse(m['createdAt'] as String),
        updatedAt: (m['updatedAt'] as String?) != null ? DateTime.parse(m['updatedAt'] as String) : null,
      );
    }

    final categories = (data['categories'] as List<dynamic>? ?? []);
    for (final cat in categories) {
      final m = cat as Map<String, dynamic>;
      await db.upsertCategoryRaw(
        id: m['id'] as int,
        name: m['name'] as String,
        normalized: m['normalized'] as String,
      );
    }

    final history = (data['history'] as List<dynamic>? ?? []);
    for (final h in history) {
      final m = h as Map<String, dynamic>;
      await db.upsertHistoryRaw(
        id: m['id'] as int,
        counterId: m['counterId'] as int,
        snapshot: m['snapshot'] as String,
        operation: m['operation'] as String,
        timestamp: DateTime.parse(m['timestamp'] as String),
      );
    }
  }
}