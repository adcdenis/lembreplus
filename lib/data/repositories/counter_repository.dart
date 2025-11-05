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
        // Reconstrói como horário local "ingênuo" a partir dos componentes,
        // evitando offsets de +3h/-3h vindos de interpretações UTC diferentes.
        eventDate: DateTime(
          r.eventDate.year,
          r.eventDate.month,
          r.eventDate.day,
          r.eventDate.hour,
          r.eventDate.minute,
          r.eventDate.second,
          r.eventDate.millisecond,
          r.eventDate.microsecond,
        ),
        category: r.category,
        recurrence: r.recurrence,
        createdAt: DateTime(
          r.createdAt.year,
          r.createdAt.month,
          r.createdAt.day,
          r.createdAt.hour,
          r.createdAt.minute,
          r.createdAt.second,
          r.createdAt.millisecond,
          r.createdAt.microsecond,
        ),
        updatedAt: r.updatedAt == null
            ? null
            : DateTime(
                r.updatedAt!.year,
                r.updatedAt!.month,
                r.updatedAt!.day,
                r.updatedAt!.hour,
                r.updatedAt!.minute,
                r.updatedAt!.second,
                r.updatedAt!.millisecond,
                r.updatedAt!.microsecond,
              ),
      );

  CountersCompanion _toCompanion(Counter c) => CountersCompanion(
        id: c.id != null ? Value(c.id!) : const Value.absent(),
        name: Value(c.name),
        description: Value(c.description),
        // Persiste como hora local (parede) para manter semântica do usuário
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