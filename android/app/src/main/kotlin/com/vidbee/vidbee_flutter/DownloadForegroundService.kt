package com.vidbee.vidbee_flutter

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.os.PowerManager
import android.os.ResultReceiver
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat

class DownloadForegroundService : Service() {
    private var wakeLock: PowerManager.WakeLock? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        @Suppress("DEPRECATION")
        val receiver = intent?.getParcelableExtra<ResultReceiver>(EXTRA_RECEIVER)
        try {
            ServiceCompat.startForeground(
                this,
                NOTIFICATION_ID,
                createNotification(),
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
                } else {
                    0
                },
            )
            if (wakeLock == null) {
                wakeLock = getSystemService(PowerManager::class.java)
                    .newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "VidBee:download")
                    .apply {
                        setReferenceCounted(false)
                        // Held only while Dart owns active download operations.
                        acquire()
                    }
            }
            receiver?.send(RESULT_STARTED, Bundle.EMPTY)
        } catch (error: Exception) {
            receiver?.send(RESULT_FAILED, Bundle().apply {
                putString("message", error.message)
            })
            releaseResources()
            stopSelf()
        }
        // Dart owns the queue. A restarted service without that engine cannot
        // resume work, so never leave a phantom notification after process death.
        return START_NOT_STICKY
    }

    override fun onTimeout(startId: Int, fgsType: Int) {
        // API 35+: stop promptly to avoid an ANR, then let Dart fail/persist work.
        releaseResources()
        stopSelf()
        onTimeLimitReached?.invoke()
    }

    override fun onDestroy() {
        releaseResources()
        super.onDestroy()
    }

    private fun releaseResources() {
        wakeLock?.let { if (it.isHeld) it.release() }
        wakeLock = null
        ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
    }

    private fun createNotification(): Notification {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            getSystemService(NotificationManager::class.java).createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    getString(R.string.background_download_channel),
                    NotificationManager.IMPORTANCE_LOW,
                ),
            )
        }
        val openApp = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_download_notification)
            .setContentTitle(getString(R.string.background_download_title))
            .setContentText(getString(R.string.background_download_text))
            .setContentIntent(openApp)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setProgress(0, 0, true)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .build()
    }

    companion object {
        const val EXTRA_RECEIVER = "receiver"
        const val RESULT_STARTED = 0
        const val RESULT_FAILED = 1
        // Task notifications use nonnegative hash IDs; reserve a negative ID.
        private const val NOTIFICATION_ID = -20261007
        private const val CHANNEL_ID = "background_download"
        var onTimeLimitReached: (() -> Unit)? = null
    }
}
