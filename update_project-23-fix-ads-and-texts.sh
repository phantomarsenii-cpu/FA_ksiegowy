#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Обновление 23: реклама всё ещё не показывается + неполный текст Pro + кривой английский 'About the app' ==="
echo ""

# -----------------------------------------------------------------------
# 1) РЕКЛАМА НЕ ПОКАЗЫВАЕТСЯ (даже после фикса краша adSize)
# -----------------------------------------------------------------------
# Причина: в debug-сборке (та, что собирается в Termux) баннер должен
# использовать официальный ТЕСТОВЫЙ рекламный блок Google, который не
# требует согласия пользователя (UMP/GDPR) и показывается всегда.
# Но в прошлой версии AdsManager.kt тестовый блок всё равно грузился
# ТОЛЬКО если consentInformation.canRequestAds() == true. А это условие
# становится true для пользователя из Польши (страна ЕЭЗ) только после
# того, как в консоли AdMob (Privacy & messaging) создано и ОПУБЛИКОВАНО
# сообщение о согласии на сбор данных. Пока это не настроено в консоли —
# canRequestAds() остаётся false, и даже тестовая (гарантированная) реклама
# не грузится — то есть баннер молчит без единой ошибки.
#
# Фикс: для debug-сборки полностью пропускаем цепочку согласия UMP и грузим
# тестовый баннер сразу. Это то, что нужно, чтобы прямо сейчас увидеть
# рекламу в приложении и убедиться, что технически всё работает.
#
# Для боевой (release) сборки цепочка согласия остаётся как есть — но
# ИМЕЙ В ВИДУ: чтобы боевая реклама показывалась пользователям из Польши/ЕС,
# нужно один раз зайти в admob.google.com -> Privacy & messaging -> создать
# и ОПУБЛИКОВАТЬ (Publish) сообщение о согласии. Без этого шага в консоли
# никакой код это не исправит — это настройка на стороне Google, а не баг.
# Также новый рекламный блок первые часы/дни может не отдавать рекламу
# ("no fill") — это нормально для новых блоков.

ADS_MANAGER="app/src/main/java/com/example/fa_ksiegowy/AdsManager.kt"
if [ ! -f "$ADS_MANAGER" ]; then
    echo "!!! Не найден $ADS_MANAGER"
    exit 1
fi

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
EOF_ADS_MANAGER_KT
echo "OK: $ADS_MANAGER — debug-сборка теперь грузит тестовый баннер без ожидания согласия UMP"
echo ""

# -----------------------------------------------------------------------
# 2) НЕПОЛНОЕ ОПИСАНИЕ TOГО, ЧТО ДАЁТ PRO (на экране Settings -> Pro)
# -----------------------------------------------------------------------
# На самом экране Pro (не во всплывающем диалоге, а в сером тексте под
# заголовком) описаны только "годовой/произвольный отчёт в Excel", но
# пропущено "без рекламы" — третье реальное преимущество Pro (оно есть
# в диалоге "Pro-версия", но не в самом тексте экрана). Дополняем текст
# во всех трёх языках, чтобы он был полным и соответствовал диалогу.

fix_pro_status() {
    local FILE="$1" OLD="$2" NEW="$3"
    if [ ! -f "$FILE" ]; then
        echo "!!! Не найден $FILE"
        exit 1
    fi
    if grep -qF "$OLD" "$FILE"; then
        python3 - "$FILE" "$OLD" "$NEW" << 'EOF_PY'
import sys, io
path, old, new = sys.argv[1], sys.argv[2], sys.argv[3]
with io.open(path, "r", encoding="utf-8") as f:
    content = f.read()
content = content.replace(old, new, 1)
with io.open(path, "w", encoding="utf-8") as f:
    f.write(content)
EOF_PY
        echo "OK: обновлён pro_status_locked в $FILE"
    else
        echo "-- pro_status_locked в $FILE уже не совпадает с ожидаемым (пропускаю, возможно уже исправлено)"
    fi
}

fix_pro_status \
    "app/src/main/res/values/strings.xml" \
    '<string name="pro_status_locked">Pro is locked. Unlock to get yearly/custom Excel reports.</string>' \
    '<string name="pro_status_locked">Pro is locked. Unlock to get yearly/custom Excel reports and remove ads.</string>'

fix_pro_status \
    "app/src/main/res/values-ru/strings.xml" \
    '<string name="pro_status_locked">Pro не активирован. Разблокируйте, чтобы получить годовые и произвольные отчёты в Excel.</string>' \
    '<string name="pro_status_locked">Pro не активирован. Разблокируйте, чтобы получить годовые и произвольные отчёты в Excel и убрать рекламу.</string>'

fix_pro_status \
    "app/src/main/res/values-pl/strings.xml" \
    '<string name="pro_status_locked">Pro jest zablokowane. Odblokuj, aby uzyskać roczne i niestandardowe raporty Excel.</string>' \
    '<string name="pro_status_locked">Pro jest zablokowane. Odblokuj, aby uzyskać roczne i niestandardowe raporty Excel oraz usunąć reklamy.</string>'

echo ""

# -----------------------------------------------------------------------
# 3) АНГЛИЙСКОЕ ОПИСАНИЕ "About the app" СЛИПЛОСЬ В ОДИН АБЗАЦ
# -----------------------------------------------------------------------
# Причина: в values/strings.xml английский about_description был записан
# как обычный многострочный текст прямо в XML-файле (реальные переносы
# строк). Android при сборке ресурсов схлопывает такие "живые" переносы
# строк в пробелы — поэтому список функций со смайликами превращался в
# одну сплошную "простыню" текста (это видно на скриншоте). В русской и
# польской версиях переносы строк заданы правильно — через \n и \n\n
# ЭКРАНИРОВАННО, одной строкой — поэтому там всё красиво с абзацами и
# списком. Приводим английскую версию к тому же формату.

STRINGS_EN="app/src/main/res/values/strings.xml"
if [ ! -f "$STRINGS_EN" ]; then
    echo "!!! Не найден $STRINGS_EN"
    exit 1
fi

python3 - "$STRINGS_EN" << 'EOF_PY'
import io, re, sys

path = sys.argv[1]
with io.open(path, "r", encoding="utf-8") as f:
    content = f.read()

new_value = (
    "FinArs is a convenient app for managing the finances of unregistered business "
    "activity. Easily track income and expenses, monitor your current balance, "
    "automatically calculate taxes and generate reports. The app helps you stay "
    "within limits, track financial indicators and always have the full history of "
    "operations at hand. A simple interface and quick data entry make daily "
    "bookkeeping as convenient as possible."
    "\\n\\nKey features:"
    "\\n\U0001F4B0 Income and expense tracking."
    "\\n\U0001F4CA Automatic profit calculation."
    "\\n\U0001F9FE Tax calculation."
    "\\n\U0001F4C8 Monitoring of unregistered activity limits."
    "\\n\U0001F4C4 Report generation."
    "\\n\U0001F50D Full operation history."
    "\\n\U0001F319 Modern dark interface."
    "\\n\U0001F512 All data is stored locally on the device."
    "\\n\\nContact: p.arsenii@interia.pl"
)

new_line = '    <string name="about_description">%s</string>\n' % new_value

pattern = re.compile(r'[ \t]*<string name="about_description">.*?</string>\n', re.DOTALL)
content_new, count = pattern.subn(new_line, content, count=1)

if count != 1:
    print("!!! Не удалось найти строку about_description для замены (count=%d)" % count)
    sys.exit(1)

with io.open(path, "w", encoding="utf-8") as f:
    f.write(content_new)

print("OK: about_description в values/strings.xml переписан в одну строку с \\n (как в RU/PL)")
EOF_PY

echo ""
echo "=== Готово. Пересобери APK: ./gradlew assembleDebug ==="
echo "=== git add -A && git commit -m 'Fix: debug banner without consent gate, fuller Pro text, format EN about text' && git push ==="
echo ""
echo "НАПОМИНАНИЕ про боевую (release) рекламу:"
echo "Зайди в admob.google.com -> Privacy & messaging -> создай и ОПУБЛИКУЙ сообщение"
echo "о согласии (GDPR), иначе боевой баннер не будет грузиться для пользователей из ЕЭЗ."
