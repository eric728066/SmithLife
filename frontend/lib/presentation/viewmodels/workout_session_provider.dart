import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/workout/workout_models.dart';

class WorkoutSession {
  final RoutineData? routine; // null = 루틴 미선택
  final int elapsedSeconds;
  final bool isRunning;
  final List<int> exerciseStatuses; // 0=미시작, 1=진행중, 2=완료
  final Map<int, double> exerciseVolumes; // exerciseIndex → 해당 운동 총 볼륨(kg)

  const WorkoutSession({
    this.routine,
    this.elapsedSeconds = 0,
    this.isRunning = false,
    this.exerciseStatuses = const [],
    this.exerciseVolumes = const {},
  });

  bool get hasRoutine => routine != null;

  List<ExerciseData> get exercises => routine?.exercises ?? [];

  String get sessionName => routine?.name ?? '';

  int get completedCount => exerciseStatuses.where((s) => s == 2).length;

  double get totalVolumeKg =>
      exerciseVolumes.values.fold(0.0, (sum, v) => sum + v);

  String get timerLabel {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  WorkoutSession copyWith({
    RoutineData? routine,
    bool clearRoutine = false,
    int? elapsedSeconds,
    bool? isRunning,
    List<int>? exerciseStatuses,
    Map<int, double>? exerciseVolumes,
  }) {
    return WorkoutSession(
      routine: clearRoutine ? null : (routine ?? this.routine),
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
      exerciseStatuses: exerciseStatuses ?? this.exerciseStatuses,
      exerciseVolumes: exerciseVolumes ?? this.exerciseVolumes,
    );
  }
}

class WorkoutSessionNotifier extends StateNotifier<WorkoutSession> {
  Timer? _timer;

  WorkoutSessionNotifier() : super(const WorkoutSession());

  void startRoutine(RoutineData routine) {
    _timer?.cancel();
    final n = routine.exercises.length;
    final statuses = List<int>.filled(n, 0);
    if (n > 0) statuses[0] = 1;
    state = WorkoutSession(
      routine: routine,
      elapsedSeconds: 0,
      isRunning: true,
      exerciseStatuses: statuses,
      exerciseVolumes: const {},
    );
    _tick();
  }

  void play() {
    if (!state.hasRoutine || state.isRunning) return;
    state = state.copyWith(isRunning: true);
    _tick();
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void completeExercise(int index) {
    if (index < 0 || index >= state.exerciseStatuses.length) return;
    final statuses = [...state.exerciseStatuses];
    statuses[index] = 2;
    if (index + 1 < statuses.length && statuses[index + 1] == 0) {
      statuses[index + 1] = 1;
    }
    state = state.copyWith(exerciseStatuses: statuses);
  }

  /// 운동 완료 시 해당 운동의 세트 볼륨 저장
  void setExerciseVolume(int exerciseIndex, double volume) {
    final updated = Map<int, double>.from(state.exerciseVolumes);
    updated[exerciseIndex] = volume;
    state = state.copyWith(exerciseVolumes: updated);
  }

  void stop() {
    _timer?.cancel();
    state = const WorkoutSession();
  }

  void _tick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final workoutSessionProvider =
    StateNotifierProvider<WorkoutSessionNotifier, WorkoutSession>(
  (ref) => WorkoutSessionNotifier(),
);
