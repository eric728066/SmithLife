import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_colors.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/signup_page.dart';
import 'presentation/pages/shell_page.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/reservation/reservation_page.dart';
import 'presentation/pages/workout/workout_page.dart';
import 'presentation/pages/workout/workout_detail_page.dart';
import 'presentation/pages/workout/routine_list_page.dart';
import 'presentation/pages/workout/routine_detail_page.dart';
import 'presentation/pages/workout/create_routine_page.dart';
import 'presentation/pages/workout/workout_summary_page.dart';
import 'presentation/pages/workout/workout_models.dart';
import 'presentation/viewmodels/workout_session_provider.dart';
import 'presentation/pages/mypage/my_page.dart';
import 'presentation/pages/mypage/usage_history_page.dart';
import 'presentation/pages/mypage/settings_page.dart';
import 'presentation/pages/mypage/inquiry_page.dart';
import 'presentation/pages/mypage/notification_page.dart';
import 'presentation/pages/workout/workout_history_page.dart';
import 'presentation/pages/workout/workout_history_detail_page.dart';
import 'presentation/viewmodels/workout_history_provider.dart';
import 'presentation/pages/admin/admin_home_page.dart';
import 'presentation/pages/admin/admin_member_list_page.dart';
import 'presentation/pages/admin/admin_member_detail_page.dart';
import 'presentation/pages/admin/admin_announcement_page.dart';
import 'presentation/pages/admin/admin_announcement_form_page.dart';
import 'data/models/admin/admin_member.dart';
import 'data/models/announcement/announcement.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final loc = state.matchedLocation;
      final isPublic = loc == '/splash' || loc == '/login' || loc == '/signup';
      if (isPublic) return null;
      final hasToken = await TokenStorage.hasToken();
      if (!hasToken) return '/login';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/usage',
        builder: (context, state) => const UsageHistoryPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/inquiry',
        builder: (context, state) => const InquiryPage(),
      ),
      GoRoute(
        path: '/notification',
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: '/workout-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return WorkoutDetailPage(
            exerciseName: extra['name'] as String? ?? '',
            muscle: extra['muscle'] as String? ?? '',
            exerciseIndex: extra['index'] as int? ?? -1,
          );
        },
      ),
      GoRoute(
        path: '/workout-summary',
        builder: (context, state) {
          final session = state.extra as WorkoutSession;
          return WorkoutSummaryPage(session: session);
        },
      ),
      GoRoute(
        path: '/routine-list',
        builder: (context, state) => const RoutineListPage(),
      ),
      GoRoute(
        path: '/routine-detail',
        builder: (context, state) {
          final routine = state.extra as RoutineData;
          return RoutineDetailPage(routine: routine);
        },
      ),
      GoRoute(
        path: '/create-routine',
        builder: (context, state) => const CreateRoutinePage(),
      ),
      GoRoute(
        path: '/workout-history',
        builder: (context, state) => const WorkoutHistoryPage(),
      ),
      GoRoute(
        path: '/workout-history-detail',
        builder: (context, state) {
          final record = state.extra as WorkoutRecord;
          return WorkoutHistoryDetailPage(record: record);
        },
      ),
      // ─── 관리자 전용 라우트 ───────────────────────────────────────────
      GoRoute(
        path: '/admin-home',
        builder: (context, state) => const AdminHomePage(),
      ),
      GoRoute(
        path: '/admin-members',
        builder: (context, state) => const AdminMemberListPage(),
      ),
      GoRoute(
        path: '/admin-member-detail',
        builder: (context, state) {
          final member = state.extra as AdminMember;
          return AdminMemberDetailPage(member: member);
        },
      ),
      GoRoute(
        path: '/admin-announcements',
        builder: (context, state) => const AdminAnnouncementPage(),
      ),
      GoRoute(
        path: '/admin-announcement-form',
        builder: (context, state) {
          final announcement = state.extra as Announcement?;
          return AdminAnnouncementFormPage(announcement: announcement);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reservation',
                builder: (context, state) => const ReservationPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/workout',
                builder: (context, state) => const WorkoutPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mypage',
                builder: (context, state) => const MyPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class SmithLifeApp extends ConsumerWidget {
  const SmithLifeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SmithLife',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.orangeBg,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.cream,
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
