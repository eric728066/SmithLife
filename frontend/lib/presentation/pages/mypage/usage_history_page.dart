import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/reservation/reservation.dart';
import '../../viewmodels/reservation_viewmodel.dart';

final _historyProvider = FutureProvider<List<Reservation>>((ref) {
  return ref.watch(reservationRepositoryProvider).getReservationHistory();
});

class UsageHistoryPage extends ConsumerStatefulWidget {
  const UsageHistoryPage({super.key});

  @override
  ConsumerState<UsageHistoryPage> createState() => _UsageHistoryPageState();
}

class _UsageHistoryPageState extends ConsumerState<UsageHistoryPage> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(_historyProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '이용 내역',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: historyAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.golden)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.red, size: 48),
              const SizedBox(height: 12),
              Text('불러오기 실패', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(_historyProvider),
                child: const Text('다시 시도',
                    style: TextStyle(color: AppColors.golden)),
              ),
            ],
          ),
        ),
        data: (reservations) {
          // 방문한 날짜 집합 (CONFIRMED or COMPLETED)
          final visitedDates = reservations
              .where((r) =>
                  r.status == 'CONFIRMED' || r.status == 'COMPLETED')
              .map((r) => r.slot.date)
              .map((s) => DateTime.tryParse(s))
              .whereType<DateTime>()
              .map((d) => DateTime(d.year, d.month, d.day))
              .toSet();

          // 포커스 월 예약 목록 (날짜 오름차순)
          final monthReservations = reservations
              .where((r) {
                final d = DateTime.tryParse(r.slot.date);
                return d != null &&
                    d.year == _focusedMonth.year &&
                    d.month == _focusedMonth.month;
              })
              .toList()
            ..sort((a, b) => a.slot.date.compareTo(b.slot.date));

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _CalendarCard(
                    focusedMonth: _focusedMonth,
                    visitedDates: visitedDates,
                    onPrev: _prevMonth,
                    onNext: _nextMonth,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: monthReservations.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              '이번 달 이용 내역이 없습니다',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[500]),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _HistoryCard(
                                reservation: monthReservations[index]),
                          ),
                          childCount: monthReservations.length,
                        ),
                      ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}

// ─── 캘린더 카드 ──────────────────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  final DateTime focusedMonth;
  final Set<DateTime> visitedDates;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _CalendarCard({
    required this.focusedMonth,
    required this.visitedDates,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final year = focusedMonth.year;
    final month = focusedMonth.month;
    final today = DateTime.now();
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(year, month);

    // 첫날 요일 오프셋 (일=0, 월=1, ..., 토=6)
    final startOffset = firstDay.weekday % 7;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 월 네비게이션
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onPrev,
                child: const Icon(Icons.chevron_left, color: AppColors.black),
              ),
              Text(
                '$year년 ${month.toString().padLeft(2, '0')}월',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              GestureDetector(
                onTap: onNext,
                child: const Icon(Icons.chevron_right, color: AppColors.black),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 요일 헤더 (일~토)
          Row(
            children: ['일', '월', '화', '수', '목', '금', '토']
                .asMap()
                .entries
                .map((e) => Expanded(
                      child: Center(
                        child: Text(
                          e.value,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: e.key == 0
                                ? Colors.red[400]
                                : e.key == 6
                                    ? Colors.blue[400]
                                    : Colors.grey[500],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // 날짜 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 0,
              childAspectRatio: 1,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startOffset) return const SizedBox();

              final day = index - startOffset + 1;
              final date = DateTime(year, month, day);
              final isVisited = visitedDates.contains(date);
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;

              return Center(
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isVisited
                        ? AppColors.orangeBg
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday && !isVisited
                        ? Border.all(color: AppColors.orangeBg, width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isVisited || isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isVisited
                            ? Colors.white
                            : isToday
                                ? AppColors.orangeBg
                                : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // 범례
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.orangeBg,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '방문일',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 이용 내역 카드 ──────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final Reservation reservation;

  const _HistoryCard({required this.reservation});

  Color get _statusColor {
    switch (reservation.status) {
      case 'CONFIRMED':
        return AppColors.green;
      case 'CANCELLED':
        return AppColors.red;
      case 'COMPLETED':
        return AppColors.blue;
      default:
        return AppColors.gray;
    }
  }

  String get _statusLabel {
    switch (reservation.status) {
      case 'CONFIRMED':
        return '예약됨';
      case 'CANCELLED':
        return '취소됨';
      case 'COMPLETED':
        return '이용완료';
      case 'NO_SHOW':
        return '노쇼';
      default:
        return reservation.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final slot = reservation.slot;
    final date = slot.date;
    final start = slot.startTime;
    final end = slot.endTime;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // 날짜 박스
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _monthDay(date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  _weekday(date),
                  style: const TextStyle(fontSize: 10, color: AppColors.gray),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$start - $end',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.gray),
                    SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        '메인 피트니스 존',
                        style: TextStyle(fontSize: 12, color: AppColors.gray),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 상태 뱃지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthDay(String date) {
    try {
      final parts = date.split('-');
      return '${parts[1]}/${parts[2]}';
    } catch (_) {
      return date;
    }
  }

  String _weekday(String date) {
    try {
      final d = DateTime.parse(date);
      const days = ['월', '화', '수', '목', '금', '토', '일'];
      return days[d.weekday - 1];
    } catch (_) {
      return '';
    }
  }
}
