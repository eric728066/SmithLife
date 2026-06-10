import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../viewmodels/workout_session_provider.dart';
import 'workout_models.dart';

class RoutineDetailPage extends ConsumerStatefulWidget {
  final RoutineData routine;

  const RoutineDetailPage({super.key, required this.routine});

  @override
  ConsumerState<RoutineDetailPage> createState() => _RoutineDetailPageState();
}

class _RoutineDetailPageState extends ConsumerState<RoutineDetailPage> {
  bool _bookmarked = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.routine;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          // 상단 헤더 이미지 영역
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _bookmarked ? Icons.favorite : Icons.favorite_border,
                  color: _bookmarked ? AppColors.red : Colors.white,
                ),
                onPressed: () =>
                    setState(() => _bookmarked = !_bookmarked),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      r.iconColor.withValues(alpha: 0.8),
                      AppColors.black,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(r.icon, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        r.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.goal,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 루틴 정보 카드
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _InfoChip(
                            icon: Icons.timer_outlined,
                            label: r.duration),
                        const _Divider(),
                        _InfoChip(
                            icon: Icons.flag_outlined,
                            label: r.goal),
                        const _Divider(),
                        _InfoChip(
                            icon: Icons.bar_chart,
                            label: r.difficulty),
                        const _Divider(),
                        _InfoChip(
                            icon: Icons.repeat,
                            label: r.frequency),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 운동 구성 리스트
                  const Text(
                    '운동 구성',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(r.exercises.length, (i) {
                    final ex = r.exercises[i];
                    return GestureDetector(
                      onTap: () => context.push(
                        '/workout-detail',
                        extra: {'name': ex.name, 'muscle': ex.muscle},
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: r.iconBg,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: r.iconColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${ex.muscle} · ${ex.defaultSets}세트',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.gray),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: AppColors.gray),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),

      // 하단 CTA 버튼
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                // 세션 시작 → 워크아웃 탭으로 이동
                ref
                    .read(workoutSessionProvider.notifier)
                    .startRoutine(r);
                context.go('/workout');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.golden,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: const Text(
                '이 루틴으로 운동 시작하기',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.golden),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.black,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.lightGray,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
