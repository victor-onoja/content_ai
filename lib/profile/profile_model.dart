class Profile {
  final String id;
  final String name;
  final String industry;
  final String brandPersonality;
  final List<String> targetPlatforms;
  final List<String> contentGoals;
  final List<String> contentTypes;
  final List<String> targetAudience;
  final String uniqueSellingProposition;

  Profile({
    required this.id,
    required this.name,
    required this.industry,
    required this.brandPersonality,
    required this.targetPlatforms,
    required this.contentGoals,
    required this.contentTypes,
    required this.targetAudience,
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
    List<String>? targetAudience,
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
      targetAudience: targetAudience ?? this.targetAudience,
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
        'targetAudience': targetAudience,
        'uniqueSellingProposition': uniqueSellingProposition,
      };

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      industry: json['industry'] as String? ?? '',
      brandPersonality: json['brandPersonality'] as String? ?? '',
      targetPlatforms: List<String>.from(json['targetPlatforms'] ?? []),
      contentGoals: List<String>.from(json['contentGoals'] ?? []),
      contentTypes: List<String>.from(json['contentTypes'] ?? []),
      targetAudience: List<String>.from(json['targetAudience'] ?? []),
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
