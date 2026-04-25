import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? accentColor;
  final VoidCallback? onTap;
  final double blurAmount;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.accentColor,
    this.onTap,
    this.blurAmount = 8,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          margin: margin,
          decoration: BoxDecoration(
            gradient: accentColor != null
                ? LinearGradient(
                    colors: [
                      accentColor!.withOpacity(0.10),
                      accentColor!.withOpacity(0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      AppColors.surfaceAlt.withOpacity(0.95),
                      AppColors.surface.withOpacity(0.80),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: accentColor != null
                  ? accentColor!.withOpacity(0.25)
                  : AppColors.divider,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              if (accentColor != null)
                BoxShadow(
                  color: accentColor!.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
