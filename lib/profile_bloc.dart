import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseFirestore _firestore;

  ProfileBloc(this._firestore) : super(ProfileState()) {
    on<CreateProfile>(_onCreateProfile);
  }

  Future<void> _onCreateProfile(
    CreateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      const String testUserId = 'test_user_blast';

      final profileData = event.profile.toJson();
      print('Profile data being saved: $profileData');

      final docRef = await _firestore
          .collection('users')
          // .doc(FirebaseAuth.instance.currentUser?.uid)
          .doc(testUserId)
          .collection('profiles')
          .add(event.profile.toJson());

      final profile = event.profile.copyWith(id: docRef.id);
      emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
      ));
    } catch (e, stackTrace) {
      print('Error creating profile: $e');
      print('Stack trace: $stackTrace');
      emit(state.copyWith(
        status: ProfileStatus.failure,
        error: e.toString(),
      ));
    }
  }
}
