import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/theme_provider.dart';
import '../widgets/score_arc_painter.dart';
import '../widgets/feedback_section.dart';

class DebateReviewScreen extends StatefulWidget {
  final Map<String, dynamic> debateData;

  const DebateReviewScreen({super.key, required this.debateData});

  @override
  State<DebateReviewScreen> createState() => _DebateReviewScreenState();
}

class _DebateReviewScreenState extends State<DebateReviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scoreAnimCtrl;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _scoreAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _scoreAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scoreAnimCtrl, curve: Curves.easeOutExpo),
    );
  }

  @override
  void dispose() {
    _scoreAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final textPrimary = AppColors.textPrimary(isDark);
    final textSecondary = AppColors.textSecondary(isDark);

    final topic = widget.debateData['topic'] as String? ?? 'Unknown Topic';
    final stance = widget.debateData['stance'] as String? ?? 'Unknown';
    final difficulty =
        widget.debateData['difficulty'] as String? ?? 'Not recorded';
    final dateStr = widget.debateData['date'] as String? ?? '';
    final score = (widget.debateData['score'] as num?)?.toInt() ?? 0;
    final summary = widget.debateData['summary'] as String? ?? '';
    final strengths = List<String>.from(widget.debateData['strengths'] ?? []);
    final weaknesses = List<String>.from(widget.debateData['weaknesses'] ?? []);

    final stanceColor = stance == 'For' ? AppColors.success : AppColors.error;
    final bgStart = isDark ? AppColors.background : AppColors.backgroundLight;
    final bgEnd = isDark ? AppColors.surface : AppColors.surfaceDeepLight;

    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(dateStr);
    } catch (_) {}

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          'Debate Review',
          style: GoogleFonts.poppins(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgStart, bgEnd],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Topic and Metadata
                Column(
                  children: [
                    Text(
                      topic,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Stance
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: stanceColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: stanceColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                stance == 'For'
                                    ? Icons.thumb_up_rounded
                                    : Icons.thumb_down_rounded,
                                size: 14,
                                color: stanceColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                stance,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: stanceColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Difficulty
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Text(
                            difficulty,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Date
                    if (parsedDate != null)
                      Text(
                        _formatDate(parsedDate),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 40),

                // Score Circle
                AnimatedBuilder(
                  animation: _scoreAnim,
                  builder: (context, _) {
                    final progress = _scoreAnim.value;
                    final displayScore = (progress * score).round();
                    final scoreColor = _getScoreColor(displayScore);

                    return Column(
                      children: [
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: CustomPaint(
                            painter: ScoreArcPainter(
                              progress: progress,
                              color: scoreColor,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$displayScore',
                                    style: GoogleFonts.poppins(
                                      fontSize: 44,
                                      fontWeight: FontWeight.w900,
                                      color: scoreColor,
                                    ),
                                  ),
                                  Text(
                                    'Score',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 36),

                // Summary
                if (summary.isNotEmpty)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfDeep(isDark),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border(isDark)),
                        ),
                        child: Text(
                          summary,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.6,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                // Strengths and Weaknesses
                FeedbackSection(
                  icon: Icons.thumb_up_alt_outlined,
                  color: AppColors.success,
                  title: 'Strengths',
                  points: strengths,
                ),
                const SizedBox(height: 16),
                FeedbackSection(
                  icon: Icons.thumb_down_alt_outlined,
                  color: AppColors.error,
                  title: 'Areas to Improve',
                  points: weaknesses,
                ),
                const SizedBox(height: 24),

                // Full Conversation
                ...(() {
                  final messages = widget.debateData['messages'] as List? ?? [];
                  if (messages.isEmpty) {
                    return [
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Conversation not available for older debates',
                          style: GoogleFonts.poppins(
                            color: AppColors.textHint(isDark),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ];
                  }

                  final widgets = <Widget>[
                    const SizedBox(height: 24),
                    Text(
                      'Full Conversation',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ];

                  for (int i = 0; i < messages.length; i++) {
                    final msg = messages[i] as Map<String, dynamic>? ?? {};
                    final isUser = msg['isUser'] as bool? ?? false;
                    final text = msg['text'] as String? ?? '';

                    widgets.add(
                      Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.purple.shade700
                                : Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            text,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return widgets;
                })(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
