import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../services/app_notification_service.dart';

class AppNotificationProvider with ChangeNotifier {
  final AppNotificationService _notificationService = AppNotificationService();

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  // Getters
  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;
  
  List<AppNotification> get unreadNotifications => 
      _notifications.where((notification) => notification.isUnread).toList();

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Load all notifications
  Future<void> loadNotifications({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _setLoading(true);
    _clearError();

    try {
      final notifications = await _notificationService.getAllNotifications();
      _notifications = notifications;
      _updateUnreadCount();
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      // Provide user-friendly error messages
      if (errorMessage.contains('Session expired') || errorMessage.contains('Token')) {
        _setError('Sesi Anda telah berakhir, silakan login kembali');
      } else if (errorMessage.contains('Connection') || errorMessage.contains('network')) {
        _setError('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      } else if (errorMessage.contains('404')) {
        _setError('Layanan notifikasi tidak tersedia saat ini');
      } else if (errorMessage.contains('500')) {
        _setError('Terjadi kesalahan pada server. Silakan coba lagi nanti.');
      } else {
        _setError(errorMessage.isEmpty ? 'Gagal memuat notifikasi' : errorMessage);
      }
    } finally {
      _setLoading(false);
    }
  }

  // Create new notification
  Future<bool> createNotification({
    required int idPenerima,
    int? idPengirim,
    int? idPostingan,
    int? idKomentar,
    required String tipe,
    required String judul,
    required String pesan,
  }) async {
    _clearError();

    try {
      final result = await _notificationService.createNotification(
        idPenerima: idPenerima,
        idPengirim: idPengirim,
        idPostingan: idPostingan,
        idKomentar: idKomentar,
        tipe: tipe,
        judul: judul,
        pesan: pesan,
      );

      if (result['success'] == true) {
        // Refresh notifications after creating new one
        await loadNotifications(refresh: true);
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to create notification');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(int notificationId) async {
    _clearError();

    try {
      final result = await _notificationService.markAsRead(notificationId);

      if (result['success'] == true) {
        // Update local notification
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final updatedNotification = AppNotification(
            id: _notifications[index].id,
            idPenerima: _notifications[index].idPenerima,
            idPengirim: _notifications[index].idPengirim,
            idPostingan: _notifications[index].idPostingan,
            idKomentar: _notifications[index].idKomentar,
            tipe: _notifications[index].tipe,
            judul: _notifications[index].judul,
            pesan: _notifications[index].pesan,
            dibaca: true, // Mark as read
            dibuatPada: _notifications[index].dibuatPada,
            pengirim: _notifications[index].pengirim,
            postingan: _notifications[index].postingan,
            komentar: _notifications[index].komentar,
          );
          
          _notifications[index] = updatedNotification;
          _updateUnreadCount();
          notifyListeners();
        }
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to mark notification as read');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    _clearError();

    try {
      final result = await _notificationService.markAllAsRead();

      if (result['success'] == true) {
        // Update all local notifications
        _notifications = _notifications.map((notification) {
          return AppNotification(
            id: notification.id,
            idPenerima: notification.idPenerima,
            idPengirim: notification.idPengirim,
            idPostingan: notification.idPostingan,
            idKomentar: notification.idKomentar,
            tipe: notification.tipe,
            judul: notification.judul,
            pesan: notification.pesan,
            dibaca: true, // Mark all as read
            dibuatPada: notification.dibuatPada,
            pengirim: notification.pengirim,
            postingan: notification.postingan,
            komentar: notification.komentar,
          );
        }).toList();
        
        _updateUnreadCount();
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to mark all notifications as read');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update unread count
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((notification) => notification.isUnread).length;
  }

  // Get notifications by type
  List<AppNotification> getNotificationsByType(String type) {
    return _notifications.where((notification) => notification.tipe == type).toList();
  }

  // Clear all notifications (local only)
  void clearNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  // Helper methods for specific notification types
  Future<bool> createLikeNotification({
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

  Future<bool> createCommentNotification({
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
}
