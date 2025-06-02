import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_notification_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/campus_background.dart';
import '../models/app_notification.dart';
import 'post_detail_screen.dart';
import 'login_screen.dart';

class AppNotificationScreen extends StatefulWidget {
  const AppNotificationScreen({super.key});

  @override
  State<AppNotificationScreen> createState() => _AppNotificationScreenState();
}

class _AppNotificationScreenState extends State<AppNotificationScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final notificationProvider = Provider.of<AppNotificationProvider>(context, listen: false);
    await notificationProvider.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check if user is authenticated
        if (!authProvider.isLoggedIn) {
          return _buildLoginRequired();
        }

        return CampusBackgroundScaffold(
          showOverlay: true,
          overlayOpacity: 0.1,
          appBar: AppBar(
            title: const Text('Notifikasi'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              Consumer<AppNotificationProvider>(
                builder: (context, notificationProvider, child) {
                  if (notificationProvider.unreadCount > 0) {
                    return TextButton(
                      onPressed: () async {
                        await notificationProvider.markAllAsRead();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Semua notifikasi ditandai sudah dibaca'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Tandai Semua Dibaca',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: Consumer<AppNotificationProvider>(
            builder: (context, notificationProvider, child) {
              if (notificationProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              if (notificationProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat notifikasi',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notificationProvider.error!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadNotifications,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              final notifications = notificationProvider.notifications;

              if (notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada notifikasi',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Notifikasi akan muncul di sini ketika ada aktivitas baru',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _loadNotifications,
                color: AppColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationCard(context, notification, notificationProvider);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, 
    AppNotification notification, 
    AppNotificationProvider notificationProvider
  ) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          // Capture navigator before async operation
          final navigator = Navigator.of(context);

          // Mark as read if unread
          if (notification.isUnread) {
            await notificationProvider.markAsRead(notification.id);
          }

          // Navigate to related content if available
          if (notification.idPostingan != null && mounted) {
            navigator.push(
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(
                  postId: notification.idPostingan!,
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.tipe).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationIcon(notification.tipe),
                  color: _getNotificationColor(notification.tipe),
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and unread indicator
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.judul,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: notification.isUnread ? FontWeight.bold : FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (notification.isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Message
                    Text(
                      notification.pesan,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Time and sender info
                    Row(
                      children: [
                        Text(
                          notification.timeAgo,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                        if (notification.pengirim != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${notification.pengirim!.nama}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'reply':
        return Icons.reply;
      case 'mention':
        return Icons.alternate_email;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return AppColors.primary;
      case 'reply':
        return Colors.blue;
      case 'mention':
        return Colors.orange;
      case 'system':
        return Colors.purple;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildLoginRequired() {
    return CampusBackgroundScaffold(
      showOverlay: true,
      overlayOpacity: 0.1,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: GlassCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_off,
                  size: 64,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),

                const SizedBox(height: 24),

                Text(
                  'Login Diperlukan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  'Anda perlu login terlebih dahulu untuk melihat notifikasi.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(color: AppColors.textSecondary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Kembali'),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Login'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
