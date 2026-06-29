class SliderModel {
  final int id;
  final String image;
  final int order;

  const SliderModel({
    required this.id,
    required this.image,
    required this.order,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      id: json['id'] as int? ?? 0,
      image: json['image'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'order': order,
    };
  }
}
