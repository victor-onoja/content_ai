import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../profile/profile_bloc.dart';
import '../profile/profile_event.dart';
import 'calendar_bloc.dart';
import 'calendar_event.dart';
import 'home_screen.dart';

class ContentSuggestionCard extends StatefulWidget {
  final ContentSuggestion suggestion;
  final VoidCallback onDelete;
  final DateTime selectedDate;

  const ContentSuggestionCard({
    super.key,
    required this.suggestion,
    required this.onDelete,
    required this.selectedDate,
  });

  @override
  State<ContentSuggestionCard> createState() => _ContentSuggestionCardState();
}

class _ContentSuggestionCardState extends State<ContentSuggestionCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(_getPlatformIconAsset()),
          radius: 10,
        ),
        title: Text(
          widget.suggestion.platform,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: GestureDetector(
          onTap: widget.suggestion.status.toLowerCase() == 'draft'
              ? () => _showTimePicker(context)
              : null,
          child: Text(
            DateFormat('h:mm a').format(widget.suggestion.scheduledTime),
            style: TextStyle(
              color: Colors.grey.shade600,
              decoration: widget.suggestion.status.toLowerCase() == 'draft'
                  ? TextDecoration.underline
                  : null,
            ),
          ),
        ),
        trailing: GestureDetector(
            onTap: () => _cycleStatus(context), child: _buildStatusChip()),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getContentTypeIcon(),
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.suggestion.contentType,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(widget.suggestion.description),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _showNotesDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Notes',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.suggestion.notes?.isNotEmpty == true
                              ? widget.suggestion.notes!
                              : 'Tap to add notes or draft your post...',
                          style: TextStyle(
                            color: widget.suggestion.notes?.isNotEmpty == true
                                ? Colors.black87
                                : Colors.grey.shade500,
                            fontStyle:
                                widget.suggestion.notes?.isNotEmpty == true
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade400,
                      ),
                      onPressed: () => _confirmDelete(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
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
                    DeleteContent(widget.suggestion, widget.selectedDate),
                  );

              context.read<ProfileBloc>().add(LoadProfile());
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

  Future<void> _showTimePicker(BuildContext context) async {
    if (widget.suggestion.status.toLowerCase() != 'draft') return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.suggestion.scheduledTime),
    );

    if (time != null) {
      final newScheduledTime = DateTime(
        widget.suggestion.scheduledTime.year,
        widget.suggestion.scheduledTime.month,
        widget.suggestion.scheduledTime.day,
        time.hour,
        time.minute,
      );

      final newSuggestion = ContentSuggestion(
        platform: widget.suggestion.platform,
        contentType: widget.suggestion.contentType,
        description: widget.suggestion.description,
        scheduledTime: newScheduledTime,
        status: widget.suggestion.status,
        notes: widget.suggestion.notes,
      );

      final normalizedDate = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
      );

      context.read<CalendarBloc>().add(
            UpdateContent(widget.suggestion, newSuggestion, normalizedDate),
          );

      context.read<ProfileBloc>().add(LoadProfile());
    }
  }

  void _cycleStatus(BuildContext context) {
    const statusCycle = ['draft', 'scheduled', 'published'];
    final currentIndex =
        statusCycle.indexOf(widget.suggestion.status.toLowerCase());
    final nextStatus = statusCycle[(currentIndex + 1) % statusCycle.length];

    final newSuggestion = ContentSuggestion(
      platform: widget.suggestion.platform,
      contentType: widget.suggestion.contentType,
      description: widget.suggestion.description,
      scheduledTime: widget.suggestion.scheduledTime,
      status: nextStatus,
      notes: widget.suggestion.notes,
    );

    context.read<CalendarBloc>().add(
          UpdateContent(widget.suggestion, newSuggestion, widget.selectedDate),
        );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (widget.suggestion.status.toLowerCase()) {
      case 'draft':
        backgroundColor = Colors.grey.shade400;
        break;
      case 'scheduled':
        backgroundColor = Colors.blue.shade400;
        break;
      case 'published':
        backgroundColor = Colors.green.shade400;
        break;
      default:
        backgroundColor = Colors.grey.shade400;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.suggestion.status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getPlatformIconAsset() {
    switch (widget.suggestion.platform.toLowerCase()) {
      case 'instagram':
        return 'assets/icons/ig_icon.webp';
      case 'x':
        return 'assets/icons/x_icon.jpeg';
      case 'linkedin':
        return 'assets/icons/linkedin_icon.png';
      case 'facebook':
        return 'assets/icons/fb_icon.jpeg';
      case 'tiktok':
        return 'assets/icons/tiktok_icon.png';
      default:
        return 'assets/images/coco.png';
    }
  }

  IconData _getContentTypeIcon() {
    switch (widget.suggestion.contentType.toLowerCase()) {
      case 'images':
        return Icons.image;
      case 'videos':
        return Icons.videocam;
      case 'stories':
        return Icons.amp_stories;
      case 'text posts':
        return Icons.text_fields;
      case 'polls':
        return Icons.poll;
      case 'live streams':
        return Icons.live_tv;
      default:
        return Icons.post_add;
    }
  }

  Future<void> _showNotesDialog(BuildContext context) async {
    final TextEditingController notesController = TextEditingController(
      text: widget.suggestion.notes ?? '',
    );

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for keyboard handling
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.only(
          top: 16,
          left: 24,
          right: 24,
          // Add padding for keyboard
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bottom Sheet Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Content Notes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                // Platform icon
                CircleAvatar(
                  backgroundImage: AssetImage(_getPlatformIconAsset()),
                  radius: 12,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Content preview
            Text(
              widget.suggestion.description,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: notesController,
                maxLines: null, // Allow unlimited lines
                expands: true, // Take up all available space
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Add notes or start drafting your post...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    final newSuggestion = ContentSuggestion(
                      platform: widget.suggestion.platform,
                      contentType: widget.suggestion.contentType,
                      description: widget.suggestion.description,
                      scheduledTime: widget.suggestion.scheduledTime,
                      status: widget.suggestion.status,
                      notes: notesController.text,
                    );

                    context.read<CalendarBloc>().add(
                          UpdateContent(
                            widget.suggestion,
                            newSuggestion,
                            widget.selectedDate,
                          ),
                        );

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddContentDialog extends StatefulWidget {
  final Function(ContentSuggestion) onSave;
  final ContentSuggestion? initialSuggestion;

  const AddContentDialog({
    super.key,
    required this.onSave,
    this.initialSuggestion,
  });

  @override
  _AddContentDialogState createState() => _AddContentDialogState();
}

class _AddContentDialogState extends State<AddContentDialog> {
  late TextEditingController _descriptionController;
  late DateTime _scheduledTime;
  late String _platform;
  late String _contentType;
  late String _status;

  final List<String> _platforms = [
    'Instagram',
    'X',
    'LinkedIn',
    'Facebook',
    'TikTok',
  ];

  final List<String> _contentTypes = [
    'Images',
    'Videos',
    'Stories',
    'Text Posts',
    'Polls',
    'Live Streams',
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.initialSuggestion?.description ?? '',
    );
    _scheduledTime = widget.initialSuggestion?.scheduledTime ?? DateTime.now();
    _platform = widget.initialSuggestion?.platform ?? _platforms.first;
    _contentType = widget.initialSuggestion?.contentType ?? _contentTypes.first;
    _status = widget.initialSuggestion?.status ?? 'draft';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.initialSuggestion == null
                    ? 'Add New Content'
                    : 'Edit Content',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              _buildDropdown(
                'Platform',
                _platform,
                _platforms,
                (value) => setState(() => _platform = value!),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                'Content Type',
                _contentType,
                _contentTypes,
                (value) => setState(() => _contentType = value!),
              ),
              const SizedBox(height: 16),
              _buildTimePicker(),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Content Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatusSelector(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveContent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: () async {
        final TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_scheduledTime),
        );
        if (time != null) {
          setState(() {
            _scheduledTime = DateTime(
              _scheduledTime.year,
              _scheduledTime.month,
              _scheduledTime.day,
              time.hour,
              time.minute,
            );
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Scheduled Time',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        child: Text(
          DateFormat('h:mm a').format(_scheduledTime),
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Status'),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'draft', label: Text('Draft')),
            ButtonSegment(value: 'scheduled', label: Text('Scheduled')),
            ButtonSegment(value: 'published', label: Text('Published')),
          ],
          selected: {_status},
          onSelectionChanged: (Set<String> selection) {
            setState(() => _status = selection.first);
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.orange.shade400;
                }
                return Colors.transparent;
              },
            ),
          ),
        ),
      ],
    );
  }

  void _saveContent() {
    final suggestion = ContentSuggestion(
      platform: _platform,
      contentType: _contentType,
      description: _descriptionController.text,
      scheduledTime: _scheduledTime,
      status: _status,
    );
    widget.onSave(suggestion);
    Navigator.pop(context);
  }
}
