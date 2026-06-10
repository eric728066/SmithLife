import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../viewmodels/workout_session_provider.dart';
import '../../viewmodels/user_routine_provider.dart';
import '../../viewmodels/workout_history_provider.dart';
import 'workout_models.dart';

class WorkoutPage extends ConsumerWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(workoutSessionProvider);
    final notifier = ref.read(workoutSessionProvider.notifier);
    final exercises = session.exercises;
    final statuses = session.exerciseStatuses;
    final userRoutines = ref.watch(userRoutineProvider);
    final history = ref.watch(workoutHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'SMITHLIFE',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.black,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.black),
            tooltip: '운동 기록',
            onPressed: () => context.push('/workout-history'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 세션 카드 (루틴 있으면 ACTIVE, 없으면 선택 유도) ───
            if (session.hasRoutine)
              _ActiveSessionCard(
                session: session,
                onPlay: notifier.play,
                onPause: notifier.pause,
                onStop: () => _confirmStop(context, ref, notifier, session),
              )
            else
              _SelectRoutineCard(
                onTap: () => context.push('/routine-list'),
              ),
            const SizedBox(height: 24),

            // ─── 루틴 선택 ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '루틴 선택',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/routine-list'),
                  child: const Text(
                    '전체보기',
                    style: TextStyle(
                      color: AppColors.golden,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _RecommendedRoutinesGrid(
              userRoutines: userRoutines,
              onTap: (r) => context.push('/routine-detail', extra: r),
            ),
            const SizedBox(height: 24),

            // ─── 최근 운동 기록 (항상 표시) ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '최근 운동 기록',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                if (history.isNotEmpty)
                  TextButton(
                    onPressed: () => context.push('/workout-history'),
                    child: const Text(
                      '전체보기',
                      style: TextStyle(
                        color: AppColors.golden,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (history.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Icon(Icons.history,
                        size: 36,
                        color: AppColors.gray.withValues(alpha: 0.5)),
                    const SizedBox(height: 10),
                    const Text(
                      '아직 운동 기록이 없습니다',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '루틴을 선택하고 운동을 완료하면 여기에 기록이 쌓여요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.gray),
                    ),
                  ],
                ),
              )
            else
              _RecentHistoryList(
                records: history.take(3).toList(),
                onTap: (r) =>
                    context.push('/workout-history-detail', extra: r),
              ),
            const SizedBox(height: 24),

            // ─── 진행중인 운동 (루틴 선택 시에만) ───
            if (session.hasRoutine) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '진행중인 운동',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    '${session.completedCount}/${exercises.length} 완료',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _CurrentExerciseList(
                exercises: exercises,
                statuses: statuses,
                onTap: (i) => context.push(
                  '/workout-detail',
                  extra: {
                    'name': exercises[i].name,
                    'muscle': exercises[i].muscle,
                    'index': i,
                  },
                ),
              ),
              const SizedBox(height: 24),

              // ─── 워크아웃 종료 버튼 ───
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmStop(context, ref, notifier, session),
                  icon: const Icon(Icons.check_box, size: 20),
                  label: const Text(
                    '오늘의 워크아웃 종료',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmStop(BuildContext context, WidgetRef ref,
      WorkoutSessionNotifier notifier, WorkoutSession session) {
    showDialog(
      context: context,
      builder: (_) => _EndWorkoutDialog(
        onConfirm: () {
          final snapshot = session;

          // 기록 저장 (로컬 즉시 반영 + 백엔드 비동기 저장)
          final record = WorkoutRecord(
            routineName: snapshot.sessionName,
            dateTime: DateTime.now(),
            elapsedSeconds: snapshot.elapsedSeconds,
            completedExercises: snapshot.completedCount,
            totalExercises: snapshot.exercises.length,
            exerciseNames: snapshot.exercises.map((e) => e.name).toList(),
            exerciseStatuses: List<int>.from(snapshot.exerciseStatuses),
            totalVolumeKg: snapshot.totalVolumeKg,
          );
          ref.read(workoutHistoryProvider.notifier).addRecord(record);

          notifier.stop();
          context.push('/workout-summary', extra: snapshot);
        },
      ),
    );
  }

}

// ─────────────────────────────────────────
// 루틴 미선택 안내 카드
// ─────────────────────────────────────────
class _SelectRoutineCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SelectRoutineCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fitness_center,
                  color: AppColors.golden, size: 28),
            ),
            const SizedBox(height: 14),
            const Text(
              '루틴을 선택해주세요',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '오늘의 운동 루틴을 골라 시작해보세요',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.golden,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '루틴 선택하기',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// ACTIVE SESSION 카드
// ─────────────────────────────────────────
class _ActiveSessionCard extends StatelessWidget {
  final WorkoutSession session;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStop;

  const _ActiveSessionCard({
    required this.session,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final isRunning = session.isRunning;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 배지 + 이름
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: AppColors.golden),
                        SizedBox(width: 6),
                        Text(
                          'ACTIVE SESSION',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.golden,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      session.sessionName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          isRunning
                              ? Icons.timer_outlined
                              : Icons.pause_circle_outline,
                          size: 14,
                          color:
                              isRunning ? AppColors.golden : AppColors.gray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          session.timerLabel,
                          style: TextStyle(
                            fontSize: 13,
                            color: isRunning
                                ? AppColors.golden
                                : AppColors.gray,
                            fontWeight: isRunning
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Icon(Icons.local_fire_department_outlined,
                            size: 14, color: AppColors.gray),
                        const SizedBox(width: 4),
                        const Text('320 kcal',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.gray)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 컨트롤 버튼 행: [시작/일시정지]  [멈춤]
          Row(
            children: [
              Expanded(
                child: _ControlButton(
                  icon: isRunning ? Icons.pause : Icons.play_arrow,
                  label: isRunning ? '일시정지' : '시작',
                  primary: true,
                  onTap: isRunning ? onPause : onPlay,
                ),
              ),
              const SizedBox(width: 10),
              _ControlButton(
                icon: Icons.stop,
                label: '멈춤',
                primary: false,
                onTap: onStop,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: primary
              ? AppColors.golden
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: primary ? Colors.white : AppColors.gray),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primary ? Colors.white : AppColors.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 루틴 선택 그리드 (2개 미리보기)
// ─────────────────────────────────────────
class _RecommendedRoutinesGrid extends StatelessWidget {
  final List<RoutineData> userRoutines;
  final void Function(RoutineData) onTap;

  const _RecommendedRoutinesGrid(
      {required this.userRoutines, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // 나만의 루틴을 먼저, 이후 추천 루틴 순으로 최대 2개 표시
    final combined = [...userRoutines, ...kRoutines];
    final displayed = combined.take(2).toList();
    return Row(
      children: List.generate(displayed.length, (i) {
        final r = displayed[i];
        return Expanded(
          child: GestureDetector(
            onTap: () => onTap(r),
            child: Container(
              margin: EdgeInsets.only(right: i == 0 ? 10 : 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: r.iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(r.icon, color: r.iconColor, size: 22),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    r.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${r.frequency} · ${r.duration}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      r.difficulty,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.golden),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────
// 진행중인 운동 리스트
// ─────────────────────────────────────────
class _CurrentExerciseList extends StatelessWidget {
  final List<ExerciseData> exercises;
  final List<int> statuses;
  final void Function(int index) onTap;

  const _CurrentExerciseList({
    required this.exercises,
    required this.statuses,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final safeStatuses = statuses.length == exercises.length
        ? statuses
        : List.filled(exercises.length, 0);

    return Column(
      children: [
        ...List.generate(exercises.length, (i) {
          final ex = exercises[i];
          final status = i < safeStatuses.length ? safeStatuses[i] : 0;
          final isDone = status == 2;
          final isNext = status == 1;

          return GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.green.withValues(alpha: 0.06)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: isDone
                    ? Border.all(
                        color: AppColors.green.withValues(alpha: 0.3))
                    : isNext
                        ? Border.all(
                            color: AppColors.golden, width: 1.5)
                        : null,
              ),
              child: Row(
                children: [
                  // 상태 아이콘
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.green
                          : isNext
                              ? Colors.grey[200]
                              : AppColors.lightGray,
                      shape: isDone
                          ? BoxShape.circle
                          : BoxShape.rectangle,
                      borderRadius:
                          isDone ? null : BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isDone ? Icons.check : Icons.fitness_center,
                      color: isDone ? Colors.white : AppColors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                ex.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDone
                                      ? AppColors.gray
                                      : AppColors.black,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: AppColors.gray,
                                ),
                              ),
                            ),
                            if (isNext) ...[
                              const SizedBox(width: 6),
                              const _UpNextBadge(),
                            ],
                            if (isDone) ...[
                              const SizedBox(width: 6),
                              const _DoneBadge(),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDone
                              ? '${ex.muscle} · ${ex.defaultSets}세트 완료'
                              : isNext
                                  ? '${ex.muscle} · 0/${ex.defaultSets}세트'
                                  : '${ex.muscle} · ${ex.defaultSets}세트',
                          style: TextStyle(
                              fontSize: 12,
                              color: isDone
                                  ? AppColors.green
                                  : AppColors.gray),
                        ),
                      ],
                    ),
                  ),
                  if (isNext)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.golden,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow,
                          color: Colors.white, size: 18),
                    )
                  else
                    const Icon(Icons.chevron_right,
                        color: AppColors.gray),
                ],
              ),
            ),
          );
        }),

        // 운동 추가하기
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.gray.withValues(alpha: 0.4),
            ),
          ),
          child: const Center(
            child: Text(
              '+ 운동 추가하기',
              style: TextStyle(fontSize: 14, color: AppColors.gray),
            ),
          ),
        ),
      ],
    );
  }
}

class _UpNextBadge extends StatelessWidget {
  const _UpNextBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.golden.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'UP NEXT',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: AppColors.golden,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DoneBadge extends StatelessWidget {
  const _DoneBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        '완료',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: AppColors.green,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 최근 운동 기록 리스트 (워크아웃 탭 인라인)
// ─────────────────────────────────────────
class _RecentHistoryList extends StatelessWidget {
  final List<WorkoutRecord> records;
  final void Function(WorkoutRecord) onTap;

  const _RecentHistoryList({required this.records, required this.onTap});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(recDay).inDays;
    if (diff == 0) return '오늘';
    if (diff == 1) return '어제';
    const wd = ['월', '화', '수', '목', '금', '토', '일'];
    return '${dt.month}/${dt.day} (${wd[dt.weekday - 1]})';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: records.map((r) {
        final pct = r.completionPercent;
        final isFullDone = pct == 100;
        return GestureDetector(
          onTap: () => onTap(r),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: isFullDone
                  ? Border.all(
                      color: AppColors.green.withValues(alpha: 0.25))
                  : null,
            ),
            child: Row(
              children: [
                // 날짜 아이콘
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isFullDone
                        ? AppColors.green.withValues(alpha: 0.1)
                        : AppColors.cream,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFullDone
                        ? Icons.emoji_events
                        : Icons.fitness_center,
                    size: 20,
                    color:
                        isFullDone ? AppColors.green : AppColors.golden,
                  ),
                ),
                const SizedBox(width: 12),
                // 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.routineName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_formatDate(r.dateTime)}  ·  ${r.timerLabel}  ·  ${r.completedExercises}/${r.totalExercises} 완료',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.gray),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 완료율
                Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isFullDone ? AppColors.green : AppColors.golden,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right,
                    color: AppColors.gray, size: 18),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────
// 종료 확인 다이얼로그
// ─────────────────────────────────────────
class _EndWorkoutDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const _EndWorkoutDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.golden.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                color: AppColors.golden,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '워크아웃 종료',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              '오늘의 운동을 종료하시겠습니까?\n운동 요약을 확인할 수 있습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.gray),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.golden,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23)),
                        elevation: 0,
                      ),
                      child: const Text('계속하기',
                          style:
                              TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23)),
                        elevation: 0,
                      ),
                      child: const Text('종료',
                          style:
                              TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
