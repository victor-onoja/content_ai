import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'profile_event.dart';
import 'profile_model.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseFirestore _firestore;

  ProfileBloc(this._firestore) : super(ProfileState()) {
    on<CreateProfile>(_onCreateProfile);
    on<LoadProfile>(_onLoadProfile);
  }

  Future<void> _onCreateProfile(
    CreateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('User is not authenticated.');
      }

      final profileData = event.profile.toJson();
      if (profileData.isEmpty) {
        throw Exception('Profile data is invalid or empty.');
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .set({'profile': profileData}, SetOptions(merge: true));

      emit(state.copyWith(
        status: ProfileStatus.success,
        profile: event.profile,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('User is not authenticated.');
      }

      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || !doc.data()!.containsKey('profile')) {
        emit(state.copyWith(status: ProfileStatus.notFound));
        return;
      }

      final profileData = doc.data()!['profile'] as Map<String, dynamic>;
      final profile = Profile.fromJson(profileData);

      emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        error: e.toString(),
      ));
    }
  }
}
