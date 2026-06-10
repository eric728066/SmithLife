import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/user/user_profile.dart';
import '../models/membership/membership.dart';

class UserRepository {
  final Dio _dio = DioClient().dio;

  Future<UserProfile> getMyProfile() async {
    final response = await _dio.get(ApiConstants.myProfile);
    return UserProfile.fromJson(DioClient.extractData(response));
  }

  Future<Membership?> getActiveMembership() async {
    try {
      final response = await _dio.get(ApiConstants.activeMembership);
      final data = DioClient.extractData(response);
      if (data == null) return null;
      return Membership.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<int> getAttendanceRate() async {
    try {
      final response = await _dio.get(ApiConstants.attendanceRate);
      final data = DioClient.extractData(response);
      return (data as num).toInt();
    } catch (_) {
      return 0;
    }
  }
}
