class SupportTicketModel {
  final int id;
  final String subject;
  final String priority;
  final int status;
  final String statusLabel;
  final bool canSendMessage;
  final int unreadCount;
  final int? lastMessageId;
  final String date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupportTicketModel({
    required this.id,
    required this.subject,
    required this.priority,
    required this.status,
    required this.statusLabel,
    required this.canSendMessage,
    required this.unreadCount,
    this.lastMessageId,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: json['id'] as int? ?? 0,
      subject: json['subject'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Low',
      status: json['status'] as int? ?? 0,
      statusLabel: json['status_label'] as String? ?? 'pending',
      canSendMessage: json['can_send_message'] as bool? ?? true,
      unreadCount: json['unread_count'] as int? ?? 0,
      lastMessageId: json['last_message_id'] as int?,
      date: json['date'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'priority': priority,
      'status': status,
      'status_label': statusLabel,
      'can_send_message': canSendMessage,
      'unread_count': unreadCount,
      'last_message_id': lastMessageId,
      'date': date,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
