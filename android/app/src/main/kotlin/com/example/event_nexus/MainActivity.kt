package com.example.event_nexus

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Disable the Flutter splash screen for Android 12+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            try {
                splashScreen.setOnExitAnimationListener { splashScreenView ->
                    splashScreenView.remove()
                }
            } catch (e: Exception) {
                // Fallback for versions that don't support this API
            }
        }
        super.onCreate(savedInstanceState)
    }
}
