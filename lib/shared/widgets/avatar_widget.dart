import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// Avatar asset catalogue
// NOTE: flutter_svg is incompatible with the iOS 26 simulator.
// AvatarWidget renders a coloured circle with an initial as a
// drop-in replacement until flutter_svg supports iOS 26.
// When running on a real device or iOS 17/18 simulator, swap
// back to SvgPicture.asset — the path strings are unchanged.
// ─────────────────────────────────────────────────────────────

const List<String> kAvatarShapes = [
  'assets/avatars/1.svg',
  'assets/avatars/2.svg',
  'assets/avatars/3.svg',
  'assets/avatars/4.svg',
  'assets/avatars/5.svg',
  'assets/avatars/6.svg',
  'assets/avatars/7.svg',
  'assets/avatars/8.svg',
  'assets/avatars/9.svg',
];

// Distinct colours — one per avatar slot
const List<Color> _kAvatarColors = [
  Color(0xFF7C6FCD), // purple
  Color(0xFF4DA6A6), // teal
  Color(0xFFE07B54), // coral
  Color(0xFF5B9BD5), // blue
  Color(0xFF6EC27A), // green
  Color(0xFFD4A843), // amber
  Color(0xFFCC5F8A), // pink
  Color(0xFF8A7A6E), // warm gray
  Color(0xFFC8FF00), // lime — matches app accent
];

/// Returns a random asset path from [kAvatarShapes].
String randomAvatarShape({int? seed}) {
  final rng = seed != null ? Random(seed) : Random();
  return kAvatarShapes[rng.nextInt(kAvatarShapes.length)];
}

// ─────────────────────────────────────────────────────────────
// AvatarWidget
// ─────────────────────────────────────────────────────────────

class AvatarWidget extends StatelessWidget {
  final String assetPath;
  final double size;

  const AvatarWidget({
    super.key,
    required this.assetPath,
    this.size = 44,
    double padding = 0, // kept for API compatibility
  });

  /// Extract a stable index from the asset path (e.g. "1.svg" → 0)
  int _indexFromPath() {
    final match = RegExp(r'(\d+)\.svg').firstMatch(assetPath);
    if (match == null) return 0;
    final n = int.tryParse(match.group(1) ?? '1') ?? 1;
    return (n - 1).clamp(0, _kAvatarColors.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final index = _indexFromPath();
    final color = _kAvatarColors[index];
    final initial = String.fromCharCode(65 + index); // A, B, C…

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
            color: index == 8
                ? const Color(0xFF1A1A1A) // dark text on lime
                : Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}
