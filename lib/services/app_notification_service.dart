import '../models/app_notification.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AppNotificationService {
  final ApiService _apiService = ApiService();

  // Get all notifications for current user
  Future<List<AppNotification>> getAllNotifications() async {
    try {
      final response = await _apiService.get(AppConstants.notificationEndpoint);

      // Handle different response formats
      List<dynamic> notificationsJson = [];

      if (response is List) {
        // Direct array response
        notificationsJson = response as List<dynamic>;
      } else if (response is Map<String, dynamic>) {
        // Check for various possible response structures
        if (response['data'] != null) {
          if (response['data'] is List) {
            notificationsJson = response['data'] as List<dynamic>;
          } else if (response['data'] is String && response['data'] == '[]') {
            // Handle empty string array
            notificationsJson = [];
          }
        } else if (response['notifikasi'] != null && response['notifikasi'] is List) {
          notificationsJson = response['notifikasi'] as List<dynamic>;
        } else if (response.containsKey('message') && response['message'] != null) {
          // Handle error response
          throw Exception(response['message']);
        } else {
          // If response is a map but doesn't contain expected keys, treat as empty
          notificationsJson = [];
        }
      } else {
        // Unexpected response format
        notificationsJson = [];
      }

      return notificationsJson
          .map((json) => AppNotification.fromJson(json))
          .toList();
    } catch (e) {
      // Provide more specific error messages
      if (e.toString().contains('Session expired') || e.toString().contains('Token')) {
        throw Exception('Sesi Anda telah berakhir, silakan login kembali');
      } else if (e.toString().contains('Connection')) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      } else {
        throw Exception('Gagal memuat notifikasi: ${e.toString().replaceAll('Exception: ', '')}');
      }
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
