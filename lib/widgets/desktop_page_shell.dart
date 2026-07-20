import 'package:flutter/material.dart';
import '../core/responsive_layout.dart';

class DesktopPageShell extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const DesktopPageShell({
    super.key,
    required this.child,
    this.maxWidth = 1200.0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideDesktop = screenWidth >= ResponsiveLayout.wideDesktopBreakpoint;

    if (isWideDesktop) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
            child: child,
          ),
        ),
      );
    }

    return child;
  }
}
