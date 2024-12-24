import 'package:equatable/equatable.dart';

import 'home_screen.dart';

enum CalendarStatus { initial, loading, success, failure }

class CalendarState extends Equatable {
  final CalendarStatus status;
  final Map<DateTime, List<ContentSuggestion>> suggestions;
  final String? error;
  final DateTime? selectedDate;

  const CalendarState({
    this.status = CalendarStatus.initial,
    this.suggestions = const {},
    this.error,
    this.selectedDate,
  });

  CalendarState copyWith({
    CalendarStatus? status,
    Map<DateTime, List<ContentSuggestion>>? suggestions,
    String? error,
    DateTime? selectedDate,
  }) {
    return CalendarState(
      status: status ?? this.status,
      suggestions: suggestions ?? this.suggestions,
      error: error ?? this.error,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  List<Object?> get props => [status, suggestions, error, selectedDate];
}
