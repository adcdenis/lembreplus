// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'counter_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CounterHistory _$CounterHistoryFromJson(Map<String, dynamic> json) {
  return _CounterHistory.fromJson(json);
}

/// @nodoc
mixin _$CounterHistory {
  int? get id => throw _privateConstructorUsedError;
  int get counterId => throw _privateConstructorUsedError;
  String get snapshot => throw _privateConstructorUsedError;
  String get operation => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this CounterHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CounterHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CounterHistoryCopyWith<CounterHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CounterHistoryCopyWith<$Res> {
  factory $CounterHistoryCopyWith(
    CounterHistory value,
    $Res Function(CounterHistory) then,
  ) = _$CounterHistoryCopyWithImpl<$Res, CounterHistory>;
  @useResult
  $Res call({
    int? id,
    int counterId,
    String snapshot,
    String operation,
    DateTime timestamp,
  });
}

/// @nodoc
class _$CounterHistoryCopyWithImpl<$Res, $Val extends CounterHistory>
    implements $CounterHistoryCopyWith<$Res> {
  _$CounterHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CounterHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? counterId = null,
    Object? snapshot = null,
    Object? operation = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            counterId: null == counterId
                ? _value.counterId
                : counterId // ignore: cast_nullable_to_non_nullable
                      as int,
            snapshot: null == snapshot
                ? _value.snapshot
                : snapshot // ignore: cast_nullable_to_non_nullable
                      as String,
            operation: null == operation
                ? _value.operation
                : operation // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CounterHistoryImplCopyWith<$Res>
    implements $CounterHistoryCopyWith<$Res> {
  factory _$$CounterHistoryImplCopyWith(
    _$CounterHistoryImpl value,
    $Res Function(_$CounterHistoryImpl) then,
  ) = __$$CounterHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    int counterId,
    String snapshot,
    String operation,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$CounterHistoryImplCopyWithImpl<$Res>
    extends _$CounterHistoryCopyWithImpl<$Res, _$CounterHistoryImpl>
    implements _$$CounterHistoryImplCopyWith<$Res> {
  __$$CounterHistoryImplCopyWithImpl(
    _$CounterHistoryImpl _value,
    $Res Function(_$CounterHistoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CounterHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? counterId = null,
    Object? snapshot = null,
    Object? operation = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$CounterHistoryImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        counterId: null == counterId
            ? _value.counterId
            : counterId // ignore: cast_nullable_to_non_nullable
                  as int,
        snapshot: null == snapshot
            ? _value.snapshot
            : snapshot // ignore: cast_nullable_to_non_nullable
                  as String,
        operation: null == operation
            ? _value.operation
            : operation // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CounterHistoryImpl implements _CounterHistory {
  const _$CounterHistoryImpl({
    this.id,
    required this.counterId,
    required this.snapshot,
    required this.operation,
    required this.timestamp,
  });

  factory _$CounterHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CounterHistoryImplFromJson(json);

  @override
  final int? id;
  @override
  final int counterId;
  @override
  final String snapshot;
  @override
  final String operation;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'CounterHistory(id: $id, counterId: $counterId, snapshot: $snapshot, operation: $operation, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CounterHistoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.counterId, counterId) ||
                other.counterId == counterId) &&
            (identical(other.snapshot, snapshot) ||
                other.snapshot == snapshot) &&
            (identical(other.operation, operation) ||
                other.operation == operation) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, counterId, snapshot, operation, timestamp);

  /// Create a copy of CounterHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CounterHistoryImplCopyWith<_$CounterHistoryImpl> get copyWith =>
      __$$CounterHistoryImplCopyWithImpl<_$CounterHistoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CounterHistoryImplToJson(this);
  }
}

abstract class _CounterHistory implements CounterHistory {
  const factory _CounterHistory({
    final int? id,
    required final int counterId,
    required final String snapshot,
    required final String operation,
    required final DateTime timestamp,
  }) = _$CounterHistoryImpl;

  factory _CounterHistory.fromJson(Map<String, dynamic> json) =
      _$CounterHistoryImpl.fromJson;

  @override
  int? get id;
  @override
  int get counterId;
  @override
  String get snapshot;
  @override
  String get operation;
  @override
  DateTime get timestamp;

  /// Create a copy of CounterHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CounterHistoryImplCopyWith<_$CounterHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
