import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/reservation/reservation.dart';
import '../../data/repositories/reservation_repository.dart';
import 'reservation_viewmodel.dart' show reservationRepositoryProvider;

class HomeState {
  final bool isLoading;
  final Reservation? nextReservation;
  final String? error;

  HomeState({
    this.isLoading = false,
    this.nextReservation,
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    Reservation? nextReservation,
    bool clearNext = false,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      nextReservation: clearNext ? null : nextReservation ?? this.nextReservation,
      error: error,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  final ReservationRepository _reservationRepository;

  HomeViewModel(this._reservationRepository) : super(HomeState());

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final next = await _reservationRepository.getNextReservation();
      if (next != null) {
        state = state.copyWith(isLoading: false, nextReservation: next);
      } else {
        state = state.copyWith(isLoading: false, clearNext: true);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false, clearNext: true);
    }
  }
}

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(ref.watch(reservationRepositoryProvider));
});
