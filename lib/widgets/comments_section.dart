import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/comment_provider.dart';
import '../providers/auth_provider.dart';
import 'comment_item.dart';

class CommentsSection extends StatefulWidget {
  final int postId;

  const CommentsSection({
    super.key,
    required this.postId,
  });

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    // Check authentication
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda harus login terlebih dahulu untuk berkomentar'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmittingComment = true;
    });

    final commentProvider = Provider.of<CommentProvider>(context, listen: false);
    final success = await commentProvider.createComment(
      postId: widget.postId,
      konten: _commentController.text.trim(),
    );

    setState(() {
      _isSubmittingComment = false;
    });

    if (success) {
      _commentController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Komentar berhasil ditambahkan'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        String errorMessage = 'Gagal menambahkan komentar';
        if (commentProvider.error?.contains('Session expired') == true ||
            commentProvider.error?.contains('Token') == true) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comments header
          Row(
            children: [
              const Icon(
                Icons.comment_outlined,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Komentar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Consumer<CommentProvider>(
                builder: (context, commentProvider, child) {
                  return Text(
                    '${commentProvider.comments.length} komentar',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Comment input
          _buildCommentInput(),

          const SizedBox(height: 20),

          // Comments list
          Consumer<CommentProvider>(
            builder: (context, commentProvider, child) {
              if (commentProvider.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (commentProvider.comments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Belum ada komentar. Jadilah yang pertama berkomentar!',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Column(
                children: commentProvider.comments.map((comment) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CommentItem(
                      name: comment.authorName,
                      time: comment.timeAgo,
                      comment: comment.konten,
                      isOP: comment.isAuthor,
                      authorRole: comment.authorRole,
                      profilePictureUrl: comment.profilePictureUrl,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comment text field
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: 'Tulis komentar Anda...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 3,
          maxLength: 500,
        ),

        const SizedBox(height: 12),

        // Submit button
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _isSubmittingComment ? null : _submitComment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSubmittingComment
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Kirim Komentar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
