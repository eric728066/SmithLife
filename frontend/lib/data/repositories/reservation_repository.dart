import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/reservation/time_slot.dart';
import '../models/reservation/reservation.dart';

class ReservationRepository {
  final Dio _dio = DioClient().dio;

  Future<List<TimeSlot>> getTimeSlots({String? date}) async {
    final response = await _dio.get(
      ApiConstants.timeSlots,
      queryParameters: date != null ? {'date': date} : null,
    );
    final List<dynamic> data = DioClient.extractData(response);
    return data.map((e) => TimeSlot.fromJson(e)).toList();
  }

  Future<List<Reservation>> getSlotReservations(int slotId) async {
    final response = await _dio.get('/api/timeslots/$slotId/reservations');
    final List<dynamic> data = DioClient.extractData(response);
    return data.map((e) => Reservation.fromJson(e)).toList();
  }

  Future<Reservation> createReservation(int slotId) async {
    final response = await _dio.post(
      ApiConstants.reservations,
      data: {'slotId': slotId},
    );
    return Reservation.fromJson(DioClient.extractData(response));
  }

  Future<void> cancelReservation(int reservationId) async {
    await _dio.delete('${ApiConstants.reservations}/$reservationId');
  }

  Future<List<Reservation>> getMyReservations() async {
    final response = await _dio.get(ApiConstants.myReservations);
    final List<dynamic> data = DioClient.extractData(response);
    return data.map((e) => Reservation.fromJson(e)).toList();
  }

  Future<Reservation?> getNextReservation() async {
    try {
      final response = await _dio.get(ApiConstants.nextReservation);
      final data = DioClient.extractData(response);
      if (data == null) return null;
      return Reservation.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<List<Reservation>> getReservationHistory() async {
    final response = await _dio.get(ApiConstants.reservationHistory);
    final List<dynamic> data = DioClient.extractData(response);
    return data.map((e) => Reservation.fromJson(e)).toList();
  }

  Future<String> generateQr() async {
    final response = await _dio.post(ApiConstants.generateQr);
    final data = DioClient.extractData(response);
    return data['qrContent'] as String;
  }
}
