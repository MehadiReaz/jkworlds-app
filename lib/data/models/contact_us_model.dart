class ContactUsModel {
  final String email;
  final String phone;

  const ContactUsModel({
    required this.email,
    required this.phone,
  });

  factory ContactUsModel.fromJson(Map<String, dynamic> json) {
    return ContactUsModel(
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
    };
  }
}
