class UserModel {
  final int id;
  final String name;
  final String? email;
  final String? contact;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.contact,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'User',
      email: json['email'],
      contact: json['contact'] ?? json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'contact': contact,
    };
  }
}
