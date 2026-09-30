import 'dart:async';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum FocusMode { timer, stopwatch, pomodoro }

enum SessionState { idle, running, paused, onBreak, completed }

// ─────────────────────────────────────────────────────────────────────────────
// TimerService — reactive ChangeNotifier
// ─────────────────────────────────────────────────────────────────────────────

class TimerService extends ChangeNotifier {
  // ── Configuration ──────────────────────────────────────────────────────
  FocusMode _mode = FocusMode.timer;
  Duration _workDuration = const Duration(minutes: 30);
  Duration _breakDuration = const Duration(minutes: 5);
  int _totalCycles = 4;

  // ── Runtime state ──────────────────────────────────────────────────────
  SessionState _state = SessionState.idle;
  Duration _phaseDuration = const Duration(minutes: 30);
  Duration _elapsed = Duration.zero;
  int _currentCycle = 1;
  bool _isBreakPhase = false;
  Duration _totalFocused = Duration.zero; // accumulated focus time

  Timer? _ticker;

  // ── Getters ────────────────────────────────────────────────────────────
  FocusMode get mode => _mode;
  SessionState get state => _state;
  Duration get elapsed => _elapsed;
  Duration get totalFocused => _totalFocused;
  int get currentCycle => _currentCycle;
  int get totalCycles => _totalCycles;
  bool get isBreakPhase => _isBreakPhase;
  bool get isRunning => _state == SessionState.running;
  bool get isActive => _state != SessionState.idle && _state != SessionState.completed;

  Duration get remaining {
    if (_mode == FocusMode.stopwatch) return _elapsed;
    final r = _phaseDuration - _elapsed;
    return r.isNegative ? Duration.zero : r;
  }

  double get progress {
    if (_mode == FocusMode.stopwatch || _phaseDuration.inSeconds == 0) return 0;
    return (_elapsed.inSeconds / _phaseDuration.inSeconds).clamp(0.0, 1.0);
  }

  String get phaseLabel {
    if (_mode == FocusMode.pomodoro) {
      return _isBreakPhase
          ? 'Break $_currentCycle / $_totalCycles'
          : 'Focus $_currentCycle / $_totalCycles';
    }
    if (_mode == FocusMode.stopwatch) return 'Stopwatch';
    return 'Focus';
  }

  // ── Configuration ──────────────────────────────────────────────────────
  void configure({
    FocusMode? mode,
    Duration? workDuration,
    Duration? breakDuration,
    int? cycles,
  }) {
    _mode = mode ?? _mode;
    _workDuration = workDuration ?? _workDuration;
    _breakDuration = breakDuration ?? _breakDuration;
    _totalCycles = cycles ?? _totalCycles;
    _phaseDuration = _workDuration;
    notifyListeners();
  }

  // ── Controls ───────────────────────────────────────────────────────────
  void start() {
    _elapsed = Duration.zero;
    _totalFocused = Duration.zero;
    _currentCycle = 1;
    _isBreakPhase = false;
    _phaseDuration = _workDuration;
    _state = SessionState.running;
    _tick();
    notifyListeners();
  }

  void pause() {
    _ticker?.cancel();
    _state = SessionState.paused;
    notifyListeners();
  }

  void resume() {
    _state = _isBreakPhase ? SessionState.onBreak : SessionState.running;
    _tick();
    notifyListeners();
  }

  void stop() {
    _ticker?.cancel();
    _state = SessionState.idle;
    _elapsed = Duration.zero;
    notifyListeners();
  }

  // ── Internal tick loop ─────────────────────────────────────────────────
  void _tick() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed += const Duration(seconds: 1);

      // Accumulate actual focus time (not break time)
      if (!_isBreakPhase) {
        _totalFocused += const Duration(seconds: 1);
      }

      // Stopwatch never completes on its own
      if (_mode == FocusMode.stopwatch) {
        notifyListeners();
        return;
      }

      // Check phase completion
      if (_elapsed >= _phaseDuration) {
        _onPhaseEnd();
        return;
      }
      notifyListeners();
    });
  }

  void _onPhaseEnd() {
    _ticker?.cancel();

    if (_mode == FocusMode.pomodoro) {
      if (_isBreakPhase) {
        // Break finished → next work phase or done
        if (_currentCycle >= _totalCycles) {
          _state = SessionState.completed;
        } else {
          _currentCycle++;
          _isBreakPhase = false;
          _elapsed = Duration.zero;
          _phaseDuration = _workDuration;
          _state = SessionState.running;
          _tick();
        }
      } else {
        // Work finished → break
        _isBreakPhase = true;
        _elapsed = Duration.zero;
        _phaseDuration = _breakDuration;
        _state = SessionState.onBreak;
        _tick();
      }
    } else {
      // Timer mode — session done
      _state = SessionState.completed;
    }
    notifyListeners();
  }

  // ── Formatting helpers ─────────────────────────────────────────────────
  static String fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static String fmtLong(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
