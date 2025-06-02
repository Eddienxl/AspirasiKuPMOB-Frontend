import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CampusBackground extends StatelessWidget {
  final Widget child;
  final bool showOverlay;
  final double overlayOpacity;

  const CampusBackground({
    super.key,
    required this.child,
    this.showOverlay = true,
    this.overlayOpacity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: showOverlay
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: overlayOpacity),
                    AppColors.secondary.withValues(alpha: overlayOpacity * 0.8),
                    AppColors.primaryDark.withValues(alpha: overlayOpacity * 0.6),
                    AppColors.secondary.withValues(alpha: overlayOpacity * 0.8),
                    AppColors.primary.withValues(alpha: overlayOpacity),
                  ],
                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                ),
              ),
              child: child,
            )
          : child,
    );
  }
}

class CampusBackgroundScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool showOverlay;
  final double overlayOpacity;

  const CampusBackgroundScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showOverlay = true,
    this.overlayOpacity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    return CampusBackground(
      showOverlay: showOverlay,
      overlayOpacity: overlayOpacity,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool isDark;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.96),
                  const Color(0xFFECFDF5).withValues(alpha: 0.94),
                ]
              : [
                  Colors.white.withValues(alpha: 0.98),
                  const Color(0xFFF0FDF4).withValues(alpha: 0.95),
                ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.1),
            blurRadius: isDark ? 16 : 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.08),
            blurRadius: isDark ? 24 : 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: padding,
        child: child,
      ),
    );
  }
}
