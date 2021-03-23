package com.tvclick.meplay_2

import com.google.android.gms.cast.framework.CastContext

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine


class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        CastContext.getSharedInstance(applicationContext)
    }
}
