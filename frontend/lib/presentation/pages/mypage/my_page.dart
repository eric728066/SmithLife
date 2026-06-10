import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user/user_profile.dart';
import '../../../data/models/membership/membership.dart';
import '../../viewmodels/user_viewmodel.dart';

// ─── MyPage ──────────────────────────────────────────────────────────────────

class MyPage extends ConsumerStatefulWidget {
  const MyPage({super.key});

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(userViewModelProvider.notifier).loadUserData());
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userViewModelProvider);
    final profile = userState.profile;
    final membership = userState.membership;
    final attendanceAsync = ref.watch(attendanceRateProvider);
    final todayVolume = ref.watch(todayVolumeProvider);

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
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.black),
            onPressed: () => context.push('/notification'),
          ),
        ],
      ),
      body: userState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.golden))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _UserCard(profile: profile, membership: membership),
                  const SizedBox(height: 16),
                  _StatsRow(
                    attendanceAsync: attendanceAsync,
                    todayVolume: todayVolume,
                    onAttendanceTap: () => context.push('/usage'),
                  ),
                  const SizedBox(height: 16),
                  _MenuItem(
                    icon: Icons.assignment_outlined,
                    label: '이용 내역',
                    onTap: () => context.push('/usage'),
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    label: '설정',
                    onTap: () => context.push('/settings'),
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    icon: Icons.chat_bubble_outline,
                    label: '문의하기',
                    onTap: () => context.push('/inquiry'),
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    label: '알림',
                    onTap: () => context.push('/notification'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

// ─── 유저 카드 ────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final UserProfile? profile;
  final Membership? membership;

  const _UserCard({this.profile, this.membership});

  @override
  Widget build(BuildContext context) {
    final name = profile?.name ?? '-';
    final membershipType = membership?.type ?? '회원권 없음';
    final remainingDays = membership?.remainingDays;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFE8878A),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name님',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  membershipType,
                  style: const TextStyle(fontSize: 14, color: AppColors.gray),
                ),
                if (remainingDays != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.orangeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'D-$remainingDays',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 통계 카드 행 ──────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final AsyncValue<int> attendanceAsync;
  final double todayVolume;
  final VoidCallback onAttendanceTap;

  const _StatsRow({
    required this.attendanceAsync,
    required this.todayVolume,
    required this.onAttendanceTap,
  });

  @override
  Widget build(BuildContext context) {
    final attendanceRate = attendanceAsync.valueOrNull ?? 0;
    final isLoading = attendanceAsync.isLoading;

    final volumeLabel = todayVolume == 0.0
        ? '-'
        : todayVolume % 1 == 0
            ? '${todayVolume.toInt()}kg'
            : '${todayVolume.toStringAsFixed(1)}kg';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 참석율 카드
        Expanded(
          child: GestureDetector(
            onTap: onAttendanceTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.orangeBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '참석율',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.bar_chart,
                          size: 14, color: Colors.white.withValues(alpha: 0.7)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            ),
                          )
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '$attendanceRate%',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Flexible(
                        child: Text(
                          '이용 내역 바로가기',
                          style:
                              TextStyle(fontSize: 11, color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right, size: 14, color: Colors.white70),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 오늘의 운동량 카드
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Flexible(
                      child: Text(
                        '오늘의 운동량',
                        style: TextStyle(fontSize: 12, color: AppColors.gray),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.fitness_center,
                        size: 14, color: Colors.grey[400]),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        volumeLabel,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '총 들어올린 무게',
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── 메뉴 아이템 ───────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.black),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

