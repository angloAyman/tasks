// member_entity.dart
class MemberEntity {
  final String id;
  final String teamId;
  final String userId;
  final String role;
  final DateTime joinedAt;
  final String username;
  final String email;

  MemberEntity({
    required this.id,
    required this.teamId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.username,
    required this.email,
  });
}
