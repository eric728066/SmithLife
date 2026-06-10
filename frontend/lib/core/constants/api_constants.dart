class ApiConstants {
  // static const String baseUrl = 'http://10.0.2.2:8080'; // Android 에뮬레이터 전용 (adb reverse 없이)
  // static const String baseUrl = 'http://192.168.100.64:8080'; // PC LAN IP
  static const String baseUrl = 'http://172.30.1.98:8080'; // Mac LAN IP

  // Auth
  static const String signup = '/api/auth/signup';
  static const String login = '/api/auth/login';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String checkEmail = '/api/auth/check-email';
  static const String findEmail = '/api/auth/find-email';
  static const String requestPasswordReset = '/api/auth/request-password-reset';
  static const String resetPassword = '/api/auth/reset-password';

  // User
  static const String myProfile = '/api/users/me';
  static const String changePassword = '/api/users/me/password';

  // Membership
  static const String activeMembership = '/api/membership/active';
  static const String membershipHistory = '/api/membership/history';

  // QR / Attendance
  static const String generateQr = '/api/qr/generate';
  static const String checkIn = '/api/attendance/checkin';
  static const String checkOut = '/api/attendance/checkout';
  static const String attendanceHistory = '/api/attendance/history';
  static const String attendanceRate = '/api/attendance/rate';

  // Reservation
  static const String timeSlots = '/api/timeslots';
  static const String reservations = '/api/reservations';
  static const String myReservations = '/api/reservations/my';
  static const String nextReservation = '/api/reservations/next';
  static const String reservationHistory = '/api/reservations/history';
  static const String facilityCongestion = '/api/facility/congestion';

  // Session
  static const String sessionStart = '/api/sessions/start';
  static const String sessionActive = '/api/sessions/active';
  static const String sessions = '/api/sessions';

  // Workout
  static const String workoutSessions = '/api/workout/sessions';

  // Exercise
  static const String exercises = '/api/exercises';
  static const String personalRecords = '/api/personal-records';

  // Routine
  static const String routines = '/api/routines';
  static const String myRoutines = '/api/routines/my';
  static const String favoriteRoutines = '/api/routines/favorites';

  // Notice
  static const String announcements = '/api/announcements';
  static const String faq = '/api/faq';

  // Admin
  static const String adminMembers = '/api/admin/members';
  static const String adminAnnouncements = '/api/admin/announcements';

  // Inquiry
  static const String inquiries = '/api/inquiries';
  static const String myInquiries = '/api/inquiries/my';

  // Notification
  static const String notifications = '/api/notifications';
  static const String unreadCount = '/api/notifications/unread-count';

  // Report
  static const String reports = '/api/reports';
  static const String weeklyStats = '/api/reports/weekly';
}
