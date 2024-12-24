class Profile {
  final String id;
  final String name;
  final String industry;
  final String brandPersonality;
  final List<String> targetPlatforms;
  final List<String> contentGoals;
  final List<String> contentTypes;
  final String toneOfVoice;
  final List<String> targetAudience;
  final Map<String, PostingFrequency> postingFrequency;
  final String uniqueSellingProposition;

  Profile({
    required this.id,
    required this.name,
    required this.industry,
    required this.brandPersonality,
    required this.targetPlatforms,
    required this.contentGoals,
    required this.contentTypes,
    required this.toneOfVoice,
    required this.targetAudience,
    required this.postingFrequency,
    required this.uniqueSellingProposition,
  });

  Profile copyWith({
    String? id,
    String? name,
    String? industry,
    String? brandPersonality,
    List<String>? targetPlatforms,
    List<String>? contentGoals,
    List<String>? contentTypes,
    Map<String, String>? brandValues,
    String? toneOfVoice,
    List<String>? targetAudience,
    Map<String, PostingFrequency>? postingFrequency,
    String? uniqueSellingProposition,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      industry: industry ?? this.industry,
      brandPersonality: brandPersonality ?? this.brandPersonality,
      targetPlatforms: targetPlatforms ?? this.targetPlatforms,
      contentGoals: contentGoals ?? this.contentGoals,
      contentTypes: contentTypes ?? this.contentTypes,
      toneOfVoice: toneOfVoice ?? this.toneOfVoice,
      targetAudience: targetAudience ?? this.targetAudience,
      postingFrequency: postingFrequency ?? this.postingFrequency,
      uniqueSellingProposition:
          uniqueSellingProposition ?? this.uniqueSellingProposition,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'industry': industry,
        'brandPersonality': brandPersonality,
        'targetPlatforms': targetPlatforms,
        'contentGoals': contentGoals,
        'contentTypes': contentTypes,
        'toneOfVoice': toneOfVoice,
        'targetAudience': targetAudience,
        'postingFrequency':
            postingFrequency.map((key, value) => MapEntry(key, value.toJson())),
        'uniqueSellingProposition': uniqueSellingProposition,
      };

  factory Profile.fromJson(Map<String, dynamic> json) {
    Map<String, PostingFrequency> postingFrequencyMap = {};
    if (json['postingFrequency'] != null) {
      (json['postingFrequency'] as Map<String, dynamic>).forEach((key, value) {
        postingFrequencyMap[key] =
            PostingFrequency.fromJson(value as Map<String, dynamic>);
      });
    }

    return Profile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      industry: json['industry'] as String? ?? '',
      brandPersonality: json['brandPersonality'] as String? ?? '',
      targetPlatforms: List<String>.from(json['targetPlatforms'] ?? []),
      contentGoals: List<String>.from(json['contentGoals'] ?? []),
      contentTypes: List<String>.from(json['contentTypes'] ?? []),
      toneOfVoice: json['toneOfVoice'] as String? ?? '',
      targetAudience: List<String>.from(json['targetAudience'] ?? []),
      postingFrequency: postingFrequencyMap,
      uniqueSellingProposition:
          json['uniqueSellingProposition'] as String? ?? '',
    );
  }
}

class PostingFrequency {
  final int postsPerWeek;
  final List<String> preferredDays;
  final String preferredTimeRange;

  PostingFrequency({
    required this.postsPerWeek,
    required this.preferredDays,
    required this.preferredTimeRange,
  });

  Map<String, dynamic> toJson() => {
        'postsPerWeek': postsPerWeek,
        'preferredDays': preferredDays,
        'preferredTimeRange': preferredTimeRange,
      };

  factory PostingFrequency.fromJson(Map<String, dynamic> json) {
    return PostingFrequency(
      postsPerWeek: json['postsPerWeek'] as int,
      preferredDays: List<String>.from(json['preferredDays'] as List),
      preferredTimeRange: json['preferredTimeRange'] as String,
    );
  }
}
