import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'home_screen.dart';

class ContentSuggestionCard extends StatelessWidget {
  final ContentSuggestion suggestion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ContentSuggestionCard({
    super.key,
    required this.suggestion,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(_getPlatformIcon()),
        title: Text(
          suggestion.platform,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          DateFormat('h:mm a').format(suggestion.scheduledTime),
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: _buildStatusChip(),
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
                      suggestion.contentType,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(suggestion.description),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: onEdit,
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade400,
                      ),
                      onPressed: onDelete,
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

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (suggestion.status.toLowerCase()) {
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
        suggestion.status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getPlatformIcon() {
    switch (suggestion.platform.toLowerCase()) {
      case 'instagram':
        return Icons.camera_alt;
      case 'x':
        return Icons.short_text;
      case 'linkedin':
        return Icons.business;
      case 'facebook':
        return Icons.facebook;
      case 'tiktok':
        return Icons.music_video;
      case 'youtube':
        return Icons.play_circle;
      default:
        return Icons.public;
    }
  }

  IconData _getContentTypeIcon() {
    switch (suggestion.contentType.toLowerCase()) {
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
    'YouTube',
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
