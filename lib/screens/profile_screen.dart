import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/app_colors.dart';
import '../core/theme_provider.dart';
import '../core/responsive_layout.dart';
import '../widgets/desktop_page_shell.dart';
import '../models/rank_model.dart';
import '../services/auth_service.dart';
import '../widgets/rank_badge_widget.dart';
import 'login_screen.dart';
import 'avatar_picker_screen.dart';
import 'change_password_screen.dart';
import 'create_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  bool _editMode = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data();
    if (data != null && mounted) {
      setState(() {
        _nameCtrl.text = data['displayName'] ?? 'Debater';
        _bioCtrl.text =
            data['bio'] ?? 'Passionate about ideas and the art of debate.';
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    final uid = AuthService.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'displayName': _nameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
      });
    }
    if (mounted)
      setState(() {
        _saving = false;
        _editMode = false;
      });
  }

  Future<void> _signOut() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _pickAvatar(String? currentSeed) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => AvatarPickerScreen(initialSeed: currentSeed),
      ),
    );
    if (result != null && mounted) {
      final uid = AuthService.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'avatarSeed': result,
          'photoUrl': FieldValue.delete(),
        });
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final textPrimary = AppColors.textPrimary(isDark);
    final uid = AuthService.currentUser?.uid ?? '';
    final email = AuthService.currentUser?.email ?? '';

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > ResponsiveLayout.desktopBreakpoint;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [AppColors.background, AppColors.surface]
              : [AppColors.backgroundLight, AppColors.surfaceDeepLight],
        ),
      ),
      child: SafeArea(
        top: !isDesktop,
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
          builder: (context, userSnap) {
            final userData =
                userSnap.data?.data() as Map<String, dynamic>? ?? {};
            final rankPoints = (userData['rankPoints'] ?? 0) as int;
            final rank = RankModel.getRankFromPoints(rankPoints);
            final rankData = RankModel.rankData[rank]!;
            final rankColor = Color(rankData['color'] as int);
            final rankProgress = RankModel.getRankProgress(rankPoints);
            final displayName = userData['displayName'] ?? 'Debater';
            final avatarSeed =
                userData['avatarSeed'] as String? ??
              userData['photoUrl'] as String?;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('debates')
                  .doc(uid)
                  .collection('history')
                  .snapshots(),
              builder: (context, debatesSnap) {
                final debates = debatesSnap.data?.docs ?? [];
                final totalDebates = debates.length;
                final wins = debates.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return (data['score'] ?? 0) >= 50;
                }).length;
                final losses = totalDebates - wins;
                final avgScore = totalDebates == 0
                    ? 0
                    : (debates.fold<int>(0, (sum, d) {
                                final data = d.data() as Map<String, dynamic>;
                                return sum + ((data['score'] ?? 0) as int);
                              }) /
                              totalDebates)
                          .round();
                final rankedDebates = debates.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return data['isRanked'] == true;
                }).length;

                Widget profileScroll({required EdgeInsets padding}) {
                  return SingleChildScrollView(
                    padding: padding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Profile',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: _editMode
                                ? _saveProfile
                                : () => setState(() => _editMode = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: _editMode
                                    ? const LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primaryLight,
                                        ],
                                      )
                                    : null,
                                color: _editMode
                                    ? null
                                    : AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: _editMode
                                      ? Colors.transparent
                                      : AppColors.primary.withOpacity(0.4),
                                ),
                              ),
                              child: _saving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _editMode ? 'Save' : 'Edit',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _editMode
                                            ? Colors.white
                                            : AppColors.primary,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                      const SizedBox(height: 24),

                      // ── Rank Card ────────────────────────────────────────
                      _RankCard(
                        displayName: displayName,
                        email: email,
                        rankPoints: rankPoints,
                        rankData: rankData,
                        rankColor: rankColor,
                        rankProgress: rankProgress,
                        isDark: isDark,
                        editMode: _editMode,
                        nameCtrl: _nameCtrl,
                        rankTier: rank,
                        avatarSeed: avatarSeed,
                        onEditAvatar: () => _pickAvatar(avatarSeed),
                      ),

                      const SizedBox(height: 24),

                      // ── Stats Section ────────────────────────────────────
                      _SectionLabel(
                        label: 'DEBATE STATS',
                        textPrimary: textPrimary,
                        delay: 100,
                      ),
                      const SizedBox(height: 12),

                      Row(
                            children: [
                              _StatBox(
                                label: 'Total',
                                value: '$totalDebates',
                                icon: Icons.sports_score_rounded,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 10),
                              _StatBox(
                                label: 'Wins',
                                value: '$wins',
                                icon: Icons.emoji_events_rounded,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 10),
                              _StatBox(
                                label: 'Losses',
                                value: '$losses',
                                icon: Icons.trending_down_rounded,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 10),
                              _StatBox(
                                label: 'Avg Score',
                                value: '$avgScore',
                                icon: Icons.analytics_rounded,
                                color: Colors.purple,
                              ),
                            ],
                          )
                          .animate(delay: 150.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1),

                      const SizedBox(height: 10),

                      // Ranked specific stat
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.military_tech_rounded,
                              size: 28,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ranked Matches',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                                Text(
                                  '$rankedDebates debates played',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              '$rankPoints pts total',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: rankColor,
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),

                      // ── Recent Debates ───────────────────────────────────
                      if (debates.isNotEmpty) ...[
                        _SectionLabel(
                          label: 'RECENT DEBATES',
                          textPrimary: textPrimary,
                          delay: 250,
                        ),
                        const SizedBox(height: 12),
                        ...debates.take(3).map((doc) {
                          final d = doc.data() as Map<String, dynamic>;
                          final score = d['score'] ?? 0;
                          final isWin = score >= 50;
                          return _RecentDebateRow(
                            topic: d['topic'] ?? '',
                            score: score,
                            isWin: isWin,
                            isRanked: d['isRanked'] ?? false,
                            pointsEarned: d['pointsEarned'] ?? 0,
                            isDark: isDark,
                          );
                        }),
                        const SizedBox(height: 24),
                      ],

                      // ── Bio Section ──────────────────────────────────────
                      _SectionLabel(
                        label: 'BIO',
                        textPrimary: textPrimary,
                        delay: 300,
                      ),
                      const SizedBox(height: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surf(isDark),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _editMode
                                ? AppColors.primary.withOpacity(0.5)
                                : AppColors.border(isDark),
                            width: _editMode ? 1.5 : 1,
                          ),
                        ),
                        child: TextField(
                          controller: _bioCtrl,
                          enabled: _editMode,
                          maxLines: 3,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: textPrimary,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Write something about yourself...',
                            hintStyle: GoogleFonts.poppins(
                              color: AppColors.textHint(isDark),
                            ),
                          ),
                        ),
                      ).animate(delay: 320.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),

                      // ── Account Section ──────────────────────────────────
                      _SectionLabel(
                        label: 'ACCOUNT',
                        textPrimary: textPrimary,
                        delay: 380,
                      ),
                      const SizedBox(height: 12),
                      _SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        label: 'Change Password',
                        isDark: isDark,
                        delay: 400,
                        onTap: () async {
                          final currentUser = AuthService.currentUser;
                          if (currentUser == null) return;

                          try {
                            final userDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentUser.uid)
                                .get();

                            final isGoogleSignIn =
                                userDoc.data()?['isGoogleSignIn'] as bool? ??
                                false;

                            if (!mounted) return;

                              if (isGoogleSignIn) {
                              if (!mounted) return;
                              // ignore: use_build_context_synchronously
                              final nav = Navigator.of(context);
                              // ignore: use_build_context_synchronously
                              nav.push(
                                MaterialPageRoute(
                                  builder: (_) => const CreatePasswordScreen(),
                                ),
                              );
                            } else {
                              if (!mounted) return;
                              // ignore: use_build_context_synchronously
                              final nav = Navigator.of(context);
                              // ignore: use_build_context_synchronously
                              nav.push(
                                MaterialPageRoute(
                                  builder: (_) => const ChangePasswordScreen(),
                                ),
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 28),

                      // Sign out button
                      SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _signOut,
                              icon: const Icon(Icons.logout_rounded),
                              label: Text(
                                'Sign Out',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: BorderSide(
                                  color: AppColors.error.withOpacity(0.5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          )
                          .animate(delay: 560.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1),

                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }

              final isWideDesktop = screenWidth >= ResponsiveLayout.wideDesktopBreakpoint;

              if (isWideDesktop) {
                return DesktopPageShell(
                  maxWidth: 800,
                  child: profileScroll(padding: EdgeInsets.zero),
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: profileScroll(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: isDesktop ? 12 : 20,
                    ),
                  ),
                ),
              );
          },
            );
          },
        ),
      ),
    );
  }
}

// ── Rank Card ─────────────────────────────────────────────────────────────────

class _RankCard extends StatelessWidget {
  final String displayName, email;
  final int rankPoints;
  final Map<String, dynamic> rankData;
  final Color rankColor;
  final double rankProgress;
  final bool isDark, editMode;
  final TextEditingController nameCtrl;
  final DebateRank rankTier;
  final String? avatarSeed;
  final VoidCallback onEditAvatar;

  const _RankCard({
    required this.displayName,
    required this.email,
    required this.rankPoints,
    required this.rankData,
    required this.rankColor,
    required this.rankProgress,
    required this.isDark,
    required this.editMode,
    required this.nameCtrl,
    required this.rankTier,
    required this.avatarSeed,
    required this.onEditAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [rankColor.withOpacity(0.4), rankColor.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: rankColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: rankColor.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with rank badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: onEditAvatar,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: rankColor.withOpacity(0.2),
                        border: Border.all(
                          color: rankColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: avatarSeed != null
                            ? SvgPicture.network(
                                'https://api.dicebear.com/9.x/bottts/svg?seed=$avatarSeed',
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                placeholderBuilder: (_) => const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 38,
                                ),
                              )
                            : const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 38,
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -8,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.surf(isDark),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: rankColor.withOpacity(0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: RankBadgeWidget(rank: rankTier, size: 28),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Editable name
                    editMode
                        ? TextField(
                            controller: nameCtrl,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              hintText: 'Your name',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.white54,
                              ),
                            ),
                          )
                        : Text(
                            displayName,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Rank badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: rankColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: rankColor.withOpacity(0.6)),
                      ),
                      child: Text(
                        '${rankData['name']}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar to next rank
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$rankPoints points',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    rankData['name'] == 'Grandmaster'
                        ? 'MAX RANK'
                        : 'Next: ${_nextRankName()}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: rankProgress,
                  minHeight: 10,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rankData['name'] == 'Grandmaster'
                    ? 'You are at the top!'
                    : '${(rankProgress * 100).toInt()}% to ${_nextRankName()}',
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 50.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  String _nextRankName() {
    final ranks = DebateRank.values;
    final current = RankModel.getRankFromPoints(rankPoints);
    final idx = ranks.indexOf(current);
    if (idx < ranks.length - 1) {
      return RankModel.rankData[ranks[idx + 1]]!['name'] as String;
    }
    return 'Grandmaster';
  }
}

// ── Stat Box ──────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recent Debate Row ─────────────────────────────────────────────────────────

class _RecentDebateRow extends StatelessWidget {
  final String topic;
  final int score, pointsEarned;
  final bool isWin, isRanked, isDark;

  const _RecentDebateRow({
    required this.topic,
    required this.score,
    required this.isWin,
    required this.isRanked,
    required this.pointsEarned,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWin ? Colors.green : Colors.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surf(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Row(
        children: [
          Icon(
            isWin ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    if (isRanked)
                      Text(
                        'Ranked  ',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber,
                        ),
                      ),
                    Text(
                      'Score: $score',
                      style: GoogleFonts.poppins(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isRanked)
            Text(
              '${pointsEarned >= 0 ? '+' : ''}$pointsEarned pts',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: color,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color textPrimary;
  final int delay;

  const _SectionLabel({
    required this.label,
    required this.textPrimary,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: textPrimary.withOpacity(0.45),
      ),
    ).animate(delay: delay.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}

// ── Settings Tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final int delay;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.delay,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surf(isDark),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(14),
        splashColor: AppColors.primary.withOpacity(0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border(isDark)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint(isDark),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: delay.ms).fadeIn(duration: 400.ms).slideY(begin: 0.06);
  }
}
