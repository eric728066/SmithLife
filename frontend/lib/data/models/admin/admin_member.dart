import '../membership/membership.dart';

class AdminMember {
  final int userId;
  final String email;
  final String name;
  final String phone;
  final String role;
  final bool isActive;
  final String? createdAt;
  final Membership? activeMembership;
  final List<Membership>? membershipHistory;

  AdminMember({
    required this.userId,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.isActive,
    this.createdAt,
    this.activeMembership,
    this.membershipHistory,
  });

  factory AdminMember.fromJson(Map<String, dynamic> json) {
    return AdminMember(
      userId: json['userId'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      role: json['role'] ?? 'USER',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt']?.toString(),
      activeMembership: json['activeMembership'] != null
          ? Membership.fromJson(json['activeMembership'])
          : null,
      membershipHistory: (json['membershipHistory'] as List<dynamic>?)
          ?.map((e) => Membership.fromJson(e))
          .toList(),
    );
  }
}
