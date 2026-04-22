import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';
import '../core/app_colors.dart';
import '../core/theme_provider.dart';
import '../models/debate_mode.dart';

class DifficultyScreen extends StatefulWidget {
  final String topic;
  final String stance;

  const DifficultyScreen({
    super.key,
    required this.topic,
    required this.stance,
  });

  @override
  State<DifficultyScreen> createState() => _DifficultyScreenState();
}

class _DifficultyScreenState extends State<DifficultyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _selectDifficulty(String difficulty) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          topic: widget.topic,
          stance: widget.stance,
          difficulty: difficulty,
          mode: DebateMode.casual,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    final bgStart = isDark
        ? const Color(0xFF1A1A2E)
        : AppColors.backgroundLight;
    final bgEnd = isDark ? const Color(0xFF0F3460) : AppColors.surfaceDeepLight;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgStart, bgEnd],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16.0 : 40.0,
                vertical: isMobile ? 20.0 : 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                    ),
                  ).animate(controller: _animCtrl).fadeIn().slideX(begin: -0.3),
                  SizedBox(height: isMobile ? 32 : 48),

                  // Header Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Your',
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 26 : 32,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                      Text(
                            'Difficulty',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 40 : 52,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              height: 1.1,
                            ),
                          )
                          .animate(controller: _animCtrl)
                          .fadeIn()
                          .slideY(begin: 0.2),
                      SizedBox(height: isMobile ? 14 : 18),
                      Text(
                            'Pick the AI opponent that matches your skill level and confidence',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 14 : 15,
                              fontWeight: FontWeight.w400,
                              height: 1.6,
                              color: AppColors.textSecondary(isDark),
                            ),
                          )
                          .animate(controller: _animCtrl)
                          .fadeIn()
                          .slideY(begin: 0.2, delay: 50.ms),
                    ],
                  ),
                  SizedBox(height: isMobile ? 40 : 56),

                  // Difficulty Cards
                  _DifficultyCard(
                    emoji: '🟢',
                    title: 'Easy',
                    subtitle: 'Perfect for Learning',
                    description:
                        'Uses simple language and makes logical mistakes. Great for building confidence.',
                    color: const Color(0xFF10B981),
                    accentColor: const Color(0xFF6EE7B7),
                    onTap: () => _selectDifficulty('easy'),
                    delay: 0,
                    animCtrl: _animCtrl,
                    isDark: isDark,
                    isMobile: isMobile,
                  ),
                  SizedBox(height: isMobile ? 16 : 20),
                  _DifficultyCard(
                    emoji: '🟡',
                    title: 'Medium',
                    subtitle: 'Real Competition',
                    description:
                        'Uses clear logic and fair arguments. Will challenge your thinking skills.',
                    color: const Color(0xFFF59E0B),
                    accentColor: const Color(0xFFFCD34D),
                    onTap: () => _selectDifficulty('medium'),
                    delay: 100,
                    animCtrl: _animCtrl,
                    isDark: isDark,
                    isMobile: isMobile,
                  ),
                  SizedBox(height: isMobile ? 16 : 20),
                  _DifficultyCard(
                    emoji: '🔴',
                    title: 'Hard',
                    subtitle: 'Master Challenge',
                    description:
                        'Advanced reasoning and sharp rebuttals. Only for experienced debaters.',
                    color: const Color(0xFFEF4444),
                    accentColor: const Color(0xFFFCA5A5),
                    onTap: () => _selectDifficulty('hard'),
                    delay: 200,
                    animCtrl: _animCtrl,
                    isDark: isDark,
                    isMobile: isMobile,
                  ),
                  SizedBox(height: isMobile ? 32 : 48),

                  // Topic display
                  Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 20,
                          vertical: isMobile ? 14 : 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.25),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Debate Topic',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.topic,
                                    style: GoogleFonts.poppins(
                                      fontSize: isMobile ? 14 : 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary(isDark),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate(controller: _animCtrl)
                      .fadeIn()
                      .slideY(delay: 300.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final Color accentColor;
  final VoidCallback onTap;
  final int delay;
  final AnimationController animCtrl;
  final bool isDark;
  final bool isMobile;

  const _DifficultyCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.accentColor,
    required this.onTap,
    required this.delay,
    required this.animCtrl,
    required this.isDark,
    required this.isMobile,
  });

  @override
  State<_DifficultyCard> createState() => _DifficultyCardState();
}

class _DifficultyCardState extends State<_DifficultyCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 150));
        widget.onTap();
      },
      borderRadius: BorderRadius.circular(18),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          transform: _isHovering
              ? (Matrix4.identity()..scale(1.02))
              : Matrix4.identity(),
          child:
              Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.color.withOpacity(0.1),
                          widget.color.withOpacity(0.03),
                        ],
                      ),
                      border: Border.all(
                        color: _isHovering
                            ? widget.color.withOpacity(0.7)
                            : widget.color.withOpacity(0.35),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: _isHovering
                          ? [
                              BoxShadow(
                                color: widget.color.withOpacity(0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    padding: EdgeInsets.all(widget.isMobile ? 18 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: widget.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                widget.emoji,
                                style: TextStyle(
                                  fontSize: widget.isMobile ? 28 : 32,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: widget.isMobile ? 20 : 24,
                                      fontWeight: FontWeight.w800,
                                      color: widget.color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.subtitle,
                                    style: GoogleFonts.poppins(
                                      fontSize: widget.isMobile ? 12 : 13,
                                      fontWeight: FontWeight.w600,
                                      color: widget.accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          widget.description,
                          style: GoogleFonts.poppins(
                            fontSize: widget.isMobile ? 13 : 14,
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                            color: AppColors.textSecondary(widget.isDark),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: widget.color.withOpacity(0.5),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Start Debate',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: widget.color.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                  .animate(controller: widget.animCtrl)
                  .fadeIn(delay: Duration(milliseconds: widget.delay))
                  .slideY(
                    begin: 0.3,
                    delay: Duration(milliseconds: widget.delay),
                  ),
        ),
      ),
    );
  }
}
