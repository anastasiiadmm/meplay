package com.tvclick.meplay_2

import android.content.Context
import io.flutter.app.FlutterApplication
import androidx.multidex.MultiDex
import com.yandex.metrica.YandexMetrica
import com.yandex.metrica.YandexMetricaConfig


const val YM_API_KEY = ""  // TODO

class Application: FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        val config = YandexMetricaConfig.newConfigBuilder(YM_API_KEY).build()
        YandexMetrica.activate(applicationContext, config)
        YandexMetrica.enableActivityAutoTracking(this)
    }

    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
}
