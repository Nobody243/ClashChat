import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'topic_screen.dart';
import '../core/app_colors.dart';
import '../core/theme_provider.dart';
import '../widgets/user_avatar.dart';
import '../services/auth_service.dart';
import '../services/usage_quota_service.dart';
import '../models/rank_model.dart';
import '../models/debate_mode.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _navIndex = 0;
  final GlobalKey<_HomeBodyState> _homeBodyKey = GlobalKey<_HomeBodyState>();

  late AnimationController _fabAnimCtrl;

  @override
  void initState() {
    super.initState();
    _fabAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();
  }

  @override
  void dispose() {
    _fabAnimCtrl.dispose();
    super.dispose();
  }

  void _onNavTap(int i) {
    if (i == _navIndex) return;
    _fabAnimCtrl.reverse().then((_) {
      setState(() => _navIndex = i);
      _fabAnimCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        ),
        child: switch (_navIndex) {
          1 => const HistoryScreen(),
          2 => const ProfileScreen(),
          3 => const SettingsScreen(),
          _ => _HomeBody(key: _homeBodyKey),
        },
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.surfaceLight,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _navIndex,
          onDestinationSelected: _onNavTap,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody({super.key});

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerCtrl;
  late List<Animation<double>> _staggerAnims;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _staggerAnims = List.generate(4, (i) {
      final start = i * 0.15;
      final end = (start + 0.55).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _staggerCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });
    _staggerCtrl.forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  Widget _animated(int index, Widget child) {
    final anim = _staggerAnims[index.clamp(0, _staggerAnims.length - 1)];
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

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
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(AuthService.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() as Map<String, dynamic>?;
            final firestoreDisplayName = data?['displayName'] as String?;
            final authDisplayName = AuthService.currentUser?.displayName;
            final displayName =
                firestoreDisplayName ?? authDisplayName ?? 'Debater';
            final avatarSeed = data?['avatarSeed'] as String? ?? 'Felix';
            final points = data?['rankPoints'] ?? 0;
          final quota = UsageQuotaService.fromData(data);
          final isQuotaLocked = quota.isLocked;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _animated(
                    0,
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: _HeroCard(
                        displayName: displayName,
                        avatarSeed: avatarSeed,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverToBoxAdapter(
                  child: _animated(
                    1,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: RankBadgeWidget(points: points),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: _animated(
                    2,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _UsageCard(quota: quota),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
                SliverToBoxAdapter(
                  child: _animated(
                    3,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _ModeCard(
                        title: 'Casual Mode',
                        subtitle:
                            isQuotaLocked
                                ? 'Daily usage exhausted. Come back tomorrow for a fresh quota.'
                                : 'Practice with custom timers & difficulties. No points at risk.',
                        icon: Icons.coffee,
                        textalignment: TextAlign.right,
                        color: Colors.blue,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const TopicScreen(mode: DebateMode.casual),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: _animated(
                    4,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _ModeCard(
                        title: 'Ranked Mode',
                        subtitle:
                            isQuotaLocked
                                ? 'Daily usage exhausted. Your next debate unlocks after reset.'
                                : '10 min fixed timer. Difficulty matches your rank. Win points to rank up!',
                        icon: Icons.emoji_events,
                        textalignment: TextAlign.right,
                        color: Colors.amber,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const TopicScreen(mode: DebateMode.ranked),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: _animated(
                    5,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _ModeCard(
                        title: 'Learning Mode',
                        subtitle:
                            isQuotaLocked
                                ? 'Daily usage exhausted. Learning mode will reopen after reset.'
                                : 'Learn the art of debate. Get real-time feedback, tips, and logical coaching.',
                        icon: Icons.school_rounded,
                        textalignment: TextAlign.right,
                        color: const Color(0xFF0F6E56),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const TopicScreen(mode: DebateMode.learning),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _UsageCard extends StatelessWidget {
  final UsageQuotaState quota;

  const _UsageCard({required this.quota});

  @override
  Widget build(BuildContext context) {
    final isEmpty = quota.isLocked;
    final color = isEmpty ? AppColors.error : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isEmpty ? Icons.lock_rounded : Icons.local_fire_department_rounded,
                color: color,
              ),
              const SizedBox(width: 10),
              Text(
                'Daily usage',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                '${quota.usedToday}/${quota.dailyLimit}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: quota.progress,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.14),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isEmpty
                ? 'You have used all available uses for today.'
                : '${quota.remainingToday} uses left today.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(context.watch<ThemeProvider>().isDark),
            ),
          ),
        ],
      ),
    );
  }
}

class RankBadgeWidget extends StatelessWidget {
  final int points;
  const RankBadgeWidget({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final rank = RankModel.getRankFromPoints(points);
    final rankData = RankModel.rankData[rank]!;
    final progress = RankModel.getRankProgress(points);
    final color = Color(rankData['color'] as int);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            rankData['emoji'] as String,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rankData['name'] as String,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$points Points',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation(color),
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

class _ModeCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final TextAlign textalignment;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.textalignment,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// Premium Hero Stats Card
// ══════════════════════════════════════════════════════════
class _HeroCard extends StatelessWidget {
  final String displayName;
  final String avatarSeed;
  const _HeroCard({this.displayName = 'Debater', this.avatarSeed = 'Felix'});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.primary, AppColors.surfaceDeep]
              : [AppColors.primary, AppColors.gold],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -18,
            right: -18,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: 60,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                                'Welcome back,',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              )
                              .animate()
                              .fadeIn(
                                duration: 400.ms,
                                curve: Curves.easeOutExpo,
                              )
                              .slideY(
                                begin: 0.1,
                                duration: 400.ms,
                                curve: Curves.easeOutExpo,
                              ),
                          const SizedBox(height: 2),
                          Text(
                                displayName,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              )
                              .animate(delay: 50.ms)
                              .fadeIn(
                                duration: 400.ms,
                                curve: Curves.easeOutExpo,
                              )
                              .slideY(
                                begin: 0.1,
                                duration: 400.ms,
                                curve: Curves.easeOutExpo,
                              ),
                        ],
                      ),
                    ),
                    UserAvatar(seed: avatarSeed, size: 48)
                        .animate(delay: 100.ms)
                        .fadeIn(duration: 400.ms, curve: Curves.easeOutExpo)
                        .scaleXY(
                          begin: 0.8,
                          duration: 400.ms,
                          curve: Curves.easeOutExpo,
                        ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
