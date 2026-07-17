import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'results_screen.dart';
import 'home_screen.dart';
import '../core/app_colors.dart';
import '../core/theme_provider.dart';
import '../models/chat_message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_input_bar.dart';
import '../services/ai_service.dart';
import '../services/auth_service.dart';
import '../services/timer_service.dart';
import '../services/usage_quota_service.dart';
import '../widgets/debate_timer_widget.dart';
import '../models/rank_model.dart';
import '../models/debate_mode.dart';

class ChatScreen extends StatefulWidget {
  final String topic;
  final String stance;
  final String difficulty;
  final int? timerMinutes;
  final DebateMode mode;

  const ChatScreen({
    super.key,
    required this.topic,
    required this.stance,
    required this.difficulty,
    this.timerMinutes,
    required this.mode,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isAiTyping = false;
  bool _isEnding = false;

  late DebateTimerService _timerService;

  late AnimationController _headerAnimCtrl;
  late Animation<double> _headerFadeAnim;
  late Animation<Offset> _headerSlideAnim;

  @override
  void initState() {
    super.initState();
    _headerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _headerFadeAnim = CurvedAnimation(
      parent: _headerAnimCtrl,
      curve: Curves.easeIn,
    );
    _headerSlideAnim =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _headerAnimCtrl, curve: Curves.easeOutCubic),
        );
    _headerAnimCtrl.forward();

    _timerService = DebateTimerService();
    if (widget.timerMinutes != null) {
      _timerService.start(
        widget.timerMinutes!,
        onExpired: () => _onTimerExpired(),
      );
    }

    Future.delayed(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      setState(() => _isAiTyping = true);

      final opener = await AiService.sendDebateMessage(
        topic: widget.topic,
        userStance: widget.stance,
        history: [],
        userMessage: 'Start the debate with a strong opening challenge.',
        difficulty: widget.difficulty,
        isLearningMode: widget.mode == DebateMode.learning,
      );

      if (!mounted) return;
      setState(() {
        _isAiTyping = false;
        _messages.add(opener);
      });
      _scrollToBottom();
    });
  }


  void _onTimerExpired() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("⏱️ Time's up! Calculating your score..."),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _scoreAndEndDebate();
    });
  }

  @override
  void dispose() {
    _timerService.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _headerAnimCtrl.dispose();
    super.dispose();
  }

  void _showExitDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _ThemedDialog(
        title: 'End debate?',
        content: 'If you leave now the debate will be ended.',
        actions: [('Cancel', null), ('End debate', Colors.red)],
        onActionSelected: (index) async {
          if (index == 1) {
            Navigator.of(dialogContext).pop();
            await _scoreAndEndDebate();
          } else {
            Navigator.of(dialogContext).pop(false);
          }
        },
      ),
    );
  }

  Future<void> _completeDebateSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final sessionDoc = FirebaseFirestore.instance
        .collection('debates')
        .doc(user.uid)
        .collection('session')
        .doc('active');

    await sessionDoc.set({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'topic': widget.topic,
      'stance': widget.stance,
      'difficulty': widget.difficulty,
      'mode': widget.mode.name,
    }, SetOptions(merge: true));
  }

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    if (!await UsageQuotaService.consume(currentUser.uid)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Daily usage exhausted. You have no debate uses left today.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _inputCtrl.clear();
      _isAiTyping = true;
    });

    // Call real Gemini AI
    final aiReply = await AiService.sendDebateMessage(
      topic: widget.topic,
      userStance: widget.stance,
      history: _messages,
      userMessage: text,
      difficulty: widget.difficulty,
      isLearningMode: widget.mode == DebateMode.learning,
    );

    if (!mounted) return;
    setState(() {
      _isAiTyping = false;
      _messages.add(aiReply);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _scoreAndEndDebate() async {
    if (_isEnding) return;
    setState(() => _isEnding = true);

    final currentUser = AuthService.currentUser;
    if (currentUser == null) {
      setState(() => _isEnding = false);
      return;
    }

    if (!await UsageQuotaService.consume(currentUser.uid)) {
      if (!mounted) return;
      setState(() => _isEnding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Daily usage exhausted. You cannot generate a score right now.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = context.watch<ThemeProvider>().isDark;
        return Dialog(
          backgroundColor: AppColors.surf(isDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 4,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Analyzing Logic...',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(isDark),
                  ),
                ).animate(onPlay: (ctrl) => ctrl.repeat(reverse: true)).fade(duration: 800.ms, begin: 0.5, end: 1.0),
                const SizedBox(height: 8),
                Text(
                  'Generating personalized feedback',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textHint(isDark),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    final result = await AiService.scoreDebate(
      topic: widget.topic,
      userStance: widget.stance,
      messages: _messages,
      difficulty: widget.difficulty,
    );

    if (!mounted) return;
    Navigator.of(context).pop(); // close loading

    debugPrint('📊 SCORE RESULT: ${result['score']} (Type: ${result['score'].runtimeType})');
    debugPrint('📊 FULL RESULT: $result');

    final finalScore = result['score'] is int
        ? result['score'] as int
        : int.tryParse(result['score'].toString()) ?? 65;
    final strengths = (result['strengths'] as List?)?.map((item) => item.toString()).toList() ?? const <String>[];
    final weaknesses = (result['weaknesses'] as List?)?.map((item) => item.toString()).toList() ?? const <String>[];
    final summary = result['summary']?.toString() ?? 'Debate completed';

    // Get current rank before updating points
    String currentRank = 'Newcomer';
    int pointsEarned = 0;
    if (widget.mode == DebateMode.ranked) {
      pointsEarned = RankModel.calculatePointsEarned(finalScore, true);
      try {
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(userDocRef);
          if (!snapshot.exists) return;
          final currentPoints = (snapshot.data()?['rankPoints'] as num?)?.toInt() ?? 0;
          // Get rank at time BEFORE points update
          final rankAtTime = RankModel.getRankFromPoints(currentPoints);
          currentRank = RankModel.rankData[rankAtTime]!['name'] as String;
          final newPoints = currentPoints + pointsEarned;
          transaction.update(userDocRef, {'rankPoints': newPoints < 0 ? 0 : newPoints});
        });
      } catch (e) {
        debugPrint('Error updating rank points: $e');
      }
    }

    await _completeDebateSession();

    // Calculate duration: use elapsed time if timer was running, otherwise estimate from messages
    final int durationMinutes = widget.timerMinutes != null
        ? _timerService.elapsedMinutes
        : ((_messages.length * 2) / 60).ceil(); // estimate 2 seconds per message

    debugPrint('💾 SAVING TO FIRESTORE - Score: $finalScore (Type: ${finalScore.runtimeType})');
    debugPrint('⏱️ TIMER DURATION: $durationMinutes minutes');
    await FirebaseFirestore.instance
        .collection('debates')
        .doc(currentUser.uid)
        .collection('history')
        .add({
          'topic': widget.topic,
          'stance': widget.stance,
          'difficulty': widget.difficulty,
          'score': finalScore,
          'mode': widget.mode.name,
          'summary': summary,
          'strengths': strengths,
          'weaknesses': weaknesses,
          'messageCount': _messages.length,
          'date': DateTime.now().toIso8601String(),
          'status': 'completed',
          'isRanked': widget.mode == DebateMode.ranked,
          'pointsEarned': pointsEarned,
          'timerMinutes': widget.timerMinutes,
          'durationMinutes': durationMinutes,
          'rankAtTime': currentRank,
          'messages': _messages
              .map(
                (m) => {
                  'text': m.text,
                  'isUser': m.isUser,
                  'timestamp': m.timestamp.toIso8601String(),
                  'coachTip': m.coachTip,
                },
              )
              .toList(),
        });

    if (!mounted) return;

    if (widget.mode == DebateMode.learning) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
        (_) => false,
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) {
          debugPrint(
            '🎯 FINAL SCORE FOR RESULTS SCREEN: $finalScore (Type: ${finalScore.runtimeType})',
          );
          debugPrint(
            '🎯   Raw result score was: ${result['score']} (Type: ${result['score'].runtimeType})',
          );
          // Create a copy of messages to prevent clearing issues
          final messagesCopy = List<ChatMessage>.from(_messages);
          return ResultsScreen(
            topic: widget.topic,
            stance: widget.stance,
            messages: messagesCopy,
            score: finalScore,
            strengths: List<String>.from(result['strengths'] ?? []),
            weaknesses: List<String>.from(result['weaknesses'] ?? []),
            summary: result['summary'] ?? '',
            difficulty: widget.difficulty,
            pointsEarned: pointsEarned,
            mode: widget.mode,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final stanceColor = widget.stance == 'For'
        ? AppColors.success
        : AppColors.error;
    final bgStart = isDark
        ? const Color(0xFF1A1A2E)
        : AppColors.backgroundLight;
    final bgEnd = isDark ? const Color(0xFF0F3460) : AppColors.surfaceDeepLight;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _showExitDialog(context);
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 8),
          child: FadeTransition(
            opacity: _headerFadeAnim,
            child: SlideTransition(
              position: _headerSlideAnim,
              child: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => _showExitDialog(context),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.topic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(top: 3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: stanceColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: stanceColor.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        widget.stance,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: stanceColor,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  if (widget.timerMinutes != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: DebateTimerWidget(timerService: _timerService),
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'end':
                          _showExitDialog(context);
                          break;
                        case 'theme':
                          context.read<ThemeProvider>().toggle();
                          break;
                        case 'pause':
                          _timerService.isRunning
                              ? _timerService.pause()
                              : _timerService.resume();
                          break;
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'end',
                        child: Row(children: [
                          Icon(Icons.stop_circle, color: Colors.red),
                          SizedBox(width: 10),
                          Text('End Debate'),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'pause',
                        child: Row(children: [
                          Icon(
                            _timerService.isRunning
                                ? Icons.pause_circle
                                : Icons.play_circle,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Text(_timerService.isRunning ? 'Pause Timer' : 'Resume Timer'),
                        ]),
                      ),
                      const PopupMenuItem(
                        value: 'theme',
                        child: Row(children: [
                          Icon(Icons.brightness_6),
                          SizedBox(width: 10),
                          Text('Toggle Theme'),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: _messages.length + (_isAiTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isAiTyping) {
                      return const TypingIndicator();
                    }
                    final message = _messages[index];
                    final prevMsg = index > 0 ? _messages[index - 1] : null;
                    final isGrouped = prevMsg?.isUser == message.isUser;
                    return MessageBubble(
                      message: message,
                      isGrouped: isGrouped,
                    );
                  },
                ),
              ),
              ChatInputBar(controller: _inputCtrl, onSend: _sendMessage)
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 400.ms, curve: Curves.easeOutExpo)
                  .slideY(
                    begin: 0.1,
                    duration: 400.ms,
                    curve: Curves.easeOutExpo,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// Themed Dialog Widget
// ══════════════════════════════════════════════════════════
class _ThemedDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<(String, Color?)> actions;
  final Future<void> Function(int)? onActionSelected;

  const _ThemedDialog({
    required this.title,
    required this.content,
    required this.actions,
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final textPrimary = AppColors.textPrimary(isDark);
    final textSecondary = AppColors.textSecondary(isDark);

    return Dialog(
      backgroundColor: AppColors.surf(isDark),
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
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: GoogleFonts.poppins(fontSize: 14, color: textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(actions.length, (index) {
                final (label, color) = actions[index];
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
                  child: TextButton(
                    onPressed: () async {
                      if (onActionSelected != null) {
                        await onActionSelected!(index);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: color ?? AppColors.primary,
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