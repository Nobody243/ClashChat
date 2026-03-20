import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserAvatar extends StatelessWidget {
  final String seed;
  final double size;

  const UserAvatar({super.key, required this.seed, this.size = 40});

  String get _effectiveSeed {
    final trimmed = seed.trim();
    if (trimmed.isEmpty) return 'Debater';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Uri.encodeComponent(trimmed);
    }
    return Uri.encodeComponent(trimmed);
  }

  String get url => 'https://api.dicebear.com/9.x/bottts/svg?seed=$_effectiveSeed';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: SvgPicture.network(
        url,
        width: size,
        height: size,
        placeholderBuilder: (_) => Container(
          width: size,
          height: size,
          color: Colors.grey.shade200,
        ),
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: Colors.grey.shade200,
          child: const Icon(Icons.person),
        ),
      ),
    );
  }
}
