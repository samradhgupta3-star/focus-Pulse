import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Multi-segment screen time progress bar matching the reference UI.
///
/// Shows productive (green), other usage (orange), and remaining (grey) segments.
class ScreenTimeBar extends StatelessWidget {
  final Duration totalScreenTime;
  final Duration productiveTime;
  final Duration dailyGoal;

  const ScreenTimeBar({
    super.key,
    this.totalScreenTime = const Duration(hours: 8, minutes: 33),
    this.productiveTime = const Duration(hours: 5, minutes: 3),
    this.dailyGoal = const Duration(hours: 14),
  });

  @override
  Widget build(BuildContext context) {
    final totalMin = dailyGoal.inMinutes;
    final productiveFlex = (productiveTime.inMinutes / totalMin * 100).round().clamp(1, 100);
    final otherMin = totalScreenTime.inMinutes - productiveTime.inMinutes;
    final otherFlex = (otherMin / totalMin * 100).round().clamp(0, 100 - productiveFlex);
    final remainFlex = (100 - productiveFlex - otherFlex).clamp(0, 100);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fmtDuration(totalScreenTime),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Screen Time',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Row(
                    children: [
                      Expanded(
                        flex: productiveFlex,
                        child: Container(height: 6, color: AppColors.greenLight),
                      ),
                      if (otherFlex > 0)
                        Expanded(
                          flex: otherFlex,
                          child: Container(height: 6, color: AppColors.orange),
                        ),
                      if (remainFlex > 0)
                        Expanded(
                          flex: remainFlex,
                          child: Container(
                            height: 6,
                            color: AppColors.textTertiary.withOpacity(0.3),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
        ],
      ),
    );
  }

  static String _fmtDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h}h ${m}m';
  }
}
