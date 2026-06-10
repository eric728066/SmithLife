import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/admin/admin_member.dart';

class AdminRepository {
  final Dio _dio = DioClient().dio;

  Future<List<AdminMember>> getMembers() async {
    final response = await _dio.get(ApiConstants.adminMembers);
    final data = DioClient.extractData(response) as List<dynamic>;
    return data.map((e) => AdminMember.fromJson(e)).toList();
  }

  Future<AdminMember> getMemberDetail(int userId) async {
    final response = await _dio.get('${ApiConstants.adminMembers}/$userId');
    return AdminMember.fromJson(DioClient.extractData(response));
  }

  Future<void> registerMembership({
    required int userId,
    required String type,
    required String startDate,
    required String endDate,
  }) async {
    await _dio.post('${ApiConstants.adminMembers}/$userId/membership', data: {
      'type': type,
      'startDate': startDate,
      'endDate': endDate,
    });
  }
}
