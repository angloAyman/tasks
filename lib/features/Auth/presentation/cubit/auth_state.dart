part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user; // من supabase_flutter

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthSuccesss extends AuthState {

  const AuthSuccesss();

  @override
  List<Object?> get props => [];
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}
