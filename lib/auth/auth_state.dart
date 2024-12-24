part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, error, loading }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState._({
    this.status = AuthStatus.unknown,
    this.user,
    this.errorMessage,
  });

  const AuthState.unknown() : this._();

  const AuthState.authenticated(User user)
      : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  const AuthState.error(String errorMessage)
      : this._(status: AuthStatus.error, errorMessage: errorMessage);
  const AuthState.loading() : this._(status: AuthStatus.loading);

  @override
  List<Object?> get props => [status, user, errorMessage];
}
