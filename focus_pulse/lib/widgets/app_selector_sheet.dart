import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/app_info.dart';
import '../services/enforcement_service.dart';

/// Granular app & web blocking selector sheet.
///
/// Matches reference image 4:
/// - Search bar with live filter
/// - YouTube section with granular sub-toggles (Shorts, homepage, channels)
/// - Browser section with granular sub-toggles (adult content, distracting sites)
/// - "Distracting" category with installed apps list
class AppSelectorSheet extends StatefulWidget {
  final ValueChanged<int>? onCountChanged;

  const AppSelectorSheet({super.key, this.onCountChanged});

  @override
  State<AppSelectorSheet> createState() => _AppSelectorSheetState();
}

class _AppSelectorSheetState extends State<AppSelectorSheet> {
  // ── YouTube controls ───────────────────────────────────────────────────
  bool _youtubeBlocked = true;
  bool _ytShortsBlocked = false;
  bool _ytHomepageBlocked = false;
  bool _ytChannelsBlocked = false;

  // ── Browser controls ───────────────────────────────────────────────────
  bool _browserBlocked = false;
  bool _blockAdultContent = false;
  bool _blockDistractingSites = false;

  // ── Distracting category ───────────────────────────────────────────────
  bool _distractingExpanded = true;
  bool _distractingAllToggle = true;
  late List<AppInfo> _apps;

  // ── Search ─────────────────────────────────────────────────────────────
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _apps = mockDistractionApps();
    _loadDeviceApps();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  Future<void> _loadDeviceApps() async {
    final realApps = await EnforcementService.fetchInstalledApps();
    if (mounted && realApps.isNotEmpty) {
      setState(() {
        _apps = realApps;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _blockedCount {
    int count = 0;
    if (_youtubeBlocked) count++;
    if (_browserBlocked) count++;
    count += _apps.where((a) => a.isBlocked).length;
    return count;
  }

  List<AppInfo> get _filteredApps {
    if (_searchQuery.isEmpty) return _apps;
    return _apps.where((a) => a.name.toLowerCase().contains(_searchQuery)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDim,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Apps to Block',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 22),
                  onPressed: () {
                    widget.onCountChanged?.call(_blockedCount);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // ── Search bar ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.modeSelectorBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: AppColors.textTertiary, size: 20),
                  hintText: 'Search apps',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                ),
              ),
            ),
          ),

          // ── Scrollable content ─────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // YouTube section
                _buildYouTubeSection(),
                const SizedBox(height: 12),

                // Browser section
                _buildBrowserSection(),
                const SizedBox(height: 18),

                // Distracting apps section
                _buildDistractingSection(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // YouTube Granular Controls
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildYouTubeSection() {
    return _sectionCard([
      _mainToggleRow(
        icon: Icons.play_circle_fill,
        iconColor: AppColors.redYT,
        title: 'YouTube',
        subtitle: _youtubeBlocked ? 'Blocked completely' : 'Allowed',
        value: _youtubeBlocked,
        onChanged: (v) => setState(() => _youtubeBlocked = v),
      ),
      _subToggleRow(
        icon: Icons.content_cut,
        label: 'Block Shorts',
        value: _ytShortsBlocked,
        onChanged: (v) => setState(() => _ytShortsBlocked = v),
      ),
      _subToggleRow(
        icon: Icons.home_outlined,
        label: 'Block homepage',
        value: _ytHomepageBlocked,
        onChanged: (v) => setState(() => _ytHomepageBlocked = v),
      ),
      _subToggleRow(
        icon: Icons.tv_outlined,
        label: 'Block distracting channels',
        value: _ytChannelsBlocked,
        onChanged: (v) => setState(() => _ytChannelsBlocked = v),
      ),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Browser Granular Controls
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBrowserSection() {
    return _sectionCard([
      _mainToggleRow(
        icon: Icons.public,
        iconColor: AppColors.chromeOrange,
        title: 'Browser apps',
        subtitle: _browserBlocked ? 'Blocked completely' : 'Allowed completely',
        value: _browserBlocked,
        onChanged: (v) => setState(() => _browserBlocked = v),
      ),
      _subToggleRow(
        icon: Icons.shield_outlined,
        label: 'Block adult content',
        value: _blockAdultContent,
        onChanged: (v) => setState(() => _blockAdultContent = v),
      ),
      _subToggleRow(
        icon: Icons.language,
        label: 'Block distracting sites',
        value: _blockDistractingSites,
        onChanged: (v) => setState(() => _blockDistractingSites = v),
      ),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Distracting Apps Section
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDistractingSection() {
    final filtered = _filteredApps;
    return Column(
      children: [
        // Section header with expand/collapse
        GestureDetector(
          onTap: () => setState(() => _distractingExpanded = !_distractingExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  _distractingExpanded ? Icons.expand_more : Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Distracting',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Toggle all
                Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    value: _distractingAllToggle,
                    onChanged: (v) {
                      setState(() {
                        _distractingAllToggle = v;
                        for (var app in _apps) {
                          app.isBlocked = v;
                        }
                      });
                    },
                    activeColor: AppColors.greenLight,
                    activeTrackColor: AppColors.greenPrimary.withOpacity(0.4),
                    inactiveTrackColor: AppColors.textTertiary.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),

        // App list
        if (_distractingExpanded)
          _sectionCard(
            filtered.map((app) => _appRow(app)).toList(),
          ),
      ],
    );
  }

  Widget _appRow(AppInfo app) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: app.iconBgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(app.icon, size: 18, color: Colors.white),
      ),
      title: Text(
        app.name,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      ),
      trailing: Switch(
        value: app.isBlocked,
        onChanged: (v) {
          setState(() {
            app.isBlocked = v;
            _distractingAllToggle = _apps.every((a) => a.isBlocked);
          });
        },
        activeColor: AppColors.greenLight,
        activeTrackColor: AppColors.greenPrimary.withOpacity(0.4),
        inactiveTrackColor: AppColors.textTertiary.withOpacity(0.3),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Shared builders
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _sectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(children: children),
    );
  }

  Widget _mainToggleRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.greenLight,
        activeTrackColor: AppColors.greenPrimary.withOpacity(0.4),
        inactiveTrackColor: AppColors.textTertiary.withOpacity(0.3),
      ),
    );
  }

  Widget _subToggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 12, bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.greenLight,
              activeTrackColor: AppColors.greenPrimary.withOpacity(0.4),
              inactiveTrackColor: AppColors.textTertiary.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
