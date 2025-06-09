import '../models/report_model.dart';
import '../models/post_model.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';
import 'api_service.dart';

class AdminService {
  final ApiService _apiService = ApiService();

  // Get all reports
  Future<List<Report>> getAllReports() async {
    try {
      final response = await _apiService.get('${AppConstants.interactionEndpoint}?tipe=lapor');

      List<dynamic> reportsJson = [];

      if (response is List) {
        reportsJson = response;
      } else if (response is Map<String, dynamic>) {
        if (response['data'] != null && response['data'] is List) {
          reportsJson = response['data'] as List<dynamic>;
        } else if (response.containsKey('message') && response['message'] != null) {
          throw Exception(response['message']);
        }
      }

      return reportsJson
          .map((json) => Report.fromJson(json))
          .toList();
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      // Log error for debugging
      AppLogger.error('Admin Service Error (Reports): $errorMessage', tag: 'AdminService');

      // For CORS or network errors, return empty list
      if (errorMessage.contains('Failed to fetch') ||
          errorMessage.contains('CORS') ||
          errorMessage.contains('XMLHttpRequest')) {
        AppLogger.network('Network/CORS issue detected, returning empty reports', tag: 'AdminService');
        return [];
      }

      // For authentication errors, rethrow
      if (errorMessage.contains('Session expired') ||
          errorMessage.contains('Token') ||
          errorMessage.contains('401') ||
          errorMessage.contains('Unauthorized')) {
        throw Exception('Sesi Anda telah berakhir, silakan login kembali');
      } else if (errorMessage.contains('Connection')) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      } else {
        // For other errors, return empty list to prevent UI crashes
        return [];
      }
    }
  }

  // Get all posts (for admin management)
  Future<List<Post>> getAllPosts() async {
    try {
      // Try regular posts endpoint first since admin endpoint doesn't exist
      final response = await _apiService.get(AppConstants.postEndpoint);

      List<dynamic> postsJson = [];

      if (response is List) {
        postsJson = response;
      } else if (response is Map<String, dynamic>) {
        if (response['data'] != null && response['data'] is List) {
          postsJson = response['data'];
        } else if (response.containsKey('message') && response['message'] != null) {
          throw Exception(response['message']);
        }
      }

      return postsJson
          .map((json) => Post.fromJson(json))
          .toList();
    } catch (e) {
      if (e.toString().contains('Session expired') || e.toString().contains('Token')) {
        throw Exception('Sesi Anda telah berakhir, silakan login kembali');
      } else if (e.toString().contains('Connection')) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      } else {
        throw Exception('Gagal memuat postingan: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }
  }

  // Ignore report
  Future<bool> ignoreReport(int reportId) async {
    try {
      await _apiService.delete('${AppConstants.interactionEndpoint}/$reportId');
      return true;
    } catch (e) {
      throw Exception('Gagal mengabaikan laporan: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  // Archive post
  Future<bool> archivePost(int postId) async {
    try {
      await _apiService.post('${AppConstants.postEndpoint}/$postId/archive', {});
      return true;
    } catch (e) {
      // Provide detailed error messages based on HTTP status
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      if (errorMessage.contains('404')) {
        throw Exception('Postingan tidak ditemukan atau sudah dihapus');
      } else if (errorMessage.contains('403')) {
        throw Exception('Anda tidak memiliki izin untuk mengarsipkan postingan ini');
      } else if (errorMessage.contains('401')) {
        throw Exception('Sesi Anda telah berakhir, silakan login kembali');
      } else if (errorMessage.contains('500')) {
        throw Exception('Terjadi kesalahan server. Silakan coba lagi nanti');
      } else if (errorMessage.contains('Connection')) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda');
      } else {
        throw Exception('Gagal mengarsipkan postingan: $errorMessage');
      }
    }
  }

  // Activate post
  Future<bool> activatePost(int postId) async {
    try {
      await _apiService.post('${AppConstants.postEndpoint}/$postId/activate', {});
      return true;
    } catch (e) {
      // Provide detailed error messages
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      if (errorMessage.contains('404')) {
        throw Exception('Postingan tidak ditemukan');
      } else if (errorMessage.contains('403')) {
        throw Exception('Anda tidak memiliki izin untuk mengaktifkan postingan ini');
      } else if (errorMessage.contains('401')) {
        throw Exception('Sesi Anda telah berakhir, silakan login kembali');
      } else if (errorMessage.contains('500')) {
        throw Exception('Terjadi kesalahan server. Silakan coba lagi nanti');
      } else if (errorMessage.contains('Connection')) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda');
      } else {
        throw Exception('Gagal mengaktifkan postingan: $errorMessage');
      }
    }
  }

  // Delete post
  Future<bool> deletePost(int postId) async {
    try {
      await _apiService.delete('${AppConstants.postEndpoint}/$postId');
      return true;
    } catch (e) {
      // Provide detailed error messages
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      if (errorMessage.contains('404')) {
        throw Exception('Postingan tidak ditemukan atau sudah dihapus');
      } else if (errorMessage.contains('403')) {
        throw Exception('Anda tidak memiliki izin untuk menghapus postingan ini');
      } else if (errorMessage.contains('401')) {
        throw Exception('Sesi Anda telah berakhir, silakan login kembali');
      } else if (errorMessage.contains('ForeignKeyConstraintError') ||
                 errorMessage.contains('still referenced')) {
        throw Exception('Postingan tidak dapat dihapus karena masih memiliki komentar atau interaksi. Hapus semua komentar terlebih dahulu.');
      } else if (errorMessage.contains('500')) {
        throw Exception('Terjadi kesalahan server. Silakan coba lagi nanti');
      } else if (errorMessage.contains('Connection')) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda');
      } else {
        throw Exception('Gagal menghapus postingan: $errorMessage');
      }
    }
  }
}
