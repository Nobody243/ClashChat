import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/theme_provider.dart';
import '../core/responsive_layout.dart';
import '../widgets/desktop_page_shell.dart';
import 'stance_screen.dart';
import '../models/debate_mode.dart';

class TopicScreen extends StatefulWidget {
  final DebateMode mode;
  const TopicScreen({super.key, required this.mode});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  static final _categories = [
    {
      'icon': Icons.computer_rounded,
      'label': 'Technology',
      'color': const Color(0xFF4A90E2),
    },
    {
      'icon': Icons.school_rounded,
      'label': 'Education',
      'color': const Color(0xFF7B4FA6),
    },
    {
      'icon': Icons.public_rounded,
      'label': 'Society',
      'color': const Color(0xFF38A169),
    },
    {
      'icon': Icons.favorite_rounded,
      'label': 'Health',
      'color': const Color(0xFFE8927C),
    },
    {
      'icon': Icons.account_balance_rounded,
      'label': 'Politics',
      'color': const Color(0xFFC49A3C),
    },
    {
      'icon': Icons.eco_rounded,
      'label': 'Environment',
      'color': const Color(0xFF48BB78),
    },
    {
      'icon': Icons.trending_up_rounded,
      'label': 'Economy',
      'color': const Color(0xFF3D7DD8),
    },
    {
      'icon': Icons.theater_comedy_rounded,
      'label': 'Culture',
      'color': const Color(0xFF9B59B6),
    },
  ];

  String? _selectedCategory;
  final _customTopicCtrl = TextEditingController();

  @override
  void dispose() {
    _customTopicCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    final topic = _customTopicCtrl.text.trim().isNotEmpty
        ? _customTopicCtrl.text.trim()
        : _selectedCategory;

    if (topic == null || topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a category or enter a custom topic.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Check if topic contains at least one letter
    if (!RegExp(r'[a-zA-Z]').hasMatch(topic)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Topic must contain at least one letter.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StanceScreen(topic: topic, mode: widget.mode),
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
                // Left Column: Topic Selection
                Expanded(
                  flex: 2,
                  child: _buildTopicSelectionPanel(isDark, textPrimary, true),
                ),
                const SizedBox(width: 32),
                // Right Column: Instructions
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDeep : AppColors.surfaceDeepLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border(isDark)),
                    ),
                    child: _buildInstructionsPanel(isDark, textPrimary, true),
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
                // Left Column: Topic Selection
                Expanded(
                  flex: 2,
                  child: _buildTopicSelectionPanel(isDark, textPrimary, false),
                ),
                // Right Column: Instructions
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDeep : AppColors.surfaceDeepLight,
                      border: Border(
                        left: BorderSide(
                          color: isDark ? const Color(0x1AFFFFFF) : AppColors.border(isDark),
                        ),
                      ),
                    ),
                    child: _buildInstructionsPanel(isDark, textPrimary, false),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Mobile: Single column layout
    return Scaffold(
      appBar: AppBar(title: const Text('Pick a Topic')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose a Category',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat['label'];
                    final catColor = cat['color'] as Color;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedCategory = isSelected
                              ? null
                              : cat['label'] as String;
                          if (!isSelected) _customTopicCtrl.clear();
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? catColor : AppColors.surf(isDark),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected ? catColor : AppColors.border(isDark),
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: catColor.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              size: 14,
                              color: isSelected ? Colors.white : catColor,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              cat['label'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 36),
                Text(
                  'Or Enter a Custom Topic',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customTopicCtrl,
                  style: TextStyle(color: textPrimary),
                  onChanged: (_) => setState(() => _selectedCategory = null),
                  decoration: const InputDecoration(
                    labelText: 'e.g. "AI will replace doctors"',
                    prefixIcon: Icon(Icons.edit_note_rounded),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _nextStep,
                    child: Text(
                      'Next Step',
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
        ),
      ),
    );
  }

  Widget _buildTopicSelectionPanel(bool isDark, Color textPrimary, bool isWideDesktop) {
    return Padding(
      padding: isWideDesktop
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(48, 48, 48, 48),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Choose Your Topic',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a category or enter a custom debate topic',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary(isDark),
              ),
            ),
            const SizedBox(height: 32),
            // Categories
            Text(
              'Categories',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['label'];
                final catColor = cat['color'] as Color;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedCategory = isSelected
                          ? null
                          : cat['label'] as String;
                      if (!isSelected) _customTopicCtrl.clear();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? catColor : AppColors.surf(isDark),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? catColor : AppColors.border(isDark),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: catColor.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 18,
                          color: isSelected ? Colors.white : catColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat['label'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            // Custom Topic
            Text(
              'Custom Topic',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _customTopicCtrl,
              style: TextStyle(color: textPrimary),
              onChanged: (_) => setState(() => _selectedCategory = null),
              decoration: InputDecoration(
                labelText: 'e.g. "AI will replace doctors"',
                prefixIcon: const Icon(Icons.edit_note_rounded),
                filled: true,
                fillColor: AppColors.surf(isDark),
              ),
            ),
            const SizedBox(height: 40),
            // Next Button
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
                  'Continue to Stance',
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

  Widget _buildInstructionsPanel(bool isDark, Color textPrimary, bool isWideDesktop) {
    return Padding(
      padding: isWideDesktop
          ? const EdgeInsets.all(24)
          : const EdgeInsets.fromLTRB(32, 48, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How It Works',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _InstructionStep(
            step: '1',
            title: 'Choose Topic',
            description: 'Select a category or enter your own debate topic.',
            icon: Icons.topic_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          _InstructionStep(
            step: '2',
            title: 'Pick Stance',
            description: 'Decide whether you\'re for or against the topic.',
            icon: Icons.thumbs_up_down_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          _InstructionStep(
            step: '3',
            title: 'Debate',
            description: 'Challenge ClashBot with your arguments and see how you score!',
            icon: Icons.chat_bubble_rounded,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final String step;
  final String title;
  final String description;
  final IconData icon;
  final bool isDark;

  const _InstructionStep({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}