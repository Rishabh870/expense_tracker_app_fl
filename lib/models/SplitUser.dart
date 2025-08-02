class SplitUser{
  final int? id;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final bool? isSelf;

  SplitUser({
    required this.id,
    this.name,
    this.email,
    this.phoneNumber,
    required this.isSelf,
  });

  factory SplitUser.fromJson(Map<String, dynamic> json) {
    return SplitUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      isSelf: json['is_self'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'is_self': isSelf,
    };
  }
}
