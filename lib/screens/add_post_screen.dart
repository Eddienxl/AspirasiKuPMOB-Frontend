import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../providers/category_provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/category_filter.dart';
import '../widgets/loading_button.dart';
import '../widgets/campus_background.dart';
import '../widgets/app_sidebar.dart';

import 'login_screen.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  String? _selectedCategory;
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    await categoryProvider.loadCategories();
  }

  void _handleSidebarNavigation(int index) {
    // Navigate back to dashboard with the selected index
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih kategori'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    
    final success = await postProvider.createPost(
      judul: _titleController.text.trim(),
      konten: _contentController.text.trim(),
      idKategori: int.parse(_selectedCategory!),
      anonim: _isAnonymous,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aspirasi berhasil dibuat!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Clear form
      _titleController.clear();
      _contentController.clear();
      setState(() {
        _selectedCategory = null;
        _isAnonymous = false;
      });

      // Navigate back to dashboard after successful submission
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(postProvider.error ?? 'Gagal membuat aspirasi'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check if user is authenticated
        if (!authProvider.isLoggedIn) {
          return _buildLoginRequired();
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final showSidebar = screenWidth > 768; // Show sidebar on larger screens

        if (showSidebar) {
          // Desktop/Tablet layout with sidebar
          return Scaffold(
            body: CampusBackground(
              showOverlay: true,
              overlayOpacity: 0.1,
              child: Row(
                children: [
                  // Sidebar
                  AppSidebar(
                    currentIndex: 2, // Add Post index
                    onItemTapped: (index) {
                      _handleSidebarNavigation(index);
                    },
                  ),

                  // Main content
                  Expanded(
                    child: SafeArea(
                      child: _buildAddPostContent(),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Mobile layout with drawer
          return Scaffold(
            appBar: AppBar(
              title: const Text('Buat Aspirasi'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            drawer: Drawer(
              child: AppSidebar(
                currentIndex: 2, // Add Post index
                onItemTapped: (index) {
                  Navigator.pop(context); // Close drawer
                  _handleSidebarNavigation(index);
                },
              ),
            ),
            body: CampusBackground(
              showOverlay: true,
              overlayOpacity: 0.1,
              child: SafeArea(
                child: _buildAddPostContent(),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildAddPostContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),

            const SizedBox(height: 24),

            // Title field
            Text(
              'Judul',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _titleController,
              label: '',
              hint: 'Masukkan judul aspirasi Anda',
              prefixIcon: Icons.title,
              maxLength: AppConstants.maxTitleLength,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul tidak boleh kosong';
                }
                if (value.length < 5) {
                  return 'Judul minimal 5 karakter';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Category dropdown
            Text(
              'Kategori',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            CategoryDropdown(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              hint: 'Pilih Kategori',
            ),

            const SizedBox(height: 16),

            // Content field
            Text(
              'Konten',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _contentController,
              label: '',
              hint: 'Jelaskan aspirasi atau pertanyaan\nAnda secara detail...',
              prefixIcon: Icons.description,
              maxLines: 8,
              maxLength: AppConstants.maxContentLength,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Isi aspirasi tidak boleh kosong';
                }
                if (value.length < 10) {
                  return 'Isi aspirasi minimal 10 karakter';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Anonymous option
            _buildAnonymousOption(),

            const SizedBox(height: 32),

            // Submit button
            Consumer<PostProvider>(
              builder: (context, postProvider, child) {
                return LoadingButton(
                  onPressed: _handleSubmit,
                  isLoading: postProvider.isLoading,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.send, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Kirim Aspirasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Add some bottom padding instead of footer to prevent overflow
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.edit_note,
              size: isSmallScreen ? 24 : 28,
              color: Colors.white,
            ),
          ),

          SizedBox(height: isSmallScreen ? 12 : 16),

          // Title
          Text(
            'Ajukan Aspirasi',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 20 : 24,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: isSmallScreen ? 6 : 8),

          // Subtitle
          Text(
            'Sampaikan aspirasi atau pertanyaan\nAnda',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: isSmallScreen ? 14 : 16,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnonymousOption() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            _isAnonymous ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary,
            size: 20,
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kirim sebagai Anonim',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  'Identitas Anda akan disembunyikan dari publik',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Switch(
              value: _isAnonymous,
              onChanged: (value) {
                setState(() {
                  _isAnonymous = value;
                });
              },
              activeColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRequired() {
    return CampusBackgroundScaffold(
      showOverlay: true,
      overlayOpacity: 0.1,
      appBar: AppBar(
        title: const Text('Buat Aspirasi'),
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
                  Icons.lock_outline,
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
                  'Anda perlu login terlebih dahulu untuk dapat membuat aspirasi baru.',
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
