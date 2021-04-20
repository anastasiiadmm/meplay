package com.tvclick.meplay_2

import android.content.Context
import io.flutter.app.FlutterApplication
import androidx.multidex.MultiDex
import com.yandex.metrica.YandexMetrica
import com.yandex.metrica.YandexMetricaConfig


class Application: FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        val apiKey: String = getString(R.string.ym_api_key)
        if(apiKey.isNotEmpty()) {
            val config = YandexMetricaConfig.newConfigBuilder(apiKey).build()
            YandexMetrica.activate(applicationContext, config)
            YandexMetrica.enableActivityAutoTracking(this)
        }
    }

    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
}
