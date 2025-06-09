import 'package:flutter/material.dart';
import '../providers/admin_provider.dart';
import '../utils/app_colors.dart';

class AdminActions {
  static Future<void> handleIgnoreReport(
    BuildContext context,
    int reportId,
    AdminProvider adminProvider,
  ) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abaikan Laporan'),
        content: const Text('Apakah Anda yakin ingin mengabaikan laporan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Abaikan'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await adminProvider.ignoreReport(reportId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
                ? 'Laporan berhasil diabaikan' 
                : adminProvider.reportsError ?? 'Gagal mengabaikan laporan'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  static Future<void> handleArchivePost(
    BuildContext context,
    int reportId,
    int postId,
    AdminProvider adminProvider,
  ) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arsipkan Postingan'),
        content: const Text('Apakah Anda yakin ingin mengarsipkan postingan ini? Postingan akan disembunyikan dari publik.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Arsipkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Mengarsipkan postingan...'),
            ],
          ),
        ),
      );

      try {
        final success = await adminProvider.archivePostFromReport(reportId, postId);

        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? '✅ Postingan berhasil diarsipkan'
                  : '❌ ${adminProvider.reportsError ?? 'Gagal mengarsipkan postingan'}'),
              backgroundColor: success ? AppColors.success : AppColors.error,
              duration: Duration(seconds: success ? 3 : 4),
              action: !success ? SnackBarAction(
                label: 'Coba Lagi',
                textColor: Colors.white,
                onPressed: () => handleArchivePost(context, reportId, postId, adminProvider),
              ) : null,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: ${e.toString()}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  static Future<void> handleDeletePost(
    BuildContext context,
    int reportId,
    int postId,
    AdminProvider adminProvider,
  ) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Postingan'),
        content: const Text('Apakah Anda yakin ingin menghapus postingan ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Menghapus postingan...'),
            ],
          ),
        ),
      );

      try {
        final success = await adminProvider.deletePostFromReport(reportId, postId);

        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? '✅ Postingan berhasil dihapus'
                  : '❌ ${adminProvider.reportsError ?? 'Gagal menghapus postingan'}'),
              backgroundColor: success ? AppColors.success : AppColors.error,
              duration: Duration(seconds: success ? 3 : 4),
              action: !success ? SnackBarAction(
                label: 'Coba Lagi',
                textColor: Colors.white,
                onPressed: () => handleDeletePost(context, reportId, postId, adminProvider),
              ) : null,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: ${e.toString()}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  static Future<void> handleArchivePostOnly(
    BuildContext context,
    int postId,
    AdminProvider adminProvider,
  ) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arsipkan Postingan'),
        content: const Text('Apakah Anda yakin ingin mengarsipkan postingan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Arsipkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Mengarsipkan postingan...'),
            ],
          ),
        ),
      );

      try {
        final success = await adminProvider.archivePost(postId);

        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? '✅ Postingan berhasil diarsipkan'
                  : '❌ ${adminProvider.postsError ?? 'Gagal mengarsipkan postingan'}'),
              backgroundColor: success ? AppColors.success : AppColors.error,
              duration: Duration(seconds: success ? 3 : 4),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: ${e.toString()}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  static Future<void> handleActivatePost(
    BuildContext context,
    int postId,
    AdminProvider adminProvider,
  ) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aktifkan Postingan'),
        content: const Text('Apakah Anda yakin ingin mengaktifkan postingan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Aktifkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await adminProvider.activatePost(postId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
                ? 'Postingan berhasil diaktifkan' 
                : adminProvider.postsError ?? 'Gagal mengaktifkan postingan'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  static Future<void> handleDeletePostOnly(
    BuildContext context,
    int postId,
    AdminProvider adminProvider,
  ) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Postingan'),
        content: const Text('Apakah Anda yakin ingin menghapus postingan ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Menghapus postingan...'),
            ],
          ),
        ),
      );

      try {
        final success = await adminProvider.deletePost(postId);

        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? '✅ Postingan berhasil dihapus'
                  : '❌ ${adminProvider.postsError ?? 'Gagal menghapus postingan'}'),
              backgroundColor: success ? AppColors.success : AppColors.error,
              duration: Duration(seconds: success ? 3 : 4),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: ${e.toString()}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }
}
