class FaqModel {
  final int id;
  final String question;
  final String answer;
  final int order;

  const FaqModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.order,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] as int? ?? 0,
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'order': order,
    };
  }
}
