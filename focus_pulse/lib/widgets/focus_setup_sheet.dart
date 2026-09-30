import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/timer_service.dart';
import 'app_selector_sheet.dart';

/// Focus Session Setup bottom sheet.
///
/// Matches the reference: mode selector (Timer / Stopwatch / Pomodoro),
/// Focus Time / Breaks rows, Blocked Apps & Deep Focus tiles, "Start Focus Now" CTA.
class FocusSetupSheet extends StatefulWidget {
  final TimerService timerService;
  final VoidCallback onStartSession;

  const FocusSetupSheet({
    super.key,
    required this.timerService,
    required this.onStartSession,
  });

  @override
  State<FocusSetupSheet> createState() => _FocusSetupSheetState();
}

class _FocusSetupSheetState extends State<FocusSetupSheet> {
  int _selectedMode = 0; // 0: Timer, 1: Stopwatch, 2: Pomodoro
  int _focusMinutes = 30;
  int _breakCount = 1;
  int _blockedAppCount = 18;
  bool _deepFocusEnabled = false;

  static const _durationOptions = [15, 25, 30, 45, 60, 90, 120];

  FocusMode get _focusMode {
    switch (_selectedMode) {
      case 1: return FocusMode.stopwatch;
      case 2: return FocusMode.pomodoro;
      default: return FocusMode.timer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ────────────────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 22),

          // ── Mode selector ──────────────────────────────────────────────
          _buildModeSelector(),
          const SizedBox(height: 20),

          // ── Duration & Breaks card ─────────────────────────────────────
          if (_selectedMode != 1) _buildDurationCard(),
          if (_selectedMode != 1) const SizedBox(height: 14),

          // ── Blocked Apps & Deep Focus tiles ────────────────────────────
          _buildTilesRow(),
          const SizedBox(height: 22),

          // ── Start CTA ──────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _handleStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ctaWhite,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Start Focus Now',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  // ── Mode Selector Pill ─────────────────────────────────────────────────

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.modeSelectorBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _modeTab('Timer', 0),
          _modeTab('Stopwatch', 1),
          _modeTab('Pomodoro', 2),
        ],
      ),
    );
  }

  Widget _modeTab(String label, int index) {
    final isSelected = _selectedMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.modeSelectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.greenLight : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Duration & Breaks Card ─────────────────────────────────────────────

  Widget _buildDurationCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Focus Time row
          _settingsRow(
            label: 'Focus Time',
            value: '$_focusMinutes mins',
            onTap: _showDurationPicker,
          ),
          Divider(height: 1, color: AppColors.textTertiary.withOpacity(0.15)),
          // Breaks row
          _settingsRow(
            label: 'Breaks',
            value: '$_breakCount break${_breakCount != 1 ? 's' : ''}',
            onTap: _showBreakPicker,
          ),
        ],
      ),
    );
  }

  Widget _settingsRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
            Row(
              children: [
                Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDurationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Focus Time',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _durationOptions.map((m) {
                final isSelected = m == _focusMinutes;
                return GestureDetector(
                  onTap: () {
                    setState(() => _focusMinutes = m);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.greenPrimary : AppColors.cardDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      m >= 60 ? '${m ~/ 60}h${m % 60 > 0 ? ' ${m % 60}m' : ''}' : '$m mins',
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showBreakPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Number of Breaks',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              children: [0, 1, 2, 3, 4, 5].map((b) {
                final isSelected = b == _breakCount;
                return GestureDetector(
                  onTap: () {
                    setState(() => _breakCount = b);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.greenPrimary : AppColors.cardDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$b',
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Blocked Apps & Deep Focus tiles ────────────────────────────────────

  Widget _buildTilesRow() {
    return Row(
      children: [
        // Blocked Apps tile
        Expanded(
          child: GestureDetector(
            onTap: _openAppSelector,
            child: Container(
              padding: const EdgeInsets.all(14),
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.cardGreen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.greenBorder, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user, color: AppColors.greenLight, size: 22),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 16),
                      const Spacer(),
                      // Overlapping app icon previews
                      _buildAppIconStack(),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.greenPrimary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$_blockedAppCount apps',
                      style: const TextStyle(
                        color: AppColors.greenLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Blocked Apps',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Deep Focus tile
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _deepFocusEnabled = !_deepFocusEnabled),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              height: 130,
              decoration: BoxDecoration(
                color: _deepFocusEnabled ? AppColors.cardAmber : AppColors.cardElevated,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: _deepFocusEnabled ? AppColors.amber : AppColors.textTertiary,
                    size: 22,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (_deepFocusEnabled ? AppColors.amber : AppColors.textTertiary)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _deepFocusEnabled ? 'Active' : '0 active',
                      style: TextStyle(
                        color: _deepFocusEnabled ? AppColors.amber : AppColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        'Deep focus',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppIconStack() {
    // 3 overlapping preview circles
    const icons = [
      (Icons.play_circle_fill, Color(0xFFFF0000)),   // YouTube
      (Icons.qr_code, Color(0xFF37474F)),              // QR
      (Icons.movie, Color(0xFFB71C1C)),                // Netflix
    ];

    return SizedBox(
      width: 56,
      height: 24,
      child: Stack(
        children: List.generate(icons.length, (i) {
          return Positioned(
            left: i * 16.0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: icons[i].$2,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardGreen, width: 1.5),
              ),
              child: Icon(icons[i].$1, size: 12, color: Colors.white),
            ),
          );
        }),
      ),
    );
  }

  void _openAppSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppSelectorSheet(
        onCountChanged: (count) => setState(() => _blockedAppCount = count),
      ),
    );
  }

  void _handleStart() {
    widget.timerService.configure(
      mode: _focusMode,
      workDuration: Duration(minutes: _focusMinutes),
      breakDuration: const Duration(minutes: 5),
      cycles: _selectedMode == 2 ? _breakCount + 1 : 1,
    );
    widget.timerService.start();
    Navigator.pop(context);
    widget.onStartSession();
  }
}
