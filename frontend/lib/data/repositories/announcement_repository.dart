import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/announcement/announcement.dart';

class AnnouncementRepository {
  final Dio _dio = DioClient().dio;

  Future<List<Announcement>> getAnnouncements() async {
    final response = await _dio.get(ApiConstants.announcements);
    final data = DioClient.extractData(response) as List<dynamic>;
    return data.map((e) => Announcement.fromJson(e)).toList();
  }

  Future<Announcement> createAnnouncement({
    required String title,
    required String content,
    required String tag,
    String? imageUrl,
  }) async {
    final response = await _dio.post(ApiConstants.adminAnnouncements, data: {
      'title': title,
      'content': content,
      'tag': tag,
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
    return Announcement.fromJson(DioClient.extractData(response));
  }

  Future<Announcement> updateAnnouncement({
    required int id,
    required String title,
    required String content,
    required String tag,
    String? imageUrl,
  }) async {
    final response = await _dio.put('${ApiConstants.adminAnnouncements}/$id', data: {
      'title': title,
      'content': content,
      'tag': tag,
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
    return Announcement.fromJson(DioClient.extractData(response));
  }

  Future<void> deleteAnnouncement(int id) async {
    await _dio.delete('${ApiConstants.adminAnnouncements}/$id');
  }
}
