import 'package:lembreplus/data/database/app_database.dart';
import 'package:lembreplus/data/models/counter_history.dart' as model;
import 'package:drift/drift.dart';

class HistoryRepository {
  final AppDatabase db;
  HistoryRepository(this.db);

  model.CounterHistory _mapRow(CounterHistoryRow r) => model.CounterHistory(
        id: r.id,
        counterId: r.counterId,
        snapshot: r.snapshot,
        operation: r.operation,
        timestamp: r.timestamp,
      );

  CounterHistoryCompanion _toCompanion(model.CounterHistory h) => CounterHistoryCompanion(
        id: h.id != null ? Value(h.id!) : const Value.absent(),
        counterId: Value(h.counterId),
        snapshot: Value(h.snapshot),
        operation: Value(h.operation),
        timestamp: Value(h.timestamp),
      );

  Future<int> create(model.CounterHistory h) => db.insertHistory(_toCompanion(h));
  Future<List<model.CounterHistory>> byCounter(int counterId) async =>
      (await db.getHistoryForCounter(counterId)).map(_mapRow).toList();

  Stream<List<model.CounterHistory>> watchByCounter(int counterId) =>
      db.watchHistoryForCounter(counterId).map((rows) => rows.map(_mapRow).toList());
}