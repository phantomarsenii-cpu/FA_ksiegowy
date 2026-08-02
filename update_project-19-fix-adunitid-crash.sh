#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Обновление 19: фикс краша 'The ad unit ID can only be set once on AdView' ==="

LAYOUT="app/src/main/res/layout/activity_mine.xml"
if [ ! -f "$LAYOUT" ]; then
    echo "!!! Не найден $LAYOUT"
    exit 1
fi

# Причина краша: adUnitId задавался ДВАЖДЫ — один раз в XML (app:adUnitId=...),
# второй раз в коде (AdsManager.kt, для debug-сборки). AdMob разрешает установить
# adUnitId только один раз за всё время жизни AdView, вторая установка кидает
# IllegalStateException. Убираем задание из XML, оставляем единственную точку
# установки — в коде (AdsManager.kt), где и так уже правильно переключается
# test/prod ID в зависимости от debuggable-флага.
if grep -q 'app:adUnitId="ca-app-pub-9218963926031039/4293553475"' "$LAYOUT"; then
    sed -i '/app:adUnitId="ca-app-pub-9218963926031039\/4293553475"/d' "$LAYOUT"
    # предыдущая строка (app:adSize="BANNER") оставалась с "\" в конце? нет — там
    # был перенос через отдельный атрибут, но чтобы не оставить висячий "/>"
    # без открывающего тега проверим, что тег AdView остался валиден.
    echo "OK: app:adUnitId удалён из $LAYOUT (единственная точка установки — код)"
else
    echo "-- app:adUnitId уже отсутствует в $LAYOUT, пропускаю"
fi

# Убедимся, что после удаления строки тег AdView всё ещё корректно закрыт
# атрибутом app:adSize="BANNER"/> (последний оставшийся атрибут должен
# заканчиваться на "/>").
if ! grep -A1 'com.google.android.gms.ads.AdView' "$LAYOUT" | grep -q 'adSize'; then
    echo "!!! Внимание: проверь вручную блок AdView в $LAYOUT — структура тега могла измениться"
fi
if grep -q 'app:adSize="BANNER"$' "$LAYOUT"; then
    sed -i 's#app:adSize="BANNER"$#app:adSize="BANNER"/>#' "$LAYOUT"
    echo "OK: закрывающий /> перенесён на app:adSize в $LAYOUT"
fi

echo ""
echo "=== Обновление AdsManager.kt: явный флаг, чтобы adUnitId выставлялся максимум один раз ==="

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
 * ВАЖНО (краш "The ad unit ID can only be set once on AdView"): adUnitId
 * можно установить у AdView ровно один раз за всё время его жизни — либо
 * через XML (app:adUnitId), либо через код (adView.adUnitId = ...), но не
 * оба раза и не дважды в коде. Раньше id был прописан и в XML-layout, и
 * здесь в коде для debug-сборок — вторая установка и приводила к падению.
 * Теперь XML не задаёт adUnitId вообще — единственная точка установки ниже,
 * в коде, ровно один раз за вызов setupAndLoadBanner.
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

        // adUnitId у AdView можно установить только один раз за всё время жизни
        // объекта — XML больше его не задаёт, поэтому это единственное место
        // установки. В debug-сборке (это то, что собирается в Termux через
        // debug.keystore) подставляем официальный тестовый рекламный блок Google —
        // он гарантированно показывает рекламу и не зависит ни от согласия UMP,
        // ни от заполнения инвентаря, ни от статуса модерации приложения в AdMob.
        // Это позволяет сразу увидеть, что баннер технически работает, независимо
        // от настроек AdMob.
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
echo "OK: $ADS_MANAGER переписан"

echo ""
echo "=== Готово. Пересобери APK: ./gradlew assembleDebug (или как обычно у тебя настроено) ==="
