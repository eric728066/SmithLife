import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/announcement/announcement.dart';
import '../../../data/models/reservation/reservation.dart';
import '../../../data/repositories/announcement_repository.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';

final announcementProvider = FutureProvider<List<Announcement>>((ref) async {
  try {
    return await AnnouncementRepository().getAnnouncements();
  } catch (_) {
    return [];
  }
});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(homeViewModelProvider.notifier).loadHomeData();
      ref.read(userViewModelProvider.notifier).loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final userState = ref.watch(userViewModelProvider);
    final membership = userState.membership;

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
            icon: const Icon(Icons.notifications_outlined, color: AppColors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              '오늘의 요약',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),

            // 다음 예약 카드
            _NextReservationCard(
              reservation: homeState.nextReservation,
              isLoading: homeState.isLoading,
            ),
            const SizedBox(height: 12),

            // 혼잡도 + 남은 기간
            Row(
              children: [
                Expanded(child: _CongestionCard()),
                const SizedBox(width: 12),
                Expanded(
                  child: _DdayCard(
                    remainingDays: membership?.remainingDays,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 공지사항
            const Text(
              '공지사항',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),
            _NoticeHorizontalList(ref: ref),
            const SizedBox(height: 24),

            // 이용 내역
            const Text(
              '이용 내역',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),
            _UsageHistoryCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _NextReservationCard extends StatelessWidget {
  final Reservation? reservation;
  final bool isLoading;

  const _NextReservationCard({this.reservation, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '다음 예약',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.orangeBg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                if (isLoading)
                  const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.golden),
                  )
                else if (reservation == null)
                  const Text(
                    '예약 없음',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray,
                    ),
                  )
                else
                  Text(
                    '${reservation!.slot.startTime} - ${reservation!.slot.endTime}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '메인 피트니스 존',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: AppColors.orangeBg,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _CongestionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: AppColors.green.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people, color: AppColors.green, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            '혼잡도',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 6),
          Row(
            children: const [
              Icon(Icons.circle, color: AppColors.green, size: 10),
              SizedBox(width: 6),
              Text(
                '원활합니다',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DdayCard extends StatelessWidget {
  final int? remainingDays;

  const _DdayCard({this.remainingDays});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: AppColors.blue.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.badge_outlined,
                color: AppColors.blue, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            '남은 기간',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 6),
          Text(
            remainingDays != null ? 'D-$remainingDays 일' : '-',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeHorizontalList extends StatelessWidget {
  final WidgetRef ref;

  const _NoticeHorizontalList({required this.ref});

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(announcementProvider);

    return announcementsAsync.when(
      loading: () => const SizedBox(
        height: 130,
        child: Center(
          child: CircularProgressIndicator(
              color: AppColors.golden, strokeWidth: 2),
        ),
      ),
      error: (_, __) => const SizedBox(height: 130),
      data: (announcements) {
        if (announcements.isEmpty) {
          return Container(
            height: 100,
            alignment: Alignment.center,
            child: Text('공지사항이 없습니다.',
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          );
        }
        return SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemCount: announcements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final n = announcements[index];
              final isEvent = n.tag == 'EVENT';
              return Container(
                width: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isEvent
                            ? AppColors.blue.withOpacity(0.8)
                            : AppColors.orangeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isEvent ? '이벤트' : '안내',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      n.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.content,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _UsageHistoryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/usage'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.assignment_outlined,
                color: AppColors.golden, size: 28),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                '이용 내역 바로가기',
                style: TextStyle(
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
