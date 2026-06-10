import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../data/models/reservation/time_slot.dart';
import '../../data/models/reservation/reservation.dart';
import '../../data/repositories/reservation_repository.dart';

class ReservationState {
  final bool isLoading;
  final List<TimeSlot> slots;
  final List<Reservation> myReservations;
  final String? error;

  ReservationState({
    this.isLoading = false,
    this.slots = const [],
    this.myReservations = const [],
    this.error,
  });

  ReservationState copyWith({
    bool? isLoading,
    List<TimeSlot>? slots,
    List<Reservation>? myReservations,
    String? error,
  }) {
    return ReservationState(
      isLoading: isLoading ?? this.isLoading,
      slots: slots ?? this.slots,
      myReservations: myReservations ?? this.myReservations,
      error: error,
    );
  }
}

class ReservationViewModel extends StateNotifier<ReservationState> {
  final ReservationRepository _repository;

  ReservationViewModel(this._repository) : super(ReservationState());

  Future<void> loadSlots({String? date}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final slots = await _repository.getTimeSlots(date: date);
      state = state.copyWith(isLoading: false, slots: slots);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: DioClient.extractError(e),
      );
    }
  }

  Future<bool> book(int slotId) async {
    try {
      await _repository.createReservation(slotId);
      await loadSlots();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: DioClient.extractError(e));
      return false;
    }
  }

  Future<bool> cancel(int reservationId) async {
    try {
      await _repository.cancelReservation(reservationId);
      await loadSlots();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: DioClient.extractError(e));
      return false;
    }
  }

  Future<List<Reservation>> getSlotReservations(int slotId) async {
    try {
      return await _repository.getSlotReservations(slotId);
    } catch (_) {
      return [];
    }
  }
}

final reservationRepositoryProvider =
    Provider((ref) => ReservationRepository());

final reservationViewModelProvider =
    StateNotifierProvider<ReservationViewModel, ReservationState>((ref) {
  return ReservationViewModel(ref.watch(reservationRepositoryProvider));
});
