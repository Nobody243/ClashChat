import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/theme_provider.dart';
import '../core/responsive_layout.dart';
import '../widgets/desktop_page_shell.dart';
import '../widgets/stance_button.dart';
import 'debate_setup_screen.dart';
import 'ranked_setup_screen.dart';
import 'chat_screen.dart';
import '../models/debate_mode.dart';

class StanceScreen extends StatefulWidget {
  final String topic;
  final DebateMode mode;

  const StanceScreen({super.key, required this.topic, required this.mode});

  @override
  State<StanceScreen> createState() => _StanceScreenState();
}

class _StanceScreenState extends State<StanceScreen> {
  bool _isFor = true;

  static const kStanceForGradient = [Color(0xFF38A169), Color(0xFF2F855A)];
  static const kStanceAgainstGradient = [Color(0xFFE53E3E), Color(0xFFC53030)];

  void _nextStep() {
    if (widget.mode == DebateMode.learning) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            topic: widget.topic,
            stance: _isFor ? 'For' : 'Against',
            difficulty: 'Adaptable', // Default for Learning Mode
            timerMinutes: null, // No timer for learning
            mode: widget.mode,
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => widget.mode == DebateMode.ranked
            ? RankedSetupScreen(topic: widget.topic, stance: _isFor ? 'For' : 'Against')
            : DebateSetupScreen(topic: widget.topic, stance: _isFor ? 'For' : 'Against', mode: widget.mode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final textPrimary = AppColors.textPrimary(isDark);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > ResponsiveLayout.desktopBreakpoint;
    final isWideDesktop = screenWidth >= ResponsiveLayout.wideDesktopBreakpoint;

    // Desktop: Two-column layout
    if (isDesktop) {
      if (isWideDesktop) {
        return Scaffold(
          body: DesktopPageShell(
            maxWidth: 1200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Stance Selection
                Expanded(
                  flex: 2,
                  child: _buildStanceSelectionPanel(isDark, textPrimary, true),
                ),
                const SizedBox(width: 32),
                // Right Column: Topic Info & Instructions
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDeep : AppColors.surfaceDeepLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border(isDark)),
                    ),
                    child: _buildTopicInfoPanel(isDark, textPrimary, true),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Stance Selection
                Expanded(
                  flex: 2,
                  child: _buildStanceSelectionPanel(isDark, textPrimary, false),
                ),
                // Right Column: Topic Info & Instructions
                Expanded(
                  flex: 1,
                  child: _buildTopicInfoPanel(isDark, textPrimary, false),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Mobile: Single column layout
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Stance')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surf(isDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border(isDark)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.topic, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.topic,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                Text('Which side are you on?', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary)),
                const SizedBox(height: 14),
                _buildStanceToggle(isDark),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _nextStep,
                    child: Text('Next Step', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStanceSelectionPanel(bool isDark, Color textPrimary, bool isWideDesktop) {
    return Padding(
      padding: isWideDesktop
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(48, 48, 48, 48),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Your Stance',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select the side you want to argue for',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary(isDark),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surf(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border(isDark)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Topic',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(isDark),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.topic,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Select Your Side',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildStanceToggle(isDark),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _nextStep,
                child: Text(
                  'Continue',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicInfoPanel(bool isDark, Color textPrimary, bool isWideDesktop) {
    Widget content() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Debate Tips',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _TipCard(
            isDark: isDark,
            icon: Icons.lightbulb_outline,
            title: _isFor ? 'Arguing For' : 'Arguing Against',
            tip: _isFor
                ? 'Present positive arguments, use data to support your claim, focus on benefits and solutions.'
                : 'Challenge assumptions, present counterarguments, highlight problems and risks.',
          ),
          const SizedBox(height: 20),
          _TipCard(
            isDark: isDark,
            icon: Icons.format_quote,
            title: 'Structure',
            tip: 'Start with a clear thesis, present 2-3 main points with evidence, conclude with a strong summary.',
          ),
          const SizedBox(height: 20),
          _TipCard(
            isDark: isDark,
            icon: Icons.timer,
            title: 'Timing',
            tip: 'Take time to think before responding. Quality over quantity wins debates.',
          ),
        ],
      );
    }

    if (isWideDesktop) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: content(),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDeep : AppColors.surfaceDeepLight,
        border: Border(
          left: BorderSide(
            color: isDark ? const Color(0x1AFFFFFF) : AppColors.border(isDark),
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
        child: content(),
      ),
    );
  }

  Widget _buildStanceToggle(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surf(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(isDark)),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: _isFor ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _isFor ? kStanceForGradient : kStanceAgainstGradient),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Row(
            children: [
              StanceButton(
                label: 'For',
                icon: Icons.thumb_up_rounded,
                isSelected: _isFor,
                activeGradient: kStanceForGradient,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _isFor = true);
                },
              ),
              StanceButton(
                label: 'Against',
                icon: Icons.thumb_down_rounded,
                isSelected: !_isFor,
                activeGradient: kStanceAgainstGradient,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _isFor = false);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String tip;

  const _TipCard({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.tip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surf(isDark).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tip,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}