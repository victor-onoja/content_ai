part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthUserChanged extends AuthEvent {
  final User? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthSignInWithGoogle extends AuthEvent {}

class AuthSignInWithApple extends AuthEvent {}

class AuthSignInAsGuest extends AuthEvent {}

class AuthSignOut extends AuthEvent {}
