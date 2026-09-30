import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom-painted circular progress ring matching the reference UI.
///
/// Features:
/// - Thick rounded-cap arc with green gradient
/// - Subtle glow at the progress tip
/// - Animated progress via [AnimationController]
class FocusProgressRing extends StatelessWidget {
  final double progress; // 0.0 → 1.0
  final double size;
  final double strokeWidth;
  final String timeText;
  final String goalText;
  final Widget? bottomWidget;

  const FocusProgressRing({
    super.key,
    required this.progress,
    this.size = 160,
    this.strokeWidth = 16,
    this.timeText = '',
    this.goalText = '',
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Painted ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              trackColor: AppColors.ringTrack,
              progressStartColor: AppColors.greenDark,
              progressEndColor: AppColors.greenLight,
            ),
          ),

          // Centre text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeText,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              if (goalText.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  goalText,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (bottomWidget != null) ...[
                const SizedBox(height: 6),
                bottomWidget!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom painter
// ─────────────────────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressStartColor;
  final Color progressEndColor;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressStartColor,
    required this.progressEndColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // ── 1. Track (full circle) ───────────────────────────────────────────
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // ── 2. Progress arc ──────────────────────────────────────────────────
    final sweepAngle = 2 * pi * progress;
    final progressPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Create a sweep gradient that fills only the progress portion
    progressPaint.shader = SweepGradient(
      startAngle: 0,
      endAngle: sweepAngle,
      colors: [progressStartColor, progressEndColor],
      transform: const GradientRotation(-pi / 2),
    ).createShader(rect);

    canvas.drawArc(rect, -pi / 2, sweepAngle, false, progressPaint);

    // ── 3. Glow at the progress tip ──────────────────────────────────────
    final tipAngle = -pi / 2 + sweepAngle;
    final tipX = center.dx + radius * cos(tipAngle);
    final tipY = center.dy + radius * sin(tipAngle);

    final glowPaint = Paint()
      ..color = progressEndColor.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(tipX, tipY), strokeWidth * 0.6, glowPaint);

    // Bright dot at the exact tip
    final dotPaint = Paint()..color = progressEndColor;
    canvas.drawCircle(Offset(tipX, tipY), strokeWidth * 0.35, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
