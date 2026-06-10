import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// ─── 알림 모델 ─────────────────────────────────────────────────────────────────

enum NotifType { reservation, workout, announcement }

class AppNotification {
  final String id;
  final NotifType type;
  final String title;
  final String body;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });
}

// ─── 더미 데이터 ───────────────────────────────────────────────────────────────

final _dummyNotifications = <AppNotification>[
  AppNotification(
    id: '1',
    type: NotifType.reservation,
    title: '예약이 확정되었습니다',
    body: '3월 2일(월) 10:00 PT 수업 예약이 확정되었습니다.',
    createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    isRead: false,
  ),
  AppNotification(
    id: '2',
    type: NotifType.workout,
    title: '운동 시간 30분 전입니다',
    body: '오늘 오전 10:00 PT 수업이 30분 후에 시작됩니다.',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    isRead: false,
  ),
  AppNotification(
    id: '3',
    type: NotifType.reservation,
    title: '회원권 만료 D-7',
    body: '회원권이 7일 후 만료됩니다. 지금 바로 연장하세요.',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    isRead: true,
  ),
  AppNotification(
    id: '4',
    type: NotifType.announcement,
    title: '정기 휴무 안내',
    body: '3월 1일(토) 삼일절로 인해 센터가 휴무입니다. 이용에 참고 부탁드립니다.',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    isRead: true,
  ),
  AppNotification(
    id: '5',
    type: NotifType.announcement,
    title: '청소의 날 안내',
    body: '매월 첫째 주 월요일은 정기 청소의 날로 오후 6시 이후 시설 이용이 제한됩니다.',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    isRead: true,
  ),
  AppNotification(
    id: '6',
    type: NotifType.announcement,
    title: '봄맞이 이벤트 안내',
    body: '3월 한 달간 신규 회원 등록 시 1개월 무료 혜택을 드립니다. 주변에 많이 알려주세요!',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    isRead: true,
  ),
];

// ─── NotificationPage ────────────────────────────────────────────────────────

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<AppNotification> _notifications = List.from(_dummyNotifications);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AppNotification> get _personal => _notifications
      .where((n) =>
          n.type == NotifType.reservation || n.type == NotifType.workout)
      .toList();

  List<AppNotification> get _announcements =>
      _notifications.where((n) => n.type == NotifType.announcement).toList();

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _markRead(String id) {
    setState(() {
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) _notifications[idx].isRead = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '알림',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                '모두 읽음',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.orangeBg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.black,
          unselectedLabelColor: AppColors.gray,
          indicatorColor: AppColors.orangeBg,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('개인 알림'),
                  if (_personal.any((n) => !n.isRead)) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.orangeBg,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: '공지사항'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NotifList(
            notifications: _personal,
            onTap: _markRead,
            emptyMessage: '새로운 알림이 없습니다',
            emptyIcon: Icons.notifications_none_outlined,
          ),
          _NotifList(
            notifications: _announcements,
            onTap: _markRead,
            emptyMessage: '공지사항이 없습니다',
            emptyIcon: Icons.campaign_outlined,
            isAnnouncement: true,
          ),
        ],
      ),
    );
  }
}

// ─── 알림 목록 ─────────────────────────────────────────────────────────────────

class _NotifList extends StatelessWidget {
  final List<AppNotification> notifications;
  final void Function(String id) onTap;
  final String emptyMessage;
  final IconData emptyIcon;
  final bool isAnnouncement;

  const _NotifList({
    required this.notifications,
    required this.onTap,
    required this.emptyMessage,
    required this.emptyIcon,
    this.isAnnouncement = false,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final n = notifications[index];
        return _NotifCard(
          notification: n,
          onTap: () => onTap(n.id),
          isAnnouncement: isAnnouncement,
        );
      },
    );
  }
}

// ─── 알림 카드 ─────────────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final bool isAnnouncement;

  const _NotifCard({
    required this.notification,
    required this.onTap,
    this.isAnnouncement = false,
  });

  IconData get _icon {
    switch (notification.type) {
      case NotifType.reservation:
        return Icons.calendar_today_outlined;
      case NotifType.workout:
        return Icons.fitness_center;
      case NotifType.announcement:
        return Icons.campaign_outlined;
    }
  }

  Color get _iconBg {
    switch (notification.type) {
      case NotifType.reservation:
        return AppColors.orangeBg;
      case NotifType.workout:
        return const Color(0xFF4CAF50);
      case NotifType.announcement:
        return const Color(0xFF2196F3);
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dt.month}월 ${dt.day}일';
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : AppColors.orangeBg.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: isRead
              ? null
              : Border.all(color: AppColors.orangeBg.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이콘
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _iconBg.withValues(alpha: isRead ? 0.12 : 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, size: 20, color: _iconBg),
            ),
            const SizedBox(width: 14),
            // 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6, top: 3),
                          decoration: const BoxDecoration(
                            color: AppColors.orangeBg,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
