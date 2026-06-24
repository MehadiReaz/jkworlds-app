class SupportMessageModel {
  final int id;
  final String message;
  final String? file;
  final bool fromAdmin;
  final String senderName;
  final String? senderAvatar;
  final String createdAt;
  final DateTime createdAtIso;
  final bool isMine;

  const SupportMessageModel({
    required this.id,
    required this.message,
    this.file,
    required this.fromAdmin,
    required this.senderName,
    this.senderAvatar,
    required this.createdAt,
    required this.createdAtIso,
    required this.isMine,
  });

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      id: json['id'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      file: json['file'] as String?,
      fromAdmin: json['from_admin'] as bool? ?? false,
      senderName: json['sender_name'] as String? ?? '',
      senderAvatar: json['sender_avatar'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      createdAtIso: json['created_at_iso'] != null
          ? DateTime.parse(json['created_at_iso'] as String)
          : DateTime.now(),
      isMine: json['is_mine'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'file': file,
      'from_admin': fromAdmin,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'created_at': createdAt,
      'created_at_iso': createdAtIso.toIso8601String(),
      'is_mine': isMine,
    };
  }
}
