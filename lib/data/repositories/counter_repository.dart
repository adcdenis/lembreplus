import 'package:lembreplus/data/database/app_database.dart';
import 'package:lembreplus/data/models/counter.dart';
import 'package:drift/drift.dart';

class CounterRepository {
  final AppDatabase db;
  CounterRepository(this.db);

  Counter _mapRow(CounterRow r) => Counter(
        id: r.id,
        name: r.name,
        description: r.description,
        eventDate: r.eventDate,
        category: r.category,
        recurrence: r.recurrence,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );

  CountersCompanion _toCompanion(Counter c) => CountersCompanion(
        id: c.id != null ? Value(c.id!) : const Value.absent(),
        name: Value(c.name),
        description: Value(c.description),
        eventDate: Value(c.eventDate),
        category: Value(c.category),
        recurrence: Value(c.recurrence),
        createdAt: Value(c.createdAt),
        updatedAt: Value(c.updatedAt),
      );

  Future<int> create(Counter c) => db.insertCounter(_toCompanion(c));
  Future<List<Counter>> all() async => (await db.getAllCounters()).map(_mapRow).toList();
  Future<Counter?> byId(int id) async {
    final r = await db.getCounterById(id);
    return r == null ? null : _mapRow(r);
  }

  Future<bool> update(Counter c) => db.updateCounter(_toCompanion(c));
  Future<int> delete(int id) => db.deleteCounter(id);

  Stream<List<Counter>> watchAll() => db.watchAllCounters().map((rows) => rows.map(_mapRow).toList());
}