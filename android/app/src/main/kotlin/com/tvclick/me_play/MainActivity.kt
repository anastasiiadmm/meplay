package com.tvclick.meplay_2

import android.app.PictureInPictureParams
import android.app.UiModeManager
import android.content.res.Configuration
import android.util.Log
import android.util.Rational
import com.google.android.gms.cast.framework.CastContext

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterFragmentActivity() {
    private val mpChannel = "MP_CHANNEL"
    private var pipAllowed: Boolean = false
    private var pipWidth: Int = 16
    private var pipHeight: Int = 10
    private var isTv = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        initChromecast()
        initChannel(flutterEngine)
    }

    private fun enablePip(width: Int?, height: Int?) {
        pipAllowed = true
        if(width != null && height != null) {
            pipWidth = width
            pipHeight = height
        }
    }

    private fun disablePip() {
        pipAllowed = false
    }

    private fun initChromecast() {
        val uiModeManager = getSystemService(UI_MODE_SERVICE) as UiModeManager
        if (uiModeManager.currentModeType == Configuration.UI_MODE_TYPE_TELEVISION) {
            Log.d("TVCheck", "Running on a TV Device")
            isTv = true
        } else {
            Log.d("TVCheck", "Running on a non-TV Device")
            CastContext.getSharedInstance(applicationContext)
        }
    }

    private fun initChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, mpChannel).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "enablePip" -> {
                    val width = call.argument<Int?>("width")
                    val height = call.argument<Int?>("height")
                    enablePip(width, height)
                    result.success(null)
                }
                "disablePip" -> {
                    disablePip()
                    result.success(null)
                }
                "isPipAllowed" -> {
                    result.success(pipAllowed)
                }
                "isTv" -> {
                    result.success(isTv)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if(pipAllowed && android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            val pipParamsBuilder = PictureInPictureParams.Builder()
            pipParamsBuilder.setAspectRatio(Rational(pipWidth, pipHeight))
            enterPictureInPictureMode(pipParamsBuilder.build())
        }
    }
}
