package com.vidbee.vidbee_flutter

import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache

class MainActivity : FlutterActivity() {
    private var platformPlugin: VidBeePlatformPlugin? = null

    override fun provideFlutterEngine(context: Context): FlutterEngine {
        val cache = FlutterEngineCache.getInstance()
        return cache.get(ENGINE_ID) ?: FlutterEngine(context.applicationContext).also {
            cache.put(ENGINE_ID, it)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val existingPlugin =
            flutterEngine.plugins.get(VidBeePlatformPlugin::class.java) as? VidBeePlatformPlugin
        platformPlugin = existingPlugin ?: VidBeePlatformPlugin().also {
            flutterEngine.plugins.add(it)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (savedInstanceState == null) platformPlugin?.receiveShare(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        platformPlugin?.receiveShare(intent)
    }

    // The foreground service protects the process; retaining the engine keeps
    // extractor callbacks and Dart queue/history handling alive without a UI.
    override fun shouldDestroyEngineWithHost(): Boolean = false

    companion object {
        private const val ENGINE_ID = "vidbee_download_engine"
    }
}
