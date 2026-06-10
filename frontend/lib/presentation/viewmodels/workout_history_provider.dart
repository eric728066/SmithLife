import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/workout_repository.dart';

class WorkoutRecord {
  final int? sessionId; // 백엔드 DB ID (삭제 시 사용)
  final String routineName;
  final DateTime dateTime;
  final int elapsedSeconds;
  final int completedExercises;
  final int totalExercises;
  final List<String> exerciseNames;
  final List<int> exerciseStatuses; // 0=PENDING, 1=IN_PROGRESS, 2=COMPLETED
  final double totalVolumeKg;

  const WorkoutRecord({
    this.sessionId,
    required this.routineName,
    required this.dateTime,
    required this.elapsedSeconds,
    required this.completedExercises,
    required this.totalExercises,
    required this.exerciseNames,
    required this.exerciseStatuses,
    this.totalVolumeKg = 0.0,
  });

  String get timerLabel {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int get completionPercent =>
      totalExercises > 0
          ? (completedExercises / totalExercises * 100).round()
          : 0;

  /// 백엔드 응답 → WorkoutRecord
  factory WorkoutRecord.fromBackend(Map<String, dynamic> json) {
    final exercises =
        (json['exercises'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final names = exercises.map((e) => e['name'] as String? ?? '').toList();
    final statuses = exercises.map((e) {
      final s = e['status'] as String? ?? 'PENDING';
      if (s == 'COMPLETED') return 2;
      if (s == 'IN_PROGRESS') return 1;
      return 0;
    }).toList();
    final completed = statuses.where((s) => s == 2).length;

    final volumeRaw = json['totalVolumeKg'];
    final volumeKg = volumeRaw != null ? (volumeRaw as num).toDouble() : 0.0;

    // 백엔드가 내려주는 실제 total/completed 사용 (DB 미매칭 운동 포함)
    final backendTotal = json['totalExercises'] as int?;
    final backendCompleted = json['completedExercises'] as int?;

    return WorkoutRecord(
      sessionId: json['sessionId'] as int?,
      routineName: json['sessionName'] as String? ?? '',
      dateTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      elapsedSeconds: json['totalDurationSec'] as int? ?? 0,
      completedExercises: backendCompleted ?? completed,
      totalExercises: backendTotal ?? exercises.length,
      exerciseNames: names,
      exerciseStatuses: statuses,
      totalVolumeKg: volumeKg,
    );
  }
}

class WorkoutHistoryNotifier extends StateNotifier<List<WorkoutRecord>> {
  final WorkoutRepository _repo = WorkoutRepository();

  WorkoutHistoryNotifier() : super([]) {
    loadFromBackend();
  }

  /// 백엔드에서 기록 로드
  Future<void> loadFromBackend() async {
    try {
      final list = await _repo.getHistory();
      state = list.map(WorkoutRecord.fromBackend).toList();
    } catch (_) {
      // 연결 실패 시 현재 상태 유지
    }
  }

  /// 운동 종료 시 호출: 백엔드 저장 후 목록 새로고침
  Future<void> addRecord(WorkoutRecord localRecord) async {
    // 즉시 로컬에 추가 (UI 즉시 반영)
    state = [localRecord, ...state];

    try {
      final statusLabels = ['PENDING', 'IN_PROGRESS', 'COMPLETED'];
      final exercises = List.generate(localRecord.exerciseNames.length, (i) {
        final statusIdx = i < localRecord.exerciseStatuses.length
            ? localRecord.exerciseStatuses[i].clamp(0, 2)
            : 0;
        return {
          'exerciseName': localRecord.exerciseNames[i],
          'orderIndex': i,
          'status': statusLabels[statusIdx],
          'sets': <Map<String, dynamic>>[],
        };
      });

      final saved = await _repo.saveSession(
        sessionName: localRecord.routineName,
        totalDurationSec: localRecord.elapsedSeconds,
        exercises: exercises,
        totalVolumeKg: localRecord.totalVolumeKg > 0 ? localRecord.totalVolumeKg : null,
      );

      // 백엔드 저장 성공 시 sessionId + volume만 반영, 나머지는 로컬 기준 유지
      final backendRecord = WorkoutRecord.fromBackend(saved);
      final withId = WorkoutRecord(
        sessionId: backendRecord.sessionId,
        routineName: localRecord.routineName,
        dateTime: localRecord.dateTime,
        elapsedSeconds: localRecord.elapsedSeconds,
        completedExercises: localRecord.completedExercises,
        totalExercises: localRecord.totalExercises,
        exerciseNames: localRecord.exerciseNames,
        exerciseStatuses: localRecord.exerciseStatuses,
        totalVolumeKg: backendRecord.totalVolumeKg > 0
            ? backendRecord.totalVolumeKg
            : localRecord.totalVolumeKg,
      );
      state = [withId, ...state.skip(1)];
    } catch (_) {
      // 백엔드 실패 시 로컬 기록 유지
    }
  }

  /// 기록 삭제
  Future<void> deleteRecord(WorkoutRecord record) async {
    // 즉시 로컬에서 제거
    state = state
        .where((r) => r != record)
        .toList();

    if (record.sessionId != null) {
      try {
        await _repo.deleteSession(record.sessionId!);
      } catch (_) {
        // 백엔드 삭제 실패 시 무시 (다음 로드 시 복원됨)
      }
    }
  }
}

final workoutHistoryProvider =
    StateNotifierProvider<WorkoutHistoryNotifier, List<WorkoutRecord>>(
  (ref) => WorkoutHistoryNotifier(),
);
