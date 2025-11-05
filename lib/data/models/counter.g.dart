// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CounterImpl _$$CounterImplFromJson(Map<String, dynamic> json) =>
    _$CounterImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      eventDate: DateTime.parse(json['eventDate'] as String),
      category: json['category'] as String?,
      recurrence: json['recurrence'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CounterImplToJson(_$CounterImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'eventDate': instance.eventDate.toIso8601String(),
      'category': instance.category,
      'recurrence': instance.recurrence,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
