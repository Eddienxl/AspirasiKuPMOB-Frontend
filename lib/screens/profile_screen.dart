import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/campus_background.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check if user is authenticated
        if (!authProvider.isLoggedIn) {
          return _buildLoginRequired(context);
        }

        final user = authProvider.user;

        if (user == null) {
          return _buildLoginRequired(context);
        }

        return CampusBackgroundScaffold(
          showOverlay: true,
          overlayOpacity: 0.1,
          appBar: AppBar(
            title: const Text('Profil'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile header
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          user.nama.isNotEmpty ? user.nama[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Name
                      Text(
                        user.nama,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: user.isReviewer ? AppColors.warning : AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.isReviewer ? 'Peninjau' : 'Mahasiswa',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Email
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      // NIM
                      Text(
                        'NIM: ${user.nim}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Menu items
                _buildMenuItem(
                  context,
                  icon: Icons.edit,
                  title: 'Edit Profil',
                  subtitle: 'Ubah informasi profil Anda',
                  onTap: () {
                    // Navigate to edit profile
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.lock,
                  title: 'Ubah Kata Sandi',
                  subtitle: 'Ganti kata sandi akun Anda',
                  onTap: () {
                    // Navigate to change password
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.notifications,
                  title: 'Notifikasi',
                  subtitle: 'Atur preferensi notifikasi',
                  onTap: () {
                    // Navigate to notifications settings
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.help,
                  title: 'Bantuan',
                  subtitle: 'FAQ dan panduan penggunaan',
                  onTap: () {
                    // Navigate to help
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.info,
                  title: 'Tentang Aplikasi',
                  subtitle: 'Informasi aplikasi AspirasiKu',
                  onTap: () {
                    // Show about dialog
                  },
                ),

                const SizedBox(height: 16),

                // Logout button
                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: 'Keluar',
                  subtitle: 'Keluar dari akun Anda',
                  isDestructive: true,
                  onTap: () => _showLogoutDialog(context, authProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? AppColors.error : AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? AppColors.error : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textTertiary,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
              
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRequired(BuildContext context) {
    return CampusBackgroundScaffold(
      showOverlay: true,
      overlayOpacity: 0.1,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
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
                  Icons.person_off,
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
                  'Anda perlu login terlebih dahulu untuk melihat profil.',
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
