/// Represents the summary statistics/unread counts and configurations of support tickets.
class SupportTicketSummaryModel {
  final int totalUnread;
  final Map<String, int> tickets;
  final Map<String, dynamic> polling;
  final Map<String, bool>? hasNew;

  const SupportTicketSummaryModel({
    required this.totalUnread,
    required this.tickets,
    required this.polling,
    this.hasNew,
  });

  factory SupportTicketSummaryModel.fromJson(Map<String, dynamic> json) {
    final ticketsRaw = json['tickets'] as Map? ?? {};
    final ticketsMap = ticketsRaw.map((k, v) => MapEntry(k.toString(), int.tryParse(v?.toString() ?? '') ?? 0));

    final hasNewRaw = json['has_new'] as Map?;
    final hasNewMap = hasNewRaw?.map((k, v) => MapEntry(k.toString(), v == true || v?.toString() == 'true'));

    return SupportTicketSummaryModel(
      totalUnread: int.tryParse(json['total_unread']?.toString() ?? '') ?? 0,
      tickets: ticketsMap,
      polling: json['polling'] is Map
          ? Map<String, dynamic>.from(json['polling'] as Map)
          : {},
      hasNew: hasNewMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_unread': totalUnread,
      'tickets': tickets,
      'polling': polling,
      if (hasNew != null) 'has_new': hasNew,
    };
  }
}
