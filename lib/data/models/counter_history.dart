import 'package:freezed_annotation/freezed_annotation.dart';

part 'counter_history.freezed.dart';
part 'counter_history.g.dart';

@freezed
class CounterHistory with _$CounterHistory {
  const factory CounterHistory({
    int? id,
    required int counterId,
    required String snapshot,
    required String operation,
    required DateTime timestamp,
  }) = _CounterHistory;

  factory CounterHistory.fromJson(Map<String, dynamic> json) => _$CounterHistoryFromJson(json);
}