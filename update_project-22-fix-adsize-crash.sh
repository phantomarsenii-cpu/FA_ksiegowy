#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Обновление 22: фикс краша 'The ad size and ad unit ID must be set before loadAd is called' ==="
echo "Причина: adSize задавался через XML (app:adSize), а adUnitId — программно в коде."
echo "Официальная документация Google Mobile Ads SDK требует задавать ОБА параметра"
echo "вместе одним и тем же способом (см. developers.google.com/admob/android -> AdView):"
echo "  mAdView.setAdSize(AdSize.BANNER); mAdView.setAdUnitId(...);"
echo "Смешивание XML + код — источник именно этого краша. Переносим adSize тоже в код."
echo ""

LAYOUT_MINE="app/src/main/res/layout/activity_mine.xml"
if [ ! -f "$LAYOUT_MINE" ]; then
    echo "!!! Не найден $LAYOUT_MINE"
    exit 1
fi

if grep -q 'app:adSize="BANNER"' "$LAYOUT_MINE"; then
    sed -i 's#app:adSize="BANNER"/>#/>#' "$LAYOUT_MINE"
    echo "OK: app:adSize убран из $LAYOUT_MINE (теперь задаётся только в коде)"
else
    echo "-- app:adSize уже отсутствует в $LAYOUT_MINE, пропускаю"
fi

ADS_MANAGER="app/src/main/java/com/example/fa_ksiegowy/AdsManager.kt"
if [ ! -f "$ADS_MANAGER" ]; then
    echo "!!! Не найден $ADS_MANAGER"
    exit 1
fi

mkdir -p "$(dirname "$ADS_MANAGER")"
cat > "$ADS_MANAGER" << 'EOF_ADS_MANAGER_KT'
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
 * Перед первым запросом рекламы сначала получаем согласие через UMP
 * (обязательно для пользователей EEA/UK по требованиям Google и GDPR).
 *
 * ВАЖНО (краш "The ad size and ad unit ID must be set before loadAd is called"):
 * официальная документация Google Mobile Ads SDK требует задавать adSize и
 * adUnitId ОБА программно, одним и тем же способом — см. пример в доке AdView:
 *   mAdView.setAdSize(AdSize.BANNER); mAdView.setAdUnitId("...");
 * Раньше adSize был в XML (app:adSize), а adUnitId — в коде. Такое смешение
 * приводило именно к этому краху при вызове loadAd(). Теперь XML не задаёт
 * ни adSize, ни adUnitId — оба выставляются здесь, в одном месте, один раз.
 *
 * ВАЖНО (краш "The ad unit ID can only be set once on AdView"): adUnitId
 * можно установить у AdView ровно один раз за всё время его жизни — либо
 * через XML, либо через код, но не оба раза. XML больше не задаёт adUnitId.
 *
 * ВАЖНО (если баннер вообще не появляется): почти всегда причина не в коде,
 * а в том, что в консоли AdMob (admob.google.com -> Privacy & messaging)
 * не создано и не ОПУБЛИКОВАНО сообщение о согласии на сбор данных (EU/UK).
 * Без этого consentInformation.canRequestAds() никогда не станет true для
 * пользователей из Польши/ЕС, и loadAd() просто никогда не вызывается —
 * без единой ошибки, тихо. Это нужно настроить один раз в консоли AdMob.
 * Дополнительно баннер может не показываться первые часы/дни после создания
 * нового рекламного блока — Google ещё не успел заполнить инвентарь ("no fill").
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

        // adSize и adUnitId задаём здесь ОБА, программно, в одном месте — так,
        // как рекомендует официальная документация Google Mobile Ads SDK.
        // XML больше не задаёт ни то, ни другое. adUnitId, вдобавок, можно
        // установить у AdView только один раз за всё время его жизни.
        adView.setAdSize(AdSize.BANNER)

        // В debug-сборке (это то, что собирается в Termux через debug.keystore)
        // подставляем официальный тестовый рекламный блок Google — он гарантированно
        // показывает рекламу и не зависит ни от согласия UMP, ни от заполнения
        // инвентаря, ни от статуса модерации приложения в AdMob. Это позволяет сразу
        // увидеть, что баннер технически работает, независимо от настроек AdMob.
        val isDebuggable = (activity.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
        adView.adUnitId = if (isDebuggable) TEST_BANNER_UNIT_ID else PROD_BANNER_UNIT_ID
        if (isDebuggable) {
            Log.i("AdsManager", "Debug build — using Google TEST banner ad unit instead of production one")
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
                // Не удалось получить статус согласия — на всякий случай не грузим рекламу,
                // КРОМЕ debug-тестового блока, который не требует согласия.
                if (isDebuggable) initAndLoad(activity, adView)
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
EOF_ADS_MANAGER_KT
echo "OK: $ADS_MANAGER переписан (adSize + adUnitId задаются вместе, программно, один раз)"

echo ""
echo "=== Готово. Пересобери APK: ./gradlew assembleDebug ==="
echo "=== git add -A && git commit -m 'Fix: set AdView adSize+adUnitId together in code (loadAd crash)' && git push ==="
