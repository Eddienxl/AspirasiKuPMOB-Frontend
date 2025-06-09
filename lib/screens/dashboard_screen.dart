import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../providers/category_provider.dart';

import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/post_card.dart';
import '../widgets/category_filter.dart';
import '../widgets/sort_dropdown.dart';
import '../widgets/campus_background.dart';

import '../widgets/app_sidebar.dart';
import '../widgets/app_footer.dart';
import 'home_landing_screen.dart';
import 'add_post_screen.dart';
import 'post_detail_screen.dart';
import 'profile_screen.dart';
import 'admin_panel_screen.dart';
import 'app_notification_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'semua';
  String _selectedSort = 'terbaru';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh posts when returning to dashboard (e.g., after creating a post)
    if (ModalRoute.of(context)?.isCurrent == true) {
      _refreshPostsIfNeeded();
    }
  }

  void _refreshPostsIfNeeded() {
    // Always refresh to get latest posts
    print('🔄 Dashboard: Refreshing posts...');
    _refreshPosts();
  }

  Future<void> _loadInitialData() async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);

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
    
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    postProvider.loadPosts(
      filter: category,
      sort: _selectedSort,
      refresh: true,
    );
  }

  void _onSortChanged(String sort) {
    setState(() {
      _selectedSort = sort;
    });

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    postProvider.loadPosts(
      filter: _selectedCategory,
      sort: sort,
      refresh: true,
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

  void _handleNavigation(int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if user is authenticated for restricted pages
    if (!authProvider.isLoggedIn) {
      // Allow access to Home (0) and Dashboard (1) only
      if (index == 0 || index == 1) {
        setState(() {
          _currentIndex = index;
        });
        return;
      }

      // For restricted pages (2: Ajukan, 3: Notifikasi, 4: Profil), redirect to login
      if (index == 2 || index == 3 || index == 4) {
        _showLoginRequiredDialog();
        return;
      }
    }

    // User is authenticated or accessing allowed pages
    setState(() {
      _currentIndex = index;
    });
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
      return CampusBackgroundScaffold(
        showOverlay: true,
        overlayOpacity: 0.1,
        body: Row(
          children: [
            // Sidebar
            AppSidebar(
              currentIndex: _currentIndex,
              onItemTapped: (index) {
                _handleNavigation(index);
              },
            ),

            // Main content
            Expanded(
              child: SafeArea(
                child: _buildBody(),
              ),
            ),
          ],
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
            child: _buildBody(),
          ),
        ),

      );
    }
  }

  Widget _buildBody() {
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
          // Header as sliver
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),

          // Filters as sliver
          SliverToBoxAdapter(
            child: _buildFilters(),
          ),

          // Posts list as sliver
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
          // Icon graduation cap
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
                // Welcome text
                Text(
                  'AspirasiKu Dashboard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 18 : 20,
                  ),
                ),

                const SizedBox(height: 4),

                // Subtitle
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
              textStyle: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                fontWeight: FontWeight.w600,
              ),
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

            const SizedBox(height: 16),

            // Filter aktif badges
            Row(
              children: [
                Text(
                  'Filter aktif:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),

                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _getCategoryDisplayName(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Sort badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _getSortDisplayName(),
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsSliver() {
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        if (postProvider.isLoading && postProvider.posts.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
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
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada aspirasi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jadilah yang pertama untuk berbagi aspirasi!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 2; // Navigate to Add Post
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Buat Aspirasi'),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == postProvider.posts.length) {
                // Footer
                return Container(
                  margin: const EdgeInsets.only(top: 16, bottom: 16),
                  child: const CompactFooter(),
                );
              }

              final post = postProvider.posts[index];
              return PostCard(
                post: post,
                onTap: () => _handleReadPost(post.id),
                onUpvote: () => _handleUpvote(post.id),
                onDownvote: () => _handleDownvote(post.id),
                onComment: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(postId: post.id),
                    ),
                  );
                },
                onReport: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(postId: post.id),
                    ),
                  );
                },
              );
            },
            childCount: postProvider.posts.length + 1, // +1 for footer
          ),
        );
      },
    );
  }







  String _getCategoryDisplayName() {
    if (_selectedCategory == 'semua') {
      return 'Semua Kategori';
    }

    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final id = int.parse(_selectedCategory);
    final category = categoryProvider.getCategoryById(id);
    return category?.nama ?? AppConstants.getCategoryName(id);
  }

  String _getSortDisplayName() {
    switch (_selectedSort) {
      case 'terbaru':
        return 'Terbaru';
      case 'terlama':
        return 'Terlama';
      case 'terpopuler':
        return 'Terpopuler';
      default:
        return 'Terbaru';
    }
  }


}
