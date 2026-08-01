package com.example.fa_ksiegowy

import android.app.Activity
import android.util.Log
import android.view.View
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.MobileAds
import com.google.android.ump.ConsentDebugSettings
import com.google.android.ump.ConsentInformation
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.UserMessagingPlatform

/**
 * Показ баннера только для пользователей без Pro.
 * Перед первым запросом рекламы сначала получаем согласие через UMP
 * (обязательно для пользователей EEA/UK по требованиям Google и GDPR).
 */
object AdsManager {

    private var sdkInitialized = false

    fun setupAndLoadBanner(activity: Activity, adView: AdView) {
        if (BillingManager.isPro(activity)) {
            adView.visibility = View.GONE
            return
        }

        val consentInformation = UserMessagingPlatform.getConsentInformation(activity)

        // ВАЖНО для тестирования: раскомментируйте и подставьте свой тестовый device ID
        // (он печатается в logcat при первом запуске), иначе форма согласия не покажется
        // на вашем устройстве в релизной сборке.
        val params = ConsentRequestParameters.Builder()
            // .setConsentDebugSettings(
            //     ConsentDebugSettings.Builder(activity)
            //         .addTestDeviceHashedId("ВАШ_ТЕСТОВЫЙ_ID")
            //         .build()
            // )
            .build()

        consentInformation.requestConsentInfoUpdate(
            activity,
            params,
            {
                UserMessagingPlatform.loadAndShowConsentFormIfRequired(activity) { formError ->
                    if (formError != null) {
                        Log.w("AdsManager", "Consent form error: ${formError.message}")
                    }
                    if (consentInformation.canRequestAds()) {
                        initAndLoad(activity, adView)
                    }
                }
            },
            { requestError ->
                Log.w("AdsManager", "Consent info update error: ${requestError.message}")
                // Не удалось получить статус согласия — на всякий случай не грузим рекламу.
            }
        )

        // Если согласие уже было получено раньше, форма повторно не показывается,
        // но canRequestAds() может быть true сразу.
        if (consentInformation.canRequestAds() && !sdkInitialized) {
            initAndLoad(activity, adView)
        }
    }

    private fun initAndLoad(activity: Activity, adView: AdView) {
        if (!sdkInitialized) {
            sdkInitialized = true
            MobileAds.initialize(activity) {}
        }
        adView.visibility = View.VISIBLE
        adView.loadAd(AdRequest.Builder().build())
    }

    /** Вызывать сразу после успешной покупки Pro, чтобы мгновенно убрать баннер без перезапуска экрана. */
    fun hideBanner(adView: AdView) {
        adView.visibility = View.GONE
        adView.pause()
    }
}
