import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user/user_profile.dart';
import '../../data/models/membership/membership.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/reservation_repository.dart';
import '../../data/repositories/workout_repository.dart';
import 'workout_history_provider.dart';

class UserState {
  final bool isLoading;
  final UserProfile? profile;
  final Membership? membership;
  final int attendanceRate;
  final String? error;

  UserState({
    this.isLoading = false,
    this.profile,
    this.membership,
    this.attendanceRate = 0,
    this.error,
  });

  UserState copyWith({
    bool? isLoading,
    UserProfile? profile,
    Membership? membership,
    int? attendanceRate,
    String? error,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      membership: membership ?? this.membership,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      error: error,
    );
  }
}

class UserViewModel extends StateNotifier<UserState> {
  final UserRepository _repository;

  UserViewModel(this._repository) : super(UserState());

  Future<void> loadUserData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _repository.getMyProfile();
      final membership = await _repository.getActiveMembership();
      state = state.copyWith(
        isLoading: false,
        profile: profile,
        membership: membership,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final userRepositoryProvider = Provider((ref) => UserRepository());

final userViewModelProvider =
    StateNotifierProvider<UserViewModel, UserState>((ref) {
  return UserViewModel(ref.watch(userRepositoryProvider));
});

/// 이번 달 참석율: CONFIRMED 예약 + 운동 기록 동시 존재 날 / 이번 달 월~토 전체 일수
final attendanceRateProvider = FutureProvider.autoDispose<int>((ref) async {
  final now = DateTime.now();
  final year = now.year;
  final month = now.month;

  // 예약 내역 + 운동 기록 병렬 로드
  final reservationRepo = ReservationRepository();
  final workoutRepo = WorkoutRepository();

  final results = await Future.wait([
    reservationRepo.getReservationHistory(),
    workoutRepo.getHistory(),
  ]);

  final reservations = results[0] as List;
  final workoutList = results[1] as List<Map<String, dynamic>>;

  // 이번 달 CONFIRMED(또는 COMPLETED) 예약 날짜 집합
  final confirmedDates = reservations
      .where((r) {
        final status = r.status as String;
        return status == 'CONFIRMED' || status == 'COMPLETED';
      })
      .map((r) => r.slot.date as String)
      .where((dateStr) {
        final d = DateTime.tryParse(dateStr);
        return d != null && d.year == year && d.month == month;
      })
      .toSet();

  // 이번 달 운동 기록 날짜 집합
  final workoutDates = workoutList.map((json) {
    final startTime = json['startTime'] as String?;
    if (startTime == null) return null;
    final dt = DateTime.tryParse(startTime);
    if (dt == null || dt.year != year || dt.month != month) return null;
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }).whereType<String>().toSet();

  // 교집합: 예약확정 AND 운동 기록이 모두 있는 날
  final attendedDays = confirmedDates.intersection(workoutDates);

  // 이번 달 월~토 총 일수
  final daysInMonth = DateUtils.getDaysInMonth(year, month);
  int monSatCount = 0;
  for (int day = 1; day <= daysInMonth; day++) {
    final weekday = DateTime(year, month, day).weekday;
    if (weekday >= 1 && weekday <= 6) {
      monSatCount++;
    }
  }

  if (monSatCount == 0) return 0;
  return (attendedDays.length / monSatCount * 100).round();
});

/// 오늘의 총 운동 볼륨 (kg) - workoutHistoryProvider에서 직접 계산
final todayVolumeProvider = Provider.autoDispose<double>((ref) {
  final history = ref.watch(workoutHistoryProvider);
  final now = DateTime.now();
  double totalVolume = 0.0;

  for (final record in history) {
    final dt = record.dateTime;
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      totalVolume += record.totalVolumeKg;
    }
  }

  return totalVolume;
});
