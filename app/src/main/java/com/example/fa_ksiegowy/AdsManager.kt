package com.example.fa_ksiegowy

import android.app.Activity
import android.content.pm.ApplicationInfo
import android.util.Log
import android.view.View
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.MobileAds
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.UserMessagingPlatform

/**
 * Показ баннера только для пользователей без Pro.
 *
 * ВАЖНО (краш "adSize/adUnitId must be set before loadAd"): adSize и
 * adUnitId задаются здесь ОБА программно, одним и тем же способом,
 * как требует документация Google Mobile Ads SDK. XML их не задаёт.
 *
 * ВАЖНО (баннер не появляется даже без крашей): в debug-сборке мы
 * используем официальный ТЕСТОВЫЙ рекламный блок Google, который не
 * требует прохождения формы согласия (UMP/GDPR) — поэтому для debug
 * цепочка согласия полностью пропускается, и тестовый баннер грузится
 * сразу. Раньше (в прошлой версии) тестовый блок тоже ждал
 * canRequestAds() == true, а это условие становится true для
 * пользователя из ЕЭЗ (в т.ч. Польши) только после того, как в консоли
 * AdMob -> Privacy & messaging создано и ОПУБЛИКОВАНО сообщение о
 * согласии. Пока это не настроено — баннер молчал даже в debug. Теперь
 * debug-сборка эту зависимость не имеет вообще.
 *
 * Для PRODUCTION (release) сборки цепочка согласия по-прежнему
 * обязательна (это требование GDPR для пользователей ЕЭЗ/Великобритании),
 * и боевой баннер не покажется, пока в консоли AdMob не опубликовано
 * сообщение о согласии на сбор данных (Privacy & messaging -> Publish).
 * Это делается один раз в консоли, кодом не чинится.
 */
object AdsManager {

    private var sdkInitialized = false
    private const val TEST_BANNER_UNIT_ID = "ca-app-pub-3940256099942544/6300978111"
    private const val PROD_BANNER_UNIT_ID = "ca-app-pub-9218963926031039/4293553475"

    fun setupAndLoadBanner(activity: Activity, adView: AdView) {
        if (BillingManager.isPro(activity)) {
            adView.visibility = View.GONE
            return
        }

        // adSize и adUnitId — оба программно, в одном месте, один раз.
        adView.setAdSize(AdSize.BANNER)

        val isDebuggable = (activity.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
        adView.adUnitId = if (isDebuggable) TEST_BANNER_UNIT_ID else PROD_BANNER_UNIT_ID

        if (isDebuggable) {
            // Тестовый блок Google не требует согласия пользователя —
            // грузим его сразу, без UMP, чтобы баннер точно появился.
            Log.i("AdsManager", "Debug build — loading Google TEST banner immediately (no consent gate)")
            initAndLoad(activity, adView)
            return
        }

        val consentInformation = UserMessagingPlatform.getConsentInformation(activity)

        // ВАЖНО для тестирования формы согласия на своём устройстве: раскомментируйте
        // и подставьте свой тестовый device ID (печатается в logcat при первом запуске).
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
                    } else {
                        Log.w("AdsManager", "canRequestAds() == false after consent flow — ad will NOT load. Check AdMob console -> Privacy & messaging (must be published).")
                    }
                }
            },
            { requestError ->
                Log.w("AdsManager", "Consent info update error: ${requestError.message}")
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
        adView.adListener = object : AdListener() {
            override fun onAdLoaded() {
                Log.i("AdsManager", "Banner ad loaded OK")
            }
            override fun onAdFailedToLoad(error: LoadAdError) {
                // errorCode 3 = ERROR_CODE_NO_FILL — самая частая причина для новых
                // рекламных блоков: у Google пока нет рекламы для показа именно вам.
                Log.w("AdsManager", "Banner failed to load: code=${error.code} message=${error.message}")
            }
        }
        adView.loadAd(AdRequest.Builder().build())
    }

    /** Вызывать сразу после успешной покупки Pro, чтобы мгновенно убрать баннер без перезапуска экрана. */
    fun hideBanner(adView: AdView) {
        adView.visibility = View.GONE
        adView.pause()
    }
}
