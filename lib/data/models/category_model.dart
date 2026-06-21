class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String type;
  final bool status;
  final String? image;
  final String? icon;
  final String? description;
  final int vehicleCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    required this.status,
    this.image,
    this.icon,
    this.description,
    this.vehicleCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status'] as bool? ?? false,
      image: json['image'] as String?,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      vehicleCount: json['vehicles_count'] is int
          ? json['vehicles_count'] as int
          : int.tryParse(json['vehicles_count']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'type': type,
        'status': status,
        'image': image,
        'icon': icon,
        'description': description,
        'vehicles_count': vehicleCount,
      };
}