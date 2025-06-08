import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onComment;
  final VoidCallback? onReport;
  final bool showInteractions;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onUpvote,
    this.onDownvote,
    this.onComment,
    this.onReport,
    this.showInteractions = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              post.judul,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: isSmallScreen ? 18 : 20,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Category badge
            _buildCategoryBadge(context),

            const SizedBox(height: 12),

            // Author info
            _buildAuthorInfo(context),

            const SizedBox(height: 12),

            // Content preview
            Text(
              post.konten,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
                height: 1.5,
                fontSize: isSmallScreen ? 14 : 15,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            // Footer with interactions
            if (showInteractions) _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black26,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            post.categoryEmoji,
            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
          ),
          const SizedBox(width: 6),
          Text(
            post.categoryName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: isSmallScreen ? 13 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorInfo(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Row(
      children: [
        // Author avatar
        CircleAvatar(
          radius: isSmallScreen ? 16 : 18,
          backgroundColor: const Color(0xFF4CAF50),
          child: Text(
            post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Author name and time
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 14 : 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                timeago.format(post.dibuatPada, locale: 'id'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                  fontSize: isSmallScreen ? 12 : 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Row(
      children: [
        // Upvote button
        _buildActionButton(
          icon: Icons.thumb_up_outlined,
          count: post.upvoteCount,
          isActive: post.hasUserUpvoted,
          activeColor: const Color(0xFF4CAF50),
          onTap: onUpvote,
          isSmallScreen: isSmallScreen,
        ),

        const SizedBox(width: 8),

        // Downvote button
        _buildActionButton(
          icon: Icons.thumb_down_outlined,
          count: post.downvoteCount,
          isActive: post.hasUserDownvoted,
          activeColor: const Color(0xFFF44336),
          onTap: onDownvote,
          isSmallScreen: isSmallScreen,
        ),

        const SizedBox(width: 8),

        // Report button
        _buildActionButton(
          icon: Icons.flag_outlined,
          count: 0,
          isActive: false,
          activeColor: const Color(0xFFFF9800),
          onTap: onReport,
          isSmallScreen: isSmallScreen,
          showCount: false,
        ),

        const Spacer(),

        // Read button
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 20,
              vertical: isSmallScreen ? 8 : 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: Text(
            'Baca',
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w600,
            ),
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
    bool isSmallScreen = false,
    bool showCount = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 10,
          vertical: isSmallScreen ? 6 : 8,
        ),
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
              size: isSmallScreen ? 16 : 18,
              color: isActive ? activeColor : Colors.black54,
            ),
            if (showCount && count > 0) ...[
              SizedBox(width: isSmallScreen ? 4 : 6),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 13,
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
