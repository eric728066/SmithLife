import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../viewmodels/workout_history_provider.dart';

class WorkoutHistoryDetailPage extends ConsumerWidget {
  final WorkoutRecord record;

  const WorkoutHistoryDetailPage({super.key, required this.record});

  String _formatFullDate(DateTime dt) {
    const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final wd = weekdays[dt.weekday - 1];
    final hour = dt.hour;
    final ampm = hour < 12 ? '오전' : '오후';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}년 ${dt.month}월 ${dt.day}일 $wd  $ampm $h:$m';
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 운동 기록을 삭제할까요?\n삭제한 기록은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(workoutHistoryProvider.notifier).deleteRecord(record);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pct = record.completionPercent;
    final isFullDone = pct == 100;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          // ─── 다크 헤더 ───
          Container(
            width: double.infinity,
            color: AppColors.black,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // 상단 네비 행
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            '운동 상세',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.white, size: 22),
                          onPressed: () => _confirmDelete(context, ref),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 아이콘 + 루틴명
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: isFullDone
                          ? AppColors.green.withValues(alpha: 0.2)
                          : AppColors.golden.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFullDone ? Icons.emoji_events : Icons.fitness_center,
                      color:
                          isFullDone ? AppColors.green : AppColors.golden,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    record.routineName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatFullDate(record.dateTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 통계 3칸
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: Row(
                      children: [
                        _StatChip(
                          icon: Icons.timer_outlined,
                          label: '운동 시간',
                          value: record.timerLabel,
                        ),
                        _VerticalDivider(),
                        _StatChip(
                          icon: Icons.fitness_center,
                          label: '완료 운동',
                          value:
                              '${record.completedExercises}/${record.totalExercises}',
                        ),
                        _VerticalDivider(),
                        _StatChip(
                          icon: Icons.check_circle_outline,
                          label: '진행률',
                          value: '$pct%',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── 운동 목록 ───
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
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
                  ...List.generate(record.exerciseNames.length, (i) {
                    final isDone = i < record.exerciseStatuses.length &&
                        record.exerciseStatuses[i] == 2;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isDone
                            ? Border.all(
                                color:
                                    AppColors.green.withValues(alpha: 0.3))
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
                            child: Text(
                              record.exerciseNames[i],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDone
                                    ? AppColors.black
                                    : AppColors.gray,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isDone)
                            const Icon(Icons.check_circle,
                                color: AppColors.green, size: 20)
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.lightGray,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '미완료',
                                style: TextStyle(
                                    fontSize: 11, color: AppColors.gray),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
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
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }
}
