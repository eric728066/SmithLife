import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../viewmodels/workout_session_provider.dart';

class WorkoutSummaryPage extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutSummaryPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final exercises = session.exercises;
    final statuses = session.exerciseStatuses;
    final completedCount = session.completedCount;
    final totalCount = exercises.length;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          // ─── 상단 헤더 (다크) ───
          Container(
            width: double.infinity,
            color: AppColors.black,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  children: [
                    // 트로피 아이콘
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.golden.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: AppColors.golden,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '운동 완료!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      session.sessionName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 통계 3칸
                    Row(
                      children: [
                        _StatChip(
                          icon: Icons.timer_outlined,
                          label: '운동 시간',
                          value: session.timerLabel,
                        ),
                        const _VerticalDivider(),
                        _StatChip(
                          icon: Icons.fitness_center,
                          label: '완료 운동',
                          value: '$completedCount/$totalCount',
                        ),
                        const _VerticalDivider(),
                        _StatChip(
                          icon: Icons.check_circle_outline,
                          label: '진행률',
                          value: totalCount > 0
                              ? '${(completedCount / totalCount * 100).round()}%'
                              : '0%',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── 운동 목록 ───
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '운동 내역',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(exercises.length, (i) {
                    final ex = exercises[i];
                    final status =
                        i < statuses.length ? statuses[i] : 0;
                    final isDone = status == 2;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isDone
                            ? Border.all(
                                color: AppColors.green.withValues(alpha: 0.3))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? AppColors.green
                                  : AppColors.lightGray,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDone ? Icons.check : Icons.remove,
                              color:
                                  isDone ? Colors.white : AppColors.gray,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDone
                                        ? AppColors.black
                                        : AppColors.gray,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isDone
                                      ? '${ex.muscle} · ${ex.defaultSets}세트 완료'
                                      : '${ex.muscle} · 미완료',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDone
                                        ? AppColors.green
                                        : AppColors.gray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isDone)
                            const Icon(Icons.check_circle,
                                color: AppColors.green, size: 20),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ─── 하단 버튼 ───
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.go('/workout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.golden,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.golden, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }
}
