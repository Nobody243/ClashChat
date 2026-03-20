import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/theme_provider.dart';

class FeedbackSection extends StatelessWidget {
  final String title;
  final List<String> points;
  final IconData icon;
  final Color color;
  const FeedbackSection({super.key, required this.title, required this.points, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    if (points.isEmpty) return const SizedBox.shrink();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surf(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: color)),
          ]),
          const SizedBox(height: 10),
          ...points.map((p) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 7, right: 10),
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                Expanded(child: Text(p, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary(isDark), height: 1.4))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
