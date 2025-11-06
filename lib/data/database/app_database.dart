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
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

@DataClassName('CounterHistoryRow')
class CounterHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get counterId => integer().references(Counters, #id, onDelete: KeyAction.cascade)();
  TextColumn get snapshot => text()();
  TextColumn get operation => text()();
  DateTimeColumn get timestamp => dateTime()();
}

@DataClassName('CategoryRow')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get normalized => text()();
}

LazyDatabase _openConnection() => openConnection();

@DriftDatabase(tables: [Counters, CounterHistory, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.test() : super(openTestConnection());

  @override
  int get schemaVersion => 1;

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
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
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
      (select(counterHistory)..where((t) => t.counterId.equals(counterId))).get();
  Stream<List<CounterHistoryRow>> watchHistoryForCounter(int counterId) =>
      (select(counterHistory)..where((t) => t.counterId.equals(counterId))).watch();
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