import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/timer_service.dart';
import '../widgets/focus_progress_ring.dart';
import '../widgets/screen_time_bar.dart';
import '../widgets/focus_setup_sheet.dart';
import '../widgets/calendar_heatmap.dart';
import 'active_session_screen.dart';
import 'calendar_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final TimerService timerService;

  const DashboardScreen({super.key, required this.timerService});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNavIndex = 0;

  void _openFocusSetupSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FocusSetupSheet(
        timerService: widget.timerService,
        onStartSession: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActiveSessionScreen(timerService: widget.timerService),
            ),
          );
        },
      ),
    );
  }

  void _openCalendarDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalendarDetailScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable Content Area
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Status bar row with avatar and action icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEE8A2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'S',
                            style: TextStyle(
                              color: Colors.brown,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.hourglass_top, color: AppColors.amber),
                        onPressed: _openFocusSetupSheet,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 1. Central Circular Progress Ring (Screenshot 3 style)
                  AnimatedBuilder(
                    animation: widget.timerService,
                    builder: (context, child) {
                      final totalFocusSec = widget.timerService.totalFocused.inSeconds;
                      // Display mock default if freshly started (5h 3m / 10h), otherwise real stats
                      final displaySec = totalFocusSec > 0 ? totalFocusSec : (5 * 3600 + 3 * 60);
                      final displayHours = displaySec ~/ 3600;
                      final displayMins = (displaySec % 3600) ~/ 60;
                      final progress = (displaySec / (10 * 3600)).clamp(0.0, 1.0);

                      return Center(
                        child: FocusProgressRing(
                          progress: progress,
                          size: 170,
                          strokeWidth: 16,
                          timeText: '${displayHours}h ${displayMins}m',
                          goalText: 'Focus goal 10h',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // 2. Screen Time Progress Bar
                  const ScreenTimeBar(
                    totalScreenTime: Duration(hours: 8, minutes: 33),
                    productiveTime: Duration(hours: 5, minutes: 3),
                    dailyGoal: Duration(hours: 14),
                  ),
                  const SizedBox(height: 24),

                  // 3. Upcoming Schedule Card
                  const Text(
                    'Upcoming schedule',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.nightlight_round, color: AppColors.amber, size: 22),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Night Study',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              '• 7:00 pm - 3:00 am',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Calendar Heatmap Preview Tile (matches screenshot 15145.jpg)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Monthly Performance',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      GestureDetector(
                        onTap: _openCalendarDetail,
                        child: const Text(
                          'View all',
                          style: TextStyle(color: AppColors.greenLight, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CalendarHeatmap(
                    month: DateTime(2026, 9),
                    focusHoursPerDay: CalendarHeatmap.mockData(30),
                    onTap: _openCalendarDetail,
                  ),
                ],
              ),
            ),

            // Fixed Bottom Actions & Navigation Bar
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Prominent "Start focus timer" action pill
                  GestureDetector(
                    onTap: _openFocusSetupSheet,
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.ctaWhite,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Start focus timer',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: AppColors.greenPrimary,
                            radius: 19,
                            child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Bottom Navigation Bar
                  Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDim,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white10, width: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(Icons.hourglass_bottom_rounded, 'Focus', 0),
                        _buildNavItem(Icons.calendar_month_rounded, 'Planner', 1),
                        _buildNavItem(Icons.people_outline_rounded, 'Groups', 2),
                        _buildNavItem(Icons.block_rounded, 'Blocks', 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          _openCalendarDetail();
        } else {
          setState(() => _selectedNavIndex = index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.greenLight : AppColors.textTertiary,
            size: 21,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.greenLight : AppColors.textTertiary,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
