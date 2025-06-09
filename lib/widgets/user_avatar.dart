import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? profilePictureUrl;
  final String userName;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const UserAvatar({
    super.key,
    this.profilePictureUrl,
    required this.userName,
    this.radius = 20,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.primary.withValues(alpha: 0.1);
    final effectiveTextColor = textColor ?? AppColors.primary;
    final effectiveFontSize = fontSize ?? radius * 0.6;

    return CircleAvatar(
      radius: radius,
      backgroundColor: effectiveBackgroundColor,
      child: profilePictureUrl != null && profilePictureUrl!.isNotEmpty
          ? ClipOval(
              child: profilePictureUrl!.startsWith('data:image/')
                  ? Image.memory(
                      base64Decode(profilePictureUrl!.split(',')[1]),
                      width: radius * 2,
                      height: radius * 2,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: effectiveFontSize,
                            fontWeight: FontWeight.bold,
                            color: effectiveTextColor,
                          ),
                        );
                      },
                    )
                  : CachedNetworkImage(
                      imageUrl: profilePictureUrl!,
                      width: radius * 2,
                      height: radius * 2,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                      ),
                      errorWidget: (context, url, error) => Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: effectiveFontSize,
                          fontWeight: FontWeight.bold,
                          color: effectiveTextColor,
                        ),
                      ),
                    ),
            )
          : Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: effectiveFontSize,
                fontWeight: FontWeight.bold,
                color: effectiveTextColor,
              ),
            ),
    );
  }
}

// Compact version for smaller spaces
class CompactUserAvatar extends StatelessWidget {
  final String? profilePictureUrl;
  final String userName;
  final double size;

  const CompactUserAvatar({
    super.key,
    this.profilePictureUrl,
    required this.userName,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return UserAvatar(
      profilePictureUrl: profilePictureUrl,
      userName: userName,
      radius: size / 2,
      fontSize: size * 0.4,
    );
  }
}

// Avatar with loading state
class LoadingUserAvatar extends StatelessWidget {
  final String? profilePictureUrl;
  final String userName;
  final double radius;
  final bool isLoading;

  const LoadingUserAvatar({
    super.key,
    this.profilePictureUrl,
    required this.userName,
    this.radius = 20,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: SizedBox(
          width: radius,
          height: radius,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    return UserAvatar(
      profilePictureUrl: profilePictureUrl,
      userName: userName,
      radius: radius,
    );
  }
}

// Avatar with error handling
class SafeUserAvatar extends StatelessWidget {
  final String? profilePictureUrl;
  final String userName;
  final double radius;

  const SafeUserAvatar({
    super.key,
    this.profilePictureUrl,
    required this.userName,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: profilePictureUrl != null && profilePictureUrl!.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: profilePictureUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: radius * 2,
                  height: radius * 2,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: Center(
                    child: SizedBox(
                      width: radius * 0.6,
                      height: radius * 0.6,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: radius * 0.6,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          : Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: radius * 0.6,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
    );
  }
}
