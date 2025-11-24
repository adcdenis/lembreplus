import 'package:drift/drift.dart';
import 'connection/open_connection.dart';
import 'connection/open_test_connection.dart';

part 'app_database.g.dart';

@DataClassName('CounterRow')
class Counters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get eventDate => dateTime()();
  TextColumn get category => text().nullable()();
  TextColumn get recurrence => text().nullable()();
  IntColumn get alertOffset => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

@DataClassName('CategoryRow')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get normalized => text()();
}

@DataClassName('CounterHistoryRow')
class CounterHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get counterId => integer().references(Counters, #id, onDelete: KeyAction.cascade)();
  TextColumn get snapshot => text()();
  TextColumn get operation => text()();
  DateTimeColumn get timestamp => dateTime()();
}

@DataClassName('CounterAlertRow')
class CounterAlerts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get counterId => integer().references(Counters, #id, onDelete: KeyAction.cascade)();
  IntColumn get offsetMinutes => integer()();
}

LazyDatabase _openConnection() => openConnection();

@DriftDatabase(tables: [Counters, CounterHistory, Categories, CounterAlerts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.test() : super(openTestConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(counters, counters.alertOffset);
          }
          if (from < 3) {
            await m.createTable(counterAlerts);
            // Migração de dados: mover alertOffset para CounterAlerts
            final oldCounters = await select(counters).get();
            for (final c in oldCounters) {
              if (c.alertOffset != null) {
                await into(counterAlerts).insert(
                  CounterAlertsCompanion.insert(
                    counterId: c.id,
                    offsetMinutes: c.alertOffset!,
                  ),
                );
              }
            }
          }
        },
        beforeOpen: (details) async {
          // Garante que chaves estrangeiras estejam ativadas (necessário para CASCADE funcionar)
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  // CRUD básico para Counters
  Future<int> insertCounter(CountersCompanion entry) => into(counters).insert(entry);
  Future<List<CounterRow>> getAllCounters() => select(counters).get();
  Future<CounterRow?> getCounterById(int id) => (select(counters)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<bool> updateCounter(CountersCompanion entry) => update(counters).replace(entry);
  Future<int> deleteCounter(int id) => (delete(counters)..where((t) => t.id.equals(id))).go();
  Future<int> countCountersByCategoryName(String name) async {
    final rows = await (select(counters)..where((t) => t.category.equals(name))).get();
    return rows.length;
  }
  Stream<List<CounterRow>> watchAllCounters() => select(counters).watch();
  Future<void> upsertCounterRaw({
    required int id,
    required String name,
    String? description,
    required DateTime eventDate,
    String? category,
    String? recurrence,
    int? alertOffset,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) async {
    await into(counters).insertOnConflictUpdate(CountersCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      eventDate: Value(eventDate),
      category: Value(category),
      recurrence: Value(recurrence),
      alertOffset: Value(alertOffset),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    ));
  }
  
  // CRUD para CounterAlerts
  Future<int> insertAlert(CounterAlertsCompanion entry) => into(counterAlerts).insert(entry);
  Future<void> deleteAlertsForCounter(int counterId) => (delete(counterAlerts)..where((t) => t.counterId.equals(counterId))).go();
  Future<List<CounterAlertRow>> getAlertsForCounter(int counterId) => (select(counterAlerts)..where((t) => t.counterId.equals(counterId))).get();
  Future<List<CounterAlertRow>> getAllAlerts() => select(counterAlerts).get();
  Future<void> upsertAlertRaw({
    required int id,
    required int counterId,
    required int offsetMinutes,
  }) async {
    await into(counterAlerts).insertOnConflictUpdate(CounterAlertsCompanion(
      id: Value(id),
      counterId: Value(counterId),
      offsetMinutes: Value(offsetMinutes),
    ));
  }

  // CRUD básico para Categories
  Future<int> insertCategory(CategoriesCompanion entry) => into(categories).insert(entry);
  Future<List<CategoryRow>> getAllCategories() => select(categories).get();
  Future<CategoryRow?> getCategoryById(int id) => (select(categories)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<CategoryRow?> getCategoryByNormalized(String normalized) =>
      (select(categories)..where((t) => t.normalized.equals(normalized))).getSingleOrNull();
  Future<bool> updateCategory(CategoriesCompanion entry) => update(categories).replace(entry);
  Future<int> deleteCategory(int id) => (delete(categories)..where((t) => t.id.equals(id))).go();
  Stream<List<CategoryRow>> watchAllCategories() => select(categories).watch();
  Future<void> upsertCategoryRaw({
    required int id,
    required String name,
    required String normalized,
  }) async {
    await into(categories).insertOnConflictUpdate(CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      normalized: Value(normalized),
    ));
  }

  // Histórico
  Future<int> insertHistory(CounterHistoryCompanion entry) => into(counterHistory).insert(entry);
  Future<List<CounterHistoryRow>> getHistoryForCounter(int counterId) =>
      (select(counterHistory)
            ..where((t) => t.counterId.equals(counterId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
              (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
            ]))
          .get();
  Stream<List<CounterHistoryRow>> watchHistoryForCounter(int counterId) =>
      (select(counterHistory)
            ..where((t) => t.counterId.equals(counterId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
              (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
            ]))
          .watch();
  Future<List<CounterHistoryRow>> getAllHistory() => select(counterHistory).get();
  Future<int> deleteHistory(int id) => (delete(counterHistory)..where((t) => t.id.equals(id))).go();
  Future<void> upsertHistoryRaw({
    required int id,
    required int counterId,
    required String snapshot,
    required String operation,
    required DateTime timestamp,
  }) async {
    await into(counterHistory).insertOnConflictUpdate(CounterHistoryCompanion(
      id: Value(id),
      counterId: Value(counterId),
      snapshot: Value(snapshot),
      operation: Value(operation),
      timestamp: Value(timestamp),
    ));
  }
}