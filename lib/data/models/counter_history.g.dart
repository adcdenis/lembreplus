// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CounterHistoryImpl _$$CounterHistoryImplFromJson(Map<String, dynamic> json) =>
    _$CounterHistoryImpl(
      id: (json['id'] as num?)?.toInt(),
      counterId: (json['counterId'] as num).toInt(),
      snapshot: json['snapshot'] as String,
      operation: json['operation'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$CounterHistoryImplToJson(
  _$CounterHistoryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'counterId': instance.counterId,
  'snapshot': instance.snapshot,
  'operation': instance.operation,
  'timestamp': instance.timestamp.toIso8601String(),
};
