import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lembreplus/data/database/app_database.dart';
import 'package:lembreplus/data/models/counter.dart';
import 'package:lembreplus/data/models/category.dart' as model;
import 'package:lembreplus/data/models/counter_history.dart' as hist;
import 'package:lembreplus/data/repositories/counter_repository.dart';
import 'package:lembreplus/data/repositories/category_repository.dart';
import 'package:lembreplus/data/repositories/history_repository.dart';
import 'package:lembreplus/data/services/backup_codec.dart';

void main() {
  group('Backup integration (encode/restore)', () {
    test('Exporta para JSON e restaura em novo banco', () async {
      // Banco A: cria dados
      final dbA = AppDatabase.test();
      final countersRepo = CounterRepository(dbA);
      final categoriesRepo = CategoryRepository(dbA);
      final historyRepo = HistoryRepository(dbA);

      final cId = await countersRepo.create(Counter(
        name: 'Evento Backup',
        description: 'Teste de backup',
        eventDate: DateTime(2032, 2, 20, 10, 30),
        category: 'geral',
        recurrence: 'none',
        createdAt: DateTime(2030, 1, 1),
        updatedAt: DateTime(2030, 1, 1),
      ));
      final catId = await categoriesRepo.create(model.Category(name: 'BackupCat', normalized: 'backupcat'));
      final hId = await historyRepo.create(hist.CounterHistory(
        counterId: cId,
        snapshot: jsonEncode({'name': 'Evento Backup'}),
        operation: 'create',
        timestamp: DateTime(2030, 1, 1),
      ));

      expect(cId, greaterThan(0));
      expect(catId, greaterThan(0));
      expect(hId, greaterThan(0));

      // Exporta JSON usando codec
      final jsonStr = await BackupCodec.encodeToJsonString(dbA);
      await dbA.close();

      // Banco B: novo e vazio; restaura a partir do JSON
      final dbB = AppDatabase.test();
      await BackupCodec.restoreFromJsonString(dbB, jsonStr);

      // Verifica que dados foram restaurados
      final counters = await dbB.getAllCounters();
      final categories = await dbB.getAllCategories();
      final history = await dbB.getAllHistory();

      expect(counters.length, 1);
      expect(categories.length, 1);
      expect(history.length, 1);

      expect(counters.first.name, 'Evento Backup');
      expect(categories.first.normalized, 'backupcat');
      expect(history.first.operation, 'create');

      await dbB.close();
    });
  });
}