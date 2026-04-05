package com.vidbee.vidbee_flutter

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.vidbee.media_scanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "scanFile") {
                val filePath = call.argument<String>("filePath")
                if (filePath != null) {
                    scanFile(filePath)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENT", "filePath is required", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun scanFile(filePath: String) {
        val file = File(filePath)
        if (file.exists()) {
            val intent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
            intent.data = Uri.fromFile(file)
            applicationContext.sendBroadcast(intent)
        }
    }
}
