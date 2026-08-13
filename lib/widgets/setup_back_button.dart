import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/theme_provider.dart';

class SetupBackButton extends StatefulWidget {
  final VoidCallback? onPressed;
  const SetupBackButton({super.key, this.onPressed});

  @override
  State<SetupBackButton> createState() => _SetupBackButtonState();
}

class _SetupBackButtonState extends State<SetupBackButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (widget.onPressed != null) {
            widget.onPressed!();
          } else {
            Navigator.of(context).pop();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovering
                ? AppColors.primary.withValues(alpha: 0.25)
                : AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovering
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.primary.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: isDark ? Colors.white : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Back',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
