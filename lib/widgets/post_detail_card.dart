import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../widgets/role_badge.dart';
import '../widgets/user_avatar.dart';

class PostDetailCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onReport;

  const PostDetailCard({
    super.key,
    required this.post,
    this.onUpvote,
    this.onDownvote,
    this.onReport,
  });

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
          // Title
          Text(
            post.judul,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          // Category badge
          _buildCategoryBadge(),

          const SizedBox(height: 16),

          // Author info
          _buildAuthorInfo(),

          const SizedBox(height: 16),

          // Content
          Text(
            post.konten,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // Divider
          Container(
            height: 1,
            color: Colors.grey.withValues(alpha: 0.3),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              _buildActionButton(
                icon: Icons.thumb_up_outlined,
                count: post.upvoteCount,
                isActive: post.hasUserUpvoted,
                activeColor: const Color(0xFF4CAF50),
                onTap: onUpvote,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.thumb_down_outlined,
                count: post.downvoteCount,
                isActive: post.hasUserDownvoted,
                activeColor: const Color(0xFFF44336),
                onTap: onDownvote,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.flag_outlined,
                count: 0,
                isActive: false,
                activeColor: const Color(0xFFFF9800),
                onTap: onReport,
                showCount: false,
                label: 'Laporkan',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black26),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            post.categoryEmoji,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 6),
          Text(
            post.categoryName,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorInfo() {
    return Row(
      children: [
        UserAvatar(
          profilePictureUrl: post.penulis?.profilePicture,
          userName: post.authorName,
          radius: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      post.authorName,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Role badge for peninjau
                  RoleBadge(
                    userRole: post.penulis?.peran,
                    fontSize: 9,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                post.timeAgo,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required Color activeColor,
    VoidCallback? onTap,
    bool showCount = true,
    String? label,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? activeColor.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? activeColor : Colors.black54,
            ),
            if (showCount && count > 0) ...[
              const SizedBox(width: 6),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? activeColor : Colors.black54,
                ),
              ),
            ],
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? activeColor : Colors.black54,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
