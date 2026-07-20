import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../core/responsive_layout.dart';
import '../models/debate_record.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'results_screen.dart';
import '../models/debate_mode.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DebateMode _selectedMode = DebateMode.ranked;
  String _stanceFilter = 'All';
  int _minScore = 0;

  void _showFilter(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDark;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfDeep(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Filter Debates',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'STANCE',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: ['All', 'For', 'Against'].map((s) {
                  final selected = _stanceFilter == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        setModal(() {});
                        setState(() => _stanceFilter = s);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? (_selectedMode == DebateMode.ranked
                                    ? AppColors.rankedTabBg
                                    : (_selectedMode == DebateMode.learning
                                          ? const Color(0xFF0F6E56)
                                          : AppColors.casualTabBg))
                              : AppColors.bg(isDark),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? (_selectedMode == DebateMode.ranked
                                      ? AppColors.rankedTabBg
                                      : (_selectedMode == DebateMode.learning
                                            ? const Color(0xFF0F6E56)
                                            : AppColors.casualTabBg))
                                : AppColors.border(isDark),
                          ),
                        ),
                        child: Text(
                          s,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? AppColors.textPrimary(true)
                                : AppColors.textSecondary(isDark),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MIN SCORE',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                  Text(
                    '$_minScore',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _selectedMode == DebateMode.ranked
                          ? AppColors.rankedTabText
                          : (_selectedMode == DebateMode.learning
                                ? const Color(0xFF1ABC9C)
                                : AppColors.casualTabText),
                    ),
                  ),
                ],
              ),
              Slider(
                value: _minScore.toDouble(),
                min: 0,
                max: 100,
                divisions: 10,
                activeColor: _selectedMode == DebateMode.ranked
                    ? AppColors.rankedTabBg
                    : (_selectedMode == DebateMode.learning
                          ? const Color(0xFF0F6E56)
                          : AppColors.casualTabBg),
                inactiveColor: AppColors.border(isDark),
                onChanged: (v) {
                  setModal(() {});
                  setState(() => _minScore = v.round());
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _selectedMode == DebateMode.ranked
                        ? AppColors.rankedTabBg
                        : (_selectedMode == DebateMode.learning
                              ? const Color(0xFF0F6E56)
                              : AppColors.casualTabBg),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Apply',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: _selectedMode == DebateMode.ranked
                          ? AppColors.rankedTabText
                          : (_selectedMode == DebateMode.learning
                                ? AppColors.textPrimary(true)
                                : AppColors.casualTabText),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > ResponsiveLayout.desktopBreakpoint;
    return Scaffold(
      backgroundColor: AppColors.bg(isDark),
      body: SafeArea(
        top: !isDesktop,
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: isDesktop ? 8 : 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'History',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.filter_list_rounded,
                      color: (_stanceFilter != 'All' || _minScore > 0)
                          ? (_selectedMode == DebateMode.ranked
                                ? AppColors.rankedTabText
                                : (_selectedMode == DebateMode.learning
                                      ? const Color(0xFF1ABC9C)
                                      : AppColors.casualTabText))
                          : AppColors.textPrimary(isDark),
                    ),
                    onPressed: () => _showFilter(context),
                  ),
                ],
              ),
            ),

            // Tab Switcher
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfDeep(isDark),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: DebateMode.values.map((mode) {
                    final isSelected = _selectedMode == mode;
                    String label = '';
                    Color activeBg = Colors.transparent;
                    Color activeText = Colors.white;
                    if (mode == DebateMode.ranked) {
                      label = 'Ranked';
                      activeBg = AppColors.rankedTabBg;
                      activeText = AppColors.rankedTabText;
                    } else if (mode == DebateMode.casual) {
                      label = 'Casual';
                      activeBg = AppColors.casualTabBg;
                      activeText = AppColors.casualTabText;
                    } else {
                      label = 'Learning';
                      activeBg = const Color(0xFF0F6E56);
                      activeText = Colors.white;
                    }

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMode = mode),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected ? activeBg : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            label,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? activeText
                                  : AppColors.textSecondary(isDark),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            SizedBox(height: isDesktop ? 12 : 20),

            // Main Content Stream
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('debates')
                    .doc(AuthService.currentUser?.uid)
                    .collection('history')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.rankedTabBg,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading history',
                        style: TextStyle(color: AppColors.textPrimary(isDark)),
                      ),
                    );
                  }

                  final allDocs = snapshot.data?.docs ?? [];
                  final records = allDocs
                      .map((d) => DebateRecord.fromFirestore(d))
                      .toList();

                  // Filter based on active tab and filter options
                  final filtered = records.where((r) {
                    if (r.mode != _selectedMode) return false;
                    if (_stanceFilter != 'All' && r.stance != _stanceFilter)
                      return false;
                    if (r.score < _minScore) return false;
                    return true;
                  }).toList();

                  return Column(
                    children: [
                      // Stats Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildStatsRow(filtered, isDark),
                      ),

                      SizedBox(height: isDesktop ? 12 : 20),

                      // List of Debates
                      Expanded(
                        child: filtered.isEmpty
                            ? _buildEmptyState(isDark, isDesktop)
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final record = filtered[index];
                                  final card = GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ResultsScreen(
                                            topic: record.topic,
                                            stance: record.stance,
                                            messages: record.messages,
                                            score: record.score,
                                            strengths: record.strengths,
                                            weaknesses: record.weaknesses,
                                            summary: record.summary,
                                            difficulty: record.difficulty,
                                            pointsEarned: record.pointsEarned,
                                            mode: record.mode,
                                            isFromHistory: true,
                                          ),
                                        ),
                                      );
                                    },
                                    child: DebateHistoryCard(record: record),
                                  );

                                  if (record.mode == DebateMode.ranked) {
                                    return card;
                                  }

                                  return Dismissible(
                                    key: Key(record.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.accentRed,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      child: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    confirmDismiss: (direction) async {
                                      return await showDialog<bool>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (_) => _ThemedDialog(
                                          title: 'Delete Debate',
                                          content:
                                              'Are you sure you want to delete this match? This cannot be undone.',
                                          actions: const [
                                            ('Cancel', Colors.white),
                                            ('Delete', AppColors.accentRed),
                                          ],
                                        ),
                                      );
                                    },
                                    onDismissed: (direction) async {
                                      await FirebaseFirestore.instance
                                          .collection('debates')
                                          .doc(AuthService.currentUser?.uid)
                                          .collection('history')
                                          .doc(record.id)
                                          .delete();
                                    },
                                    child: card,
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(List<DebateRecord> records, bool isDark) {
    if (_selectedMode == DebateMode.ranked) {
      final total = records.length;
      final wins = records.where((r) => r.score >= 50).length;
      final losses = total - wins;

      return Row(
        children: [
          _buildStatCard(
            value: total.toString(),
            valueColor: AppColors.rankedTabText,
            label: 'Total ranked',
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            value: wins.toString(),
            valueColor: AppColors.accentGreen,
            label: 'Wins',
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            value: losses.toString(),
            valueColor: AppColors.accentRed,
            label: 'Losses',
            isDark: isDark,
          ),
        ],
      );
    } else {
      final total = records.length;
      final avgScore = total == 0
          ? 0
          : (records.fold(0, (sum, r) => sum + r.score) / total).round();
      final totalTime = records.fold(0, (sum, r) => sum + r.durationMinutes);

      return Row(
        children: [
          _buildStatCard(
            value: total.toString(),
            valueColor: _selectedMode == DebateMode.casual
                ? AppColors.accentGreen
                : const Color(0xFF1ABC9C),
            label: _selectedMode == DebateMode.casual
                ? 'Total casual'
                : 'Total learning',
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            value: avgScore.toString(),
            valueColor: AppColors.textPrimary(isDark),
            label: 'Avg score',
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            value: '${totalTime}m',
            valueColor: AppColors.accentAmber,
            label: 'Total time',
            isDark: isDark,
          ),
        ],
      );
    }
  }

  Widget _buildStatCard({
    required String value,
    required Color valueColor,
    required String label,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfDeep(isDark),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isDesktop) {
    return Container(
      alignment: isDesktop ? Alignment.topCenter : Alignment.center,
      padding: isDesktop ? const EdgeInsets.only(top: 80) : EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 64,
            color: AppColors.surfDeep(isDark),
          ),
          const SizedBox(height: 16),
          Text(
            'No debates yet',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary(isDark),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedMode == DebateMode.ranked
                  ? AppColors.rankedTabBg
                  : (_selectedMode == DebateMode.learning
                        ? const Color(0xFF0F6E56)
                        : AppColors.casualTabBg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Start a ${_selectedMode.name} Match',
              style: GoogleFonts.poppins(
                color: _selectedMode == DebateMode.ranked
                    ? AppColors.rankedTabText
                    : (_selectedMode == DebateMode.learning
                          ? AppColors.textPrimary(true)
                          : AppColors.casualTabText),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DebateHistoryCard extends StatelessWidget {
  final DebateRecord record;

  const DebateHistoryCard({super.key, required this.record});

  Color _getAccentColor() {
    if (record.isRanked) {
      return record.score >= 50 ? AppColors.accentGreen : AppColors.accentRed;
    } else {
      if (record.score >= 70) return AppColors.accentGreen;
      if (record.score >= 50) return AppColors.accentAmber;
      return AppColors.accentRed;
    }
  }

  String _formatDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(record.date.year, record.date.month, record.date.day);

    if (date == today) {
      return 'Today, ${DateFormat.jm().format(record.date)}';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(record.date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surf(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(isDark), width: 0.5),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Accent Bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _getAccentColor(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Topic and Score Arc
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            record.topic,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(isDark),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: CustomPaint(
                            painter: ScoreArcMiniPainter(score: record.score),
                            child: Center(
                              child: Text(
                                record.score.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary(isDark),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Meta Row
                    Row(
                      children: [
                        if (record.isRanked) ...[
                          _buildPointsBadge(),
                          const SizedBox(width: 8),
                          _buildRankPill(),
                        ] else ...[
                          _buildDifficultyPill(),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: AppColors.textSecondary(isDark),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${record.durationMinutes} min',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Spacer(),
                        Text(
                          _formatDate(),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textSecondary(isDark),
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
    );
  }

  Widget _buildPointsBadge() {
    final isPositive = record.pointsEarned >= 0;
    final sign = isPositive ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPositive ? AppColors.pillPositiveBg : AppColors.pillNegativeBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$sign${record.pointsEarned} pts',
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isPositive
              ? AppColors.pillPositiveText
              : AppColors.pillNegativeText,
        ),
      ),
    );
  }

  Widget _buildRankPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.pillRankBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        record.rankAtTime,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.pillRankText,
        ),
      ),
    );
  }

  Widget _buildDifficultyPill() {
    Color bg;
    Color text;
    final diff = record.difficulty.toLowerCase();

    if (diff == 'easy') {
      bg = AppColors.pillEasyBg;
      text = AppColors.pillEasyText;
    } else if (diff == 'hard') {
      bg = AppColors.pillHardBg;
      text = AppColors.pillHardText;
    } else {
      bg = AppColors.pillMediumBg;
      text = AppColors.pillMediumText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        record.difficulty,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}

class ScoreArcMiniPainter extends CustomPainter {
  final int score;

  ScoreArcMiniPainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 3.5) / 2;

    // Track
    final trackPaint = Paint()
      ..color = const Color(0xFF2A2A2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final startAngle = -3 * math.pi / 4;
    final sweepAngle = 3 * math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Fill
    final fillPaint = Paint()
      ..color = score >= 50 ? AppColors.accentGreen : AppColors.accentRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final progressSweep = (score / 100.0) * sweepAngle;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScoreArcMiniPainter oldDelegate) {
    return oldDelegate.score != score;
  }
}

class _ThemedDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<(String, Color)> actions;

  const _ThemedDialog({
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return Dialog(
      backgroundColor: AppColors.surfDeep(isDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(isDark),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textPrimary(isDark),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(actions.length, (index) {
                final (label, color) = actions[index];
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pop(index != 0); // index 0 is cancel, index 1 is delete
                    },
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
