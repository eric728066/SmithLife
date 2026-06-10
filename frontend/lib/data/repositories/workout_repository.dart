import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';

class WorkoutRepository {
  final Dio _dio = DioClient().dio;

  /// 운동 기록 목록 조회 (GET /api/workout/sessions)
  Future<List<Map<String, dynamic>>> getHistory() async {
    final response = await _dio.get(ApiConstants.workoutSessions);
    final data = DioClient.extractData(response) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  /// 운동 세션 저장 (POST /api/workout/sessions)
  Future<Map<String, dynamic>> saveSession({
    required String sessionName,
    required int totalDurationSec,
    required List<Map<String, dynamic>> exercises,
    int? routineId,
    double? totalVolumeKg,
  }) async {
    final response = await _dio.post(
      ApiConstants.workoutSessions,
      data: {
        'sessionName': sessionName,
        'totalDurationSec': totalDurationSec,
        if (routineId != null) 'routineId': routineId,
        'exercises': exercises,
        if (totalVolumeKg != null && totalVolumeKg > 0)
          'totalVolumeKgOverride': totalVolumeKg,
      },
    );
    return DioClient.extractData(response) as Map<String, dynamic>;
  }

  /// 운동 세션 삭제 (DELETE /api/workout/sessions/{id})
  Future<void> deleteSession(int sessionId) async {
    await _dio.delete('${ApiConstants.workoutSessions}/$sessionId');
  }
}
