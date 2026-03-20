import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/theme_provider.dart';
import '../models/debate_record.dart';

class HistoryDebateCard extends StatefulWidget {
  final DebateRecord record;
  final VoidCallback onTap;
  final String? difficulty;
  final String? summary;
  final int? messageCount;

  const HistoryDebateCard({
    super.key,
    required this.record,
    required this.onTap,
    this.difficulty,
    this.summary,
    this.messageCount,
  });

  @override
  State<HistoryDebateCard> createState() => _HistoryDebateCardState();
}

class _HistoryDebateCardState extends State<HistoryDebateCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final textPrimary = AppColors.textPrimary(isDark);
    final textSecondary = AppColors.textSecondary(isDark);
    final textHint = AppColors.textHint(isDark);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surf(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border(isDark)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _getScoreColor(widget.record.score),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              // Rest of card content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: Topic and Score
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.record.topic,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _getScoreColor(widget.record.score),
                                      _getScoreColor(
                                        widget.record.score,
                                      ).withValues(alpha: 0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                child: Center(
                                  child: Text(
                                    '${widget.record.score.round()}',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.textHint(isDark),
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Summary text
                      if (widget.summary != null && widget.summary!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.summary!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: textSecondary,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),

                      // Bottom row: Difficulty, Stance, Exchanges, Date
                      Row(
                        children: [
                          // Difficulty badge with emoji
                          if (widget.difficulty != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor().withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _getDifficultyColor(),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                '${_getDifficultyEmoji()} ${widget.difficulty}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getDifficultyColor(),
                                ),
                              ),
                            ),
                          const SizedBox(width: 6),

                          // Stance badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (widget.record.stance == 'For'
                                          ? AppColors.success
                                          : AppColors.error)
                                      .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: widget.record.stance == 'For'
                                    ? AppColors.success
                                    : AppColors.error,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 5,
                                  color: widget.record.stance == 'For'
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  widget.record.stance,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: widget.record.stance == 'For'
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Exchanges and Date
                          if (widget.messageCount != null)
                            Text(
                              '${widget.messageCount}',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: textHint,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          Text(
                            ' • ${widget.record.date.day}/${widget.record.date.month}',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: textHint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score <= 30) return const Color(0xFFE53935);
    if (score <= 50) return const Color(0xFFFF6F00);
    if (score <= 70) return const Color(0xFFFFD600);
    if (score <= 85) return const Color(0xFFAED581);
    return const Color(0xFF43A047);
  }

  Color _getDifficultyColor() {
    final difficulty = widget.difficulty?.toLowerCase() ?? '';
    if (difficulty == 'easy') return const Color(0xFF43A047);
    if (difficulty == 'medium') return const Color(0xFFFFD600);
    return const Color(0xFFE53935);
  }

  String _getDifficultyEmoji() {
    final difficulty = widget.difficulty?.toLowerCase() ?? '';
    if (difficulty == 'easy') return '🟢';
    if (difficulty == 'medium') return '🟡';
    return '🔴';
  }
}
