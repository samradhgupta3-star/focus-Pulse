package com.focuspulse

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val ENFORCEMENT_CHANNEL = "com.focuspulse/enforcement"
    private val APPS_CHANNEL = "com.focuspulse/apps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. App Query Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APPS_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInstalledApps") {
                val apps = queryInstalledApps()
                result.success(apps)
            } else {
                result.notImplemented()
            }
        }

        // 2. Enforcement Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ENFORCEMENT_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startFocus" -> {
                    val blockedList = call.argument<List<String>>("blockedPackages") ?: emptyList()
                    val blockYouTube = call.argument<Boolean>("blockYouTube") ?: false
                    val blockShorts = call.argument<Boolean>("blockShorts") ?: false
                    val blockBrowsers = call.argument<Boolean>("blockBrowsers") ?: false
                    val blockAdultSites = call.argument<Boolean>("blockAdultSites") ?: false
                    val isDeep = call.argument<Boolean>("isDeepFocus") ?: false

                    FocusAccessibilityService.isFocusActive = true
                    FocusAccessibilityService.isDeepFocus = isDeep
                    FocusAccessibilityService.blockYouTube = blockYouTube
                    FocusAccessibilityService.blockShorts = blockShorts
                    FocusAccessibilityService.blockBrowsers = blockBrowsers
                    FocusAccessibilityService.blockAdultSites = blockAdultSites
                    FocusAccessibilityService.blockedPackages = blockedList.toMutableSet()

                    result.success(true)
                }
                "stopFocus" -> {
                    FocusAccessibilityService.isFocusActive = false
                    FocusAccessibilityService.blockedPackages.clear()
                    result.success(true)
                }
                "isAccessibilityEnabled" -> {
                    result.success(isAccessibilityServiceEnabled(context))
                }
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    startActivity(intent)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun queryInstalledApps(): List<Map<String, Any>> {
        val packageManager = packageManager
        val mainIntent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val resolveInfos = packageManager.queryIntentActivities(mainIntent, 0)
        val appList = mutableListOf<Map<String, Any>>()

        for (resolveInfo in resolveInfos) {
            val appInfo = resolveInfo.activityInfo.applicationInfo
            // Exclude self
            if (appInfo.packageName == packageName) continue

            val appName = packageManager.getApplicationLabel(appInfo).toString()
            val isSystem = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0

            val item = mapOf(
                "name" to appName,
                "packageName" to appInfo.packageName,
                "isSystem" to isSystem
            )
            appList.add(item)
        }
        return appList.sortedBy { (it["name"] as String).lowercase() }
    }

    private fun isAccessibilityServiceEnabled(context: Context): Boolean {
        val expectedServiceName = "${context.packageName}/${FocusAccessibilityService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        return enabledServices.split(":").any { it.equals(expectedServiceName, ignoreCase = true) }
    }
}
