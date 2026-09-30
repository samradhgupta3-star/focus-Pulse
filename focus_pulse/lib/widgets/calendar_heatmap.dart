import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// GitHub-style calendar heatmap with green-outlined date circles.
///
/// Matches the home screen widget reference (September 2026 calendar).
/// Each day shows a circle whose outline/fill intensity maps to focus hours.
class CalendarHeatmap extends StatelessWidget {
  final DateTime month;
  final Map<int, double> focusHoursPerDay; // day → hours
  final VoidCallback? onTap;

  const CalendarHeatmap({
    super.key,
    required this.month,
    this.focusHoursPerDay = const {},
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0 = Sunday
    final today = DateTime.now();
    final isCurrentMonth = month.year == today.year && month.month == today.month;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDim.withOpacity(0.92),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Month / Year header
            Text(
              _monthName(month.month) + ' ${month.year}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Day-of-week headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map((d) => SizedBox(
                        width: 32,
                        child: Center(
                          child: Text(
                            d,
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),

            // Day grid
            _buildGrid(daysInMonth, startWeekday, isCurrentMonth ? today.day : -1),

            const SizedBox(height: 8),
            Text(
              'Focus calendar',
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(int daysInMonth, int startWeekday, int todayDay) {
    final rows = <Widget>[];
    int dayCounter = 1;

    // Calculate how many rows we need
    final totalSlots = startWeekday + daysInMonth;
    final numRows = (totalSlots / 7).ceil();

    for (int row = 0; row < numRows; row++) {
      final cells = <Widget>[];
      for (int col = 0; col < 7; col++) {
        final slotIndex = row * 7 + col;
        if (slotIndex < startWeekday || dayCounter > daysInMonth) {
          cells.add(const SizedBox(width: 32, height: 32));
        } else {
          final day = dayCounter;
          final hours = focusHoursPerDay[day] ?? 0.0;
          final isToday = day == todayDay;
          cells.add(_buildDayCell(day, hours, isToday));
          dayCounter++;
        }
      }
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: cells,
        ),
      ));
    }

    return Column(children: rows);
  }

  Widget _buildDayCell(int day, double hours, bool isToday) {
    // Intensity: 0h = dim outline, 10h = full bright outline + fill
    final intensity = (hours / 10.0).clamp(0.0, 1.0);
    final hasData = hours > 0;

    return SizedBox(
      width: 32,
      height: 32,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: hasData
                ? AppColors.greenLight.withOpacity(0.35 + intensity * 0.65)
                : AppColors.greenLight.withOpacity(0.18),
            width: hasData ? 2.0 : 1.2,
          ),
          color: hasData
              ? AppColors.greenLight.withOpacity(intensity * 0.15)
              : Colors.transparent,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              color: isToday
                  ? AppColors.amber
                  : hasData
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: isToday ? FontWeight.bold : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  static String _monthName(int m) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[m];
  }

  /// Generate mock focus data for demo purposes.
  static Map<int, double> mockData(int daysInMonth) {
    final map = <int, double>{};
    for (int d = 1; d <= daysInMonth; d++) {
      // Simulate varying focus hours (0–8h per day)
      if (d % 3 != 0) {
        map[d] = (d * 1.7 % 8) + 0.5;
      }
    }
    return map;
  }
}
