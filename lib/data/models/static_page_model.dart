class StaticPageModel {
  final int id;
  final String key;
  final String title;
  final String slug;
  final String content;
  final int order;

  const StaticPageModel({
    required this.id,
    required this.key,
    required this.title,
    required this.slug,
    required this.content,
    required this.order,
  });

  factory StaticPageModel.fromJson(Map<String, dynamic> json) {
    return StaticPageModel(
      id: json['id'] as int? ?? 0,
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      content: json['content'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'title': title,
      'slug': slug,
      'content': content,
      'order': order,
    };
  }
}
