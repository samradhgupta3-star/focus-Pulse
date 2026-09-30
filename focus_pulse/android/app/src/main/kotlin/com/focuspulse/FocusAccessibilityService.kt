package com.focuspulse

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import java.util.Locale

class FocusAccessibilityService : AccessibilityService() {

    companion object {
        var isFocusActive: Boolean = false
        var isDeepFocus: Boolean = false
        var blockYouTube: Boolean = false
        var blockShorts: Boolean = false
        var blockBrowsers: Boolean = false
        var blockAdultSites: Boolean = false
        var blockedPackages: MutableSet<String> = mutableSetOf()

        private val BROWSER_PACKAGES = setOf(
            "com.android.chrome",
            "com.brave.browser",
            "com.microsoft.emmx",
            "org.mozilla.firefox"
        )

        private val YOUTUBE_PACKAGE = "com.google.android.youtube"
        private val SETTINGS_PACKAGE = "com.android.settings"

        private val ADULT_KEYWORDS = listOf("porn", "xxx", "sex", "adult", "xvideos", "xnxx")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (!isFocusActive || event == null) return

        val packageName = event.packageName?.toString() ?: return

        // 1. Strict Mode / Deep Focus: Block Settings & Package Installers
        if (isDeepFocus && (packageName == SETTINGS_PACKAGE || packageName.contains("packageinstaller"))) {
            redirectHome()
            return
        }

        // 2. Block direct package match
        if (blockedPackages.contains(packageName)) {
            redirectHome()
            return
        }

        // 3. YouTube Granular Checks
        if (packageName == YOUTUBE_PACKAGE) {
            if (blockYouTube) {
                redirectHome()
                return
            }
            if (blockShorts && isYouTubeShortsActive(rootInActiveWindow)) {
                redirectHome()
                return
            }
        }

        // 4. Browser Granular URL Checks
        if (BROWSER_PACKAGES.contains(packageName)) {
            if (blockBrowsers) {
                redirectHome()
                return
            }
            if (blockAdultSites) {
                val currentUrl = extractBrowserUrl(rootInActiveWindow)
                if (currentUrl != null && containsAdultContent(currentUrl)) {
                    redirectHome()
                    return
                }
            }
        }
    }

    private fun isYouTubeShortsActive(root: AccessibilityNodeInfo?): Boolean {
        if (root == null) return false
        val nodes = root.findAccessibilityNodeInfosByViewId("com.google.android.youtube:id/reel_recycler")
        if (!nodes.isNullOrEmpty()) return true

        val shortsTab = root.findAccessibilityNodeInfosByText("Shorts")
        if (!shortsTab.isNullOrEmpty()) {
            for (node in shortsTab) {
                if (node.isSelected || node.isFocused) return true
            }
        }
        return false
    }

    private fun extractBrowserUrl(root: AccessibilityNodeInfo?): String? {
        if (root == null) return null
        val idList = listOf(
            "com.android.chrome:id/url_bar",
            "com.brave.browser:id/url_bar",
            "com.microsoft.emmx:id/url_bar"
        )
        for (id in idList) {
            val nodes = root.findAccessibilityNodeInfosByViewId(id)
            if (!nodes.isNullOrEmpty()) {
                val text = nodes[0].text?.toString()
                if (!text.isNullOrBlank()) return text.lowercase(Locale.ROOT)
            }
        }
        return null
    }

    private fun containsAdultContent(url: String): Boolean {
        return ADULT_KEYWORDS.any { url.contains(it) }
    }

    private fun redirectHome() {
        performGlobalAction(GLOBAL_ACTION_HOME)
    }

    override fun onInterrupt() {}
}
