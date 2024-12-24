import 'package:equatable/equatable.dart';

import 'home_screen.dart';

abstract class CalendarEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCalendar extends CalendarEvent {}

class AddContent extends CalendarEvent {
  final ContentSuggestion suggestion;
  final DateTime date;

  AddContent(this.suggestion, this.date);

  @override
  List<Object?> get props => [suggestion, date];
}

class UpdateContent extends CalendarEvent {
  final ContentSuggestion oldSuggestion;
  final ContentSuggestion newSuggestion;
  final DateTime date;

  UpdateContent(this.oldSuggestion, this.newSuggestion, this.date);

  @override
  List<Object?> get props => [oldSuggestion, newSuggestion, date];
}

class DeleteContent extends CalendarEvent {
  final ContentSuggestion suggestion;
  final DateTime date;

  DeleteContent(this.suggestion, this.date);

  @override
  List<Object?> get props => [suggestion, date];
}

class RegenerateContentSuggestions extends CalendarEvent {
  final DateTime startDate;
  final DateTime endDate;

  RegenerateContentSuggestions(this.startDate, this.endDate);

  @override
  List<Object?> get props => [startDate, endDate];
}
