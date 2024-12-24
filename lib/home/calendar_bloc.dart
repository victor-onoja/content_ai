import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../profile/profile_bloc.dart';
import '../profile/profile_state.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';
import 'home_screen.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final FirebaseFirestore _firestore;
  final GenerativeModel _generativeModel;
  final ProfileBloc _profileBloc;
  StreamSubscription<ProfileState>? _profileSubscription;

  CalendarBloc(this._firestore, this._generativeModel, this._profileBloc)
      : super(const CalendarState()) {
    on<LoadCalendar>(_onLoadCalendar);
    on<AddContent>(_onAddContent);
    on<UpdateContent>(_onUpdateContent);
    on<DeleteContent>(_onDeleteContent);
    on<RegenerateContentSuggestions>(_onRegenerateContentSuggestions);

    _profileSubscription = _profileBloc.stream.listen((profileState) {
      if (profileState.status == ProfileStatus.success &&
          profileState.profile != null) {
        add(LoadCalendar());
      }
    });
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadCalendar(
    LoadCalendar event,
    Emitter<CalendarState> emit,
  ) async {
    emit(state.copyWith(status: CalendarStatus.loading));

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('calendar')
          .get();

      final suggestions = Map<DateTime, List<ContentSuggestion>>.fromEntries(
        snapshot.docs.map((doc) {
          final data = doc.data();
          final date = (data['date'] as Timestamp).toDate();
          // Normalize the date to remove time component
          final normalizedDate = DateTime(date.year, date.month, date.day);

          return MapEntry(
            normalizedDate,
            (data['suggestions'] as List)
                .map((s) => ContentSuggestion.fromJson(s))
                .toList(),
          );
        }),
      );

      if (snapshot.docs.isEmpty && _profileBloc.state.profile != null) {
        add(RegenerateContentSuggestions(
          DateTime.now(),
          DateTime.now().add(const Duration(days: 14)),
        ));
        return;
      }

      emit(state.copyWith(
        status: CalendarStatus.success,
        suggestions: suggestions,
      ));
    } catch (e) {
      print('Calendar load error: $e');
      emit(state.copyWith(
        status: CalendarStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onAddContent(
    AddContent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Update local state
      final updatedSuggestions = Map<DateTime, List<ContentSuggestion>>.from(
        state.suggestions,
      );

      if (updatedSuggestions[event.date] == null) {
        updatedSuggestions[event.date] = [];
      }
      updatedSuggestions[event.date]!.add(event.suggestion);

      // Update Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('calendar')
          .doc(event.date.toIso8601String())
          .set({
        'date': event.date,
        'suggestions':
            updatedSuggestions[event.date]!.map((s) => s.toJson()).toList(),
      });

      emit(state.copyWith(
        suggestions: updatedSuggestions,
        status: CalendarStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CalendarStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateContent(
    UpdateContent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Update local state
      final updatedSuggestions = Map<DateTime, List<ContentSuggestion>>.from(
        state.suggestions,
      );

      final daySuggestions = updatedSuggestions[event.date] ?? [];
      final index = daySuggestions.indexOf(event.oldSuggestion);

      if (index != -1) {
        daySuggestions[index] = event.newSuggestion;
      }

      // Update Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('calendar')
          .doc(event.date.toIso8601String())
          .set({
        'date': event.date,
        'suggestions': daySuggestions.map((s) => s.toJson()).toList(),
      });

      emit(state.copyWith(
        suggestions: updatedSuggestions,
        status: CalendarStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CalendarStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteContent(
    DeleteContent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Update local state
      final updatedSuggestions = Map<DateTime, List<ContentSuggestion>>.from(
        state.suggestions,
      );

      final daySuggestions = updatedSuggestions[event.date] ?? [];
      daySuggestions.remove(event.suggestion);

      // Update Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('calendar')
          .doc(event.date.toIso8601String())
          .set({
        'date': event.date,
        'suggestions': daySuggestions.map((s) => s.toJson()).toList(),
      });

      emit(state.copyWith(
        suggestions: updatedSuggestions,
        status: CalendarStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CalendarStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onRegenerateContentSuggestions(
    RegenerateContentSuggestions event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      final profile = _profileBloc.state.profile;
      if (profile == null) {
        emit(state.copyWith(
          status: CalendarStatus.failure,
          error: 'Profile not loaded',
        ));
        return;
      }

      emit(state.copyWith(status: CalendarStatus.loading));

      final prompt = '''
    Generate a detailed social media content calendar for "${profile.name}" based on this profile:
    
    Brand Details:
    - Industry: ${profile.industry}
    - Brand Personality: ${profile.brandPersonality}
    - Tone of Voice: ${profile.toneOfVoice}
    - Unique Selling Proposition: ${profile.uniqueSellingProposition}
    
    Target Audience: ${profile.targetAudience.join(', ')}
    Primary Goals: ${profile.contentGoals.join(', ')}
    
    For each platform (${profile.targetPlatforms.join(', ')}), generate content suggestions that:
    1. Match the specified content types: ${profile.contentTypes.join(', ')}
    2. Align with posting frequencies:
    ${profile.postingFrequency.entries.map((e) => '   - ${e.key}: ${e.value.postsPerWeek} posts/week').join('\n')}
    
    Please provide content suggestions for the next 14 days in this format:
    Platform: [platform name]
    Day [number]: [content type]: [description]
    
    Ensure each suggestion includes:
    - The platform
    - The day number (1-14)
    - Content type
    - Brief but specific description
    ''';

      final content = [Content.text(prompt)];
      final response = await _generativeModel.generateContent(content);
      print('Raw AI Response: ${response.text}');
      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from AI model');
      }
      final suggestions =
          _parseAIResponse(response.text ?? '', event.startDate);

      if (suggestions.isEmpty) {
        throw Exception(
            'Failed to parse any content suggestions from the AI response');
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final batch = _firestore.batch();
      final Map<DateTime, List<ContentSuggestion>> updatedSuggestions =
          Map.from(state.suggestions);

      for (final entry in suggestions.entries) {
        final date = entry.key;
        final dateSuggestions = entry.value;

        // Update local state
        updatedSuggestions[date] = dateSuggestions;

        // Add Firestore operation to batch
        batch.set(
          _firestore
              .collection('users')
              .doc(user.uid)
              .collection('calendar')
              .doc(date.toIso8601String()),
          {
            'date': date,
            'suggestions': dateSuggestions.map((s) => s.toJson()).toList(),
          },
        );
      }

      await batch.commit();

      emit(state.copyWith(
        status: CalendarStatus.success,
        suggestions: updatedSuggestions,
      ));
    } catch (e) {
      print('Error generating suggestions: $e');
      emit(state.copyWith(
        status: CalendarStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Map<DateTime, List<ContentSuggestion>> _parseAIResponse(
    String responseText,
    DateTime startDate,
  ) {
    final Map<DateTime, List<ContentSuggestion>> suggestions = {};

    // Split response into lines and clean up
    final lines = responseText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    String currentPlatform = '';
    String? currentContentType;
    String? currentDescription;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Skip headers and empty lines
      if (line.startsWith('##') || line.isEmpty) continue;

      // Check for platform line
      if (line.contains('Platform:')) {
        currentPlatform = line.split('Platform:')[1].replaceAll('*', '').trim();
        continue;
      }

      // Parse day entry
      // Match both "Day 1:" and "**Day 1:**" formats
      final dayPattern = RegExp(r'\*?Day (\d+)\*?:');
      final dayMatch = dayPattern.firstMatch(line);

      if (dayMatch != null) {
        final dayNumber = int.tryParse(dayMatch.group(1) ?? '');
        if (dayNumber != null) {
          // Extract content type and description
          final contentPart = line.substring(dayMatch.end).trim();

          // Split content into type and description
          final parts = contentPart.split(':');
          if (parts.length >= 2) {
            currentContentType = parts[0].trim().replaceAll('*', '');
            currentDescription = parts.sublist(1).join(':').trim();

            final date = startDate.add(Duration(days: dayNumber - 1));
            final suggestion = ContentSuggestion(
              platform: currentPlatform,
              contentType: currentContentType,
              description: currentDescription,
              scheduledTime: date,
              status: 'draft',
            );

            if (!suggestions.containsKey(date)) {
              suggestions[date] = [];
            }
            suggestions[date]!.add(suggestion);
            print(
                'Successfully parsed suggestion for $date: ${suggestion.toJson()}');
          }
        }
      }
    }

    if (suggestions.isEmpty) {
      print('Warning: No suggestions were parsed from the response');
      print('Response text was: $responseText');
    }

    return suggestions;
  }
}

// calendar_repository.dart
class CalendarRepository {
  final FirebaseFirestore _firestore;
  final String userId;

  CalendarRepository(this._firestore, this.userId);

  Future<Map<DateTime, List<ContentSuggestion>>> loadCalendar() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('calendar')
        .get();

    return Map.fromEntries(
      snapshot.docs.map((doc) {
        final data = doc.data();
        return MapEntry(
          (data['date'] as Timestamp).toDate(),
          (data['suggestions'] as List)
              .map((s) => ContentSuggestion.fromJson(s))
              .toList(),
        );
      }),
    );
  }

  Future<void> saveContent(
      DateTime date, List<ContentSuggestion> suggestions) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('calendar')
        .doc(date.toIso8601String())
        .set({
      'date': date,
      'suggestions': suggestions.map((s) => s.toJson()).toList(),
    });
  }
}
