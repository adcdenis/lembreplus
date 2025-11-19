// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CountersTable extends Counters
    with TableInfo<$CountersTable, CounterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventDateMeta = const VerificationMeta(
    'eventDate',
  );
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
    'event_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceMeta = const VerificationMeta(
    'recurrence',
  );
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
    'recurrence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alertOffsetMeta = const VerificationMeta(
    'alertOffset',
  );
  @override
  late final GeneratedColumn<int> alertOffset = GeneratedColumn<int>(
    'alert_offset',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    eventDate,
    category,
    recurrence,
    alertOffset,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'counters';
  @override
  VerificationContext validateIntegrity(
    Insertable<CounterRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('event_date')) {
      context.handle(
        _eventDateMeta,
        eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta),
      );
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('recurrence')) {
      context.handle(
        _recurrenceMeta,
        recurrence.isAcceptableOrUnknown(data['recurrence']!, _recurrenceMeta),
      );
    }
    if (data.containsKey('alert_offset')) {
      context.handle(
        _alertOffsetMeta,
        alertOffset.isAcceptableOrUnknown(
          data['alert_offset']!,
          _alertOffsetMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CounterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CounterRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      eventDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}event_date'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      recurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence'],
      ),
      alertOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alert_offset'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CountersTable createAlias(String alias) {
    return $CountersTable(attachedDatabase, alias);
  }
}

class CounterRow extends DataClass implements Insertable<CounterRow> {
  final int id;
  final String name;
  final String? description;
  final DateTime eventDate;
  final String? category;
  final String? recurrence;
  final int? alertOffset;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const CounterRow({
    required this.id,
    required this.name,
    this.description,
    required this.eventDate,
    this.category,
    this.recurrence,
    this.alertOffset,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['event_date'] = Variable<DateTime>(eventDate);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || recurrence != null) {
      map['recurrence'] = Variable<String>(recurrence);
    }
    if (!nullToAbsent || alertOffset != null) {
      map['alert_offset'] = Variable<int>(alertOffset);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  CountersCompanion toCompanion(bool nullToAbsent) {
    return CountersCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      eventDate: Value(eventDate),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      recurrence: recurrence == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrence),
      alertOffset: alertOffset == null && nullToAbsent
          ? const Value.absent()
          : Value(alertOffset),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CounterRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CounterRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      eventDate: serializer.fromJson<DateTime>(json['eventDate']),
      category: serializer.fromJson<String?>(json['category']),
      recurrence: serializer.fromJson<String?>(json['recurrence']),
      alertOffset: serializer.fromJson<int?>(json['alertOffset']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'eventDate': serializer.toJson<DateTime>(eventDate),
      'category': serializer.toJson<String?>(category),
      'recurrence': serializer.toJson<String?>(recurrence),
      'alertOffset': serializer.toJson<int?>(alertOffset),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  CounterRow copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    DateTime? eventDate,
    Value<String?> category = const Value.absent(),
    Value<String?> recurrence = const Value.absent(),
    Value<int?> alertOffset = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => CounterRow(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    eventDate: eventDate ?? this.eventDate,
    category: category.present ? category.value : this.category,
    recurrence: recurrence.present ? recurrence.value : this.recurrence,
    alertOffset: alertOffset.present ? alertOffset.value : this.alertOffset,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CounterRow copyWithCompanion(CountersCompanion data) {
    return CounterRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      category: data.category.present ? data.category.value : this.category,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      alertOffset: data.alertOffset.present
          ? data.alertOffset.value
          : this.alertOffset,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CounterRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('eventDate: $eventDate, ')
          ..write('category: $category, ')
          ..write('recurrence: $recurrence, ')
          ..write('alertOffset: $alertOffset, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    eventDate,
    category,
    recurrence,
    alertOffset,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CounterRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.eventDate == this.eventDate &&
          other.category == this.category &&
          other.recurrence == this.recurrence &&
          other.alertOffset == this.alertOffset &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CountersCompanion extends UpdateCompanion<CounterRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime> eventDate;
  final Value<String?> category;
  final Value<String?> recurrence;
  final Value<int?> alertOffset;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  const CountersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.category = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.alertOffset = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CountersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    required DateTime eventDate,
    this.category = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.alertOffset = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       eventDate = Value(eventDate),
       createdAt = Value(createdAt);
  static Insertable<CounterRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? eventDate,
    Expression<String>? category,
    Expression<String>? recurrence,
    Expression<int>? alertOffset,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (eventDate != null) 'event_date': eventDate,
      if (category != null) 'category': category,
      if (recurrence != null) 'recurrence': recurrence,
      if (alertOffset != null) 'alert_offset': alertOffset,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CountersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<DateTime>? eventDate,
    Value<String?>? category,
    Value<String?>? recurrence,
    Value<int?>? alertOffset,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
  }) {
    return CountersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      category: category ?? this.category,
      recurrence: recurrence ?? this.recurrence,
      alertOffset: alertOffset ?? this.alertOffset,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<DateTime>(eventDate.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    if (alertOffset.present) {
      map['alert_offset'] = Variable<int>(alertOffset.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('eventDate: $eventDate, ')
          ..write('category: $category, ')
          ..write('recurrence: $recurrence, ')
          ..write('alertOffset: $alertOffset, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CounterHistoryTable extends CounterHistory
    with TableInfo<$CounterHistoryTable, CounterHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CounterHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _counterIdMeta = const VerificationMeta(
    'counterId',
  );
  @override
  late final GeneratedColumn<int> counterId = GeneratedColumn<int>(
    'counter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES counters (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _snapshotMeta = const VerificationMeta(
    'snapshot',
  );
  @override
  late final GeneratedColumn<String> snapshot = GeneratedColumn<String>(
    'snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    counterId,
    snapshot,
    operation,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'counter_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<CounterHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('counter_id')) {
      context.handle(
        _counterIdMeta,
        counterId.isAcceptableOrUnknown(data['counter_id']!, _counterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_counterIdMeta);
    }
    if (data.containsKey('snapshot')) {
      context.handle(
        _snapshotMeta,
        snapshot.isAcceptableOrUnknown(data['snapshot']!, _snapshotMeta),
      );
    } else if (isInserting) {
      context.missing(_snapshotMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CounterHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CounterHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      counterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}counter_id'],
      )!,
      snapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $CounterHistoryTable createAlias(String alias) {
    return $CounterHistoryTable(attachedDatabase, alias);
  }
}

class CounterHistoryRow extends DataClass
    implements Insertable<CounterHistoryRow> {
  final int id;
  final int counterId;
  final String snapshot;
  final String operation;
  final DateTime timestamp;
  const CounterHistoryRow({
    required this.id,
    required this.counterId,
    required this.snapshot,
    required this.operation,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['counter_id'] = Variable<int>(counterId);
    map['snapshot'] = Variable<String>(snapshot);
    map['operation'] = Variable<String>(operation);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  CounterHistoryCompanion toCompanion(bool nullToAbsent) {
    return CounterHistoryCompanion(
      id: Value(id),
      counterId: Value(counterId),
      snapshot: Value(snapshot),
      operation: Value(operation),
      timestamp: Value(timestamp),
    );
  }

  factory CounterHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CounterHistoryRow(
      id: serializer.fromJson<int>(json['id']),
      counterId: serializer.fromJson<int>(json['counterId']),
      snapshot: serializer.fromJson<String>(json['snapshot']),
      operation: serializer.fromJson<String>(json['operation']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'counterId': serializer.toJson<int>(counterId),
      'snapshot': serializer.toJson<String>(snapshot),
      'operation': serializer.toJson<String>(operation),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  CounterHistoryRow copyWith({
    int? id,
    int? counterId,
    String? snapshot,
    String? operation,
    DateTime? timestamp,
  }) => CounterHistoryRow(
    id: id ?? this.id,
    counterId: counterId ?? this.counterId,
    snapshot: snapshot ?? this.snapshot,
    operation: operation ?? this.operation,
    timestamp: timestamp ?? this.timestamp,
  );
  CounterHistoryRow copyWithCompanion(CounterHistoryCompanion data) {
    return CounterHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      counterId: data.counterId.present ? data.counterId.value : this.counterId,
      snapshot: data.snapshot.present ? data.snapshot.value : this.snapshot,
      operation: data.operation.present ? data.operation.value : this.operation,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CounterHistoryRow(')
          ..write('id: $id, ')
          ..write('counterId: $counterId, ')
          ..write('snapshot: $snapshot, ')
          ..write('operation: $operation, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, counterId, snapshot, operation, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CounterHistoryRow &&
          other.id == this.id &&
          other.counterId == this.counterId &&
          other.snapshot == this.snapshot &&
          other.operation == this.operation &&
          other.timestamp == this.timestamp);
}

class CounterHistoryCompanion extends UpdateCompanion<CounterHistoryRow> {
  final Value<int> id;
  final Value<int> counterId;
  final Value<String> snapshot;
  final Value<String> operation;
  final Value<DateTime> timestamp;
  const CounterHistoryCompanion({
    this.id = const Value.absent(),
    this.counterId = const Value.absent(),
    this.snapshot = const Value.absent(),
    this.operation = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  CounterHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int counterId,
    required String snapshot,
    required String operation,
    required DateTime timestamp,
  }) : counterId = Value(counterId),
       snapshot = Value(snapshot),
       operation = Value(operation),
       timestamp = Value(timestamp);
  static Insertable<CounterHistoryRow> custom({
    Expression<int>? id,
    Expression<int>? counterId,
    Expression<String>? snapshot,
    Expression<String>? operation,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (counterId != null) 'counter_id': counterId,
      if (snapshot != null) 'snapshot': snapshot,
      if (operation != null) 'operation': operation,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  CounterHistoryCompanion copyWith({
    Value<int>? id,
    Value<int>? counterId,
    Value<String>? snapshot,
    Value<String>? operation,
    Value<DateTime>? timestamp,
  }) {
    return CounterHistoryCompanion(
      id: id ?? this.id,
      counterId: counterId ?? this.counterId,
      snapshot: snapshot ?? this.snapshot,
      operation: operation ?? this.operation,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (counterId.present) {
      map['counter_id'] = Variable<int>(counterId.value);
    }
    if (snapshot.present) {
      map['snapshot'] = Variable<String>(snapshot.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CounterHistoryCompanion(')
          ..write('id: $id, ')
          ..write('counterId: $counterId, ')
          ..write('snapshot: $snapshot, ')
          ..write('operation: $operation, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedMeta = const VerificationMeta(
    'normalized',
  );
  @override
  late final GeneratedColumn<String> normalized = GeneratedColumn<String>(
    'normalized',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, normalized];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized')) {
      context.handle(
        _normalizedMeta,
        normalized.isAcceptableOrUnknown(data['normalized']!, _normalizedMeta),
      );
    } else if (isInserting) {
      context.missing(_normalizedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final int id;
  final String name;
  final String normalized;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.normalized,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['normalized'] = Variable<String>(normalized);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      normalized: Value(normalized),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      normalized: serializer.fromJson<String>(json['normalized']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'normalized': serializer.toJson<String>(normalized),
    };
  }

  CategoryRow copyWith({int? id, String? name, String? normalized}) =>
      CategoryRow(
        id: id ?? this.id,
        name: name ?? this.name,
        normalized: normalized ?? this.normalized,
      );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      normalized: data.normalized.present
          ? data.normalized.value
          : this.normalized,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalized: $normalized')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, normalized);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.normalized == this.normalized);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> normalized;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.normalized = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String normalized,
  }) : name = Value(name),
       normalized = Value(normalized);
  static Insertable<CategoryRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? normalized,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (normalized != null) 'normalized': normalized,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? normalized,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      normalized: normalized ?? this.normalized,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalized.present) {
      map['normalized'] = Variable<String>(normalized.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalized: $normalized')
          ..write(')'))
        .toString();
  }
}

class $CounterAlertsTable extends CounterAlerts
    with TableInfo<$CounterAlertsTable, CounterAlertRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CounterAlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _counterIdMeta = const VerificationMeta(
    'counterId',
  );
  @override
  late final GeneratedColumn<int> counterId = GeneratedColumn<int>(
    'counter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES counters (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _offsetMinutesMeta = const VerificationMeta(
    'offsetMinutes',
  );
  @override
  late final GeneratedColumn<int> offsetMinutes = GeneratedColumn<int>(
    'offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, counterId, offsetMinutes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'counter_alerts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CounterAlertRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('counter_id')) {
      context.handle(
        _counterIdMeta,
        counterId.isAcceptableOrUnknown(data['counter_id']!, _counterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_counterIdMeta);
    }
    if (data.containsKey('offset_minutes')) {
      context.handle(
        _offsetMinutesMeta,
        offsetMinutes.isAcceptableOrUnknown(
          data['offset_minutes']!,
          _offsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_offsetMinutesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CounterAlertRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CounterAlertRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      counterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}counter_id'],
      )!,
      offsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}offset_minutes'],
      )!,
    );
  }

  @override
  $CounterAlertsTable createAlias(String alias) {
    return $CounterAlertsTable(attachedDatabase, alias);
  }
}

class CounterAlertRow extends DataClass implements Insertable<CounterAlertRow> {
  final int id;
  final int counterId;
  final int offsetMinutes;
  const CounterAlertRow({
    required this.id,
    required this.counterId,
    required this.offsetMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['counter_id'] = Variable<int>(counterId);
    map['offset_minutes'] = Variable<int>(offsetMinutes);
    return map;
  }

  CounterAlertsCompanion toCompanion(bool nullToAbsent) {
    return CounterAlertsCompanion(
      id: Value(id),
      counterId: Value(counterId),
      offsetMinutes: Value(offsetMinutes),
    );
  }

  factory CounterAlertRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CounterAlertRow(
      id: serializer.fromJson<int>(json['id']),
      counterId: serializer.fromJson<int>(json['counterId']),
      offsetMinutes: serializer.fromJson<int>(json['offsetMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'counterId': serializer.toJson<int>(counterId),
      'offsetMinutes': serializer.toJson<int>(offsetMinutes),
    };
  }

  CounterAlertRow copyWith({int? id, int? counterId, int? offsetMinutes}) =>
      CounterAlertRow(
        id: id ?? this.id,
        counterId: counterId ?? this.counterId,
        offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      );
  CounterAlertRow copyWithCompanion(CounterAlertsCompanion data) {
    return CounterAlertRow(
      id: data.id.present ? data.id.value : this.id,
      counterId: data.counterId.present ? data.counterId.value : this.counterId,
      offsetMinutes: data.offsetMinutes.present
          ? data.offsetMinutes.value
          : this.offsetMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CounterAlertRow(')
          ..write('id: $id, ')
          ..write('counterId: $counterId, ')
          ..write('offsetMinutes: $offsetMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, counterId, offsetMinutes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CounterAlertRow &&
          other.id == this.id &&
          other.counterId == this.counterId &&
          other.offsetMinutes == this.offsetMinutes);
}

class CounterAlertsCompanion extends UpdateCompanion<CounterAlertRow> {
  final Value<int> id;
  final Value<int> counterId;
  final Value<int> offsetMinutes;
  const CounterAlertsCompanion({
    this.id = const Value.absent(),
    this.counterId = const Value.absent(),
    this.offsetMinutes = const Value.absent(),
  });
  CounterAlertsCompanion.insert({
    this.id = const Value.absent(),
    required int counterId,
    required int offsetMinutes,
  }) : counterId = Value(counterId),
       offsetMinutes = Value(offsetMinutes);
  static Insertable<CounterAlertRow> custom({
    Expression<int>? id,
    Expression<int>? counterId,
    Expression<int>? offsetMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (counterId != null) 'counter_id': counterId,
      if (offsetMinutes != null) 'offset_minutes': offsetMinutes,
    });
  }

  CounterAlertsCompanion copyWith({
    Value<int>? id,
    Value<int>? counterId,
    Value<int>? offsetMinutes,
  }) {
    return CounterAlertsCompanion(
      id: id ?? this.id,
      counterId: counterId ?? this.counterId,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (counterId.present) {
      map['counter_id'] = Variable<int>(counterId.value);
    }
    if (offsetMinutes.present) {
      map['offset_minutes'] = Variable<int>(offsetMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CounterAlertsCompanion(')
          ..write('id: $id, ')
          ..write('counterId: $counterId, ')
          ..write('offsetMinutes: $offsetMinutes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CountersTable counters = $CountersTable(this);
  late final $CounterHistoryTable counterHistory = $CounterHistoryTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $CounterAlertsTable counterAlerts = $CounterAlertsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    counters,
    counterHistory,
    categories,
    counterAlerts,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'counters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('counter_history', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'counters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('counter_alerts', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CountersTableCreateCompanionBuilder =
    CountersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      required DateTime eventDate,
      Value<String?> category,
      Value<String?> recurrence,
      Value<int?> alertOffset,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
    });
typedef $$CountersTableUpdateCompanionBuilder =
    CountersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<DateTime> eventDate,
      Value<String?> category,
      Value<String?> recurrence,
      Value<int?> alertOffset,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });

final class $$CountersTableReferences
    extends BaseReferences<_$AppDatabase, $CountersTable, CounterRow> {
  $$CountersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CounterHistoryTable, List<CounterHistoryRow>>
  _counterHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.counterHistory,
    aliasName: $_aliasNameGenerator(
      db.counters.id,
      db.counterHistory.counterId,
    ),
  );

  $$CounterHistoryTableProcessedTableManager get counterHistoryRefs {
    final manager = $$CounterHistoryTableTableManager(
      $_db,
      $_db.counterHistory,
    ).filter((f) => f.counterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_counterHistoryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CounterAlertsTable, List<CounterAlertRow>>
  _counterAlertsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.counterAlerts,
    aliasName: $_aliasNameGenerator(db.counters.id, db.counterAlerts.counterId),
  );

  $$CounterAlertsTableProcessedTableManager get counterAlertsRefs {
    final manager = $$CounterAlertsTableTableManager(
      $_db,
      $_db.counterAlerts,
    ).filter((f) => f.counterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_counterAlertsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CountersTableFilterComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get alertOffset => $composableBuilder(
    column: $table.alertOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> counterHistoryRefs(
    Expression<bool> Function($$CounterHistoryTableFilterComposer f) f,
  ) {
    final $$CounterHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.counterHistory,
      getReferencedColumn: (t) => t.counterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CounterHistoryTableFilterComposer(
            $db: $db,
            $table: $db.counterHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> counterAlertsRefs(
    Expression<bool> Function($$CounterAlertsTableFilterComposer f) f,
  ) {
    final $$CounterAlertsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.counterAlerts,
      getReferencedColumn: (t) => t.counterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CounterAlertsTableFilterComposer(
            $db: $db,
            $table: $db.counterAlerts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CountersTableOrderingComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get alertOffset => $composableBuilder(
    column: $table.alertOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get alertOffset => $composableBuilder(
    column: $table.alertOffset,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> counterHistoryRefs<T extends Object>(
    Expression<T> Function($$CounterHistoryTableAnnotationComposer a) f,
  ) {
    final $$CounterHistoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.counterHistory,
      getReferencedColumn: (t) => t.counterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CounterHistoryTableAnnotationComposer(
            $db: $db,
            $table: $db.counterHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> counterAlertsRefs<T extends Object>(
    Expression<T> Function($$CounterAlertsTableAnnotationComposer a) f,
  ) {
    final $$CounterAlertsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.counterAlerts,
      getReferencedColumn: (t) => t.counterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CounterAlertsTableAnnotationComposer(
            $db: $db,
            $table: $db.counterAlerts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CountersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CountersTable,
          CounterRow,
          $$CountersTableFilterComposer,
          $$CountersTableOrderingComposer,
          $$CountersTableAnnotationComposer,
          $$CountersTableCreateCompanionBuilder,
          $$CountersTableUpdateCompanionBuilder,
          (CounterRow, $$CountersTableReferences),
          CounterRow,
          PrefetchHooks Function({
            bool counterHistoryRefs,
            bool counterAlertsRefs,
          })
        > {
  $$CountersTableTableManager(_$AppDatabase db, $CountersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CountersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> eventDate = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> recurrence = const Value.absent(),
                Value<int?> alertOffset = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => CountersCompanion(
                id: id,
                name: name,
                description: description,
                eventDate: eventDate,
                category: category,
                recurrence: recurrence,
                alertOffset: alertOffset,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                required DateTime eventDate,
                Value<String?> category = const Value.absent(),
                Value<String?> recurrence = const Value.absent(),
                Value<int?> alertOffset = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => CountersCompanion.insert(
                id: id,
                name: name,
                description: description,
                eventDate: eventDate,
                category: category,
                recurrence: recurrence,
                alertOffset: alertOffset,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CountersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({counterHistoryRefs = false, counterAlertsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (counterHistoryRefs) db.counterHistory,
                    if (counterAlertsRefs) db.counterAlerts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (counterHistoryRefs)
                        await $_getPrefetchedData<
                          CounterRow,
                          $CountersTable,
                          CounterHistoryRow
                        >(
                          currentTable: table,
                          referencedTable: $$CountersTableReferences
                              ._counterHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CountersTableReferences(
                                db,
                                table,
                                p0,
                              ).counterHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.counterId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (counterAlertsRefs)
                        await $_getPrefetchedData<
                          CounterRow,
                          $CountersTable,
                          CounterAlertRow
                        >(
                          currentTable: table,
                          referencedTable: $$CountersTableReferences
                              ._counterAlertsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CountersTableReferences(
                                db,
                                table,
                                p0,
                              ).counterAlertsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.counterId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CountersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CountersTable,
      CounterRow,
      $$CountersTableFilterComposer,
      $$CountersTableOrderingComposer,
      $$CountersTableAnnotationComposer,
      $$CountersTableCreateCompanionBuilder,
      $$CountersTableUpdateCompanionBuilder,
      (CounterRow, $$CountersTableReferences),
      CounterRow,
      PrefetchHooks Function({bool counterHistoryRefs, bool counterAlertsRefs})
    >;
typedef $$CounterHistoryTableCreateCompanionBuilder =
    CounterHistoryCompanion Function({
      Value<int> id,
      required int counterId,
      required String snapshot,
      required String operation,
      required DateTime timestamp,
    });
typedef $$CounterHistoryTableUpdateCompanionBuilder =
    CounterHistoryCompanion Function({
      Value<int> id,
      Value<int> counterId,
      Value<String> snapshot,
      Value<String> operation,
      Value<DateTime> timestamp,
    });

final class $$CounterHistoryTableReferences
    extends
        BaseReferences<_$AppDatabase, $CounterHistoryTable, CounterHistoryRow> {
  $$CounterHistoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CountersTable _counterIdTable(_$AppDatabase db) =>
      db.counters.createAlias(
        $_aliasNameGenerator(db.counterHistory.counterId, db.counters.id),
      );

  $$CountersTableProcessedTableManager get counterId {
    final $_column = $_itemColumn<int>('counter_id')!;

    final manager = $$CountersTableTableManager(
      $_db,
      $_db.counters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_counterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CounterHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $CounterHistoryTable> {
  $$CounterHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshot => $composableBuilder(
    column: $table.snapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  $$CountersTableFilterComposer get counterId {
    final $$CountersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.counterId,
      referencedTable: $db.counters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CountersTableFilterComposer(
            $db: $db,
            $table: $db.counters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CounterHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $CounterHistoryTable> {
  $$CounterHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshot => $composableBuilder(
    column: $table.snapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  $$CountersTableOrderingComposer get counterId {
    final $$CountersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.counterId,
      referencedTable: $db.counters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CountersTableOrderingComposer(
            $db: $db,
            $table: $db.counters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CounterHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $CounterHistoryTable> {
  $$CounterHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get snapshot =>
      $composableBuilder(column: $table.snapshot, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$CountersTableAnnotationComposer get counterId {
    final $$CountersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.counterId,
      referencedTable: $db.counters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CountersTableAnnotationComposer(
            $db: $db,
            $table: $db.counters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CounterHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CounterHistoryTable,
          CounterHistoryRow,
          $$CounterHistoryTableFilterComposer,
          $$CounterHistoryTableOrderingComposer,
          $$CounterHistoryTableAnnotationComposer,
          $$CounterHistoryTableCreateCompanionBuilder,
          $$CounterHistoryTableUpdateCompanionBuilder,
          (CounterHistoryRow, $$CounterHistoryTableReferences),
          CounterHistoryRow,
          PrefetchHooks Function({bool counterId})
        > {
  $$CounterHistoryTableTableManager(
    _$AppDatabase db,
    $CounterHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CounterHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CounterHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CounterHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> counterId = const Value.absent(),
                Value<String> snapshot = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => CounterHistoryCompanion(
                id: id,
                counterId: counterId,
                snapshot: snapshot,
                operation: operation,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int counterId,
                required String snapshot,
                required String operation,
                required DateTime timestamp,
              }) => CounterHistoryCompanion.insert(
                id: id,
                counterId: counterId,
                snapshot: snapshot,
                operation: operation,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CounterHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({counterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (counterId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.counterId,
                                referencedTable: $$CounterHistoryTableReferences
                                    ._counterIdTable(db),
                                referencedColumn:
                                    $$CounterHistoryTableReferences
                                        ._counterIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CounterHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CounterHistoryTable,
      CounterHistoryRow,
      $$CounterHistoryTableFilterComposer,
      $$CounterHistoryTableOrderingComposer,
      $$CounterHistoryTableAnnotationComposer,
      $$CounterHistoryTableCreateCompanionBuilder,
      $$CounterHistoryTableUpdateCompanionBuilder,
      (CounterHistoryRow, $$CounterHistoryTableReferences),
      CounterHistoryRow,
      PrefetchHooks Function({bool counterId})
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      required String normalized,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> normalized,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalized => $composableBuilder(
    column: $table.normalized,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalized => $composableBuilder(
    column: $table.normalized,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalized => $composableBuilder(
    column: $table.normalized,
    builder: (column) => column,
  );
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            CategoryRow,
            BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
          ),
          CategoryRow,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalized = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                normalized: normalized,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String normalized,
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                normalized: normalized,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        CategoryRow,
        BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
      ),
      CategoryRow,
      PrefetchHooks Function()
    >;
typedef $$CounterAlertsTableCreateCompanionBuilder =
    CounterAlertsCompanion Function({
      Value<int> id,
      required int counterId,
      required int offsetMinutes,
    });
typedef $$CounterAlertsTableUpdateCompanionBuilder =
    CounterAlertsCompanion Function({
      Value<int> id,
      Value<int> counterId,
      Value<int> offsetMinutes,
    });

final class $$CounterAlertsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CounterAlertsTable, CounterAlertRow> {
  $$CounterAlertsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CountersTable _counterIdTable(_$AppDatabase db) =>
      db.counters.createAlias(
        $_aliasNameGenerator(db.counterAlerts.counterId, db.counters.id),
      );

  $$CountersTableProcessedTableManager get counterId {
    final $_column = $_itemColumn<int>('counter_id')!;

    final manager = $$CountersTableTableManager(
      $_db,
      $_db.counters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_counterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CounterAlertsTableFilterComposer
    extends Composer<_$AppDatabase, $CounterAlertsTable> {
  $$CounterAlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get offsetMinutes => $composableBuilder(
    column: $table.offsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  $$CountersTableFilterComposer get counterId {
    final $$CountersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.counterId,
      referencedTable: $db.counters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CountersTableFilterComposer(
            $db: $db,
            $table: $db.counters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CounterAlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $CounterAlertsTable> {
  $$CounterAlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get offsetMinutes => $composableBuilder(
    column: $table.offsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  $$CountersTableOrderingComposer get counterId {
    final $$CountersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.counterId,
      referencedTable: $db.counters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CountersTableOrderingComposer(
            $db: $db,
            $table: $db.counters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CounterAlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CounterAlertsTable> {
  $$CounterAlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get offsetMinutes => $composableBuilder(
    column: $table.offsetMinutes,
    builder: (column) => column,
  );

  $$CountersTableAnnotationComposer get counterId {
    final $$CountersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.counterId,
      referencedTable: $db.counters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CountersTableAnnotationComposer(
            $db: $db,
            $table: $db.counters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CounterAlertsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CounterAlertsTable,
          CounterAlertRow,
          $$CounterAlertsTableFilterComposer,
          $$CounterAlertsTableOrderingComposer,
          $$CounterAlertsTableAnnotationComposer,
          $$CounterAlertsTableCreateCompanionBuilder,
          $$CounterAlertsTableUpdateCompanionBuilder,
          (CounterAlertRow, $$CounterAlertsTableReferences),
          CounterAlertRow,
          PrefetchHooks Function({bool counterId})
        > {
  $$CounterAlertsTableTableManager(_$AppDatabase db, $CounterAlertsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CounterAlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CounterAlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CounterAlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> counterId = const Value.absent(),
                Value<int> offsetMinutes = const Value.absent(),
              }) => CounterAlertsCompanion(
                id: id,
                counterId: counterId,
                offsetMinutes: offsetMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int counterId,
                required int offsetMinutes,
              }) => CounterAlertsCompanion.insert(
                id: id,
                counterId: counterId,
                offsetMinutes: offsetMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CounterAlertsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({counterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (counterId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.counterId,
                                referencedTable: $$CounterAlertsTableReferences
                                    ._counterIdTable(db),
                                referencedColumn: $$CounterAlertsTableReferences
                                    ._counterIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CounterAlertsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CounterAlertsTable,
      CounterAlertRow,
      $$CounterAlertsTableFilterComposer,
      $$CounterAlertsTableOrderingComposer,
      $$CounterAlertsTableAnnotationComposer,
      $$CounterAlertsTableCreateCompanionBuilder,
      $$CounterAlertsTableUpdateCompanionBuilder,
      (CounterAlertRow, $$CounterAlertsTableReferences),
      CounterAlertRow,
      PrefetchHooks Function({bool counterId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CountersTableTableManager get counters =>
      $$CountersTableTableManager(_db, _db.counters);
  $$CounterHistoryTableTableManager get counterHistory =>
      $$CounterHistoryTableTableManager(_db, _db.counterHistory);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$CounterAlertsTableTableManager get counterAlerts =>
      $$CounterAlertsTableTableManager(_db, _db.counterAlerts);
}
