import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/theme_provider.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Pick a Topic')),
      body: SingleChildScrollView(
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
    );
  }
}
