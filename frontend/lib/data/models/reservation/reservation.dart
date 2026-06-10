import 'time_slot.dart';

class Reservation {
  final int reservationId;
  final String reservationNo;
  final String status;
  final String reservedAt;
  final String? cancelledAt;
  final TimeSlot slot;
  final String? userName;

  Reservation({
    required this.reservationId,
    required this.reservationNo,
    required this.status,
    required this.reservedAt,
    this.cancelledAt,
    required this.slot,
    this.userName,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      reservationId: json['reservationId'],
      reservationNo: json['reservationNo'],
      status: json['status'],
      reservedAt: json['reservedAt'],
      cancelledAt: json['cancelledAt'],
      slot: TimeSlot.fromJson(json['slot']),
      userName: json['userName'],
    );
  }
}
