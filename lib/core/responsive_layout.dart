import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'app_colors.dart';

/// A responsive layout widget that switches between mobile and desktop layouts
/// based on screen width. Desktop layout uses a fixed left sidebar navigation.
class ResponsiveLayout extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigationChanged;
  final List<Widget> screens;

  const ResponsiveLayout({
    super.key,
    required this.currentIndex,
    required this.onNavigationChanged,
    required this.screens,
  });

  static const double desktopBreakpoint = 850.0;
  static const double wideDesktopBreakpoint = 1024.0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > desktopBreakpoint;

    if (isDesktop) {
      return _DesktopScaffold(
        currentIndex: currentIndex,
        onNavigationChanged: onNavigationChanged,
        screens: screens,
      );
    }

    return _MobileScaffold(
      currentIndex: currentIndex,
      onNavigationChanged: onNavigationChanged,
      screens: screens,
    );
  }
}

class _DesktopScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigationChanged;
  final List<Widget> screens;

  const _DesktopScaffold({
    required this.currentIndex,
    required this.onNavigationChanged,
    required this.screens,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      body: Row(
        children: [
          // Fixed Left Sidebar Navigation
          _SidebarNavigation(
            currentIndex: currentIndex,
            onNavigationChanged: onNavigationChanged,
            isDark: isDark,
          ),
          // Main Content Area
          Expanded(
            child: screens[currentIndex],
          ),
        ],
      ),
    );
  }
}

class _MobileScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigationChanged;
  final List<Widget> screens;

  const _MobileScaffold({
    required this.currentIndex,
    required this.onNavigationChanged,
    required this.screens,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      body: screens[currentIndex],
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
          selectedIndex: currentIndex,
          onDestinationSelected: onNavigationChanged,
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

class _SidebarNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigationChanged;
  final bool isDark;

  const _SidebarNavigation({
    required this.currentIndex,
    required this.onNavigationChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDeep : AppColors.surfaceLight,
        border: Border(
          right: BorderSide(
            color: isDark ? const Color(0x1AFFFFFF) : AppColors.border(isDark),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // App Logo/Header
          Container(
            height: kToolbarHeight + 40,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0x1AFFFFFF) : AppColors.border(isDark),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.gold],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'ClashChat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _SidebarNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  onTap: () => onNavigationChanged(0),
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _SidebarNavItem(
                  icon: Icons.history_rounded,
                  label: 'History',
                  isSelected: currentIndex == 1,
                  onTap: () => onNavigationChanged(1),
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _SidebarNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: currentIndex == 2,
                  onTap: () => onNavigationChanged(2),
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _SidebarNavItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: currentIndex == 3,
                  onTap: () => onNavigationChanged(3),
                  isDark: isDark,
                ),
              ],
            ),
          ),
          // Theme Toggle at Bottom
          Padding(
            padding: const EdgeInsets.all(16),
            child: _SidebarNavItem(
              icon: Icons.brightness_6_rounded,
              label: 'Toggle Theme',
              isSelected: false,
              onTap: () => context.read<ThemeProvider>().toggle(),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? Colors.white70
                        : AppColors.textSecondary(isDark)),
                size: 22,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? Colors.white70
                          : AppColors.textSecondary(isDark)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}