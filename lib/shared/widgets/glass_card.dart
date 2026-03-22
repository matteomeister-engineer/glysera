import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// iOS 26-inspired Liquid Glass card
/// Uses BackdropFilter + ImageFilter.blur to create the frosted
/// translucent glass effect. Works best over dark or image backgrounds.
///
/// Usage:
///   GlassCard(child: Text('Hello'))
///   GlassCard.dark(child: Text('Hello'))
///   GlassCard.tinted(color: AppColors.glassRedFill, child: ...)
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double blurSigma;
  final Color fillColor;
  final Color borderColor;
  final double borderRadius;
  final double borderWidth;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.blurSigma = AppDimens.blurMd,
    this.fillColor = AppColors.glassFill,
    this.borderColor = AppColors.glassBorder,
    this.borderRadius = AppDimens.radiusLg,
    this.borderWidth = 1.0,
  });

  /// Dark glass — use on light/cream backgrounds
  const GlassCard.dark({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.blurSigma = AppDimens.blurMd,
    this.fillColor = AppColors.glassDarkFill,
    this.borderColor = AppColors.glassDarkBorder,
    this.borderRadius = AppDimens.radiusLg,
    this.borderWidth = 0.5,
  });

  /// Lime/accent glass — for in-range status and CTAs
  GlassCard.lime({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.blurSigma = AppDimens.blurSm,
  })  : fillColor = const Color(0xD9E7FE54), // 85% lime
        borderColor = const Color(0x66E7FE54),
        borderRadius = AppDimens.radiusLg,
        borderWidth = 1.0;

  /// Purple card — for weekly stats, growth metrics
  GlassCard.purple({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.blurSigma = AppDimens.blurSm,
  })  : fillColor = AppColors.purpleCard,
        borderColor = AppColors.purplePrimary.withOpacity(0.3),
        borderRadius = AppDimens.radiusLg,
        borderWidth = 0;

  /// Red tinted — for urgent low/high alerts
  const GlassCard.red({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.blurSigma = AppDimens.blurMd,
    this.fillColor = AppColors.glassRedFill,
    this.borderColor = AppColors.glassRedBorder,
    this.borderRadius = AppDimens.radiusLg,
    this.borderWidth = 1.0,
  });

  /// Amber tinted — for low/high warnings
  const GlassCard.amber({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.blurSigma = AppDimens.blurMd,
    this.fillColor = AppColors.glassAmberFill,
    this.borderColor = AppColors.glassAmberBorder,
    this.borderRadius = AppDimens.radiusLg,
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurSigma,
          sigmaY: blurSigma,
        ),
        child: Container(
          width: width,
          height: height,
          padding: padding ??
              const EdgeInsets.all(AppDimens.xxl),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(borderRadius),
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

/// Glass pill badge — for status labels, duration tags
class GlassPill extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color fillColor;
  final Color borderColor;

  const GlassPill(
    this.label, {
    super.key,
    this.textColor = Colors.white,
    this.fillColor = AppColors.glassFill,
    this.borderColor = AppColors.glassBorder,
  });

  const GlassPill.lime(
    this.label, {
    super.key,
    this.textColor = AppColors.black,
    this.fillColor = AppColors.accent,
    this.borderColor = AppColors.accent,
  });

  const GlassPill.dark(
    this.label, {
    super.key,
    this.textColor = Colors.white,
    this.fillColor = AppColors.glassDarkFill,
    this.borderColor = AppColors.glassDarkBorder,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass alert banner — translucent tinted strip
class GlassAlertBanner extends StatelessWidget {
  final String message;
  final Color dotColor;
  final Color fillColor;
  final Color borderColor;
  final Widget? trailing;

  const GlassAlertBanner({
    super.key,
    required this.message,
    this.dotColor = AppColors.glucoseUrgentLow,
    this.fillColor = AppColors.glassRedFill,
    this.borderColor = AppColors.glassRedBorder,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withOpacity(0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Purple stat card — matches the reference screenshot style:
/// soft violet background, deep purple text, mini bar chart
class PurpleStatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String valueSuffix;
  final List<double> barData; // values 0.0–1.0 (relative heights)

  const PurpleStatCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    this.valueSuffix = '%',
    this.barData = const [0.4, 0.6, 0.8, 0.55, 0.9, 0.7, 0.65],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.xl),
      decoration: BoxDecoration(
        color: AppColors.purpleCard,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.purpleText,
                        letterSpacing: 0.8,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.purpleSubtext,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$value$valueSuffix',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.purpleText,
                  letterSpacing: -0.8,
                  height: 1,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Mini bar chart
          SizedBox(
            height: 56,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: barData.map((v) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: FractionallySizedBox(
                        heightFactor: v.clamp(0.1, 1.0),
                        alignment: Alignment.bottomCenter,
                        child: Container(color: AppColors.purplePrimary),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

