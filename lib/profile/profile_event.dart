import 'package:equatable/equatable.dart';

import 'profile_model.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateProfile extends ProfileEvent {
  final Profile profile;
  CreateProfile(this.profile);
  @override
  List<Object?> get props => [profile];
}

class LoadProfile extends ProfileEvent {}
