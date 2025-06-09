import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../services/avatar_service.dart';
import '../utils/app_colors.dart';

class AvatarUploadWidget extends StatefulWidget {
  final String? currentAvatarUrl;
  final String userName;
  final Function(String?) onAvatarChanged;
  final double radius;

  const AvatarUploadWidget({
    super.key,
    this.currentAvatarUrl,
    required this.userName,
    required this.onAvatarChanged,
    this.radius = 50,
  });

  @override
  State<AvatarUploadWidget> createState() => _AvatarUploadWidgetState();
}

class _AvatarUploadWidgetState extends State<AvatarUploadWidget> {
  final AvatarService _avatarService = AvatarService();
  bool _isUploading = false;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _currentAvatarUrl = widget.currentAvatarUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Avatar display
        CircleAvatar(
          radius: widget.radius,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          backgroundImage: _currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
              ? CachedNetworkImageProvider(_currentAvatarUrl!)
              : null,
          child: _currentAvatarUrl == null || _currentAvatarUrl!.isEmpty
              ? Text(
                  widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: widget.radius * 0.6,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),

        // Upload button overlay
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _isUploading ? null : _showAvatarOptions,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isUploading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Foto Profil',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Options
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                ),
              ),
              title: const Text('Pilih dari Galeri'),
              subtitle: const Text('JPG/JPEG, maksimal 5MB'),
              onTap: () {
                Navigator.pop(context);
                _uploadAvatar();
              },
            ),

            if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: AppColors.error,
                  ),
                ),
                title: const Text('Hapus Foto'),
                subtitle: const Text('Kembali ke avatar default'),
                onTap: () {
                  Navigator.pop(context);
                  _removeAvatar();
                },
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadAvatar() async {
    try {
      setState(() {
        _isUploading = true;
      });

      // Pick image
      final XFile? imageFile = await _avatarService.pickImageFromGallery();
      if (imageFile == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      // Upload to server
      final avatarUrl = await _avatarService.uploadAvatar(imageFile);

      setState(() {
        _currentAvatarUrl = avatarUrl;
        _isUploading = false;
      });

      // Notify parent
      widget.onAvatarChanged(avatarUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diperbarui'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _removeAvatar() async {
    try {
      setState(() {
        _isUploading = true;
      });

      await _avatarService.removeAvatar();

      setState(() {
        _currentAvatarUrl = null;
        _isUploading = false;
      });

      // Notify parent
      widget.onAvatarChanged(null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil dihapus'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
