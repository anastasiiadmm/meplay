package com.tvclick.me_play

import android.content.Context
import io.flutter.app.FlutterApplication
import androidx.multidex.MultiDex


class Application: FlutterApplication() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
}
