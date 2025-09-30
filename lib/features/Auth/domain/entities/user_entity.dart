import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;          // profile.id
  final String authUid;     // Supabase auth.uid
  final String username;
  final String email;
  final String? phone;
  final String role;        // admin, manager, member
  final bool is_verified;

  const UserEntity({
    required this.id,
    required this.authUid,
    required this.username,
    required this.email,
    this.phone,
    required this.role,
    required this.is_verified,

  });

  @override
  List<Object?> get props => [id, authUid, username, email, phone, role,is_verified];
}
