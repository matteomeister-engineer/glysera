import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

const Color kOnboardingBg = Color(0xFF1F1F1F);

// ── Shell ─────────────────────────────────────────────────────

class OnboardingShell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBack;
  final bool showBack;

  const OnboardingShell({super.key, required this.child, this.onBack, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kOnboardingBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showBack)
              Padding(
                padding: const EdgeInsets.only(left: AppDimens.screenHorizontal, top: AppDimens.sm),
                child: GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

// ── Dots ──────────────────────────────────────────────────────

class OnboardingDots extends StatelessWidget {
  final int current;
  final int total;

  const OnboardingDots({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: 6),
          width: active ? 22 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          ),
        );
      }),
    );
  }
}

// ── Lime card ─────────────────────────────────────────────────

class LimeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const LimeCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppDimens.xxl),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl + 4),
      ),
      child: child,
    );
  }
}

// ── CTA ───────────────────────────────────────────────────────

class OnboardingCta extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const OnboardingCta({super.key, required this.label, required this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: enabled ? AppColors.backgroundPrimary : Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.play_arrow_rounded, color: enabled ? AppColors.black : Colors.white38, size: 26),
          ),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white, letterSpacing: -0.3)),
          const SizedBox(width: 6),
          Text('>>', style: TextStyle(color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -1)),
        ],
      ),
    );
  }
}

// ── Stepper ───────────────────────────────────────────────────

class LimeStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final String unit;
  final ValueChanged<int> onChanged;

  const LimeStepper({super.key, required this.value, required this.min, required this.max, required this.unit, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepBtn(icon: Icons.remove_rounded, onTap: value > min ? () => onChanged(value - 1) : null),
        const SizedBox(width: 16),
        Column(children: [
          Text('$value', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.black, letterSpacing: -2, height: 1)),
          Text(unit, style: const TextStyle(fontSize: 12, color: Color(0x88000000), fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(width: 16),
        _StepBtn(icon: Icons.add_rounded, onTap: value < max ? () => onChanged(value + 1) : null),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: onTap != null ? Colors.black.withOpacity(0.1) : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: Icon(icon, size: 22, color: onTap != null ? AppColors.black : AppColors.black.withOpacity(0.3)),
      ),
    );
  }
}

// ── Big toggle ────────────────────────────────────────────────

class BigToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String labelOn;
  final String labelOff;

  const BigToggle({super.key, required this.value, required this.onChanged, this.labelOn = 'On', this.labelOff = 'Off'});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 88, height: 42,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              left: value ? 46 : 0,
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
              ),
            ),
            Positioned(
              left: value ? 8 : null,
              right: value ? null : 8,
              child: Text(value ? labelOn : labelOff,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Therapy chip ──────────────────────────────────────────────

class TherapyChip extends StatelessWidget {
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const TherapyChip({super.key, required this.label, required this.description, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: selected ? AppColors.accent : Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.black : Colors.transparent,
                border: Border.all(color: selected ? AppColors.black : Colors.white.withOpacity(0.3), width: 2),
              ),
              child: selected ? const Icon(Icons.check, size: 12, color: AppColors.accent) : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? AppColors.black : Colors.white)),
                const SizedBox(height: 2),
                Text(description, style: TextStyle(fontSize: 11, color: selected ? AppColors.black.withOpacity(0.5) : Colors.white.withOpacity(0.4))),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

// ── Heading ───────────────────────────────────────────────────

class OnboardingHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const OnboardingHeading({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -1.2, height: 1.1)),
        const SizedBox(height: 6),
        Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.45), height: 1.5)),
      ],
    );
  }
}

// ── Unit chip ─────────────────────────────────────────────────

class UnitChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const UnitChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: selected ? AppColors.black : Colors.white54)),
      ),
    );
  }
}
