class TimeSlot {
  final int slotId;
  final String date;
  final String startTime;
  final String endTime;
  final int maxCapacity;
  final int currentCount;
  final String congestionStatus; // SMOOTH, NORMAL, CROWDED
  final bool myReservation;

  TimeSlot({
    required this.slotId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.maxCapacity,
    required this.currentCount,
    required this.congestionStatus,
    required this.myReservation,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      slotId: json['slotId'],
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      maxCapacity: json['maxCapacity'],
      currentCount: json['currentCount'],
      congestionStatus: json['congestionStatus'] ?? 'SMOOTH',
      myReservation: json['myReservation'] ?? false,
    );
  }

  String get congestionLabel {
    switch (congestionStatus) {
      case 'CROWDED':
        return '혼잡합니다';
      case 'NORMAL':
        return '보통입니다';
      default:
        return '원활합니다';
    }
  }
}
