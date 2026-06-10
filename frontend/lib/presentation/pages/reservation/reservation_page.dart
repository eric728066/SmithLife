import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/reservation/time_slot.dart';
import '../../../data/models/reservation/reservation.dart';
import '../../viewmodels/reservation_viewmodel.dart';

class ReservationPage extends ConsumerStatefulWidget {
  const ReservationPage({super.key});

  @override
  ConsumerState<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends ConsumerState<ReservationPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(reservationViewModelProvider.notifier).loadSlots());
  }

  Color _slotColor(String status) {
    switch (status) {
      case 'CROWDED':
        return AppColors.red;
      case 'NORMAL':
        return AppColors.amber;
      default:
        return AppColors.green;
    }
  }

  Future<void> _showResultAlert({
    required bool ok,
    required String successMessage,
    required String failMessage,
  }) async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultAlert(
        ok: ok,
        message: ok ? successMessage : failMessage,
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }

  void _showBookingSheet(TimeSlot slot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BookingConfirmSheet(
        slot: slot,
        onConfirm: () async {
          Navigator.pop(context);
          final ok =
              await ref.read(reservationViewModelProvider.notifier).book(slot.slotId);
          await _showResultAlert(
            ok: ok,
            successMessage: '${slot.startTime} 예약 완료!',
            failMessage: '예약에 실패했습니다.',
          );
        },
      ),
    );
  }

  void _showCancelSheet(TimeSlot slot, int reservationId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CancelConfirmSheet(
        slot: slot,
        onConfirm: () async {
          Navigator.pop(context);
          final ok = await ref
              .read(reservationViewModelProvider.notifier)
              .cancel(reservationId);
          await _showResultAlert(
            ok: ok,
            successMessage: '${slot.startTime} 예약이 취소되었습니다.',
            failMessage: '취소에 실패했습니다.',
          );
        },
      ),
    );
  }

  void _showAttendeesSheet(TimeSlot slot) async {
    final attendees = await ref
        .read(reservationViewModelProvider.notifier)
        .getSlotReservations(slot.slotId);

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AttendeesSheet(slot: slot, attendees: attendees),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reservationViewModelProvider);
    final today = DateFormat('yyyy년 M월 d일').format(DateTime.now());

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '오늘 날짜 : $today',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.golden))
                : state.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(state.error!,
                                style: const TextStyle(color: AppColors.red)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(reservationViewModelProvider.notifier)
                                  .loadSlots(),
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        itemCount: state.slots.length,
                        itemBuilder: (context, index) {
                          final slot = state.slots[index];
                          final color = _slotColor(slot.congestionStatus);
                          return _SlotCard(
                            slot: slot,
                            color: color,
                            onTap: () => _showAttendeesSheet(slot),
                            onBook: () => _showBookingSheet(slot),
                            onCancel: (reservationId) =>
                                _showCancelSheet(slot, reservationId),
                            myReservations: state.myReservations,
                          );
                        },
                      ),
          ),

          // 하단 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final available = state.slots
                            .where((s) =>
                                !s.myReservation &&
                                s.congestionStatus != 'CROWDED')
                            .toList();
                        if (available.isNotEmpty) {
                          _showSlotPickerSheet(available);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('예약 가능한 시간대가 없습니다.')),
                          );
                        }
                      },
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: const Text('예약하기',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // 내 예약 중 첫 번째 취소
                        final myBooked =
                            state.slots.where((s) => s.myReservation).toList();
                        if (myBooked.isNotEmpty) {
                          // 내 예약 목록에서 reservationId 찾기
                          _showMyCancelPicker();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('취소할 예약이 없습니다.')),
                          );
                        }
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('예약취소',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.golden,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSlotPickerSheet(List<TimeSlot> availableSlots) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SlotPickerSheet(
        slots: availableSlots,
        onSelect: (slot) {
          Navigator.pop(ctx);
          _showBookingSheet(slot);
        },
      ),
    );
  }

  void _showMyCancelPicker() async {
    final state = ref.read(reservationViewModelProvider);
    final mySlots = state.slots.where((s) => s.myReservation).toList();

    if (mySlots.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _MyCancelPickerSheet(
        mySlots: mySlots,
        onCancel: (slot) async {
          Navigator.pop(ctx);
          // getMyReservations로 reservationId 찾기
          final reservations = await ref
              .read(reservationRepositoryProvider)
              .getMyReservations();
          final match = reservations.where((r) => r.slot.slotId == slot.slotId);
          if (match.isNotEmpty && mounted) {
            _showCancelSheet(slot, match.first.reservationId);
          }
        },
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  final TimeSlot slot;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onBook;
  final void Function(int reservationId) onCancel;
  final List<Reservation> myReservations;

  const _SlotCard({
    required this.slot,
    required this.color,
    required this.onTap,
    required this.onBook,
    required this.onCancel,
    required this.myReservations,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: slot.myReservation
              ? AppColors.golden.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: slot.myReservation
              ? Border.all(color: AppColors.golden, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            // 시간
            SizedBox(
              width: 60,
              child: Text(
                slot.startTime,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 혼잡도 도트 + 텍스트
            Icon(Icons.circle, size: 10, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                slot.congestionLabel,
                style: TextStyle(fontSize: 14, color: color),
              ),
            ),
            // 내 예약 뱃지 OR 예약하기 버튼
            if (slot.myReservation)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.golden,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '예약됨',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              )
            else
              GestureDetector(
                onTap: onBook,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: slot.congestionStatus == 'CROWDED'
                        ? Colors.grey[200]
                        : AppColors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    slot.congestionStatus == 'CROWDED' ? '만석' : '예약',
                    style: TextStyle(
                      fontSize: 11,
                      color: slot.congestionStatus == 'CROWDED'
                          ? AppColors.gray
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BookingConfirmSheet extends StatelessWidget {
  final TimeSlot slot;
  final VoidCallback onConfirm;

  const _BookingConfirmSheet({required this.slot, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '예약 확인',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.golden),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${slot.startTime} - ${slot.endTime}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black),
                    ),
                    Text(
                      '현재 ${slot.currentCount}/${slot.maxCapacity}명 예약',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.gray),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: const Text('예약하기',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.golden,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: const Text('닫기',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CancelConfirmSheet extends StatelessWidget {
  final TimeSlot slot;
  final VoidCallback onConfirm;

  const _CancelConfirmSheet({required this.slot, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '예약 취소',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.cancel_outlined, color: AppColors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${slot.startTime} - ${slot.endTime} 예약을 취소합니다.',
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: const Text('취소하기',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.golden,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: const Text('닫기',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendeesSheet extends StatelessWidget {
  final TimeSlot slot;
  final List<Reservation> attendees;

  const _AttendeesSheet({required this.slot, required this.attendees});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people_outline, color: AppColors.golden),
                const SizedBox(width: 8),
                Text(
                  '${slot.startTime} 예약 현황',
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black),
                ),
                const Spacer(),
                Text(
                  '${slot.currentCount}/${slot.maxCapacity}명',
                  style: const TextStyle(fontSize: 14, color: AppColors.golden),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (attendees.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('예약자가 없습니다.',
                      style: TextStyle(color: AppColors.gray)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: attendees.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final r = attendees[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.golden.withOpacity(0.2),
                      child: Text(
                        r.userName?.isNotEmpty == true
                            ? r.userName![0]
                            : '?',
                        style: const TextStyle(
                            color: AppColors.golden,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(r.userName ?? '알 수 없음',
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.black)),
                    subtitle: Text(r.reservationNo,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.gray)),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _MyCancelPickerSheet extends StatelessWidget {
  final List<TimeSlot> mySlots;
  final void Function(TimeSlot slot) onCancel;

  const _MyCancelPickerSheet(
      {required this.mySlots, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '취소할 예약 선택',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.black),
          ),
          const SizedBox(height: 16),
          ...mySlots.map((slot) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time, color: AppColors.golden),
                title: Text('${slot.startTime} - ${slot.endTime}',
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.black)),
                trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
                onTap: () => onCancel(slot),
              )),
        ],
      ),
    );
  }
}

class _SlotPickerSheet extends StatelessWidget {
  final List<TimeSlot> slots;
  final void Function(TimeSlot slot) onSelect;

  const _SlotPickerSheet({required this.slots, required this.onSelect});

  Color _dotColor(String status) {
    switch (status) {
      case 'CROWDED':
        return AppColors.red;
      case 'NORMAL':
        return AppColors.amber;
      default:
        return AppColors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '시간 선택',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black),
            ),
            const SizedBox(height: 4),
            Text(
              '예약할 시간대를 선택하세요',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: slots.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final slot = slots[i];
                final dotColor = _dotColor(slot.congestionStatus);
                return GestureDetector(
                  onTap: () => onSelect(slot),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 56,
                          child: Text(
                            slot.startTime,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.circle, size: 8, color: dotColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            slot.congestionLabel,
                            style: TextStyle(fontSize: 14, color: dotColor),
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppColors.gray, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultAlert extends StatelessWidget {
  final bool ok;
  final String message;

  const _ResultAlert({required this.ok, required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: ok
                    ? AppColors.green.withOpacity(0.12)
                    : AppColors.red.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                ok ? Icons.check_circle_outline : Icons.error_outline,
                color: ok ? AppColors.green : AppColors.red,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
