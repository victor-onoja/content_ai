import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../auth/auth_bloc.dart';
import '../profile/profile_event.dart';
import '../splash_screen.dart';
import 'calendar_bloc.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';
import 'home_widgets.dart';
import '../profile/profile_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CalendarBloc, CalendarState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == CalendarStatus.failure,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'An error occurred'),
                backgroundColor: Colors.red.shade400,
              ),
            );
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == AuthStatus.unauthenticated,
          listener: (context, state) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const SplashScreen(),
              ),
            );
          },
        ),
      ],
      child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.yellow.shade100,
                  Colors.orange.shade50,
                ],
              ),
            ),
            child: SafeArea(
              child: BlocBuilder<CalendarBloc, CalendarState>(
                builder: (context, state) {
                  return Stack(children: [
                    Column(
                      children: [
                        _buildHeader(),
                        _buildCalendar(state),
                        _buildSuggestionsList(state),
                      ],
                    ),
                    if (state.status == CalendarStatus.loading)
                      Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                  ]);
                },
              ),
            ),
          ),
          floatingActionButton: _selectedDay != null
              ? FloatingActionButton(
                  onPressed: () => _showAddContentDialog(context),
                  backgroundColor: Colors.orange.shade400,
                  child: const Icon(Icons.add),
                )
              : null),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Content Calendar',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.logout, color: Colors.orange.shade800),
                onPressed: () {
                  context.read<AuthBloc>().add(AuthSignOut());
                },
              ),
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(
                  'assets/images/coco-min.png',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(CalendarState state) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 90)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        eventLoader: (day) {
          return state.suggestions[DateTime(
                day.year,
                day.month,
                day.day,
              )] ??
              [];
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.orange.shade200,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.orange.shade400,
            shape: BoxShape.circle,
          ),
        ),
        onFormatChanged: (format) => setState(() {
          _calendarFormat = format;
        }),
      ),
    );
  }

  Widget _buildSuggestionsList(CalendarState state) {
    if (_selectedDay == null) {
      return const Expanded(
        child: Center(
          child: Text('Select a day to view or add content'),
        ),
      );
    }

    final suggestions = state.suggestions[DateTime(
          _selectedDay!.year,
          _selectedDay!.month,
          _selectedDay!.day,
        )] ??
        [];

    if (suggestions.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No content planned for this day',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showAddContentDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Add Content'),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ContentSuggestionCard(
            suggestion: suggestion,
            // onEdit: () => _editSuggestion(context, suggestion),
            onDelete: () => _deleteSuggestion(context, suggestion),
            selectedDate: _selectedDay!,
          );
        },
      ),
    );
  }

  void _deleteSuggestion(BuildContext context, ContentSuggestion suggestion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Content'),
        content: const Text('Are you sure you want to delete this content?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CalendarBloc>().add(
                    DeleteContent(suggestion, _selectedDay!),
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade400,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddContentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddContentDialog(
        onSave: (suggestion) {
          context.read<CalendarBloc>().add(
                AddContent(suggestion, _selectedDay!),
              );
        },
      ),
    );
  }
}

class ContentSuggestion {
  final String platform;
  final String contentType;
  final String description;
  final DateTime scheduledTime;
  final String status; // draft, scheduled, published
  final String? notes;

  ContentSuggestion({
    required this.platform,
    required this.contentType,
    required this.description,
    required this.scheduledTime,
    required this.status,
    this.notes,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentSuggestion &&
          platform == other.platform &&
          contentType == other.contentType &&
          description == other.description &&
          status == other.status &&
          notes == other.notes;

  @override
  int get hashCode =>
      platform.hashCode ^
      contentType.hashCode ^
      description.hashCode ^
      status.hashCode ^
      notes.hashCode;

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'contentType': contentType,
        'description': description,
        'scheduledTime': Timestamp.fromDate(scheduledTime),
        'status': status,
        'notes': notes,
      };

  factory ContentSuggestion.fromJson(Map<String, dynamic> json) =>
      ContentSuggestion(
        platform: json['platform'],
        contentType: json['contentType'],
        description: json['description'],
        scheduledTime: (json['scheduledTime'] as Timestamp).toDate(),
        status: json['status'],
        notes: json['notes'],
      );
}
