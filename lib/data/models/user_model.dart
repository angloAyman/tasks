import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id; // profile id
  final String authUid; // auth.uid
  final String username;
  final String email;
  final String? phone;
  final String role;
  final bool is_verified;


  UserModel({required this.id, required this.authUid, required this.username, required this.email, this.phone, required this.role, required this.is_verified});

  factory UserModel.fromMap(Map<String, dynamic> m) {
    return UserModel(
      id: m['id'] as String,
      authUid: m['auth_uid'] as String,
      username: m['username'] as String,
      email: m['email'] as String,
      phone: m['phone'] as String?,
      role: m['role'] as String? ?? 'member',
      is_verified: m['is_verified'] as bool,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'auth_uid': authUid,
    'username': username,
    'email': email,
    'phone': phone,
    'role': role,
    'is_verified': is_verified,
  };

  @override
  List<Object?> get props => [id, authUid, username, email, phone, role, is_verified];
}
