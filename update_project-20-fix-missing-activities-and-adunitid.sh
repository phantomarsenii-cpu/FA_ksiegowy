#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Обновление 20: восстанавливаем недостающие экраны + фикс краша AdView ==="
echo "Диагноз: update-17 должен был создать 4 новых экрана настроек, но в репозитории"
echo "оказались только SettingsTaxActivity/SettingsBackupActivity (+ их layout)."
echo "SettingsLanguageActivity, SettingsProActivity и их layout отсутствовали,"
echo "хотя SettingsActivity.kt на них уже ссылается — это unresolved reference"
echo "при сборке. Плюс все 4 новых экрана не были прописаны в AndroidManifest.xml."
echo ""

# ---------------------------------------------------------------------------
# 1) Восстанавливаем activity_settings_language.xml
# ---------------------------------------------------------------------------
LAYOUT_LANG="app/src/main/res/layout/activity_settings_language.xml"
if [ ! -f "$LAYOUT_LANG" ]; then
    mkdir -p "$(dirname "$LAYOUT_LANG")"
    cat > "$LAYOUT_LANG" << 'EOF_LAYOUT_LANG'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:fillViewport="true">

<LinearLayout
    android:orientation="vertical" android:padding="24dp"
    android:layout_width="match_parent" android:layout_height="wrap_content">

    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="@string/settings_menu_language" android:textSize="22sp" android:textStyle="bold"
        android:textColor="@color/accent_cyan" android:layout_marginBottom="24dp"/>

    <Button android:id="@+id/btn_lang_en" android:layout_width="match_parent" android:layout_height="52dp"
        android:text="English" android:textAllCaps="false" android:textColor="@color/text_primary"
        android:background="@drawable/btn_pill_outline" android:layout_marginBottom="12dp"/>
    <Button android:id="@+id/btn_lang_ru" android:layout_width="match_parent" android:layout_height="52dp"
        android:text="Русский" android:textAllCaps="false" android:textColor="@color/text_primary"
        android:background="@drawable/btn_pill_outline" android:layout_marginBottom="12dp"/>
    <Button android:id="@+id/btn_lang_pl" android:layout_width="match_parent" android:layout_height="52dp"
        android:text="Polski" android:textAllCaps="false" android:textColor="@color/text_primary"
        android:background="@drawable/btn_pill_outline"/>

</LinearLayout>
</ScrollView>
EOF_LAYOUT_LANG
    echo "OK: $LAYOUT_LANG восстановлен"
else
    echo "-- $LAYOUT_LANG уже есть, пропускаю"
fi

# ---------------------------------------------------------------------------
# 2) Восстанавливаем activity_settings_pro.xml
# ---------------------------------------------------------------------------
LAYOUT_PRO="app/src/main/res/layout/activity_settings_pro.xml"
if [ ! -f "$LAYOUT_PRO" ]; then
    mkdir -p "$(dirname "$LAYOUT_PRO")"
    cat > "$LAYOUT_PRO" << 'EOF_LAYOUT_PRO'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:fillViewport="true">

<LinearLayout
    android:orientation="vertical" android:padding="24dp"
    android:layout_width="match_parent" android:layout_height="wrap_content">

    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="@string/settings_menu_pro" android:textSize="22sp" android:textStyle="bold"
        android:textColor="@color/accent_cyan" android:layout_marginBottom="16dp"/>

    <TextView android:id="@+id/tv_pro_status" android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="@string/pro_status_locked" android:textSize="15sp"
        android:textColor="@color/text_primary" android:layout_marginBottom="20dp"/>

    <Button android:id="@+id/btn_unlock_pro" android:layout_width="match_parent" android:layout_height="56dp"
        android:text="@string/pro_unlock_button" android:textAllCaps="false" android:textSize="16sp"
        android:textColor="@color/text_primary" android:background="@drawable/btn_pill_primary"/>

</LinearLayout>
</ScrollView>
EOF_LAYOUT_PRO
    echo "OK: $LAYOUT_PRO восстановлен"
else
    echo "-- $LAYOUT_PRO уже есть, пропускаю"
fi

# ---------------------------------------------------------------------------
# 3) Восстанавливаем SettingsLanguageActivity.kt
# ---------------------------------------------------------------------------
KT_LANG="app/src/main/java/com/example/fa_ksiegowy/SettingsLanguageActivity.kt"
if [ ! -f "$KT_LANG" ]; then
    mkdir -p "$(dirname "$KT_LANG")"
    cat > "$KT_LANG" << 'EOF_KT_LANG'
package com.example.fa_ksiegowy

import android.content.Intent
import android.os.Bundle
import android.widget.Button

/** Выбор языка приложения. Смена языка перезапускает MineActivity как единственный
 *  экран в задаче, чтобы весь UI (в т.ч. уже открытые экраны) пересобрался с новой локалью. */
class SettingsLanguageActivity : BaseActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_settings_language)

        findViewById<Button>(R.id.btn_lang_en).setOnClickListener { setLocale("en") }
        findViewById<Button>(R.id.btn_lang_ru).setOnClickListener { setLocale("ru") }
        findViewById<Button>(R.id.btn_lang_pl).setOnClickListener { setLocale("pl") }
    }

    private fun setLocale(code: String) {
        LocaleHelper.setLanguage(this, code)
        val intent = Intent(this, MineActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
        startActivity(intent)
        finishAffinity()
    }
}
EOF_KT_LANG
    echo "OK: $KT_LANG восстановлен"
else
    echo "-- $KT_LANG уже есть, пропускаю"
fi

# ---------------------------------------------------------------------------
# 4) Восстанавливаем SettingsProActivity.kt
# ---------------------------------------------------------------------------
KT_PRO="app/src/main/java/com/example/fa_ksiegowy/SettingsProActivity.kt"
if [ ! -f "$KT_PRO" ]; then
    mkdir -p "$(dirname "$KT_PRO")"
    cat > "$KT_PRO" << 'EOF_KT_PRO'
package com.example.fa_ksiegowy

import android.app.AlertDialog
import android.os.Bundle
import android.widget.Button
import android.widget.TextView

/** Разблокировка Pro-версии (разовая покупка через Google Play Billing). */
class SettingsProActivity : BaseActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_settings_pro)
        setupProSection()
    }

    private fun setupProSection() {
        val tvStatus = findViewById<TextView>(R.id.tv_pro_status)
        val btnUnlock = findViewById<Button>(R.id.btn_unlock_pro)

        fun refreshUi() {
            if (BillingManager.isPro(this)) {
                tvStatus.text = getString(R.string.pro_status_active)
                btnUnlock.isEnabled = false
                btnUnlock.text = getString(R.string.pro_status_active)
            } else {
                tvStatus.text = getString(R.string.pro_status_locked)
                btnUnlock.isEnabled = true
            }
        }
        refreshUi()

        BillingManager.connect(this) { connected ->
            runOnUiThread {
                if (!connected) return@runOnUiThread
                BillingManager.restorePurchases(this) { refreshUi() }
                if (!BillingManager.isPro(this)) {
                    BillingManager.queryProProductDetails { price ->
                        runOnUiThread {
                            btnUnlock.text = if (price != null) {
                                getString(R.string.pro_unlock_button_price, price)
                            } else {
                                getString(R.string.pro_unlock_button)
                            }
                        }
                    }
                }
            }
        }

        btnUnlock.setOnClickListener {
            AlertDialog.Builder(this)
                .setTitle(getString(R.string.pro_info_title))
                .setMessage(getString(R.string.pro_info_message))
                .setPositiveButton(getString(R.string.pro_info_continue)) { _, _ ->
                    BillingManager.launchPurchase(this)
                }
                .setNegativeButton(getString(R.string.dialog_close), null)
                .show()
        }
    }

    override fun onResume() {
        super.onResume()
        // На случай возврата из окна оплаты Google Play — обновить статус и кнопку.
        BillingManager.restorePurchases(this) {
            val tvStatus = findViewById<TextView>(R.id.tv_pro_status)
            val btnUnlock = findViewById<Button>(R.id.btn_unlock_pro)
            if (BillingManager.isPro(this)) {
                tvStatus.text = getString(R.string.pro_status_active)
                btnUnlock.isEnabled = false
                btnUnlock.text = getString(R.string.pro_status_active)
            }
        }
    }
}
EOF_KT_PRO
    echo "OK: $KT_PRO восстановлен"
else
    echo "-- $KT_PRO уже есть, пропускаю"
fi

# ---------------------------------------------------------------------------
# 5) Регистрируем ВСЕ 4 новых экрана настроек в AndroidManifest.xml
#    (SettingsTaxActivity и SettingsBackupActivity тоже отсутствовали там)
# ---------------------------------------------------------------------------
MANIFEST="app/src/main/AndroidManifest.xml"
if [ ! -f "$MANIFEST" ]; then
    echo "!!! Не найден $MANIFEST"
    exit 1
fi

for ACT in SettingsTaxActivity SettingsBackupActivity SettingsLanguageActivity SettingsProActivity; do
    if ! grep -q "android:name=\"\.$ACT\"" "$MANIFEST"; then
        sed -i "s#<activity android:name=\"\.SettingsActivity\" android:exported=\"false\" />#<activity android:name=\".SettingsActivity\" android:exported=\"false\" />\n        <activity android:name=\".$ACT\" android:exported=\"false\" />#" "$MANIFEST"
        echo "OK: $ACT зарегистрирован в $MANIFEST"
    else
        echo "-- $ACT уже зарегистрирован, пропускаю"
    fi
done

# ---------------------------------------------------------------------------
# 6) Фикс краша "The ad unit ID can only be set once on AdView"
#    (adUnitId задавался и в XML, и повторно в коде для debug-сборок)
# ---------------------------------------------------------------------------
LAYOUT_MINE="app/src/main/res/layout/activity_mine.xml"
if [ -f "$LAYOUT_MINE" ] && grep -q 'app:adUnitId="ca-app-pub-9218963926031039/4293553475"' "$LAYOUT_MINE"; then
    sed -i '/app:adUnitId="ca-app-pub-9218963926031039\/4293553475"/d' "$LAYOUT_MINE"
    sed -i 's#app:adSize="BANNER"$#app:adSize="BANNER"/>#' "$LAYOUT_MINE"
    echo "OK: app:adUnitId удалён из $LAYOUT_MINE (единственная точка установки — код)"
else
    echo "-- $LAYOUT_MINE уже без дублирующего adUnitId, пропускаю"
fi

ADS_MANAGER="app/src/main/java/com/example/fa_ksiegowy/AdsManager.kt"
if [ -f "$ADS_MANAGER" ]; then
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
fi

echo ""
echo "=== Готово. Пересобери APK: ./gradlew assembleDebug ==="
echo "=== git add -A && git commit -m 'Fix: restore missing settings screens + AdView adUnitId crash' && git push ==="
