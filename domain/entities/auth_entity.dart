import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String authUid;
  final String email;

  const AuthEntity({
    required this.authUid,
    required this.email,
  });

  @override
  List<Object?> get props => [authUid, email];
}
