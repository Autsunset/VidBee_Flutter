package com.vidbee.vidbee_flutter

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache

class MainActivity : FlutterActivity() {
    override fun provideFlutterEngine(context: Context): FlutterEngine {
        val cache = FlutterEngineCache.getInstance()
        return cache.get(ENGINE_ID) ?: FlutterEngine(context.applicationContext).also {
            cache.put(ENGINE_ID, it)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        if (!flutterEngine.plugins.has(VidBeePlatformPlugin::class.java)) {
            flutterEngine.plugins.add(VidBeePlatformPlugin())
        }
    }

    // The foreground service protects the process; retaining the engine keeps
    // extractor callbacks and Dart queue/history handling alive without a UI.
    override fun shouldDestroyEngineWithHost(): Boolean = false

    companion object {
        private const val ENGINE_ID = "vidbee_download_engine"
    }
}
