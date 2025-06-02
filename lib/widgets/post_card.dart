import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post_model.dart';
import '../utils/app_colors.dart';

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

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with category and author
              _buildHeader(context),

              const SizedBox(height: 12),

              // Title
              Text(
                post.judul,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: isSmallScreen ? 16 : 18,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Content preview
              Text(
                post.konten,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
                maxLines: isSmallScreen ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),

              // Footer with interactions
              if (showInteractions) _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Row(
      children: [
        // Category badge
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 12,
              vertical: isSmallScreen ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.getCategoryColor(post.idKategori).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.getCategoryColor(post.idKategori).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  post.categoryEmoji,
                  style: TextStyle(fontSize: isSmallScreen ? 10 : 12),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    post.categoryName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.getCategoryColor(post.idKategori),
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Time ago
        Text(
          timeago.format(post.dibuatPada, locale: 'id'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiary,
            fontSize: isSmallScreen ? 10 : 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Column(
      children: [
        Row(
          children: [
            // Author info
            Expanded(
              child: Row(
                children: [
                  // Author avatar
                  CircleAvatar(
                    radius: isSmallScreen ? 12 : 16,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 10 : 14,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Author name
                  Expanded(
                    child: Text(
                      post.authorName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: isSmallScreen ? 11 : 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // More options
            IconButton(
              onPressed: () => _showMoreOptions(context),
              icon: const Icon(Icons.more_vert),
              iconSize: isSmallScreen ? 16 : 20,
              color: AppColors.textTertiary,
              constraints: BoxConstraints(
                minWidth: isSmallScreen ? 24 : 32,
                minHeight: isSmallScreen ? 24 : 32,
              ),
            ),
          ],
        ),

        if (isSmallScreen) const SizedBox(height: 8),

        // Interaction buttons
        Row(
          mainAxisAlignment: isSmallScreen ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.end,
          children: [
            // Upvote button
            _buildInteractionButton(
              icon: Icons.keyboard_arrow_up,
              count: post.upvoteCount,
              isActive: post.hasUserUpvoted,
              color: AppColors.success,
              onTap: onUpvote,
              isSmallScreen: isSmallScreen,
            ),

            SizedBox(width: isSmallScreen ? 4 : 8),

            // Downvote button
            _buildInteractionButton(
              icon: Icons.keyboard_arrow_down,
              count: post.downvoteCount,
              isActive: post.hasUserDownvoted,
              color: AppColors.error,
              onTap: onDownvote,
              isSmallScreen: isSmallScreen,
            ),

            SizedBox(width: isSmallScreen ? 4 : 8),

            // Comment button
            _buildInteractionButton(
              icon: Icons.chat_bubble_outline,
              count: post.commentCount,
              isActive: false,
              color: AppColors.info,
              onTap: onComment,
              isSmallScreen: isSmallScreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required Color color,
    VoidCallback? onTap,
    bool isSmallScreen = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 6 : 8,
          vertical: isSmallScreen ? 3 : 4,
        ),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isSmallScreen ? 16 : 18,
              color: isActive ? color : AppColors.textTertiary,
            ),
            if (count > 0) ...[
              SizedBox(width: isSmallScreen ? 2 : 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  fontWeight: FontWeight.w500,
                  color: isActive ? color : AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Options
            ListTile(
              leading: const Icon(Icons.share, color: AppColors.info),
              title: const Text('Bagikan'),
              onTap: () {
                Navigator.pop(context);
                // Handle share
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.flag, color: AppColors.warning),
              title: const Text('Laporkan'),
              onTap: () {
                Navigator.pop(context);
                if (onReport != null) onReport!();
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
