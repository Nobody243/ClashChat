import 'package:flutter/material.dart';
import '../services/timer_service.dart';

class DebateTimerWidget extends StatelessWidget {
  final DebateTimerService timerService;

  const DebateTimerWidget({super.key, required this.timerService});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: timerService,
      builder: (context, _) {
        final isLow = timerService.remainingSeconds <= 30 && timerService.remainingSeconds > 0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: timerService.timerColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: timerService.timerColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLow ? Icons.timer_off : Icons.timer,
                color: timerService.timerColor,
                size: 16,
              ),
              const SizedBox(width: 6),
              // Pulse animation when low
              isLow
                  ? _PulsingText(
                      text: timerService.formattedTime,
                      color: timerService.timerColor,
                    )
                  : Text(
                      timerService.formattedTime,
                      style: TextStyle(
                        color: timerService.timerColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}

class _PulsingText extends StatefulWidget {
  final String text;
  final Color color;
  const _PulsingText({required this.text, required this.color});

  @override
  State<_PulsingText> createState() => _PulsingTextState();
}

class _PulsingTextState extends State<_PulsingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Text(
        widget.text,
        style: TextStyle(
          color: widget.color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
