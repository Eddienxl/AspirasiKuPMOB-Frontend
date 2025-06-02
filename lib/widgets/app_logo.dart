import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final String? text;
  final Color? textColor;
  final bool isCircular;
  final bool showShadow;

  const AppLogo({
    super.key,
    this.size = 40,
    this.showText = false,
    this.text,
    this.textColor,
    this.isCircular = false,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogo(),
        if (showText) ...[
          const SizedBox(width: 12),
          _buildText(context),
        ],
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isCircular ? size / 2 : 12),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isCircular ? size / 2 : 12),
        child: Image.asset(
          'assets/images/aspirasikulogo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackLogo();
          },
        ),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(isCircular ? size / 2 : 12),
      ),
      child: Center(
        child: Text(
          'A',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    return Text(
      text ?? 'AspirasiKu',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: textColor ?? AppColors.textPrimary,
      ),
    );
  }
}

class AspirasiKuLogo extends StatelessWidget {
  final double size;
  final bool showShadow;

  const AspirasiKuLogo({
    super.key,
    this.size = 40,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/aspirasikulogo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HeaderLogo extends StatelessWidget {
  final bool showTitle;
  final VoidCallback? onTap;

  const HeaderLogo({
    super.key,
    this.showTitle = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLogo(
            size: 40,
            showShadow: false,
          ),
          if (showTitle) ...[
            const SizedBox(width: 12),
            Text(
              'AspirasiKu',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
