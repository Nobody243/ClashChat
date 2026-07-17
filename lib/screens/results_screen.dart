import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';
import 'home_screen.dart';
import '../core/app_colors.dart';
import '../core/theme_provider.dart';
import '../models/chat_message.dart';
import '../widgets/score_arc_painter.dart';
import '../widgets/feedback_section.dart';
import '../widgets/result_stat_card.dart';
import '../widgets/gradient_button.dart';
import '../models/debate_mode.dart';

class ResultsScreen extends StatefulWidget {
  final String topic;
  final String stance;
  final List<ChatMessage> messages;
  final int score;
  final DebateMode mode;
  final int pointsEarned;
  final List<String> strengths;
  final List<String> weaknesses;
  final String summary;
  final String difficulty;
  final bool isFromHistory;

  const ResultsScreen({
    super.key,
    required this.topic,
    required this.stance,
    required this.messages,
    required this.score,
    this.mode = DebateMode.casual,
    this.pointsEarned = 0,
    this.strengths = const [],
    this.weaknesses = const [],
    this.summary = '',
    this.difficulty = 'Medium',
    this.isFromHistory = false,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreAnimCtrl;
  late Animation<double> _scoreAnim;
  late AnimationController _cardSlideCtrl;
  late Animation<Offset> _cardSlideAnim;
  late Animation<double> _cardFadeAnim;
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late AnimationController _pointsBannerCtrl;
  late Animation<double> _pointsBannerAnim;

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeIn);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));

    _scoreAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scoreAnim = Tween<double>(begin: 0, end: widget.score / 100.0).animate(
      CurvedAnimation(parent: _scoreAnimCtrl, curve: Curves.easeOutCubic),
    );

    _cardSlideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardSlideCtrl, curve: Curves.easeOut));
    _cardFadeAnim = CurvedAnimation(
      parent: _cardSlideCtrl,
      curve: Curves.easeIn,
    );

    _pointsBannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pointsBannerAnim = CurvedAnimation(
      parent: _pointsBannerCtrl,
      curve: Curves.elasticOut,
    );

    _headerCtrl
        .forward()
        .then((_) => _scoreAnimCtrl.forward())
        .then((_) => _cardSlideCtrl.forward())
        .then((_) {
          if (widget.mode == DebateMode.ranked) _pointsBannerCtrl.forward();
        });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _scoreAnimCtrl.dispose();
    _cardSlideCtrl.dispose();
    _pointsBannerCtrl.dispose();
    super.dispose();
  }

  bool get _isWin => widget.score >= 50;

  Color get _scoreColor {
    if (widget.score >= 75) return AppColors.success;
    if (widget.score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  String get _scoreLabel {
    if (widget.mode == DebateMode.learning) return 'Knowledge Gained';
    if (widget.score >= 75) return 'Excellent Debater!';
    if (widget.score >= 50) return 'Good Effort — You Won!';
    return 'Keep Practicing';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bgStart = isDark
        ? const Color(0xFF1A1A2E)
        : AppColors.backgroundLight;
    final bgEnd = isDark ? const Color(0xFF16213E) : AppColors.surfaceDeepLight;
    final textPrimary = AppColors.textPrimary(isDark);
    final textHint = AppColors.textHint(isDark);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.isFromHistory,
        title: Text(
          'Debate Results',
          style: GoogleFonts.poppins(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getModeColor(widget.mode).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getModeColor(widget.mode).withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getModeIcon(widget.mode),
                  color: _getModeColor(widget.mode),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  _getModeName(widget.mode),
                  style: TextStyle(
                    color: _getModeColor(widget.mode),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: context.read<ThemeProvider>().toggle,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                key: ValueKey(isDark),
                color: isDark ? Colors.amber : AppColors.primary,
              ),
            ),
          ),
        ],
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
                // Header
                FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: Column(
                      children: [
                        Text(
                          widget.mode == DebateMode.learning
                              ? 'Learning Complete'
                              : (_isWin ? '🎉 You Won!' : '😤 You Lost'),
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.topic,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: textHint,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Difficulty + mode tag
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _InfoChip(
                              label: widget.difficulty,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            _InfoChip(
                              label: widget.stance,
                              color: widget.stance == 'For'
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Score arc — uses your existing ScoreArcPainter
                AnimatedBuilder(
                  animation: _scoreAnim,
                  builder: (context, _) {
                    final progress = _scoreAnim.value;
                    final displayScore = (progress * 100).round();
                    return Column(
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CustomPaint(
                            painter: ScoreArcPainter(
                              progress: progress,
                              color: _scoreColor,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$displayScore',
                                    style: GoogleFonts.poppins(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w900,
                                      color: _scoreColor,
                                    ),
                                  ),
                                  Text(
                                    'Logic Score',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: textHint,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _scoreColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _scoreColor.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            _scoreLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _scoreColor,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // ── RANKED POINTS BANNER ──
                if (widget.mode == DebateMode.ranked)
                  ScaleTransition(
                    scale: _pointsBannerAnim,
                    child: _RankedPointsBanner(
                      pointsEarned: widget.pointsEarned,
                      isWin: _isWin,
                      score: widget.score,
                    ),
                  ),

                const SizedBox(height: 20),

                // AI Summary
                if (widget.summary.isNotEmpty)
                  SlideTransition(
                    position: _cardSlideAnim,
                    child: FadeTransition(
                      opacity: _cardFadeAnim,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.summary,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: textPrimary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Feedback card — uses your existing FeedbackSection widget
                SlideTransition(
                  position: _cardSlideAnim,
                  child: FadeTransition(
                    opacity: _cardFadeAnim,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.analytics_outlined,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Feedback Summary',
                                  style: GoogleFonts.poppins(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              color: AppColors.border(isDark),
                              height: 24,
                            ),
                            FeedbackSection(
                              icon: Icons.thumb_up_alt_outlined,
                              color: AppColors.success,
                              title: 'Strengths',
                              points: widget.strengths.isNotEmpty
                                  ? widget.strengths
                                  : ['Good effort in this debate!'],
                            ),
                            const SizedBox(height: 16),
                            FeedbackSection(
                              icon: Icons.thumb_down_alt_outlined,
                              color: AppColors.error,
                              title: 'Areas to Improve',
                              points: widget.weaknesses.isNotEmpty
                                  ? widget.weaknesses
                                  : ['Keep practicing to improve!'],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Stat cards — your existing ResultStatCard widget
                SlideTransition(
                  position: _cardSlideAnim,
                  child: FadeTransition(
                    opacity: _cardFadeAnim,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ResultStatCard(
                            padding: 0,
                            label: 'Arguments',
                            value:
                                '${widget.messages.where((m) => m.isUser).length}',
                            icon: Icons.record_voice_over_outlined,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ResultStatCard(
                            padding: 0,
                            label: 'Stance',
                            value: widget.stance,
                            icon: widget.stance == 'For'
                                ? Icons.thumb_up_rounded
                                : Icons.thumb_down_rounded,
                            color: widget.stance == 'For'
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ResultStatCard(
                            padding: 0,
                            label: 'Exchanges',
                            value: '${widget.messages.length}',
                            icon: Icons.swap_horiz_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Chat History
                SlideTransition(
                  position: _cardSlideAnim,
                  child: FadeTransition(
                    opacity: _cardFadeAnim,
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surf(isDark),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border(isDark)),
                        ),
                        child: ExpansionTile(
                          iconColor: textPrimary,
                          collapsedIconColor: textPrimary,
                          title: Text(
                            'Chat History',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                                bottom: 12,
                              ),
                              itemCount: widget.messages.length,
                              itemBuilder: (context, index) {
                                final msg = widget.messages[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: msg.isUser
                                          ? AppColors.primary.withOpacity(0.15)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          msg.isUser ? 'You' : 'ClashBot',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: msg.isUser
                                                ? AppColors.primary
                                                : textHint,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (msg.coachTip != null) ...[
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            margin: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF0F6E56,
                                              ).withOpacity(0.15),
                                              border: Border(
                                                left: BorderSide(
                                                  color: Color(0xFF0F6E56),
                                                  width: 3,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              'Tip: ${msg.coachTip!}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                                color: textPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                        Text(
                                          msg.text,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Buttons
                if (!widget.isFromHistory)
                  SlideTransition(
                    position: _cardSlideAnim,
                    child: FadeTransition(
                      opacity: _cardFadeAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GradientButton(
                            label: 'Return to Home',
                            icon: Icons.home_rounded,
                            onPressed: () =>
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                  (_) => false,
                                ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () =>
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      topic: widget.topic,
                                      stance: widget.stance,
                                      difficulty: widget.difficulty,
                                      timerMinutes: null,
                                      mode: DebateMode.casual,
                                    ),
                                  ),
                                  (route) => route.isFirst,
                                ),
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(
                              'Rematch (${widget.mode.name[0].toUpperCase()}${widget.mode.name.substring(1)})',
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              foregroundColor: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getModeColor(DebateMode mode) {
    switch (mode) {
      case DebateMode.ranked:
        return Colors.amber;
      case DebateMode.learning:
        return const Color(0xFF1ABC9C);
      case DebateMode.casual:
        return Colors.blue;
    }
  }

  IconData _getModeIcon(DebateMode mode) {
    switch (mode) {
      case DebateMode.ranked:
        return Icons.emoji_events;
      case DebateMode.learning:
        return Icons.school;
      case DebateMode.casual:
        return Icons.people_alt_rounded;
    }
  }

  String _getModeName(DebateMode mode) {
    switch (mode) {
      case DebateMode.ranked:
        return 'Ranked';
      case DebateMode.learning:
        return 'Learning';
      case DebateMode.casual:
        return 'Casual';
    }
  }
}

// ── Ranked Points Banner ──────────────────────────────────────────────────────

class _RankedPointsBanner extends StatelessWidget {
  final int pointsEarned;
  final bool isWin;
  final int score;

  const _RankedPointsBanner({
    required this.pointsEarned,
    required this.isWin,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWin ? Colors.green : Colors.red;
    final sign = pointsEarned >= 0 ? '+' : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          // Trophy / skull icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              isWin ? '🏆' : '😞',
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWin ? 'Ranked Victory!' : 'Ranked Defeat',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: color,
                  ),
                ),
                Text(
                  isWin
                      ? 'Score $score — higher score = more points'
                      : 'Score below 50 — points deducted',
                  style: GoogleFonts.poppins(fontSize: 11),
                ),
              ],
            ),
          ),
          // Points pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(
              '$sign$pointsEarned pts',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
