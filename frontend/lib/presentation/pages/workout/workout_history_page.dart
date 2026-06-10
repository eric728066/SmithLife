import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../viewmodels/workout_history_provider.dart';

class WorkoutHistoryPage extends ConsumerWidget {
  const WorkoutHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(workoutHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          '운동 기록',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.black),
            onPressed: () =>
                ref.read(workoutHistoryProvider.notifier).loadFromBackend(),
          ),
        ],
      ),
      body: records.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final record = records[i];
                return Dismissible(
                  key: ValueKey(record.sessionId ?? record.dateTime.toString()),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('기록 삭제'),
                        content: const Text('이 운동 기록을 삭제할까요?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('삭제',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    return ok == true;
                  },
                  onDismissed: (_) {
                    ref
                        .read(workoutHistoryProvider.notifier)
                        .deleteRecord(record);
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.white, size: 28),
                  ),
                  child: GestureDetector(
                    onTap: () => context.push(
                      '/workout-history-detail',
                      extra: record,
                    ),
                    child: _RecordCard(record: record),
                  ),
                );
              },
            ),
    );
  }
}

// ─────────────────────────────────────────
// 기록 없을 때 빈 화면
// ─────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history,
              color: AppColors.gray,
              size: 44,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '아직 운동 기록이 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '루틴을 선택하고 운동을 완료하면\n여기에 기록이 쌓여요!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.gray, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 운동 기록 카드
// ─────────────────────────────────────────
class _RecordCard extends StatelessWidget {
  final WorkoutRecord record;

  const _RecordCard({required this.record});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(recDay).inDays;

    String dayStr;
    if (diff == 0) {
      dayStr = '오늘';
    } else if (diff == 1) {
      dayStr = '어제';
    } else {
      const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      final wd = weekdays[dt.weekday - 1];
      dayStr =
          '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} ($wd)';
    }

    final hour = dt.hour;
    final ampm = hour < 12 ? '오전' : '오후';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    return '$dayStr  $ampm $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final pct = record.completionPercent;
    final isFullDone = pct == 100;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isFullDone
            ? Border.all(color: AppColors.green.withValues(alpha: 0.25))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── 날짜 + 완료율 ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(record.dateTime),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.gray),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      record.routineName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isFullDone
                      ? AppColors.green.withValues(alpha: 0.12)
                      : AppColors.golden.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isFullDone ? AppColors.green : AppColors.golden,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ─── 통계 칩 (시간 + 완료 운동수) ───
          Row(
            children: [
              _StatChip(
                icon: Icons.timer_outlined,
                label: record.timerLabel,
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.fitness_center,
                label:
                    '${record.completedExercises}/${record.totalExercises} 완료',
              ),
            ],
          ),

          // ─── 운동 목록 ───
          if (record.exerciseNames.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.lightGray),
            const SizedBox(height: 12),
            ...List.generate(
              record.exerciseNames.length.clamp(0, 4),
              (i) {
                final isDone = i < record.exerciseStatuses.length &&
                    record.exerciseStatuses[i] == 2;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        isDone
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 15,
                        color: isDone ? AppColors.green : AppColors.gray,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        record.exerciseNames[i],
                        style: TextStyle(
                          fontSize: 13,
                          color: isDone ? AppColors.black : AppColors.gray,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (record.exerciseNames.length > 4)
              Text(
                '+ ${record.exerciseNames.length - 4}개 더',
                style:
                    const TextStyle(fontSize: 12, color: AppColors.gray),
              ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 통계 칩
// ─────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.golden),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
