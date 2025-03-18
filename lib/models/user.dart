class User {
  final String id;
  final String email;
  final String username;
  final String password;
  final String name;
  final String phone;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.password,
    required this.name,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'],
      username: json['username'],
      password: json['password'],
      name: json['name'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'password': password,
      'name': name,
      'phone': phone,
    };
  }
}
