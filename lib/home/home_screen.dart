import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../profile/profile_event.dart';
import '../profile/profile_state.dart';
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
  final CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
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
            print('error: ${state.error}');
          },
        ),
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) =>
              previous.profile != current.profile && current.profile != null,
          listener: (context, state) {
            // Regenerate suggestions when profile changes
            context.read<CalendarBloc>().add(
                  RegenerateContentSuggestions(
                    DateTime.now(),
                    DateTime.now().add(const Duration(days: 14)),
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
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
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
        firstDay: DateTime.now(),
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
            onEdit: () => _editSuggestion(context, suggestion),
            onDelete: () => _deleteSuggestion(context, suggestion),
          );
        },
      ),
    );
  }

  void _editSuggestion(BuildContext context, ContentSuggestion suggestion) {
    showDialog(
      context: context,
      builder: (context) => AddContentDialog(
        initialSuggestion: suggestion,
        onSave: (newSuggestion) {
          context.read<CalendarBloc>().add(
                UpdateContent(
                  suggestion,
                  newSuggestion,
                  _selectedDay!,
                ),
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

  ContentSuggestion({
    required this.platform,
    required this.contentType,
    required this.description,
    required this.scheduledTime,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'contentType': contentType,
        'description': description,
        'scheduledTime': scheduledTime,
        'status': status,
      };

  factory ContentSuggestion.fromJson(Map<String, dynamic> json) =>
      ContentSuggestion(
        platform: json['platform'],
        contentType: json['contentType'],
        description: json['description'],
        scheduledTime: (json['scheduledTime'] as Timestamp).toDate(),
        status: json['status'],
      );
}
