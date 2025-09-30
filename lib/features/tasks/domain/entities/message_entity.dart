class MessageEntity {
  final String id;
  final String taskId;
  final String senderId;
  final String content;
  final String senderName;
  final DateTime createdAt;
  final String? fileUrl;   // 👈 for document URL
  final String? fileType;  // 👈 image, video, pdf, docx, etc.

  MessageEntity({
    required this.id,
    required this.taskId,
    required this.senderId,
    required this.content,
    required this.senderName,
    required this.createdAt,
    this.fileUrl,
    this.fileType,
  });


  factory MessageEntity.fromMap(Map<String, dynamic> map) {

    return MessageEntity(
      id: map['id'] as String? ?? '',
      taskId: map['task_id'] as String? ?? '',
      senderId: map['sender_id'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      content: map['content'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String? ?? DateTime.now().toString()),
      fileUrl: map['file_url'],
      fileType: map['file_type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'sender_id': senderId,
      'senderName': senderName,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'file_url': fileUrl,
      'file_type': fileType,
    };
  }
}
