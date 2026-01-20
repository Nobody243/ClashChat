import 'dart:async';
import 'package:flutter/material.dart';

class DebateTimerService extends ChangeNotifier {
  Timer? _timer;
  int _totalSeconds = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _hasExpired = false;
  VoidCallback? onExpired;

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get hasExpired => _hasExpired;

  // Format as MM:SS
  String get formattedTime {
    final mins = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Color changes as time runs out
  Color get timerColor {
    if (_totalSeconds == 0) return Colors.green;
    final ratio = _remainingSeconds / _totalSeconds;
    if (ratio > 0.5) return Colors.green;
    if (ratio > 0.25) return Colors.orange;
    return Colors.red;
  }

  // Get elapsed time in minutes (actual time used)
  int get elapsedMinutes {
    final usedSeconds = _totalSeconds - _remainingSeconds;
    return (usedSeconds / 60).ceil();
  }

  // Get total timer minutes (original setting)
  int get totalMinutes => _totalSeconds > 0 ? (_totalSeconds / 60).ceil() : 0;

  void start(int minutes, {VoidCallback? onExpired}) {
    _totalSeconds = minutes * 60;
    _remainingSeconds = _totalSeconds;
    _isRunning = true;
    _hasExpired = false;
    this.onExpired = onExpired;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _isRunning = false;
        _hasExpired = true;
        _timer?.cancel();
        notifyListeners();
        this.onExpired?.call(); // trigger auto-end
      }
    });
  }

  void pause() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resume() {
    if (_remainingSeconds > 0) {
      _isRunning = true;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          notifyListeners();
        } else {
          _isRunning = false;
          _hasExpired = true;
          _timer?.cancel();
          notifyListeners();
          onExpired?.call(); // trigger auto-end
        }
      });
    }
  }

  void stop() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}