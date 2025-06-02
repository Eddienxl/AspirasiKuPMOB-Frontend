import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class LoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 56,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: (isLoading || onPressed == null)
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            foregroundColor: foregroundColor ?? Colors.white,
            disabledBackgroundColor: AppColors.disabled,
            disabledForegroundColor: AppColors.textTertiary,
            elevation: isLoading ? 0 : 2,
            shadowColor: AppColors.primary.withValues(alpha: 0.3),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      foregroundColor ?? Colors.white,
                    ),
                  ),
                )
              : child,
        ),
      ),
    );
  }
}

class LoadingIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final String? tooltip;

  const LoadingIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 48,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: isLoading ? null : onPressed,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? Colors.white,
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: AppColors.textTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    foregroundColor ?? Colors.white,
                  ),
                ),
              )
            : Icon(icon, size: size * 0.5),
      ),
    );
  }
}

class LoadingTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final Color? foregroundColor;

  const LoadingTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor ?? AppColors.primary,
        disabledForegroundColor: AppColors.textTertiary,
      ),
      child: isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      foregroundColor ?? AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                child,
              ],
            )
          : child,
    );
  }
}
