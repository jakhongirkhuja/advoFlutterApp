package com.example.vatandoshlar

import android.content.Context
import android.media.AudioManager
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private companion object {
        const val emergencyAudioChannel = "vatandoshlar/emergency_audio"
        const val restoreDelayMillis = 45_000L
    }

    private val handler = Handler(Looper.getMainLooper())
    private var originalAlarmVolume: Int? = null
    private var audioManager: AudioManager? = null
    private val restoreAlarmVolume = Runnable {
        originalAlarmVolume?.let { originalVolume ->
            audioManager?.setStreamVolume(AudioManager.STREAM_ALARM, originalVolume, 0)
            originalAlarmVolume = null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, emergencyAudioChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "activateSosAlarmAudio" -> {
                        activateSosAlarmAudio()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun activateSosAlarmAudio() {
        val manager = audioManager
            ?: (getSystemService(Context.AUDIO_SERVICE) as AudioManager).also {
                audioManager = it
            }

        if (originalAlarmVolume == null) {
            originalAlarmVolume = manager.getStreamVolume(AudioManager.STREAM_ALARM)
        }

        handler.removeCallbacks(restoreAlarmVolume)
        val targetVolume = (manager.getStreamMaxVolume(AudioManager.STREAM_ALARM) * 0.8)
            .toInt()
            .coerceAtLeast(1)
        manager.setStreamVolume(AudioManager.STREAM_ALARM, targetVolume, 0)
        handler.postDelayed(restoreAlarmVolume, restoreDelayMillis)
    }

    override fun onDestroy() {
        handler.removeCallbacks(restoreAlarmVolume)
        restoreAlarmVolume.run()
        super.onDestroy()
    }
}
