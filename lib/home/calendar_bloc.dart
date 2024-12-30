import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../profile/profile_bloc.dart';
import '../profile/profile_event.dart';
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

      final calendarCollection =
          _firestore.collection('users').doc(user.uid).collection('calendar');

      final normalizedDate = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );

      final querySnapshot = await calendarCollection.get();

      DocumentReference? docToUpdate;
      List<ContentSuggestion> updatedSuggestionsList = [];

      for (var doc in querySnapshot.docs) {
        final date = (doc.data()['date'] as Timestamp).toDate();
        final normalizedDocDate = DateTime(date.year, date.month, date.day);

        if (normalizedDocDate == normalizedDate) {
          docToUpdate = doc.reference;
          updatedSuggestionsList = (doc.data()['suggestions'] as List)
              .map((s) => ContentSuggestion.fromJson(s))
              .toList();
          updatedSuggestionsList.add(event.suggestion);
          break;
        }
      }

      if (docToUpdate != null) {
        await docToUpdate.set({
          'date': Timestamp.fromDate(normalizedDate),
          'suggestions': updatedSuggestionsList.map((s) => s.toJson()).toList(),
        });

        final updatedSuggestions =
            Map<DateTime, List<ContentSuggestion>>.from(state.suggestions);
        updatedSuggestions[normalizedDate] = updatedSuggestionsList;

        emit(state.copyWith(
          suggestions: updatedSuggestions,
          status: CalendarStatus.success,
        ));
      } else {
        await calendarCollection.doc(normalizedDate.toIso8601String()).set({
          'date': Timestamp.fromDate(normalizedDate),
          'suggestions': [event.suggestion.toJson()],
        });

        final updatedSuggestions =
            Map<DateTime, List<ContentSuggestion>>.from(state.suggestions);
        updatedSuggestions[normalizedDate] = [event.suggestion];

        emit(state.copyWith(
          suggestions: updatedSuggestions,
          status: CalendarStatus.success,
        ));
      }
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

      final calendarCollection =
          _firestore.collection('users').doc(user.uid).collection('calendar');

      final querySnapshot = await calendarCollection.get();

      List<ContentSuggestion> updatedSuggestionsList = [];
      DocumentReference? docToUpdate;

      for (var doc in querySnapshot.docs) {
        // Delete any document containing this suggestion
        final suggestions = (doc.data()['suggestions'] as List);
        bool foundMatch = false;
        for (var suggestion in suggestions) {
          if (suggestion['platform'] == event.oldSuggestion.platform &&
              suggestion['description'] == event.oldSuggestion.description) {
            foundMatch = true;
            docToUpdate = doc.reference;
            updatedSuggestionsList = suggestions
                .where((s) =>
                    s['platform'] != event.oldSuggestion.platform ||
                    s['description'] != event.oldSuggestion.description)
                .map((s) => ContentSuggestion.fromJson(s))
                .toList();
          }
        }
        if (foundMatch) break;
      }

      updatedSuggestionsList.add(event.newSuggestion);

      if (docToUpdate != null) {
        final normalizedDate = DateTime(
          event.date.year,
          event.date.month,
          event.date.day,
        );

        await docToUpdate.set({
          'date': Timestamp.fromDate(normalizedDate),
          'suggestions': updatedSuggestionsList.map((s) => s.toJson()).toList(),
        });

        final updatedSuggestions =
            Map<DateTime, List<ContentSuggestion>>.from(state.suggestions);
        updatedSuggestions[normalizedDate] = updatedSuggestionsList;

        emit(state.copyWith(
          suggestions: updatedSuggestions,
          status: CalendarStatus.success,
        ));
      }
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

      final calendarCollection =
          _firestore.collection('users').doc(user.uid).collection('calendar');

      final querySnapshot = await calendarCollection.get();

      List<ContentSuggestion> updatedSuggestionsList = [];
      DocumentReference? docToUpdate;

      for (var doc in querySnapshot.docs) {
        // Delete any document containing this suggestion
        final suggestions = (doc.data()['suggestions'] as List);
        bool foundMatch = false;
        for (var suggestion in suggestions) {
          if (suggestion['platform'] == event.suggestion.platform &&
              suggestion['description'] == event.suggestion.description) {
            foundMatch = true;
            docToUpdate = doc.reference;
            updatedSuggestionsList = suggestions
                .where((s) =>
                    s['platform'] != event.suggestion.platform ||
                    s['description'] != event.suggestion.description)
                .map((s) => ContentSuggestion.fromJson(s))
                .toList();
          }
        }
        if (foundMatch) break;
      }

      if (docToUpdate != null) {
        final normalizedDate = DateTime(
          event.date.year,
          event.date.month,
          event.date.day,
        );

        await docToUpdate.set({
          'date': Timestamp.fromDate(normalizedDate),
          'suggestions': updatedSuggestionsList.map((s) => s.toJson()).toList(),
        });

        final updatedSuggestions =
            Map<DateTime, List<ContentSuggestion>>.from(state.suggestions);
        updatedSuggestions[normalizedDate] = updatedSuggestionsList;

        emit(state.copyWith(
          suggestions: updatedSuggestions,
          status: CalendarStatus.success,
        ));
      }
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
    - Unique Selling Proposition: ${profile.uniqueSellingProposition}
    - Target Audience: ${profile.targetAudience.join(', ')}
    - Primary Goals: ${profile.contentGoals.join(', ')}
    - Platforms: ${profile.targetPlatforms.join(', ')}
    - Content Types: ${profile.contentTypes.join(', ')}
    
    For each platform (${profile.targetPlatforms.join(', ')}), generate content suggestions that:
    1. Match the specified content types: ${profile.contentTypes.join(', ')}
    2. Align with the brand personality: ${profile.brandPersonality} and unique selling proposition: ${profile.uniqueSellingProposition}
    3. Target the specified audience: ${profile.targetAudience.join(', ')}
    
    Ensure each suggestion includes:
    - The platform (must specify one of ${profile.targetPlatforms.join(', ')})
    - The day number (1-7)
    - Content type
    - Brief but specific description

    Platform-specific posting guidelines:
    - Facebook: 1 post/day, optimal times 9-11 AM or 1-3 PM weekdays, focus on Thursdays/Fridays
    - Instagram: 1-2 posts/day, optimal at 11 AM-1 PM or 7-9 PM weekdays, prioritize Wednesdays
    - X: 2-5 posts/day, best at 10-11 AM or 6-7 PM weekdays, focus on Wed/Thu
    - LinkedIn: 3-5 posts/week, optimal 10-11 AM or 12-1 PM Tue/Wed/Thu, prioritize Tuesdays
    - TikTok: 1-4 posts/day, best 8-11 PM, prioritize weekend evenings

    Please provide content suggestions for the next 7 days in this format:
    Platform: [platform name]
    Day [number]: [content type]: [description]

    Create an engaging mix of content types and times that maintains consistent brand presence while respecting platform-specific best practices.
    Don't use hashtags
    Always ensure you specify the platform name and day number for each suggestion.
    
    ''';

      final content = [Content.text(prompt)];
      final response = await _generativeModel.generateContent(content);
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
      // load profile
      _profileBloc.add(LoadProfile());
    } catch (e) {
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
    final random = Random(); // Initialize random

    // Define platform-specific posting times
    final Map<String, List<TimeOfDay>> postingTimes = {
      'facebook': [
        TimeOfDay(hour: 9, minute: 0),
        TimeOfDay(hour: 11, minute: 0),
        TimeOfDay(hour: 13, minute: 0),
        TimeOfDay(hour: 15, minute: 0),
      ],
      'instagram': [
        TimeOfDay(hour: 11, minute: 0),
        TimeOfDay(hour: 13, minute: 0),
        TimeOfDay(hour: 19, minute: 0),
        TimeOfDay(hour: 21, minute: 0),
      ],
      'x': [
        TimeOfDay(hour: 10, minute: 0),
        TimeOfDay(hour: 11, minute: 0),
        TimeOfDay(hour: 18, minute: 0),
        TimeOfDay(hour: 19, minute: 0),
      ],
      'linkedin': [
        TimeOfDay(hour: 10, minute: 0),
        TimeOfDay(hour: 11, minute: 0),
        TimeOfDay(hour: 12, minute: 0),
        TimeOfDay(hour: 13, minute: 0),
      ],
      'tiktok': [
        TimeOfDay(hour: 20, minute: 0),
        TimeOfDay(hour: 21, minute: 0),
        TimeOfDay(hour: 22, minute: 0),
        TimeOfDay(hour: 23, minute: 0),
      ],
    };

    // Split response into lines and clean up
    final lines = responseText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // Add this line for debugging

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
        // Add this line for debugging
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
            final platformKey = currentPlatform.toLowerCase();
            final times = postingTimes[platformKey] ??
                [
                  TimeOfDay(hour: 9, minute: 0),
                  TimeOfDay(hour: 17, minute: 0),
                ];
            final randomTime = times[random.nextInt(times.length)];

            final suggestion = ContentSuggestion(
              platform: currentPlatform,
              contentType: currentContentType,
              description: currentDescription,
              scheduledTime: DateTime(
                date.year,
                date.month,
                date.day,
                randomTime.hour,
                randomTime.minute,
              ),
              status: 'draft',
            );

            if (!suggestions.containsKey(date)) {
              suggestions[date] = [];
            }
            suggestions[date]!.add(suggestion);
            // Add this line for debugging
          }
        }
      }
    }

    if (suggestions.isEmpty) {}

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
