import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/theme_provider.dart';
import '../core/responsive_layout.dart';
import '../widgets/desktop_page_shell.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final textPrimary = AppColors.textPrimary(isDark);
    final textSecondary = AppColors.textSecondary(isDark);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > ResponsiveLayout.desktopBreakpoint;
    final isWideDesktop = screenWidth >= ResponsiveLayout.wideDesktopBreakpoint;

    Widget settingsScroll({required EdgeInsets padding}) {
      return SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                  'Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms, curve: Curves.easeOutExpo)
                .slideY(
                  begin: 0.1,
                  duration: 400.ms,
                  curve: Curves.easeOutExpo,
                ),
            const SizedBox(height: 28),

            _SectionLabel(label: 'Appearance', textColor: textSecondary)
                .animate(delay: 50.ms)
                .fadeIn(duration: 400.ms, curve: Curves.easeOutExpo)
                .slideY(
                  begin: 0.1,
                  duration: 400.ms,
                  curve: Curves.easeOutExpo,
                ),
            const SizedBox(height: 10),
            _SettingsTile(
                  isDark: isDark,
                  icon: isDark
                      ? Icons.nightlight_round
                      : Icons.wb_sunny_rounded,
                  iconColor: isDark
                      ? const Color(0xFF9B59B6)
                      : const Color(0xFFFFA500),
                  title: 'Dark Mode',
                  titleColor: textPrimary,
                  trailing: Switch.adaptive(
                    value: isDark,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primary,
                    onChanged: (_) => context.read<ThemeProvider>().toggle(),
                  ),
                )
                .animate(delay: 100.ms)
                .fadeIn(duration: 400.ms, curve: Curves.easeOutExpo)
                .slideY(
                  begin: 0.1,
                  duration: 400.ms,
                  curve: Curves.easeOutExpo,
                ),


            const SizedBox(height: 20),
            _SectionLabel(label: 'About', textColor: textSecondary)
                .animate(delay: 350.ms)
                .fadeIn(duration: 400.ms, curve: Curves.easeOutExpo)
                .slideY(
                  begin: 0.1,
                  duration: 400.ms,
                  curve: Curves.easeOutExpo,
                ),
            const SizedBox(height: 10),
            _SettingsTile(
                  isDark: isDark,
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.primary,
                  title: 'App Version',
                  titleColor: textPrimary,
                  subtitle: '1.0.0',
                  subtitleColor: textSecondary,
                )
                .animate(delay: 400.ms)
                .fadeIn(duration: 400.ms, curve: Curves.easeOutExpo)
                .slideY(
                  begin: 0.1,
                  duration: 400.ms,
                  curve: Curves.easeOutExpo,
                ),
            const SizedBox(height: 8),
            _SettingsTile(
                  isDark: isDark,
                  icon: Icons.privacy_tip_outlined,
                  iconColor: AppColors.secondary,
                  title: 'Privacy Policy',
                  titleColor: textPrimary,
                  onTap: () {},
                )
                .animate(delay: 450.ms)
                .fadeIn(duration: 400.ms, curve: Curves.easeOutExpo)
                .slideY(
                  begin: 0.1,
                  duration: 400.ms,
                  curve: Curves.easeOutExpo,
                ),
            const SizedBox(height: 8),
            _SettingsTile(
                  isDark: isDark,
                  icon: Icons.description_outlined,
                  iconColor: AppColors.textSecondary(isDark),
                  title: 'Terms of Service',
                  titleColor: textPrimary,
                  onTap: () {},
                )
                .animate(delay: 500.ms)
                .fadeIn(duration: 400.ms, curve: Curves.easeOutExpo)
                .slideY(
                  begin: 0.1,
                  duration: 400.ms,
                  curve: Curves.easeOutExpo,
                ),

            const SizedBox(height: 40),
          ],
        ),
      );
    }

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
        child: isWideDesktop
            ? DesktopPageShell(
                maxWidth: 800,
                child: settingsScroll(padding: EdgeInsets.zero),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: settingsScroll(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: isDesktop ? 12 : 20,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color textColor;
  const _SectionLabel({required this.label, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.titleColor,
    this.subtitle,
    this.subtitleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppColors.surf(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(isDark)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: GoogleFonts.poppins(fontSize: 12, color: subtitleColor),
              )
            : null,
        trailing:
            trailing ??
            (onTap != null
                ? Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textHint(isDark),
                  )
                : null),
      ),
    );
  }
}
