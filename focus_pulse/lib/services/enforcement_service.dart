import 'package:flutter/services.dart';
import '../models/app_info.dart';

class EnforcementService {
  static const _enforcementChannel = MethodChannel('com.focuspulse/enforcement');
  static const _appsChannel = MethodChannel('com.focuspulse/apps');

  /// Fetches real installed launchable apps from Android device.
  static Future<List<AppInfo>> fetchInstalledApps() async {
    try {
      final List<dynamic>? result = await _appsChannel.invokeMethod('getInstalledApps');
      if (result == null) return mockDistractionApps();

      return result.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return AppInfo(
          name: map['name'] as String? ?? 'App',
          packageName: map['packageName'] as String? ?? '',
          isBlocked: false,
        );
      }).toList();
    } catch (_) {
      // Fallback to mock data if not running on Android native
      return mockDistractionApps();
    }
  }

  /// Checks if Accessibility Service is enabled in Android settings.
  static Future<bool> isAccessibilityEnabled() async {
    try {
      final bool? isEnabled = await _enforcementChannel.invokeMethod('isAccessibilityEnabled');
      return isEnabled ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Opens Android Accessibility Settings.
  static Future<void> openAccessibilitySettings() async {
    try {
      await _enforcementChannel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  /// Starts native enforcement during an active focus session.
  static Future<void> startEnforcement({
    required List<String> blockedPackages,
    required bool blockYouTube,
    required bool blockShorts,
    required bool blockBrowsers,
    required bool blockAdultSites,
    required bool isDeepFocus,
  }) async {
    try {
      await _enforcementChannel.invokeMethod('startFocus', {
        'blockedPackages': blockedPackages,
        'blockYouTube': blockYouTube,
        'blockShorts': blockShorts,
        'blockBrowsers': blockBrowsers,
        'blockAdultSites': blockAdultSites,
        'isDeepFocus': isDeepFocus,
      });
    } catch (_) {}
  }

  /// Stops native enforcement.
  static Future<void> stopEnforcement() async {
    try {
      await _enforcementChannel.invokeMethod('stopFocus');
    } catch (_) {}
  }
}
