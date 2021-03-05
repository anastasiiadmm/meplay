package com.tvclick.meplay_2

import com.google.android.gms.cast.framework.CastContext

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine


class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        CastContext.getSharedInstance(applicationContext)
    }
}
