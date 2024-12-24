import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../home/home_screen.dart';
import 'profile_bloc.dart';
import 'profile_event.dart';
import 'profile_model.dart';
import 'profile_state.dart';

class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  _ProfileCreationScreenState createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'targetPlatforms': <String>[],
    'contentTypes': <String>[],
    'contentGoals': <String>[],
    'postingSchedule': <String, dynamic>{},
  };

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

  final List<Map<String, String>> _contentGoals = [
    {
      'goal': 'Increase Brand Awareness',
      'description': 'Focus on reach and impressions'
    },
    {
      'goal': 'Drive Website Traffic',
      'description': 'Optimize for clicks and conversions'
    },
    {
      'goal': 'Generate Leads',
      'description': 'Encourage email sign-ups and form submissions'
    },
    {
      'goal': 'Build Community',
      'description': 'Foster engagement and grow followers'
    },
    {
      'goal': 'Boost Sales',
      'description': 'Promote products and drive direct sales'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'Failed to create profile'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state.status == ProfileStatus.success) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return Stack(children: [
              Container(
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Let's Create Your Profile! 🌟",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            'Brand/Profile Name',
                            'name',
                            'Give your profile a name',
                          ),
                          _buildTextField(
                            'Industry',
                            'industry',
                            'E.g., Technology, Fashion, Food',
                          ),
                          _buildTextField(
                            'Brand Personality',
                            'brandPersonality',
                            'E.g., Playful, Professional, Innovative',
                          ),
                          _buildMultiSelect(
                            'Target Platforms',
                            'targetPlatforms',
                            _platforms,
                          ),
                          _buildMultiSelect(
                            'Content Types',
                            'contentTypes',
                            _contentTypes,
                          ),
                          _buildTextField(
                            'Tone of Voice',
                            'toneOfVoice',
                            'E.g., Casual, Formal, Humorous',
                          ),
                          _buildTargetAudienceField(),
                          _buildPostingFrequencySection(),
                          _buildTextField(
                            'Unique Selling Proposition',
                            'uniqueSellingProposition',
                            'What makes your brand special?',
                          ),
                          _buildContentGoalsSection(),
                          const SizedBox(height: 32),
                          Center(
                            child: ElevatedButton(
                              onPressed: state.status == ProfileStatus.loading
                                  ? null
                                  : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade400,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: state.status == ProfileStatus.loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Create Profile',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (state.status == ProfileStatus.loading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String field, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.9),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Please enter $label';
          }
          return null;
        },
        onSaved: (value) {
          _formData[field] = value;
        },
      ),
    );
  }

  Widget _buildMultiSelect(String label, String field, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Wrap(
            spacing: 8,
            children: options.map((option) {
              return FilterChip(
                label: Text(option),
                selected: (_formData[field] ?? []).contains(option),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _formData[field] = [...(_formData[field] ?? []), option];
                    } else {
                      _formData[field] = (_formData[field] as List)
                          .where((item) => item != option)
                          .toList();
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostingFrequencySection() {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final timeRanges = ['Morning', 'Afternoon', 'Evening'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Posting Schedule',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 16),
          ..._formData['targetPlatforms']?.map<Widget>((platform) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          platform,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Posts per week slider
                        Row(
                          children: [
                            const Text('Posts per week:'),
                            Expanded(
                              child: Slider(
                                value: (_formData['postingSchedule']?[platform]
                                            ?['postsPerWeek'] ??
                                        3)
                                    .toDouble(),
                                min: 1,
                                max: 14,
                                divisions: 13,
                                label:
                                    '${(_formData['postingSchedule']?[platform]?['postsPerWeek'] ?? 3)}',
                                onChanged: (value) {
                                  setState(() {
                                    if (_formData['postingSchedule'] == null) {
                                      _formData['postingSchedule'] = {};
                                    }
                                    if (_formData['postingSchedule']
                                            [platform] ==
                                        null) {
                                      _formData['postingSchedule']
                                          [platform] = {};
                                    }
                                    _formData['postingSchedule'][platform]
                                        ['postsPerWeek'] = value.round();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        // Preferred days
                        const Text('Preferred days:'),
                        Wrap(
                          spacing: 8,
                          children: weekDays.map((day) {
                            return FilterChip(
                              label: Text(day),
                              selected: (_formData['postingSchedule']?[platform]
                                          ?['preferredDays'] ??
                                      [])
                                  .contains(day),
                              onSelected: (selected) {
                                setState(() {
                                  if (_formData['postingSchedule'] == null) {
                                    _formData['postingSchedule'] = {};
                                  }
                                  if (_formData['postingSchedule'][platform] ==
                                      null) {
                                    _formData['postingSchedule'][platform] = {};
                                  }
                                  if (_formData['postingSchedule'][platform]
                                          ['preferredDays'] ==
                                      null) {
                                    _formData['postingSchedule'][platform]
                                        ['preferredDays'] = [];
                                  }

                                  var days = _formData['postingSchedule']
                                      [platform]['preferredDays'] as List;
                                  if (selected) {
                                    days.add(day);
                                  } else {
                                    days.remove(day);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        // Preferred time range
                        const Text('Preferred time:'),
                        Wrap(
                          spacing: 8,
                          children: timeRanges.map((time) {
                            return ChoiceChip(
                              label: Text(time),
                              selected: (_formData['postingSchedule']?[platform]
                                          ?['preferredTimeRange'] ??
                                      '') ==
                                  time,
                              onSelected: (selected) {
                                setState(() {
                                  if (_formData['postingSchedule'] == null) {
                                    _formData['postingSchedule'] = {};
                                  }
                                  if (_formData['postingSchedule'][platform] ==
                                      null) {
                                    _formData['postingSchedule'][platform] = {};
                                  }
                                  _formData['postingSchedule'][platform]
                                          ['preferredTimeRange'] =
                                      selected ? time : null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              })?.toList() ??
              [],
        ],
      ),
    );
  }

  Widget _buildContentGoalsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Content Goals',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          Text(
            'Select your primary content objectives',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: _contentGoals
                  .map((goal) => CheckboxListTile(
                        title: Text(goal['goal']!),
                        subtitle: Text(goal['description']!),
                        value: (_formData['contentGoals'] ?? [])
                            .contains(goal['goal']),
                        onChanged: (selected) {
                          setState(() {
                            if (selected ?? false) {
                              _formData['contentGoals'] = [
                                ...(_formData['contentGoals'] ?? []),
                                goal['goal']
                              ];
                            } else {
                              _formData['contentGoals'] =
                                  (_formData['contentGoals'] as List)
                                      .where((item) => item != goal['goal'])
                                      .toList();
                            }
                          });
                        },
                        activeColor: Colors.orange.shade400,
                        checkColor: Colors.white,
                      ))
                  .toList(),
            ),
          ),
          if ((_formData['contentGoals']?.length ?? 0) == 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Please select at least one content goal',
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTargetAudienceField() {
    final TextEditingController _controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Target Audience'),
          TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Type and press Enter to add',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.9),
            ),
            onFieldSubmitted: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _formData['targetAudience'] = [
                    ...(_formData['targetAudience'] ?? []),
                    value
                  ];
                });
                _controller.clear();
              }
            },
          ),
          Wrap(
            spacing: 8,
            children:
                (_formData['targetAudience'] ?? []).map<Widget>((audience) {
              return Chip(
                label: Text(audience),
                onDeleted: () {
                  setState(() {
                    _formData['targetAudience'] =
                        (_formData['targetAudience'] as List)
                            .where((item) => item != audience)
                            .toList();
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if ((_formData['contentGoals']?.length ?? 0) == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select at least one content goal'),
            backgroundColor: Colors.red.shade400,
          ),
        );
        return;
      }
      _formKey.currentState?.save();

      // Convert posting schedule data to PostingFrequency objects
      final Map<String, PostingFrequency> postingFrequency = {};
      if (_formData['postingSchedule'] != null) {
        (_formData['postingSchedule'] as Map<String, dynamic>)
            .forEach((platform, data) {
          postingFrequency[platform] = PostingFrequency(
            postsPerWeek: data['postsPerWeek'] ?? 0,
            preferredDays: List<String>.from(data['preferredDays'] ?? []),
            preferredTimeRange: data['preferredTimeRange'] ?? '',
          );
        });
      }

      final profile = Profile(
        id: '', // Will be set by Firebase
        name: _formData['name'] ?? '',
        industry: _formData['industry'] ?? '',
        brandPersonality: _formData['brandPersonality'] ?? '',
        targetPlatforms: List<String>.from(_formData['targetPlatforms'] ?? []),
        contentTypes: List<String>.from(_formData['contentTypes'] ?? []),
        toneOfVoice: _formData['toneOfVoice'] ?? '',
        targetAudience: List<String>.from(_formData['targetAudience'] ?? []),
        postingFrequency: postingFrequency,
        uniqueSellingProposition: _formData['uniqueSellingProposition'] ?? '',
        contentGoals: List<String>.from(_formData['contentGoals'] ?? []),
      );
      context.read<ProfileBloc>().add(CreateProfile(profile));
    }
  }
}
