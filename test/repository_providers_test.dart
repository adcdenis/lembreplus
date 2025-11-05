import 'package:flutter_test/flutter_test.dart';
import 'package:lembreplus/data/database/app_database.dart';
import 'package:lembreplus/data/models/counter.dart';
import 'package:lembreplus/data/models/category.dart' as model;
import 'package:lembreplus/data/models/counter_history.dart' as hist;
import 'package:lembreplus/data/repositories/counter_repository.dart';
import 'package:lembreplus/data/repositories/category_repository.dart';
import 'package:lembreplus/data/repositories/history_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lembreplus/state/providers.dart';

void main() {
  group('Repositories and Providers', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase.test();
      container = ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(db),
      ]);
    });

    tearDown(() async {
      await db.close();
      container.dispose();
    });

    test('CounterRepository CRUD and stream', () async {
      final repo = CounterRepository(db);
      final c = Counter(
        name: 'Evento',
        description: 'Desc',
        eventDate: DateTime(2030, 1, 1),
        category: 'general',
        recurrence: 'none',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final id = await repo.create(c);
      expect(id, greaterThan(0));

      final list = await repo.all();
      expect(list.length, 1);
      expect(list.first.name, 'Evento');

      final items = await repo.watchAll().first;
      expect(items.length, 1);
      expect(items.first.id, id);
    });

    test('CategoryRepository CRUD and stream', () async {
      final repo = CategoryRepository(db);
      final cat = model.Category(name: 'Aniversário', normalized: 'aniversario');
      final id = await repo.create(cat);
      expect(id, greaterThan(0));

      final list = await repo.all();
      expect(list.length, 1);
      expect(list.first.normalized, 'aniversario');

      final items = await repo.watchAll().first;
      expect(items.length, 1);
      expect(items.first.id, id);
    });

    test('HistoryRepository insert and watchByCounter', () async {
      final counters = CounterRepository(db);
      final histories = HistoryRepository(db);
      final id = await counters.create(Counter(
        name: 'Teste',
        description: 'Hist',
        eventDate: DateTime(2030, 5, 20),
        category: 'general',
        recurrence: 'none',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      final hId = await histories.create(hist.CounterHistory(
        counterId: id,
        snapshot: '0',
        operation: 'create',
        timestamp: DateTime.now(),
      ));
      expect(hId, greaterThan(0));

      final list = await histories.byCounter(id);
      expect(list.length, 1);
      expect(list.first.operation, 'create');

      final items = await histories.watchByCounter(id).first;
      expect(items.length, 1);
      expect(items.first.counterId, id);
    });

    test('Providers stream integration', () async {
      final countersRepo = container.read(counterRepositoryProvider);
      final categoriesRepo = container.read(categoryRepositoryProvider);
      final historiesRepo = container.read(historyRepositoryProvider);

      final id = await countersRepo.create(Counter(
        name: 'Provider',
        description: 'Stream',
        eventDate: DateTime(2031, 1, 1),
        category: 'general',
        recurrence: 'none',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      await categoriesRepo.create(model.Category(name: 'Geral', normalized: 'geral'));
      await historiesRepo.create(hist.CounterHistory(counterId: id, snapshot: '1', operation: 'create', timestamp: DateTime.now()));

      final countersFuture = container.read(countersProvider.future);
      final categoriesFuture = container.read(categoriesProvider.future);
      final historyFuture = container.read(historyProvider(id).future);

      final c = await countersFuture;
      final cat = await categoriesFuture;
      final h = await historyFuture;

      expect(c.length, 1);
      expect(cat.length, 1);
      expect(h.length, 1);
    });
  });
}