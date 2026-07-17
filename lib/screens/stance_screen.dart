import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/theme_provider.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Stance')),
      body: Padding(
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
            AnimatedContainer(
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
            ),
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
    );
  }
}
