import 'package:flutter/material.dart';

/// Represents an installed device application in the block selector.
class AppInfo {
  final String name;
  final String packageName;
  final IconData icon;
  final Color iconBgColor;
  bool isBlocked;

  AppInfo({
    required this.name,
    required this.packageName,
    this.icon = Icons.android,
    this.iconBgColor = const Color(0xFF2C322C),
    this.isBlocked = false,
  });

  AppInfo copyWith({bool? isBlocked}) => AppInfo(
        name: name,
        packageName: packageName,
        icon: icon,
        iconBgColor: iconBgColor,
        isBlocked: isBlocked ?? this.isBlocked,
      );
}

/// Mock data — replaced by real installed apps via platform channel in Phase 2.
List<AppInfo> mockDistractionApps() => [
      AppInfo(name: 'GTA: SA', packageName: 'com.rockstar.gta', icon: Icons.sports_esports, iconBgColor: const Color(0xFF37474F), isBlocked: true),
      AppInfo(name: 'NetMirror', packageName: 'com.netmirror', icon: Icons.wifi_tethering, iconBgColor: const Color(0xFFB71C1C), isBlocked: true),
      AppInfo(name: 'Stumble Guys', packageName: 'com.stumble', icon: Icons.directions_run, iconBgColor: const Color(0xFF4A148C), isBlocked: true),
      AppInfo(name: 'Google TV', packageName: 'com.google.tv', icon: Icons.tv, iconBgColor: const Color(0xFF1B5E20), isBlocked: true),
      AppInfo(name: 'OnePlus Store', packageName: 'com.oneplus.store', icon: Icons.store, iconBgColor: const Color(0xFFB71C1C), isBlocked: true),
      AppInfo(name: 'Videos', packageName: 'com.videos', icon: Icons.play_circle_fill, iconBgColor: const Color(0xFFE65100), isBlocked: true),
      AppInfo(name: 'Da Fit', packageName: 'com.dafit', icon: Icons.watch, iconBgColor: const Color(0xFF0D47A1), isBlocked: true),
      AppInfo(name: 'Flipkart', packageName: 'com.flipkart', icon: Icons.shopping_bag, iconBgColor: const Color(0xFF0D47A1), isBlocked: true),
      AppInfo(name: 'Netflix', packageName: 'com.netflix', icon: Icons.movie, iconBgColor: const Color(0xFFB71C1C), isBlocked: true),
      AppInfo(name: 'JioHotstar', packageName: 'com.jiohotstar', icon: Icons.star, iconBgColor: const Color(0xFF1565C0), isBlocked: true),
      AppInfo(name: 'Telegram', packageName: 'org.telegram', icon: Icons.send, iconBgColor: const Color(0xFF0288D1), isBlocked: true),
      AppInfo(name: 'Instagram', packageName: 'com.instagram', icon: Icons.camera_alt, iconBgColor: const Color(0xFFC62828), isBlocked: true),
    ];
