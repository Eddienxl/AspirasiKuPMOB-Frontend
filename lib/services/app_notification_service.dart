import '../models/app_notification.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AppNotificationService {
  final ApiService _apiService = ApiService();

  // Get all notifications for current user
  Future<List<AppNotification>> getAllNotifications() async {
    try {
      final response = await _apiService.get(AppConstants.notificationEndpoint);
      
      if (response['data'] != null) {
        final List<dynamic> notificationsJson = response['data'];
        return notificationsJson
            .map((json) => AppNotification.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  // Create new notification
  Future<Map<String, dynamic>> createNotification({
    required int idPenerima,
    int? idPengirim,
    int? idPostingan,
    int? idKomentar,
    required String tipe,
    required String judul,
    required String pesan,
  }) async {
    try {
      final data = {
        'id_penerima': idPenerima,
        'id_pengirim': idPengirim,
        'id_postingan': idPostingan,
        'id_komentar': idKomentar,
        'tipe': tipe,
        'judul': judul,
        'pesan': pesan,
      };

      final response = await _apiService.post(
        AppConstants.notificationEndpoint,
        data,
      );

      return {
        'success': true,
        'message': response['message'] ?? 'Notification created successfully',
        'data': response['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  // Mark notification as read
  Future<Map<String, dynamic>> markAsRead(int notificationId) async {
    try {
      final response = await _apiService.put(
        '${AppConstants.notificationEndpoint}/$notificationId/dibaca',
        {},
      );

      return {
        'success': true,
        'message': response['message'] ?? 'Notification marked as read',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  // Mark all notifications as read
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final response = await _apiService.put(
        '${AppConstants.notificationEndpoint}/semua/dibaca',
        {},
      );

      return {
        'success': true,
        'message': response['message'] ?? 'All notifications marked as read',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  // Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final notifications = await getAllNotifications();
      return notifications.where((notification) => notification.isUnread).length;
    } catch (e) {
      return 0;
    }
  }

  // Helper method to create like notification
  Future<Map<String, dynamic>> createLikeNotification({
    required int idPenerima,
    required int idPengirim,
    required int idPostingan,
    required String namaPengirim,
    required String judulPostingan,
  }) async {
    return await createNotification(
      idPenerima: idPenerima,
      idPengirim: idPengirim,
      idPostingan: idPostingan,
      tipe: 'like',
      judul: 'Aspirasi Disukai',
      pesan: '$namaPengirim menyukai aspirasi Anda: "$judulPostingan"',
    );
  }

  // Helper method to create comment notification
  Future<Map<String, dynamic>> createCommentNotification({
    required int idPenerima,
    required int idPengirim,
    required int idPostingan,
    required int idKomentar,
    required String namaPengirim,
    required String judulPostingan,
  }) async {
    return await createNotification(
      idPenerima: idPenerima,
      idPengirim: idPengirim,
      idPostingan: idPostingan,
      idKomentar: idKomentar,
      tipe: 'comment',
      judul: 'Komentar Baru',
      pesan: '$namaPengirim mengomentari aspirasi Anda: "$judulPostingan"',
    );
  }

  // Helper method to create system notification
  Future<Map<String, dynamic>> createSystemNotification({
    required int idPenerima,
    required String judul,
    required String pesan,
    int? idPostingan,
  }) async {
    return await createNotification(
      idPenerima: idPenerima,
      idPostingan: idPostingan,
      tipe: 'system',
      judul: judul,
      pesan: pesan,
    );
  }
}
