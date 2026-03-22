import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ─────────────────────────────────────────────────────────────
// Avatar asset catalogue — 1.svg through 9.svg
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

/// Returns a random asset path from [kAvatarShapes].
/// Pass an optional [seed] for a stable, reproducible result.
String randomAvatarShape({int? seed}) {
  final rng = seed != null ? Random(seed) : Random();
  return kAvatarShapes[rng.nextInt(kAvatarShapes.length)];
}

// ─────────────────────────────────────────────────────────────
// AvatarWidget — no background, SVG fills the whole circle
// ─────────────────────────────────────────────────────────────

class AvatarWidget extends StatelessWidget {
  final String assetPath;
  final double size;

  const AvatarWidget({
    super.key,
    required this.assetPath,
    this.size = 44,
    double padding = 0, // kept for API compatibility, ignored
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: SvgPicture.asset(
          assetPath,
          fit: BoxFit.cover,
          width: size,
          height: size,
        ),
      ),
    );
  }
}
