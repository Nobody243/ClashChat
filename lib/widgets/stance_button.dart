import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';

/// One side of the "For / Against" segmented stance control on the Home screen.
class StanceButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final List<Color> activeGradient;
  final VoidCallback onTap;
  final IconData? icon;

  const StanceButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.activeGradient,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor = isDark ? Colors.white70 : const Color(0xFF1A1A2E);
    final contentColor = isSelected ? Colors.white : unselectedColor;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: activeGradient)
                : null,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 17, color: contentColor),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: contentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Convenience preset gradients used in HomeScreen
const List<Color> kStanceForGradient = [
  AppColors.success,
  AppColors.successAlt,
];

const List<Color> kStanceAgainstGradient = [
  AppColors.error,
  AppColors.errorAlt,
];
