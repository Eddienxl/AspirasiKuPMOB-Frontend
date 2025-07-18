import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../providers/category_provider.dart';

import '../utils/app_colors.dart';
import '../widgets/campus_background.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/post_card.dart';
import '../widgets/category_filter.dart';
import '../widgets/sort_dropdown.dart';
import '../widgets/report_dialog.dart';
import 'home_landing_screen.dart';
import 'add_post_screen.dart';
import 'profile_screen.dart';
import 'admin_panel_screen.dart';
import 'app_notification_screen.dart';
import 'post_detail_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0; // Start with Home tab
  String _selectedCategory = 'semua';
  String _selectedSort = 'terbaru';

  @override
  void initState() {
    super.initState();
    // Data will be loaded when user navigates to Dashboard tab
  }

  Future<void> _loadDashboardData() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    // Load categories first
    await categoryProvider.loadCategories();

    // Then load posts
    await postProvider.loadPosts(
      filter: _selectedCategory,
      sort: _selectedSort,
    );
  }

  Future<void> _refreshPosts() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    await postProvider.loadPosts(
      filter: _selectedCategory,
      sort: _selectedSort,
      refresh: true,
    );
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _refreshPosts();
  }

  void _onSortChanged(String sort) {
    setState(() {
      _selectedSort = sort;
    });
    _refreshPosts();
  }

  void _handleNavigation(int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if user is authenticated for restricted pages
    if (!authProvider.isLoggedIn) {
      // Allow access to Home (0) and Dashboard (1) only
      if (index == 0 || index == 1) {
        setState(() {
          _currentIndex = index;
        });
        // Load dashboard data when navigating to dashboard
        if (index == 1) {
          _loadDashboardData();
        }
        return;
      }

      // For restricted pages, redirect to login
      if (index == 2 || index == 3 || index == 4) {
        _showLoginRequiredDialog();
        return;
      }
    }

    // User is authenticated or accessing allowed pages
    setState(() {
      _currentIndex = index;
    });

    // Load dashboard data when navigating to dashboard
    if (index == 1) {
      _loadDashboardData();
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Diperlukan'),
        content: const Text(
          'Anda perlu login terlebih dahulu untuk mengakses fitur ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final showSidebar = screenWidth > 768; // Show sidebar on larger screens

    if (showSidebar) {
      // Desktop/Tablet layout with sidebar
      return CampusBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Row(
              children: [
                // Sidebar
                AppSidebar(
                  currentIndex: _currentIndex,
                  onItemTapped: _handleNavigation,
                ),

                // Main content area
                Expanded(
                  child: _buildCurrentTab(),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Mobile layout with drawer
      return Scaffold(
        appBar: AppBar(
          title: const Text('AspirasiKu'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        drawer: Drawer(
          child: AppSidebar(
            currentIndex: _currentIndex,
            onItemTapped: (index) {
              Navigator.pop(context); // Close drawer first
              _handleNavigation(index);
            },
          ),
        ),
        body: CampusBackground(
          showOverlay: true,
          overlayOpacity: 0.1,
          child: SafeArea(
            child: _buildCurrentTab(),
          ),
        ),
      );
    }
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return const HomeLandingScreen();
      case 1:
        return _buildDashboardTab();
      case 2:
        return const AddPostScreen(isEmbedded: true);
      case 3:
        return const AppNotificationScreen();
      case 4:
        return const ProfileScreen();
      case 5:
        return const AdminPanelScreen();
      default:
        return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _refreshPosts,
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),

          // Filters
          SliverToBoxAdapter(
            child: _buildFilters(),
          ),

          // Posts list
          _buildPostsSliver(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      margin: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.school,
              size: isSmallScreen ? 24 : 28,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 16),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AspirasiKu Dashboard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 18 : 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Platform aspirasi mahasiswa UIN Suska Riau',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: isSmallScreen ? 12 : 13,
                  ),
                ),
              ],
            ),
          ),

          // Action button
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _currentIndex = 2; // Navigate to Add Post
              });
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Buat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 8 : 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Kategori Section
            Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filter Kategori:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Category filter dropdown
            CategoryFilterDropdown(
              selectedCategory: _selectedCategory,
              onCategoryChanged: _onCategoryChanged,
            ),

            const SizedBox(height: 16),

            // Urutan Section
            Row(
              children: [
                Icon(
                  Icons.sort,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Urutan:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Sort dropdown
            SortDropdown(
              selectedSort: _selectedSort,
              onSortChanged: _onSortChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsSliver() {
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        // Show welcome message if no data loaded yet
        if (postProvider.posts.isEmpty && !postProvider.isLoading && postProvider.error == null) {
          return SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.dashboard_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Selamat datang di Dashboard',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Klik tombol "Buat" untuk membuat aspirasi baru',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (postProvider.isLoading && postProvider.posts.isEmpty) {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (postProvider.error != null) {
          return SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat aspirasi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    postProvider.error!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshPosts,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        if (postProvider.posts.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada aspirasi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jadilah yang pertama membuat aspirasi!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final post = postProvider.posts[index];
              return PostCard(
                post: post,
                onTap: () => _handleReadPost(post.id),
                onUpvote: () => _handleUpvote(post.id),
                onDownvote: () => _handleDownvote(post.id),
                onReport: () => _handleReport(post.id),
              );
            },
            childCount: postProvider.posts.length,
          ),
        );
      },
    );
  }

  // Handle read post with authentication check
  void _handleReadPost(int postId) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(postId: postId),
      ),
    );
  }

  // Handle upvote with authentication check
  Future<void> _handleUpvote(int postId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final success = await postProvider.toggleUpvote(postId);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(postProvider.error ?? 'Gagal memberikan upvote'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Handle downvote with authentication check
  Future<void> _handleDownvote(int postId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final success = await postProvider.toggleDownvote(postId);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(postProvider.error ?? 'Gagal memberikan downvote'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Handle report with authentication check
  Future<void> _handleReport(int postId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    // Show report dialog
    final String? reportReason = await showDialog<String>(
      context: context,
      builder: (context) => const ReportDialog(),
    );

    if (reportReason != null && mounted) {
      // Submit report
      final postProvider = Provider.of<PostProvider>(context, listen: false);

      try {
        await postProvider.reportPost(postId, reportReason);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Laporan berhasil dikirim'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengirim laporan: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
