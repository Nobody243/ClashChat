import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/theme_provider.dart';
import '../core/responsive_layout.dart';
import '../widgets/desktop_page_shell.dart';
import 'chat_screen.dart';
import '../models/debate_mode.dart';

class DebateSetupScreen extends StatefulWidget {
  final String topic;
  final String stance;
  final DebateMode mode;

  const DebateSetupScreen({
    super.key,
    required this.topic,
    required this.stance,
    required this.mode,
  });

  @override
  State<DebateSetupScreen> createState() => _DebateSetupScreenState();
}

class _DebateSetupScreenState extends State<DebateSetupScreen> {
  String _difficulty = 'Medium';
  int? _timerMinutes; // null = no timer
  bool _timerEnabled = false;

  final List<Map<String, dynamic>> _difficulties = [
    {
      'name': 'Easy',
      'emoji': '🌱',
      'desc': 'AI is gentle and encouraging',
      'color': Colors.green,
    },
    {
      'name': 'Medium',
      'emoji': '⚔️',
      'desc': 'AI pushes back moderately',
      'color': Colors.orange,
    },
    {
      'name': 'Hard',
      'emoji': '🔥',
      'desc': 'AI is aggressive and sharp',
      'color': Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
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
                // Left Column: Topic recap and Settings
                Expanded(
                  flex: 2,
                  child: _buildSettingsPanel(isDark, true),
                ),
                const SizedBox(width: 32),
                // Right Column: Preview/Rules
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDeep : AppColors.surfaceDeepLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border(isDark)),
                    ),
                    child: _buildRulesPanel(isDark, true),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        body: Row(
          children: [
            // Left Column: Topic recap and Settings
            Expanded(
              child: _buildSettingsPanel(isDark, false),
            ),
            // Right Column: Preview/Rules
            Container(
              width: 340,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDeep : AppColors.surfaceDeepLight,
                border: Border(
                  left: BorderSide(
                    color: isDark ? const Color(0x1AFFFFFF) : AppColors.border(isDark),
                  ),
                ),
              ),
              child: _buildRulesPanel(isDark, false),
            ),
          ],
        ),
      );
    }

    // Mobile: Single column layout
    return Scaffold(
      appBar: AppBar(title: const Text('Debate Setup')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Topic recap
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.topic, color: Colors.blue),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.topic,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Arguing: ${widget.stance}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Difficulty selector
                    const Text(
                      'Difficulty',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: _difficulties.map((d) {
                        final isSelected = _difficulty == d['name'];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _difficulty = d['name']),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (d['color'] as Color).withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? d['color'] as Color
                                      : Colors.grey.withOpacity(0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    d['emoji'],
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    d['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? d['color'] as Color : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      d['desc'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),

                    if (widget.mode != DebateMode.learning) ...[
                      // Timer toggle
                      const Text(
                        'Timer',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Enable Timer'),
                        subtitle: Text(
                          _timerEnabled
                              ? 'Debate ends when time runs out'
                              : 'No time limit',
                        ),
                        value: _timerEnabled,
                        onChanged: (val) => setState(() {
                          _timerEnabled = val;
                          if (val) _timerMinutes = 10; // default
                        }),
                      ),

                      if (_timerEnabled) ...[
                        const SizedBox(height: 12),
                        Row(
                          children:
                              [5, 10, 15].map((mins) {
                                final isSelected = _timerMinutes == mins;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _timerMinutes = mins),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.blue.withOpacity(0.2)
                                            : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.timer, size: 20),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$mins min',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? Colors.blue : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList()..add(
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _showCustomTimePicker,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: (_timerMinutes != null && ![5, 10, 15].contains(_timerMinutes))
                                            ? Colors.blue.withOpacity(0.2)
                                            : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.edit, size: 20),
                                          const SizedBox(height: 4),
                                          Text(
                                            (_timerMinutes != null &&
                                                ![
                                                  5,
                                                  10,
                                                  15,
                                                ].contains(_timerMinutes))
                                                ? '$_timerMinutes min'
                                                : 'Custom',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      ],

                      const Spacer(),

                      // Start button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _startDebate,
                          child: const Text(
                            'Start Debate 🔥',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ] else ...[
                      const Spacer(),
                      // Start button for Learning Mode
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _startDebate,
                          child: const Text(
                            'Start Learning Session 📚',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsPanel(bool isDark, bool isWideDesktop) {
    return Padding(
      padding: isWideDesktop
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(48, 80, 48, 48),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Setup Your Debate',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure difficulty and timer settings',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary(isDark),
              ),
            ),
            const SizedBox(height: 32),
            // Topic recap
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.topic, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.topic,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary(isDark),
                          ),
                        ),
                        Text(
                          'Stance: ${widget.stance}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Difficulty selector
            Text(
              'Difficulty',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(isDark),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: _difficulties.map((d) {
                final isSelected = _difficulty == d['name'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _difficulty = d['name']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (d['color'] as Color).withOpacity(0.2)
                            : AppColors.surf(isDark).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? d['color'] as Color
                              : AppColors.border(isDark),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            d['emoji'],
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            d['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isSelected ? d['color'] as Color : AppColors.textPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              d['desc'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary(isDark),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (widget.mode != DebateMode.learning) ...[
              const SizedBox(height: 32),
              // Timer toggle
              Text(
                'Timer',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text(
                  'Enable Timer',
                  style: GoogleFonts.poppins(color: AppColors.textPrimary(isDark)),
                ),
                subtitle: Text(
                  _timerEnabled
                      ? 'Debate ends when time runs out'
                      : 'No time limit',
                  style: TextStyle(color: AppColors.textSecondary(isDark)),
                ),
                value: _timerEnabled,
                onChanged: (val) => setState(() {
                  _timerEnabled = val;
                  if (val) _timerMinutes = 10; // default
                }),
                activeColor: AppColors.primary,
              ),
              if (_timerEnabled) ...[
                const SizedBox(height: 12),
                Row(
                  children: [5, 10, 15].map((mins) {
                    final isSelected = _timerMinutes == mins;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _timerMinutes = mins),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.withOpacity(0.2)
                                : AppColors.surf(isDark).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.blue : AppColors.border(isDark),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.timer, size: 22),
                              const SizedBox(height: 6),
                              Text(
                                '$mins min',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.blue : AppColors.textPrimary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList()
                    ..add(
                      Expanded(
                        child: GestureDetector(
                          onTap: _showCustomTimePicker,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: (_timerMinutes != null && ![5, 10, 15].contains(_timerMinutes))
                                  ? Colors.blue.withOpacity(0.2)
                                  : AppColors.surf(isDark).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.border(isDark),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.edit, size: 22),
                                const SizedBox(height: 6),
                                Text(
                                  (_timerMinutes != null &&
                                      ![5, 10, 15].contains(_timerMinutes))
                                      ? '$_timerMinutes min'
                                      : 'Custom',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ),
              ],
            ],
            const SizedBox(height: 40),
            // Start button
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
                onPressed: _startDebate,
                child: Text(
                  widget.mode == DebateMode.learning
                      ? 'Start Learning Session 📚'
                      : 'Start Debate 🔥',
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

  Widget _buildRulesPanel(bool isDark, bool isWideDesktop) {
    return Padding(
      padding: isWideDesktop
          ? const EdgeInsets.fromLTRB(32, 48, 32, 32)
          : const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rules & Guidelines',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: 24),
          _RuleItem(
            isDark: isDark,
            icon: Icons.rule,
            title: 'Respectful Debate',
            description: 'Keep arguments civil and focused on facts, not personal attacks.',
          ),
          const SizedBox(height: 16),
          _RuleItem(
            isDark: isDark,
            icon: Icons.schedule,
            title: 'Time Management',
            description: 'Use your time wisely. Think before you type for better responses.',
          ),
          const SizedBox(height: 16),
          _RuleItem(
            isDark: isDark,
            icon: Icons.psychology,
            title: 'AI Behavior',
            description: 'The AI will match your selected difficulty and challenge your stance.',
          ),
        ],
      ),
    );
  }

  void _showCustomTimePicker() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Custom Timer'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter minutes (1-60)',
            suffixText: 'minutes',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final mins = int.tryParse(ctrl.text);
              if (mins != null && mins >= 1 && mins <= 60) {
                setState(() => _timerMinutes = mins);
                Navigator.pop(context);
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  void _startDebate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          topic: widget.topic,
          stance: widget.stance,
          difficulty: _difficulty,
          timerMinutes: _timerEnabled ? _timerMinutes : null,
          mode: widget.mode,
        ),
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String description;

  const _RuleItem({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surf(isDark).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}