import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Reusable Clean Card Container with subtle shadow and rounded corners.
/// Replaces the glassmorphism dark-mode blur with a light, professional card style.
class GlassContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry borderRadius;
  final double blur;
  final double opacity;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const GlassContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.blur = 0.0,
    this.opacity = 1.0,
    this.fillColor = AppColors.surface,
    this.borderColor = AppColors.glassBorder,
    this.borderWidth = 0.5,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBoxShadow = boxShadow ??
        [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12.0,
            spreadRadius: 0.0,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4.0,
            spreadRadius: 0.0,
            offset: const Offset(0, 1),
          ),
        ];

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: effectiveBoxShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: fillColor.withOpacity(opacity),
            gradient: gradient,
            borderRadius: borderRadius,
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Reusable Card widget with optional tap handler.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry borderRadius;
  final double blur;
  final double opacity;
  final Color fillColor;
  final Color borderColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.blur = 0.0,
    this.opacity = 1.0,
    this.fillColor = AppColors.surface,
    this.borderColor = AppColors.glassBorder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = GlassContainer(
      margin: margin,
      padding: padding,
      borderRadius: borderRadius,
      blur: blur,
      opacity: opacity,
      fillColor: fillColor,
      borderColor: borderColor,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }
    return container;
  }
}

/// Reusable Badge widget for tags, status indicators, and pill labels.
class GlassBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final Color? textColor;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  const GlassBadge({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.electricCyan,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? color;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: effectiveTextColor),
            const SizedBox(width: 4.0),
          ],
          Text(
            label,
            style: TextStyle(
              color: effectiveTextColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable Button widget.
class GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? label;
  final IconData? icon;
  final Color color;
  final double? width;
  final double height;
  final BorderRadiusGeometry borderRadius;

  const GlassButton({
    super.key,
    required this.onPressed,
    this.child,
    this.label,
    this.icon,
    this.color = AppColors.electricCyan,
    this.width,
    this.height = 48.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(14.0)),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: onPressed != null ? color : color.withOpacity(0.3),
          borderRadius: borderRadius,
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: child ??
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                  ],
                  if (label != null)
                    Flexible(
                      child: Text(
                        label!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: onPressed != null ? Colors.white : AppColors.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
        ),
      ),
    );
  }
}
