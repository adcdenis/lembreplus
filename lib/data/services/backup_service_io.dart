import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
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
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}lembre_backup.json');

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

    await file.writeAsString(json);
    return 'Backup salvo em ${file.path}';
  }

  @override
  Future<String> import() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}lembre_backup.json');
    if (!await file.exists()) {
      throw 'Arquivo não encontrado em ${file.path}';
    }
    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;

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

    return 'Dados importados com sucesso';
  }
}