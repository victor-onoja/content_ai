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

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'],
        name: json['name'],
        industry: json['industry'],
        brandPersonality: json['brandPersonality'],
        targetPlatforms: List<String>.from(json['targetPlatforms']),
        contentGoals: List<String>.from(json['contentGoals']),
        contentTypes: List<String>.from(json['contentTypes']),
        toneOfVoice: json['toneOfVoice'],
        targetAudience: List<String>.from(json['targetAudience']),
        postingFrequency:
            Map<String, PostingFrequency>.from(json['postingFrequency']),
        uniqueSellingProposition: json['uniqueSellingProposition'],
      );
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

  factory PostingFrequency.fromJson(Map<String, dynamic> json) =>
      PostingFrequency(
        postsPerWeek: json['postsPerWeek'],
        preferredDays: List<String>.from(json['preferredDays']),
        preferredTimeRange: json['preferredTimeRange'],
      );
}
