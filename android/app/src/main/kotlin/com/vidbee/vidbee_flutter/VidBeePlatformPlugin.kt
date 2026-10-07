package com.vidbee.vidbee_flutter

import android.content.Intent
import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.ResultReceiver
import android.provider.Settings
import android.webkit.MimeTypeMap
import androidx.core.content.FileProvider
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File

// Engine-owned channels must not retain an Activity: downloads, output scanning,
// and queue advancement continue after the UI has been detached.
class VidBeePlatformPlugin : FlutterPlugin {
    private lateinit var context: Context
    private val channels = mutableListOf<MethodChannel>()
    private val mediaScannerChannel = "com.vidbee.media_scanner"
    private val appUpdateChannel = "com.vidbee.app_update"
    private val fileOpenerChannel = "com.vidbee.file_opener"

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        val messenger = binding.binaryMessenger

        channel(messenger, mediaScannerChannel).setMethodCallHandler { call, result ->
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

        channel(messenger, appUpdateChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSupportedAbis" -> result.success(Build.SUPPORTED_ABIS.toList())
                "installApk" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath.isNullOrBlank()) {
                        result.error("INVALID_ARGUMENT", "filePath is required", null)
                        return@setMethodCallHandler
                    }

                    try {
                        installApk(filePath)
                        result.success(null)
                    } catch (e: SecurityException) {
                        result.error("INSTALL_PERMISSION_REQUIRED", e.message, null)
                    } catch (e: IllegalArgumentException) {
                        result.error("INVALID_ARGUMENT", e.message, null)
                    } catch (e: Exception) {
                        result.error("INSTALL_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        channel(messenger, fileOpenerChannel).setMethodCallHandler { call, result ->
            if (call.method == "openFile") {
                val filePath = call.argument<String>("filePath")
                if (filePath.isNullOrBlank()) {
                    result.error("INVALID_ARGUMENT", "filePath is required", null)
                    return@setMethodCallHandler
                }

                try {
                    openFile(filePath)
                    result.success(true)
                } catch (e: IllegalArgumentException) {
                    result.error("FILE_NOT_FOUND", e.message, null)
                } catch (e: Exception) {
                    result.error("OPEN_FAILED", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }

        val backgroundChannel = channel(messenger, "com.vidbee.background_download")
        DownloadForegroundService.onTimeLimitReached = {
            backgroundChannel.invokeMethod("onTimeout", null)
        }
        backgroundChannel.setMethodCallHandler { call, result ->
            val intent = Intent(context, DownloadForegroundService::class.java)
            when (call.method) {
                "start" -> {
                    val receiver = object : ResultReceiver(Handler(Looper.getMainLooper())) {
                        override fun onReceiveResult(resultCode: Int, resultData: Bundle?) {
                            if (resultCode == DownloadForegroundService.RESULT_STARTED) {
                                result.success(null)
                            } else {
                                result.error("BACKGROUND_START_FAILED", resultData?.getString("message"), null)
                            }
                        }
                    }
                    intent.putExtra(DownloadForegroundService.EXTRA_RECEIVER, receiver)
                    try {
                        ContextCompat.startForegroundService(context, intent)
                    } catch (error: Exception) {
                        result.error("BACKGROUND_START_FAILED", error.message, null)
                    }
                }
                "stop" -> {
                    context.stopService(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun channel(messenger: BinaryMessenger, name: String): MethodChannel =
        MethodChannel(messenger, name).also { channels.add(it) }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channels.forEach { it.setMethodCallHandler(null) }
        channels.clear()
        DownloadForegroundService.onTimeLimitReached = null
        context.stopService(Intent(context, DownloadForegroundService::class.java))
    }

    // 通知系统媒体库索引新文件，使相册/文件管理器能看到 Download 目录下的视频。
    // 优先 MediaScannerConnection（Android 10+ 仍有效）；广播作为兼容兜底。
    private fun scanFile(filePath: String) {
        val file = File(filePath)
        if (!file.exists() || !file.isFile) return

        val mimeType = guessMimeType(file.name)
        MediaScannerConnection.scanFile(
            context,
            arrayOf(file.absolutePath),
            arrayOf(mimeType),
            null,
        )

        // 旧版广播兜底（部分定制 ROM 仍依赖）
        try {
            @Suppress("DEPRECATION")
            val intent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE).apply {
                data = Uri.fromFile(file)
            }
            context.sendBroadcast(intent)
        } catch (_: Exception) {
            // ignore
        }
    }

    private fun installApk(filePath: String) {
        val file = File(filePath)
        if (!file.exists()) {
            throw IllegalArgumentException("APK file does not exist")
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && !context.packageManager.canRequestPackageInstalls()) {
            val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
                data = Uri.parse("package:${context.packageName}")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
            throw SecurityException("Install permission required")
        }

        val apkUri = FileProvider.getUriForFile(context, "${context.packageName}.fileprovider", file)
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(apkUri, "application/vnd.android.package-archive")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    // 用 FileProvider 暴露本地文件，并弹出系统「用哪个应用打开」选择器。
    private fun openFile(filePath: String) {
        val file = File(filePath)
        if (!file.exists() || !file.isFile) {
            throw IllegalArgumentException("File does not exist: $filePath")
        }

        val uri = FileProvider.getUriForFile(context, "${context.packageName}.fileprovider", file)
        val mimeType = guessMimeType(file.name)

        val viewIntent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, mimeType)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        val chooser = Intent.createChooser(viewIntent, null).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            // 让选择器里的目标应用也能读到 content URI
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        context.startActivity(chooser)
    }

    private fun guessMimeType(fileName: String): String {
        val extension = fileName.substringAfterLast('.', missingDelimiterValue = "")
            .lowercase()
        if (extension.isEmpty()) return "*/*"
        return MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension) ?: "*/*"
    }
}
