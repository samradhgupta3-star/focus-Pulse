import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/timer_service.dart';
import '../services/enforcement_service.dart';
import '../widgets/focus_progress_ring.dart';

class ActiveSessionScreen extends StatelessWidget {
  final TimerService timerService;

  const ActiveSessionScreen({super.key, required this.timerService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: timerService,
          builder: (context, _) {
            final remainingStr = TimerService.fmt(timerService.remaining);
            final phaseLabel = timerService.phaseLabel;
            final isRunning = timerService.isRunning;
            final isCompleted = timerService.state == SessionState.completed;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Top bar: Back / Minimize button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: timerService.isBreakPhase ? AppColors.amber.withOpacity(0.15) : AppColors.cardGreen,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          phaseLabel,
                          style: TextStyle(
                            color: timerService.isBreakPhase ? AppColors.amber : AppColors.greenLight,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // balance spacer
                    ],
                  ),
                  const Spacer(),

                  // Main Interactive Ring
                  FocusProgressRing(
                    progress: timerService.mode == FocusMode.stopwatch 
                        ? 1.0 
                        : (1.0 - timerService.progress),
                    size: 260,
                    strokeWidth: 20,
                    timeText: isCompleted ? "Done!" : remainingStr,
                    goalText: isCompleted 
                        ? 'Great job!' 
                        : (timerService.isBreakPhase ? 'Take a rest' : 'Stay Focused'),
                  ),
                  const Spacer(),

                  // Quotes / State Message
                  Text(
                    timerService.isBreakPhase
                        ? "Rest your eyes, hydrate, and stretch."
                        : "Apps and distracting websites are locked.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Session Control Actions
                  if (!isCompleted)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Give Up / Cancel
                        IconButton.filledTonal(
                          onPressed: () {
                            EnforcementService.stopEnforcement();
                            timerService.stop();
                            Navigator.pop(context);
                          },
                          iconSize: 26,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.cardElevated,
                            foregroundColor: Colors.redAccent,
                            padding: const EdgeInsets.all(16),
                          ),
                          icon: const Icon(Icons.stop_rounded),
                        ),
                        const SizedBox(width: 24),

                        // Pause / Resume Main Button
                        ElevatedButton.icon(
                          onPressed: () {
                            if (isRunning) {
                              timerService.pause();
                            } else {
                              timerService.resume();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.ctaWhite,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: Icon(
                            isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 26,
                          ),
                          label: Text(
                            isRunning ? 'Pause' : 'Resume',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          EnforcementService.stopEnforcement();
                          timerService.stop();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        ),
                        child: const Text('Complete Session', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
