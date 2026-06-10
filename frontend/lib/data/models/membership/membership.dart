class Membership {
  final int membershipId;
  final String type;
  final String startDate;
  final String endDate;
  final String status;
  final int remainingDays;

  Membership({
    required this.membershipId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.remainingDays,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      membershipId: json['membershipId'],
      type: json['type'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      status: json['status'],
      remainingDays: json['remainingDays'] ?? 0,
    );
  }
}
