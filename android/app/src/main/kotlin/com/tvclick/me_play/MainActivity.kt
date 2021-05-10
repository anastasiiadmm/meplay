package com.tvclick.meplay_2

import android.app.PictureInPictureParams
import android.util.Rational
import com.google.android.gms.cast.framework.CastContext

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterFragmentActivity() {
    private val pipChannel = "PIP_CHANNEL"
    private var mayPip: Boolean = false
    private var pipWidth: Int = 4
    private var pipHeight: Int = 3

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        CastContext.getSharedInstance(applicationContext)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, pipChannel).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "enablePip" -> {
                    val width = call.argument<Int?>("width")
                    val height = call.argument<Int?>("height")
                    allowPip(width, height)
                    result.success(null)
                }
                "disablePip" -> {
                    disallowPip()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun allowPip(width: Int?, height: Int?) {
        mayPip = true
        if(width != null && height != null) {
            pipWidth = width
            pipHeight = height
        }
    }

    private fun disallowPip() {
        mayPip = false
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if(mayPip && android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            val pipParamsBuilder = PictureInPictureParams.Builder();
            pipParamsBuilder.setAspectRatio(Rational(pipWidth, pipHeight))
            enterPictureInPictureMode(pipParamsBuilder.build())
        }
    }
}
