import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/theme_provider.dart';
import '../models/debate_record.dart';

class HistorySummaryStrip extends StatelessWidget {
  final List<DebateRecord> records;
  const HistorySummaryStrip({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    if (records.isEmpty) return const SizedBox.shrink();
    final avg = records.isEmpty
        ? 0
        : (records.map((r) => r.score).reduce((a, b) => a + b) / records.length)
              .round();
    final wins = records.where((r) => r.score >= 70).length;
    final stats = [
      {
        'label': 'Debates',
        'value': '${records.length}',
        'color': AppColors.primary,
      },
      {'label': 'Avg Score', 'value': '$avg%', 'color': AppColors.secondary},
      {'label': 'Wins', 'value': '$wins', 'color': AppColors.success},
    ];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surf(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stats.map((s) {
          return Column(
            children: [
              Text(
                s['value']! as String,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: s['color'] as Color,
                ),
              ),
              Text(
                s['label']! as String,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
