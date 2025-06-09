import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class RoleBadge extends StatelessWidget {
  final String? userRole;
  final double fontSize;
  final EdgeInsets padding;
  final bool showIcon;

  const RoleBadge({
    super.key,
    required this.userRole,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    // Only show badge for "peninjau" role
    if (userRole != 'peninjau') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.verified,
              size: fontSize + 2,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            'PENINJAU',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Alternative compact badge for smaller spaces
class CompactRoleBadge extends StatelessWidget {
  final String? userRole;
  final double size;

  const CompactRoleBadge({
    super.key,
    required this.userRole,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    // Only show badge for "peninjau" role
    if (userRole != 'peninjau') {
      return const SizedBox.shrink();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        Icons.verified,
        size: size * 0.7,
        color: Colors.white,
      ),
    );
  }
}

// Badge with tooltip for better UX
class TooltipRoleBadge extends StatelessWidget {
  final String? userRole;
  final double fontSize;
  final EdgeInsets padding;

  const TooltipRoleBadge({
    super.key,
    required this.userRole,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  });

  @override
  Widget build(BuildContext context) {
    // Only show badge for "peninjau" role
    if (userRole != 'peninjau') {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: 'Peninjau - Staf yang bertugas meninjau dan mengelola aspirasi',
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      child: RoleBadge(
        userRole: userRole,
        fontSize: fontSize,
        padding: padding,
      ),
    );
  }
}
