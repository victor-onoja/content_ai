import 'profile_model.dart';

enum ProfileStatus { initial, loading, success, failure, notFound }

class ProfileState {
  final ProfileStatus status;
  final Profile? profile;
  final String? error;

  ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.error,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    Profile? profile,
    String? error,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      error: error ?? this.error,
    );
  }
}
