import 'dart:convert';
import 'package:lembreplus/data/database/app_database.dart';
import 'package:lembreplus/data/models/counter.dart';
import 'package:drift/drift.dart';
import 'package:lembreplus/domain/time_utils.dart';

class CounterRepository {
  final AppDatabase db;
  CounterRepository(this.db);

  Counter _mapRow(CounterRow r) => Counter(
        id: r.id,
        name: r.name,
        description: r.description,
        // Converte para local primeiro (se vier em UTC do banco) e então
        // reconstrói como horário local "ingênuo" a partir dos componentes.
        eventDate: (() {
          final ev = r.eventDate.isUtc ? r.eventDate.toLocal() : r.eventDate;
          return DateTime(
            ev.year,
            ev.month,
            ev.day,
            ev.hour,
            ev.minute,
            ev.second,
            ev.millisecond,
            ev.microsecond,
          );
        })(),
        category: r.category,
        recurrence: r.recurrence,
        createdAt: (() {
          final ca = r.createdAt.isUtc ? r.createdAt.toLocal() : r.createdAt;
          return DateTime(
            ca.year,
            ca.month,
            ca.day,
            ca.hour,
            ca.minute,
            ca.second,
            ca.millisecond,
            ca.microsecond,
          );
        })(),
        updatedAt: r.updatedAt == null
            ? null
            : (() {
                final up = r.updatedAt!.isUtc ? r.updatedAt!.toLocal() : r.updatedAt!;
                return DateTime(
                  up.year,
                  up.month,
                  up.day,
                  up.hour,
                  up.minute,
                  up.second,
                  up.millisecond,
                  up.microsecond,
                );
              })(),
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

  /// Gera um snapshot JSON completo do contador com
  /// nome, descrição, categoria, recorrência, componentes de tempo e direção
  String _buildSnapshotFromCounter(Counter c, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final eventDate = c.eventDate;
    final comps = calendarDiff(eventDate, reference);
    final direction = isPast(eventDate, now: reference) ? 'past' : 'future';
    final offsetMinutes = reference.timeZoneOffset.inMinutes;
    final payload = {
      // Metadados do contador
      'name': c.name,
      'description': c.description,
      'category': c.category,
      'recurrence': c.recurrence,
      // Diferença de tempo
      'direction': direction,
      'years': comps.years,
      'months': comps.months,
      'days': comps.days,
      'hours': comps.hours,
      'minutes': comps.minutes,
      'seconds': comps.seconds,
      // Datas em ISO
      'eventDate': eventDate.toIso8601String(),
      'now': reference.toIso8601String(),
      // Componentes para evitar ambiguidades de fuso
      'event': {
        'year': eventDate.year,
        'month': eventDate.month,
        'day': eventDate.day,
        'hour': eventDate.hour,
        'minute': eventDate.minute,
        'second': eventDate.second,
      },
      'timezoneOffsetMinutes': offsetMinutes,
    };
    return jsonEncode(payload);
  }

  /// Cria contador e grava histórico com snapshot no momento da criação
  Future<int> createWithHistory(Counter c) async {
    final id = await db.insertCounter(_toCompanion(c));
    final snapshot = _buildSnapshotFromCounter(c);
    await db.insertHistory(CounterHistoryCompanion.insert(
      counterId: id,
      snapshot: snapshot,
      operation: 'create',
      timestamp: DateTime.now(),
    ));
    return id;
  }

  /// Atualiza contador gravando histórico ANTES de aplicar as mudanças
  Future<bool> updateWithHistory(Counter c) async {
    if (c.id == null) {
      // Sem id não é possível registrar histórico corretamente
      return db.updateCounter(_toCompanion(c));
    }
    final current = await db.getCounterById(c.id!);
    if (current != null) {
      final snapshot = _buildSnapshotFromCounter(_mapRow(current));
      await db.insertHistory(CounterHistoryCompanion.insert(
        counterId: current.id,
        snapshot: snapshot,
        operation: 'update',
        timestamp: DateTime.now(),
      ));
    }
    return db.updateCounter(_toCompanion(c));
  }
}