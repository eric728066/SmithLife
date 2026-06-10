class UserProfile {
  final int userId;
  final String email;
  final String name;
  final String? phone;
  final String? profileImageUrl;
  final String? role;
  final String? createdAt;

  UserProfile({
    required this.userId,
    required this.email,
    required this.name,
    this.phone,
    this.profileImageUrl,
    this.role,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      profileImageUrl: json['profileImageUrl'],
      role: json['role'],
      createdAt: json['createdAt']?.toString(),
    );
  }
}
