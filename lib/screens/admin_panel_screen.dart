import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/campus_background.dart';
import '../widgets/glass_card.dart' as glass;
import '../widgets/admin_report_card.dart';
import '../widgets/admin_post_card.dart';
import '../utils/admin_actions.dart';


class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load data after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    await Future.wait([
      adminProvider.loadReports(),
      adminProvider.loadAllPosts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check if user is admin/peninjau
        if (!authProvider.isLoggedIn || authProvider.user?.peran != 'peninjau') {
          return _buildAccessDenied();
        }

        return CampusBackgroundScaffold(
          showOverlay: true,
          overlayOpacity: 0.1,
          appBar: AppBar(
            title: const Text('Panel Admin'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(
                  icon: Icon(Icons.report),
                  text: 'Laporan',
                ),
                Tab(
                  icon: Icon(Icons.article),
                  text: 'Postingan',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildReportsTab(),
              _buildPostsTab(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccessDenied() {
    return CampusBackgroundScaffold(
      showOverlay: true,
      overlayOpacity: 0.1,
      appBar: AppBar(
        title: const Text('Panel Admin'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: glass.GlassCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.block,
                  size: 64,
                  color: AppColors.error.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 24),
                Text(
                  'Akses Ditolak',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Anda tidak memiliki izin untuk mengakses panel admin. Hanya peninjau yang dapat mengakses halaman ini.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.isLoadingReports) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (adminProvider.reportsError != null) {
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
                  'Gagal memuat laporan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  adminProvider.reportsError!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => adminProvider.loadReports(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        final reports = adminProvider.reports;

        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.report_off,
                  size: 64,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada laporan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Belum ada laporan yang perlu ditinjau',
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
          onRefresh: () => adminProvider.loadReports(),
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return AdminReportCard(
                report: report,
                adminProvider: adminProvider,
                onIgnore: (reportId) => AdminActions.handleIgnoreReport(context, reportId, adminProvider),
                onArchive: (reportId, postId) => AdminActions.handleArchivePost(context, reportId, postId, adminProvider),
                onDelete: (reportId, postId) => AdminActions.handleDeletePost(context, reportId, postId, adminProvider),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPostsTab() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.isLoadingPosts) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (adminProvider.postsError != null) {
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
                  'Gagal memuat postingan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  adminProvider.postsError!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => adminProvider.loadAllPosts(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        final posts = adminProvider.allPosts;

        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 64,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada postingan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Belum ada postingan yang tersedia',
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
          onRefresh: () => adminProvider.loadAllPosts(),
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return AdminPostCard(
                post: post,
                adminProvider: adminProvider,
                onArchive: (postId) => AdminActions.handleArchivePostOnly(context, postId, adminProvider),
                onActivate: (postId) => AdminActions.handleActivatePost(context, postId, adminProvider),
                onDelete: (postId) => AdminActions.handleDeletePostOnly(context, postId, adminProvider),
              );
            },
          ),
        );
      },
    );
  }



}
