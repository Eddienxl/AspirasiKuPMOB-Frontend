import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../providers/post_provider.dart';
import '../providers/comment_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/post_detail_card.dart';
import '../widgets/comments_section.dart';
import '../widgets/report_dialog.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Post? _post;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPostDetail();
      _loadComments();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadPostDetail() async {
    try {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final post = await postProvider.getPostById(widget.postId);

      setState(() {
        _post = post;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat detail postingan: $e')),
        );
      }
    }
  }

  Future<void> _loadComments() async {
    final commentProvider = Provider.of<CommentProvider>(context, listen: false);
    await commentProvider.loadComments(widget.postId);
  }



  Future<void> _handleUpvote() async {
    if (_post == null) return;

    // Check authentication
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda harus login terlebih dahulu untuk memberikan upvote'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final postProvider = Provider.of<PostProvider>(context, listen: false);

    // Store current state for optimistic update
    final wasUpvoted = _post!.hasUserUpvoted;
    final wasDownvoted = _post!.hasUserDownvoted;
    final currentUpvotes = _post!.upvoteCount;
    final currentDownvotes = _post!.downvoteCount;

    // Optimistic update
    setState(() {
      if (wasUpvoted) {
        // Remove upvote
        _post = _post!.copyWith(
          userInteraction: null,
          upvoteCount: currentUpvotes - 1,
        );
      } else {
        // Add upvote (and remove downvote if exists)
        _post = _post!.copyWith(
          userInteraction: 'upvote',
          upvoteCount: currentUpvotes + 1,
          downvoteCount: wasDownvoted ? currentDownvotes - 1 : currentDownvotes,
        );
      }
    });

    final success = await postProvider.toggleUpvote(_post!.id);

    if (success) {
      // Refresh with actual data from server
      final updatedPost = await postProvider.getPostById(widget.postId);
      if (mounted) {
        setState(() {
          _post = updatedPost;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(wasUpvoted ? 'Upvote dibatalkan' : 'Upvote berhasil!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Revert optimistic update on failure
      if (mounted) {
        setState(() {
          String? originalInteraction;
          if (wasUpvoted) originalInteraction = 'upvote';
          if (wasDownvoted) originalInteraction = 'downvote';

          _post = _post!.copyWith(
            userInteraction: originalInteraction,
            upvoteCount: currentUpvotes,
            downvoteCount: currentDownvotes,
          );
        });

        String errorMessage = 'Gagal memberikan upvote';
        if (postProvider.error?.contains('Session expired') == true ||
            postProvider.error?.contains('Token') == true) {
          errorMessage = 'Sesi Anda telah berakhir, silakan login kembali';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDownvote() async {
    if (_post == null) return;

    // Check authentication
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda harus login terlebih dahulu untuk memberikan downvote'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final postProvider = Provider.of<PostProvider>(context, listen: false);

    // Store current state for optimistic update
    final wasUpvoted = _post!.hasUserUpvoted;
    final wasDownvoted = _post!.hasUserDownvoted;
    final currentUpvotes = _post!.upvoteCount;
    final currentDownvotes = _post!.downvoteCount;

    // Optimistic update
    setState(() {
      if (wasDownvoted) {
        // Remove downvote
        _post = _post!.copyWith(
          userInteraction: null,
          downvoteCount: currentDownvotes - 1,
        );
      } else {
        // Add downvote (and remove upvote if exists)
        _post = _post!.copyWith(
          userInteraction: 'downvote',
          downvoteCount: currentDownvotes + 1,
          upvoteCount: wasUpvoted ? currentUpvotes - 1 : currentUpvotes,
        );
      }
    });

    final success = await postProvider.toggleDownvote(_post!.id);

    if (success) {
      // Refresh with actual data from server
      final updatedPost = await postProvider.getPostById(widget.postId);
      if (mounted) {
        setState(() {
          _post = updatedPost;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(wasDownvoted ? 'Downvote dibatalkan' : 'Downvote berhasil!'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Revert optimistic update on failure
      if (mounted) {
        setState(() {
          String? originalInteraction;
          if (wasUpvoted) originalInteraction = 'upvote';
          if (wasDownvoted) originalInteraction = 'downvote';

          _post = _post!.copyWith(
            userInteraction: originalInteraction,
            upvoteCount: currentUpvotes,
            downvoteCount: currentDownvotes,
          );
        });

        String errorMessage = 'Gagal memberikan downvote';
        if (postProvider.error?.contains('Session expired') == true ||
            postProvider.error?.contains('Token') == true) {
          errorMessage = 'Sesi Anda telah berakhir, silakan login kembali';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleReport() async {
    // Check authentication
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda harus login terlebih dahulu untuk melaporkan postingan'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => const ReportDialog(),
    );

    if (result != null && result.isNotEmpty && mounted) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final success = await postProvider.reportPost(_post!.id, result);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Laporan berhasil dikirim. Terima kasih atas laporan Anda.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          String errorMessage = 'Gagal mengirim laporan';
          if (postProvider.error?.contains('Session expired') == true ||
              postProvider.error?.contains('Token') == true) {
            errorMessage = 'Sesi Anda telah berakhir, silakan login kembali';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A7C59),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _post == null
                ? const Center(
                    child: Text(
                      'Postingan tidak ditemukan',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Back button
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Detail Aspirasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),

          const SizedBox(height: 16),

          // Post Detail Card
          PostDetailCard(
            post: _post!,
            onUpvote: _handleUpvote,
            onDownvote: _handleDownvote,
            onReport: _handleReport,
          ),

          const SizedBox(height: 16),

          // Comments Section
          CommentsSection(postId: widget.postId),
        ],
      ),
    );
  }








}
