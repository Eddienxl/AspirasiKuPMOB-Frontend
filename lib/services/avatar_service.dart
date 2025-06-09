import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class AvatarService {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery with validation
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Validate file type
      if (!_isValidImageType(image.name)) {
        throw Exception('Format file tidak didukung. Hanya JPG/JPEG yang diperbolehkan.');
      }

      // Validate file size (5MB max)
      final bytes = await image.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        throw Exception('Ukuran file terlalu besar. Maksimal 5MB.');
      }

      return image;
    } catch (e) {
      throw Exception('Gagal memilih gambar: ${e.toString()}');
    }
  }

  /// Upload avatar to server
  Future<String> uploadAvatar(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      // Get file extension
      final extension = imageFile.name.split('.').last.toLowerCase();
      final mimeType = 'image/$extension';
      
      // Create data URL format
      final dataUrl = 'data:$mimeType;base64,$base64Image';

      final response = await _apiService.put(
        '${AppConstants.userEndpoint}/profile-picture',
        {
          'profile_picture': dataUrl,
        },
      );

      // Extract the profile picture URL from response
      if (response is Map<String, dynamic> && 
          response['user'] != null && 
          response['user']['profile_picture'] != null) {
        return response['user']['profile_picture'];
      }

      throw Exception('Response tidak valid dari server');
    } catch (e) {
      throw Exception('Gagal mengupload avatar: ${e.toString()}');
    }
  }

  /// Remove avatar from server
  Future<bool> removeAvatar() async {
    try {
      await _apiService.put(
        '${AppConstants.userEndpoint}/profile-picture',
        {
          'profile_picture': null,
        },
      );
      return true;
    } catch (e) {
      throw Exception('Gagal menghapus avatar: ${e.toString()}');
    }
  }

  /// Validate image type
  bool _isValidImageType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg'].contains(extension);
  }

  /// Compress image if needed (for web)
  Future<Uint8List> _compressImage(Uint8List bytes) async {
    // For web, we can implement image compression here if needed
    // For now, we'll rely on the picker's built-in compression
    return bytes;
  }

  /// Get image size info
  Future<Map<String, dynamic>> getImageInfo(XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return {
      'size': bytes.length,
      'sizeFormatted': _formatFileSize(bytes.length),
      'name': imageFile.name,
      'type': imageFile.mimeType ?? 'unknown',
    };
  }

  /// Format file size for display
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
