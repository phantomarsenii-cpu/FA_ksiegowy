#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Обновление: Google Play Billing (Unlock Pro) + AdMob реклама + защита покупок + скрытый код разработчика ==="

mkdir -p "$(dirname "app/build.gradle")"
cat > app/build.gradle << 'GRADLE_EOF_0'
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
    id 'com.google.devtools.ksp'
}

android {
    signingConfigs {
        debug {
            storeFile file("debug.keystore")
            storePassword "fa_ksiegowy_debug"
            keyAlias "fa_ksiegowy_debug"
            keyPassword "fa_ksiegowy_debug"
        }
    }

    namespace "com.example.fa_ksiegowy"
    compileSdk 34

    defaultConfig {
        applicationId "com.example.fa_ksiegowy"
        minSdk 26
        targetSdk 34
        versionCode 1
        versionName "1.0"
        multiDexEnabled true
    }

    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    compileOptions { sourceCompatibility JavaVersion.VERSION_17; targetCompatibility JavaVersion.VERSION_17 }
    kotlinOptions { jvmTarget = '17' }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib:1.9.0"
    implementation "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3"
    implementation "androidx.core:core-ktx:1.10.1"
    implementation "androidx.appcompat:appcompat:1.6.1"
    implementation "androidx.activity:activity-ktx:1.7.2"
    implementation "com.google.android.material:material:1.9.0"
    implementation "androidx.constraintlayout:constraintlayout:2.1.4"
    implementation "androidx.recyclerview:recyclerview:1.2.1"
    implementation "androidx.room:room-runtime:2.5.0"
    ksp "androidx.room:room-compiler:2.5.0"
    implementation "androidx.room:room-ktx:2.5.0"
    implementation "org.apache.poi:poi-ooxml:5.2.3"
    implementation "androidx.multidex:multidex:2.0.1"
    implementation "com.android.billingclient:billing-ktx:7.1.1"
    implementation "com.google.android.gms:play-services-ads:23.6.0"
    implementation "com.google.android.ump:user-messaging-platform:3.1.0"
}
GRADLE_EOF_0
echo "OK: app/build.gradle"

mkdir -p "$(dirname "app/src/main/AndroidManifest.xml")"
cat > app/src/main/AndroidManifest.xml << 'XML_EOF_1'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:allowBackup="true"
        android:label="@string/app_name"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:theme="@style/Theme.FA">

        <!-- ЗАМЕНИТЬ на реальный AdMob App ID из консоли AdMob (Apps -> Ваше приложение -> App settings) -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3940256099942544~3347511713" />

        <activity android:name=".SettingsActivity" android:exported="false" />
        <activity android:name=".AddEntryActivity" android:exported="false" />
        <activity android:name=".ReportActivity" android:exported="false" />
        <activity android:name=".MineActivity" android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths" />
        </provider>
    </application>
</manifest>
XML_EOF_1
echo "OK: app/src/main/AndroidManifest.xml"

mkdir -p "$(dirname "app/proguard-rules.pro")"
cat > app/proguard-rules.pro << 'PRO_EOF_2'
# ВАЖНО: включение minifyEnabled требует тщательного тестирования release-сборки перед публикацией —
# особенно экспорт отчётов (Apache POI активно использует рефлексию) и Room (генерируемый код).
# Соберите release APK, установите на реальное устройство и пройдите все сценарии (добавление
# записей, экспорт годового отчёта, покупка/восстановление Pro, показ рекламы) до релиза в Play.

# Room — сгенерированный код доступа к базе
-keep class androidx.room.** { *; }
-keep @androidx.room.Entity class * { *; }
-keep @androidx.room.Dao class * { *; }
-dontwarn androidx.room.paging.**

# Apache POI (генерация xlsx-отчётов) — использует рефлексию и XML-парсинг, легко ломается R8
-keep class org.apache.poi.** { *; }
-keep class org.apache.xmlbeans.** { *; }
-keep class org.openxmlformats.** { *; }
-keep class schemasMicrosoftComVml.** { *; }
-dontwarn org.apache.poi.**
-dontwarn org.apache.xmlbeans.**
-dontwarn org.openxmlformats.**
-dontwarn org.apache.commons.compress.**
-dontwarn javax.xml.**
-dontwarn org.w3c.dom.**

# Google Play Billing — публичные модели покупок (Purchase, ProductDetails и т.п.)
-keep class com.android.billingclient.api.** { *; }

# Google Mobile Ads / UMP
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.ump.** { *; }
-dontwarn com.google.android.gms.ads.**

# Наши модели данных (Entry и т.п.) — не переименовывать поля/классы, используемые Room/Gson-подобной сериализацией
-keep class com.example.fa_ksiegowy.Entry { *; }

# Kotlin coroutines / metadata
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod, RuntimeVisibleAnnotations
-dontwarn kotlinx.coroutines.**
PRO_EOF_2
echo "OK: app/proguard-rules.pro"

mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/BillingManager.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/BillingManager.kt << 'KOTLIN_EOF_3'
package com.example.fa_ksiegowy

import android.app.Activity
import android.content.Context
import android.util.Log
import java.security.MessageDigest
import com.android.billingclient.api.AcknowledgePurchaseParams
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.QueryPurchasesParams
import com.android.billingclient.api.queryProductDetails
import com.android.billingclient.api.queryPurchasesAsync

/**
 * Обёртка над Google Play Billing для разовой покупки "Pro" (не подписка).
 * Product ID "pro_unlock" должен быть создан в Play Console:
 * Monetize -> Products -> In-app products -> Create product (One-time product).
 */
object BillingManager {

    const val PRO_PRODUCT_ID = "pro_unlock"
    private const val PREFS_NAME = "settings"

    // Два независимых флага: реальная покупка через Google Play, и "выданный вручную"
    // доступ (промокод разработчика). isPro() = ИЛИ этих двух флагов. Это важно:
    // restorePurchases() должен обновлять ТОЛЬКО первый флаг — иначе он затрёт промокод
    // разработчика при следующей сверке с Google Play (у которого об этом коде ничего не известно).
    private const val KEY_IS_PRO_PURCHASED = "isProPurchased"
    private const val KEY_IS_PRO_PROMO = "isProPromo"

    // Код разработчика/тестировщика хранится как SHA-256 хэш, а не открытым текстом,
    // чтобы он не был виден при поверхностном просмотре декомпилированного APK.
    private const val DEV_CODE_SHA256 = "1edc850201cfdf17a41d59873127825355e7a03a3f8c0ab3e550099291844a55"

    private var billingClient: BillingClient? = null
    private var proProductDetails: com.android.billingclient.api.ProductDetails? = null

    private val purchasesUpdatedListener = PurchasesUpdatedListener { result, purchases ->
        if (result.responseCode == BillingClient.BillingResponseCode.OK && purchases != null) {
            for (purchase in purchases) {
                handlePurchase(purchase)
            }
        }
        // Если пользователь отменил окно оплаты (USER_CANCELED) — просто ничего не делаем.
    }

    /** Быстрая локальная проверка (кэш) — используйте её для скрытия/показа Pro-функций в UI. */
    fun isPro(context: Context): Boolean {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getBoolean(KEY_IS_PRO_PURCHASED, false) || prefs.getBoolean(KEY_IS_PRO_PROMO, false)
    }

    private fun setPurchasedLocally(context: Context, value: Boolean) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit().putBoolean(KEY_IS_PRO_PURCHASED, value).apply()
    }

    /**
     * Ввод кода разработчика/тестировщика — выдаёт Pro локально, без реальной покупки.
     * @return true, если код верный и Pro выдан.
     *
     * ПРИМЕЧАНИЕ: для полноценного тестирования покупок (а не просто разблокировки фич)
     * гораздо правильнее добавить свой email в Play Console -> Monetization setup ->
     * License testing — тогда можно пройти НАСТОЯЩЕЕ окно оплаты бесплатно ("тестовая карта").
     * Код ниже — это просто быстрый бэкдор для себя, а не замена нормальному тестированию биллинга.
     */
    fun tryUnlockWithDevCode(context: Context, code: String): Boolean {
        val hash = sha256(code.trim())
        val ok = hash.equals(DEV_CODE_SHA256, ignoreCase = true)
        if (ok) {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit().putBoolean(KEY_IS_PRO_PROMO, true).apply()
        }
        return ok
    }

    private fun sha256(input: String): String {
        val bytes = MessageDigest.getInstance("SHA-256").digest(input.toByteArray())
        return bytes.joinToString("") { "%02x".format(it) }
    }

    /** Вызывайте один раз при старте активности, где нужен биллинг (например SettingsActivity). */
    fun connect(context: Context, onReady: (connected: Boolean) -> Unit) {
        if (billingClient?.isReady == true) {
            onReady(true)
            return
        }
        val client = BillingClient.newBuilder(context.applicationContext)
            .setListener(purchasesUpdatedListener)
            .enablePendingPurchases()
            .build()
        billingClient = client

        client.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(result: BillingResult) {
                val ok = result.responseCode == BillingClient.BillingResponseCode.OK
                if (ok) {
                    // При каждом подключении сверяем реальное состояние покупки с Google Play,
                    // а не только с локальным кэшем (на случай новой установки/смены устройства).
                    restorePurchases(context) {}
                }
                onReady(ok)
            }

            override fun onBillingServiceDisconnected() {
                // BillingClient сам не переподключается — переподключение произойдёт
                // при следующем вызове connect().
            }
        })
    }

    /** Подтягивает цену и название товара из консоли Google Play, чтобы показать в UI. */
    fun queryProProductDetails(callback: (price: String?) -> Unit) {
        val client = billingClient ?: return callback(null)
        val product = QueryProductDetailsParams.Product.newBuilder()
            .setProductId(PRO_PRODUCT_ID)
            .setProductType(BillingClient.ProductType.INAPP)
            .build()
        val params = QueryProductDetailsParams.newBuilder()
            .setProductList(listOf(product))
            .build()

        client.queryProductDetailsAsync(params) { result, productDetailsList ->
            if (result.responseCode == BillingClient.BillingResponseCode.OK &&
                productDetailsList.isNotEmpty()
            ) {
                proProductDetails = productDetailsList[0]
                val price = productDetailsList[0].oneTimePurchaseOfferDetails?.formattedPrice
                callback(price)
            } else {
                callback(null)
            }
        }
    }

    /** Запускает окно оплаты Google Play. Требует, чтобы queryProProductDetails уже отработал. */
    fun launchPurchase(activity: Activity) {
        val client = billingClient ?: return
        val details = proProductDetails ?: return

        val productDetailsParams = BillingFlowParams.ProductDetailsParams.newBuilder()
            .setProductDetails(details)
            .build()
        val flowParams = BillingFlowParams.newBuilder()
            .setProductDetailsParamsList(listOf(productDetailsParams))
            .build()
        client.launchBillingFlow(activity, flowParams)
    }

    private fun handlePurchase(purchase: Purchase) {
        if (purchase.purchaseState != Purchase.PurchaseState.PURCHASED) return
        if (!purchase.products.contains(PRO_PRODUCT_ID)) return

        // Защита от поддельных/подменённых ответов биллинга (см. PurchaseVerifier.kt):
        // не подтверждаем и не засчитываем покупку с невалидной подписью.
        if (!PurchaseVerifier.verify(purchase.originalJson, purchase.signature)) {
            Log.w("BillingManager", "Purchase signature verification FAILED — ignoring purchase")
            return
        }

        if (!purchase.isAcknowledged) {
            val client = billingClient ?: return
            val ackParams = AcknowledgePurchaseParams.newBuilder()
                .setPurchaseToken(purchase.purchaseToken)
                .build()
            client.acknowledgePurchase(ackParams) { }
        }
    }

    /**
     * Сверяет с серверами Google, куплен ли pro_unlock, и обновляет локальный кэш.
     * Учитываются только покупки с валидной подписью.
     * Вызывать: при старте (после connect) и сразу после возврата из окна оплаты.
     */
    fun restorePurchases(context: Context, onResult: (isPro: Boolean) -> Unit) {
        val client = billingClient
        if (client == null || !client.isReady) {
            onResult(isPro(context))
            return
        }
        val params = QueryPurchasesParams.newBuilder()
            .setProductType(BillingClient.ProductType.INAPP)
            .build()

        client.queryPurchasesAsync(params) { result, purchases ->
            if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                val validOwned = purchases.filter {
                    it.products.contains(PRO_PRODUCT_ID) &&
                        it.purchaseState == Purchase.PurchaseState.PURCHASED &&
                        PurchaseVerifier.verify(it.originalJson, it.signature)
                }
                setPurchasedLocally(context, validOwned.isNotEmpty())
                validOwned.forEach { handlePurchase(it) }
                onResult(isPro(context))
            } else {
                onResult(isPro(context))
            }
        }
    }
}
KOTLIN_EOF_3
echo "OK: app/src/main/java/com/example/fa_ksiegowy/BillingManager.kt"

mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/PurchaseVerifier.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/PurchaseVerifier.kt << 'KOTLIN_EOF_4'
package com.example.fa_ksiegowy

import android.util.Base64
import android.util.Log
import java.security.KeyFactory
import java.security.PublicKey
import java.security.Signature
import java.security.spec.X509EncodedKeySpec

/**
 * Проверка подписи покупки локальным публичным ключом лицензирования из Play Console
 * (Play Console -> ваше приложение -> Monetize -> Monetization setup -> Licensing ->
 * "Base64-encoded RSA public key").
 *
 * Зачем это нужно: инструменты вроде Lucky Patcher / freedom apk на рутованных
 * устройствах подменяют ОТВЕТ BillingClient, заставляя приложение думать, что покупка
 * прошла, хотя реальной транзакции в Google Play не было. BillingClient сам НЕ проверяет
 * подпись за вас — эта проверка ложится на приложение (в старом Billing API v3 её делала
 * входящая в комплект библиотека IabHelper, сейчас это нужно писать самим).
 *
 * ВАЖНО (честно): это не защита уровня сервера. Ключ и код проверки лежат в APK,
 * и опытный человек с реверс-инжинирингом теоретически может его вырезать целиком.
 * Настоящая защита "от взлома" делается только серверной проверкой через
 * Google Play Developer API (purchases.products.get) с вашим service account —
 * тогда решение "выдавать Pro или нет" принимает не устройство пользователя, а ваш
 * сервер. Локальная проверка — это разумный компромисс без бэкенда: она отсекает
 * подавляющее большинство массовых "патчеров", которые просто подменяют локальный
 * ответ, но не подделывают RSA-подпись.
 */
object PurchaseVerifier {

    // TODO: обязательно вставьте сюда свой ключ из Play Console (см. описание выше).
    // Пока тут заглушка — проверка работать не будет, пока вы его не подставите.
    private const val BASE64_PUBLIC_KEY = "PASTE_YOUR_LICENSING_PUBLIC_KEY_HERE"

    private val publicKey: PublicKey? by lazy {
        if (BASE64_PUBLIC_KEY == "PASTE_YOUR_LICENSING_PUBLIC_KEY_HERE") {
            Log.w("PurchaseVerifier", "Licensing public key is not configured — signature check is skipped!")
            null
        } else try {
            val keyBytes = Base64.decode(BASE64_PUBLIC_KEY, Base64.DEFAULT)
            KeyFactory.getInstance("RSA").generatePublic(X509EncodedKeySpec(keyBytes))
        } catch (e: Exception) {
            Log.e("PurchaseVerifier", "Invalid public key", e)
            null
        }
    }

    /**
     * @return true, если подпись валидна ИЛИ ключ ещё не настроен (fail-open на время разработки,
     * чтобы не сломать вам тестирование, пока вы не вставили реальный ключ — не забудьте это убрать
     * / настроить ключ перед релизом, иначе проверка фактически не работает).
     */
    fun verify(signedData: String, signature: String): Boolean {
        val key = publicKey ?: return true // ключ не настроен — см. предупреждение выше
        return try {
            val sig = Signature.getInstance("SHA1withRSA")
            sig.initVerify(key)
            sig.update(signedData.toByteArray())
            sig.verify(Base64.decode(signature, Base64.DEFAULT))
        } catch (e: Exception) {
            Log.e("PurchaseVerifier", "Signature verification failed", e)
            false
        }
    }
}
KOTLIN_EOF_4
echo "OK: app/src/main/java/com/example/fa_ksiegowy/PurchaseVerifier.kt"

mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/AdsManager.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/AdsManager.kt << 'KOTLIN_EOF_5'
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
KOTLIN_EOF_5
echo "OK: app/src/main/java/com/example/fa_ksiegowy/AdsManager.kt"

mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/MineActivity.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/MineActivity.kt << 'KOTLIN_EOF_6'
package com.example.fa_ksiegowy

import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.MotionEvent
import android.widget.Button
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.gms.ads.AdView
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.Locale

class MineActivity : BaseActivity() {
    private lateinit var db: AppDatabase

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_mine)
        db = AppDatabase.getInstance(this)

        findViewById<Button>(R.id.btn_add_income).setOnClickListener {
            startActivity(Intent(this, AddEntryActivity::class.java).putExtra("isIncome", true))
        }
        findViewById<Button>(R.id.btn_add_expense).setOnClickListener {
            startActivity(Intent(this, AddEntryActivity::class.java).putExtra("isIncome", false))
        }
        findViewById<Button>(R.id.btn_settings).setOnClickListener {
            startActivity(Intent(this, SettingsActivity::class.java))
        }
        findViewById<Button>(R.id.btn_reports).setOnClickListener {
            startActivity(Intent(this, ReportActivity::class.java))
        }

        findViewById<RecyclerView>(R.id.rv_entries).layoutManager = LinearLayoutManager(this)

        AdsManager.setupAndLoadBanner(this, findViewById(R.id.ad_banner))
        setupHiddenDevCodeGesture()
    }

    /**
     * Скрытый вход для разработчика: удержание пальца на логотипе 10 секунд открывает
     * диалог ввода кода. Никакой видимой кнопки/подсказки в UI нет — это сделано умышленно,
     * чтобы обычный пользователь не наткнулся на неё случайно.
     */
    private fun setupHiddenDevCodeGesture() {
        val handler = Handler(Looper.getMainLooper())
        val holdDurationMs = 10_000L
        var triggered = false

        val showCodeDialog = Runnable {
            if (triggered) return@Runnable
            triggered = true
            val input = EditText(this)
            input.hint = getString(R.string.enter_code_hint)
            AlertDialog.Builder(this)
                .setTitle(getString(R.string.enter_code_title))
                .setView(input)
                .setPositiveButton(getString(R.string.enter_code_apply)) { _, _ ->
                    val ok = BillingManager.tryUnlockWithDevCode(this, input.text.toString())
                    Toast.makeText(
                        this,
                        getString(if (ok) R.string.enter_code_success else R.string.enter_code_wrong),
                        Toast.LENGTH_SHORT
                    ).show()
                }
                .setNegativeButton(getString(R.string.dialog_close), null)
                .show()
        }

        findViewById<ImageView>(R.id.iv_logo).setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    triggered = false
                    handler.postDelayed(showCodeDialog, holdDurationMs)
                    true
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    handler.removeCallbacks(showCodeDialog)
                    true
                }
                else -> false
            }
        }
    }

    override fun onDestroy() {
        findViewById<AdView>(R.id.ad_banner).destroy()
        super.onDestroy()
    }

    override fun onResume() {
        super.onResume()
        loadData()
        if (BillingManager.isPro(this)) {
            AdsManager.hideBanner(findViewById(R.id.ad_banner))
        }
    }

    private fun loadData() {
        CoroutineScope(Dispatchers.IO).launch {
            // Полная история — для списка операций (не ограничена годом).
            val allEntries = db.entryDao().getAll()

            // Баланс/статистика/налог — только за текущий календарный год,
            // так как лимит 30 000 zł годовой (см. TaxHelper).
            val year = TaxHelper.currentYear()
            val (yearStart, yearEndExclusive) = TaxHelper.yearRange(year)
            val yearEntries = db.entryDao().getBetween(yearStart, yearEndExclusive - 1)

            val income = yearEntries.filter { it.isIncome }.sumOf { it.amount }
            val expense = yearEntries.filter { !it.isIncome }.sumOf { it.amount }
            val profit = income - expense

            val prefs = getSharedPreferences("settings", MODE_PRIVATE)
            val taxPercent = prefs.getFloat("taxPercent", 12f)
            val otherIncome = TaxHelper.getOtherIncome(prefs, year)
            val taxResult = TaxHelper.calc(profit, otherIncome, taxPercent)

            withContext(Dispatchers.Main) {
                findViewById<TextView>(R.id.tv_balance).text = formatMoney(profit)
                findViewById<TextView>(R.id.tv_stat_income).text = formatMoney(income)
                findViewById<TextView>(R.id.tv_stat_expense).text = formatMoney(expense)
                findViewById<TextView>(R.id.tv_stat_profit).text = formatMoney(profit)
                findViewById<TextView>(R.id.tv_stat_tax_label).text =
                    getString(R.string.stat_tax_format, taxPercent.toInt())
                findViewById<TextView>(R.id.tv_stat_tax).text = formatMoney(taxResult.tax)
                findViewById<RecyclerView>(R.id.rv_entries).adapter = EntryAdapter(allEntries)
            }
        }
    }

    private fun formatMoney(v: Double): String = String.format(Locale.getDefault(), "%.2f", v)
}
KOTLIN_EOF_6
echo "OK: app/src/main/java/com/example/fa_ksiegowy/MineActivity.kt"

mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/SettingsActivity.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/SettingsActivity.kt << 'KOTLIN_EOF_7'
package com.example.fa_ksiegowy

import android.app.AlertDialog
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class SettingsActivity : BaseActivity() {
    private lateinit var prefs: SharedPreferences

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_settings)
        prefs = getSharedPreferences("settings", MODE_PRIVATE)

        val etTax = findViewById<EditText>(R.id.et_tax)
        etTax.setText(prefs.getFloat("taxPercent", 12f).toString())
        findViewById<Button>(R.id.btn_save_tax).setOnClickListener {
            val v = etTax.text.toString().toFloatOrNull() ?: 12f
            prefs.edit().putFloat("taxPercent", v).apply()
            Toast.makeText(this, getString(R.string.saved), Toast.LENGTH_SHORT).show()
        }

        val year = TaxHelper.currentYear()
        val tvOtherIncomeLabel = findViewById<TextView>(R.id.tv_other_income_label)
        tvOtherIncomeLabel.text = getString(R.string.other_income_label, year)
        val etOtherIncome = findViewById<EditText>(R.id.et_other_income)
        etOtherIncome.setText(TaxHelper.getOtherIncome(prefs, year).toString())
        findViewById<Button>(R.id.btn_save_other_income).setOnClickListener {
            val v = etOtherIncome.text.toString().toDoubleOrNull() ?: 0.0
            TaxHelper.setOtherIncome(prefs, year, v)
            Toast.makeText(this, getString(R.string.saved), Toast.LENGTH_SHORT).show()
        }

        // Автоподбор процента по прогрессивной шкале PIT (12% / 32%, порог 120000 zł),
        // на основе прибыли из приложения за текущий год + прочих доходов из поля выше.
        // Пользователь, знающий свою ставку, может после этого поправить значение вручную.
        findViewById<Button>(R.id.btn_auto_tax).setOnClickListener {
            val otherIncome = etOtherIncome.text.toString().toDoubleOrNull() ?: 0.0
            CoroutineScope(Dispatchers.IO).launch {
                val db = AppDatabase.getInstance(this@SettingsActivity)
                val (yearStart, yearEndExclusive) = TaxHelper.yearRange(year)
                val entries = db.entryDao().getBetween(yearStart, yearEndExclusive - 1)
                val income = entries.filter { it.isIncome }.sumOf { it.amount }
                val expense = entries.filter { !it.isIncome }.sumOf { it.amount }
                val appProfit = income - expense
                val totalTaxable = otherIncome + (if (appProfit > 0) appProfit else 0.0)
                val suggested = TaxHelper.suggestTaxPercent(totalTaxable)

                withContext(Dispatchers.Main) {
                    etTax.setText(suggested.toString())
                    Toast.makeText(
                        this@SettingsActivity,
                        getString(R.string.auto_tax_result, suggested),
                        Toast.LENGTH_LONG
                    ).show()
                }
            }
        }

        findViewById<Button>(R.id.btn_lang_ru).setOnClickListener { setLocale("ru") }
        findViewById<Button>(R.id.btn_lang_pl).setOnClickListener { setLocale("pl") }
        findViewById<Button>(R.id.btn_lang_en).setOnClickListener { setLocale("en") }

        setupProSection()

        findViewById<Button>(R.id.btn_about).setOnClickListener {
            AlertDialog.Builder(this)
                .setTitle(getString(R.string.about_app))
                .setMessage(getString(R.string.about_description))
                .setPositiveButton(getString(R.string.dialog_write)) { _, _ ->
                    val intent = Intent(Intent.ACTION_SENDTO).apply {
                        data = Uri.parse("mailto:" + getString(R.string.about_email))
                    }
                    startActivity(intent)
                }
                .setNegativeButton(getString(R.string.dialog_close), null)
                .show()
        }
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

    private fun setLocale(code: String) {
        LocaleHelper.setLanguage(this, code)
        val intent = Intent(this, MineActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
        startActivity(intent)
        finishAffinity()
    }
}
KOTLIN_EOF_7
echo "OK: app/src/main/java/com/example/fa_ksiegowy/SettingsActivity.kt"

mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/ReportActivity.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/ReportActivity.kt << 'KOTLIN_EOF_8'
package com.example.fa_ksiegowy

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.FileProvider
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.apache.poi.ss.usermodel.BorderStyle
import org.apache.poi.ss.usermodel.FillPatternType
import org.apache.poi.ss.usermodel.HorizontalAlignment
import org.apache.poi.ss.usermodel.IndexedColors
import org.apache.poi.xssf.usermodel.XSSFWorkbook
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

class ReportActivity : BaseActivity() {
    lateinit var db: AppDatabase

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_report)
        db = AppDatabase.getInstance(this)
        findViewById<Button>(R.id.btn_report_month).setOnClickListener { generateForMonth() }
        findViewById<Button>(R.id.btn_report_year).setOnClickListener {
            runIfPro { generateForYear() }
        }
        findViewById<Button>(R.id.btn_report_custom).setOnClickListener {
            runIfPro { Toast.makeText(this, "—", Toast.LENGTH_LONG).show() }
        }
    }

    /** Годовой и произвольный отчёт — платная функция; месячный остаётся бесплатным. */
    private fun runIfPro(action: () -> Unit) {
        if (BillingManager.isPro(this)) {
            action()
        } else {
            androidx.appcompat.app.AlertDialog.Builder(this)
                .setTitle(getString(R.string.pro_feature_locked_title))
                .setMessage(getString(R.string.pro_feature_locked_message))
                .setPositiveButton(getString(R.string.pro_feature_locked_go_settings)) { _, _ ->
                    startActivity(Intent(this, SettingsActivity::class.java))
                }
                .setNegativeButton(getString(R.string.dialog_close), null)
                .show()
        }
    }

    private fun generateForMonth() {
        val now = System.currentTimeMillis()
        val monthMs = 30L * 24 * 60 * 60 * 1000
        // Лимит 30 000 zł годовой, к частичному периоду его применять некорректно
        // (профит за один месяц почти всегда меньше лимита, отчёт вводил бы в
        // заблуждение) — поэтому здесь налог считается по старой формуле, без лимита.
        generateReport(now - monthMs, now, getString(R.string.report_title_month), applyAnnualLimit = false)
    }

    private fun generateForYear() {
        val year = TaxHelper.currentYear()
        val (yearStart, yearEndExclusive) = TaxHelper.yearRange(year)
        val now = System.currentTimeMillis()
        generateReport(
            yearStart, minOf(now, yearEndExclusive - 1),
            getString(R.string.report_title_year), applyAnnualLimit = true, year = year
        )
    }

    private fun generateReport(
        from: Long, to: Long, title: String,
        applyAnnualLimit: Boolean, year: Int = TaxHelper.currentYear()
    ) {
        setButtonsEnabled(false)
        Toast.makeText(this, getString(R.string.report_generating), Toast.LENGTH_SHORT).show()
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val entries = db.entryDao().getBetween(from, to)
                if (entries.isEmpty()) {
                    withContext(Dispatchers.Main) {
                        Toast.makeText(this@ReportActivity, getString(R.string.no_entries), Toast.LENGTH_LONG).show()
                        setButtonsEnabled(true)
                    }
                    return@launch
                }

                val reportsDir = File(getExternalFilesDir(null), "reports")
                reportsDir.mkdirs()
                val xlsx = File(reportsDir, "report_${System.currentTimeMillis()}.xlsx")
                val wb = XSSFWorkbook()
                val sheet = wb.createSheet(getString(R.string.report_sheet_name))

                val dateFmt = SimpleDateFormat("dd.MM.yyyy HH:mm", Locale.getDefault())
                val prefs = getSharedPreferences("settings", MODE_PRIVATE)
                val taxPercent = prefs.getFloat("taxPercent", 12f)

                // ---- styles (types inferred as XSSFCellStyle — required by XSSFCell.setCellStyle) ----
                val titleFont = wb.createFont().apply {
                    bold = true
                    fontHeightInPoints = 14
                    color = IndexedColors.WHITE.index
                }
                val titleStyle = wb.createCellStyle().apply {
                    setFont(titleFont)
                    fillForegroundColor = IndexedColors.ROYAL_BLUE.index
                    fillPattern = FillPatternType.SOLID_FOREGROUND
                    alignment = HorizontalAlignment.CENTER
                }

                val headerFont = wb.createFont().apply {
                    bold = true
                    color = IndexedColors.WHITE.index
                }
                val headerStyle = wb.createCellStyle().apply {
                    setFont(headerFont)
                    fillForegroundColor = IndexedColors.BLUE_GREY.index
                    fillPattern = FillPatternType.SOLID_FOREGROUND
                    alignment = HorizontalAlignment.CENTER
                    borderBottom = BorderStyle.THIN
                    borderTop = BorderStyle.THIN
                    borderLeft = BorderStyle.THIN
                    borderRight = BorderStyle.THIN
                }

                val dataStyle = wb.createCellStyle().apply {
                    borderBottom = BorderStyle.THIN
                    borderTop = BorderStyle.THIN
                    borderLeft = BorderStyle.THIN
                    borderRight = BorderStyle.THIN
                }

                val moneyFormat = wb.createDataFormat().getFormat("#,##0.00")
                val moneyStyle = wb.createCellStyle().apply {
                    cloneStyleFrom(dataStyle)
                    dataFormat = moneyFormat
                }

                val incomeStyle = wb.createCellStyle().apply {
                    cloneStyleFrom(moneyStyle)
                    setFont(wb.createFont().apply { color = IndexedColors.GREEN.index })
                }
                val expenseStyle = wb.createCellStyle().apply {
                    cloneStyleFrom(moneyStyle)
                    setFont(wb.createFont().apply { color = IndexedColors.RED.index })
                }

                val totalLabelFont = wb.createFont().apply { bold = true }
                val totalLabelStyle = wb.createCellStyle().apply {
                    setFont(totalLabelFont)
                    borderTop = BorderStyle.THIN
                }
                val totalValueStyle = wb.createCellStyle().apply {
                    setFont(totalLabelFont)
                    dataFormat = moneyFormat
                    borderTop = BorderStyle.THIN
                }

                // ---- title row ----
                val titleRow = sheet.createRow(0)
                titleRow.heightInPoints = 24f
                for (c in 0..5) titleRow.createCell(c).cellStyle = titleStyle
                titleRow.getCell(0).setCellValue(title)
                sheet.addMergedRegion(org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 5))

                // ---- header row ----
                val headers = listOf(
                    getString(R.string.report_col_date),
                    getString(R.string.report_col_income),
                    getString(R.string.report_col_expense),
                    getString(R.string.report_col_tax_percent),
                    getString(R.string.report_col_tax_amount),
                    getString(R.string.report_col_comment)
                )
                val headerRow = sheet.createRow(1)
                for ((i, h) in headers.withIndex()) {
                    val cell = headerRow.createCell(i)
                    cell.setCellValue(h)
                    cell.cellStyle = headerStyle
                }

                // ---- data rows ----
                var rowN = 2
                var totalIncome = 0.0
                var totalExpense = 0.0
                var totalTax = 0.0

                for (e in entries) {
                    val r = sheet.createRow(rowN++)

                    val dateCell = r.createCell(0)
                    dateCell.setCellValue(dateFmt.format(Date(e.dateMillis)))
                    dateCell.cellStyle = dataStyle

                    val incomeVal = if (e.isIncome) e.amount else 0.0
                    val expenseVal = if (!e.isIncome) e.amount else 0.0
                    val taxAmount = if (e.isIncome) e.amount * taxPercent / 100.0 else 0.0

                    val incomeCell = r.createCell(1)
                    incomeCell.setCellValue(incomeVal)
                    incomeCell.cellStyle = incomeStyle

                    val expenseCell = r.createCell(2)
                    expenseCell.setCellValue(expenseVal)
                    expenseCell.cellStyle = expenseStyle

                    val taxPercentCell = r.createCell(3)
                    taxPercentCell.setCellValue(taxPercent.toDouble())
                    taxPercentCell.cellStyle = moneyStyle

                    val taxAmountCell = r.createCell(4)
                    taxAmountCell.setCellValue(taxAmount)
                    taxAmountCell.cellStyle = moneyStyle

                    val commentCell = r.createCell(5)
                    commentCell.setCellValue(e.comment ?: "")
                    commentCell.cellStyle = dataStyle

                    totalIncome += incomeVal
                    totalExpense += expenseVal
                    totalTax += taxAmount
                }

                // ---- totals ----
                rowN++
                val profitRow = sheet.createRow(rowN++)
                profitRow.createCell(0).also { it.setCellValue(getString(R.string.report_total_profit)); it.cellStyle = totalLabelStyle }
                profitRow.createCell(1).also { it.setCellValue(totalIncome - totalExpense); it.cellStyle = totalValueStyle }

                val incomeRow = sheet.createRow(rowN++)
                incomeRow.createCell(0).also { it.setCellValue(getString(R.string.report_total_income)); it.cellStyle = totalLabelStyle }
                incomeRow.createCell(1).also { it.setCellValue(totalIncome); it.cellStyle = totalValueStyle }

                val expenseRow = sheet.createRow(rowN++)
                expenseRow.createCell(0).also { it.setCellValue(getString(R.string.report_total_expense)); it.cellStyle = totalLabelStyle }
                expenseRow.createCell(1).also { it.setCellValue(totalExpense); it.cellStyle = totalValueStyle }

                // Налог считаем от прибыли (доход - расход), так же как на главном
                // экране приложения, а не от суммы отдельных доходов — иначе итог
                // в отчёте не совпадает с балансом в приложении.
                val totalProfitForTax = totalIncome - totalExpense
                val correctedTotalTax = if (applyAnnualLimit) {
                    val otherIncome = TaxHelper.getOtherIncome(prefs, year)
                    TaxHelper.calc(totalProfitForTax, otherIncome, taxPercent).tax
                } else {
                    if (totalProfitForTax > 0) totalProfitForTax * taxPercent / 100.0 else 0.0
                }

                val taxRow = sheet.createRow(rowN)
                taxRow.createCell(0).also { it.setCellValue(getString(R.string.report_total_tax)); it.cellStyle = totalLabelStyle }
                taxRow.createCell(1).also { it.setCellValue(correctedTotalTax); it.cellStyle = totalValueStyle }

                // ---- column widths (manual — avoids java.awt dependency on Android) ----
                sheet.setColumnWidth(0, 20 * 256)
                sheet.setColumnWidth(1, 13 * 256)
                sheet.setColumnWidth(2, 13 * 256)
                sheet.setColumnWidth(3, 11 * 256)
                sheet.setColumnWidth(4, 14 * 256)
                sheet.setColumnWidth(5, 32 * 256)

                FileOutputStream(xlsx).use { fos ->
                    wb.write(fos)
                    wb.close()
                }

                val zipf = File(reportsDir, xlsx.name.replace(".xlsx", ".zip"))
                ZipOutputStream(FileOutputStream(zipf)).use { zos ->
                    FileInputStream(xlsx).use { fis ->
                        zos.putNextEntry(ZipEntry("report.xlsx"))
                        fis.copyTo(zos)
                        zos.closeEntry()
                    }
                    for (e in entries) {
                        e.receiptPath?.let { path ->
                            val f = File(path)
                            if (f.exists()) {
                                FileInputStream(f).use { fis ->
                                    zos.putNextEntry(ZipEntry("receipts/${f.name}"))
                                    fis.copyTo(zos)
                                    zos.closeEntry()
                                }
                            }
                        }
                    }
                }

                withContext(Dispatchers.Main) {
                    setButtonsEnabled(true)
                    shareFile(zipf)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    setButtonsEnabled(true)
                    Toast.makeText(this@ReportActivity, getString(R.string.report_error, e.message ?: ""), Toast.LENGTH_LONG).show()
                }
            }
        }
    }

    private fun setButtonsEnabled(enabled: Boolean) {
        findViewById<Button>(R.id.btn_report_month).isEnabled = enabled
        findViewById<Button>(R.id.btn_report_year).isEnabled = enabled
        findViewById<Button>(R.id.btn_report_custom).isEnabled = enabled
    }

    private fun shareFile(file: File) {
        val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "application/zip"
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        Toast.makeText(this, getString(R.string.report_ready), Toast.LENGTH_SHORT).show()
        startActivity(Intent.createChooser(intent, getString(R.string.report_share_title)))
    }
}
KOTLIN_EOF_8
echo "OK: app/src/main/java/com/example/fa_ksiegowy/ReportActivity.kt"

mkdir -p "$(dirname "app/src/main/res/layout/activity_mine.xml")"
cat > app/src/main/res/layout/activity_mine.xml << 'XML_EOF_9'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:orientation="vertical"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:paddingStart="24dp"
    android:paddingEnd="24dp"
    android:paddingTop="36dp"
    android:paddingBottom="16dp">

    <ImageView
            android:id="@+id/iv_logo"
            android:layout_width="120dp"
            android:layout_height="120dp"
            android:layout_gravity="center_horizontal"
            android:layout_marginBottom="4dp"
            android:adjustViewBounds="true"
            android:src="@drawable/logo"
            android:contentDescription="@string/app_name"/>

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="center_horizontal"
        android:layout_marginTop="2dp"
        android:layout_marginBottom="20dp"
        android:text="@string/app_subtitle"
        android:textColor="@color/text_primary"
        android:textSize="24sp"
        android:textStyle="bold"/>

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="center_horizontal"
        android:text="@string/balance"
        android:textColor="@color/text_secondary"
        android:textSize="13sp"
        android:letterSpacing="0.1"/>

    <TextView
        android:id="@+id/tv_balance"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="center_horizontal"
        android:layout_marginBottom="16dp"
        android:text="0.00"
        android:textColor="@color/text_primary"
        android:textSize="34sp"
        android:textStyle="bold"/>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:background="@drawable/card_bg"
        android:padding="16dp"
        android:layout_marginBottom="18dp">

        <TextView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="@string/statistics"
            android:textColor="@color/text_secondary"
            android:textSize="11sp"
            android:textStyle="bold"
            android:letterSpacing="0.12"
            android:layout_marginBottom="10dp"/>

        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"
            android:orientation="horizontal" android:layout_marginBottom="8dp">
            <TextView android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1"
                android:text="@string/stat_income" android:textColor="@color/text_primary" android:textSize="15sp"/>
            <TextView android:id="@+id/tv_stat_income" android:layout_width="wrap_content" android:layout_height="wrap_content"
                android:textColor="@color/income_green" android:textSize="15sp" android:textStyle="bold"/>
        </LinearLayout>

        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"
            android:orientation="horizontal" android:layout_marginBottom="8dp">
            <TextView android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1"
                android:text="@string/stat_expense" android:textColor="@color/text_primary" android:textSize="15sp"/>
            <TextView android:id="@+id/tv_stat_expense" android:layout_width="wrap_content" android:layout_height="wrap_content"
                android:textColor="@color/expense_red" android:textSize="15sp" android:textStyle="bold"/>
        </LinearLayout>

        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"
            android:orientation="horizontal" android:layout_marginBottom="8dp">
            <TextView android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1"
                android:text="@string/stat_profit" android:textColor="@color/text_primary" android:textSize="15sp"/>
            <TextView android:id="@+id/tv_stat_profit" android:layout_width="wrap_content" android:layout_height="wrap_content"
                android:textColor="@color/accent_cyan" android:textSize="15sp" android:textStyle="bold"/>
        </LinearLayout>

        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"
            android:orientation="horizontal">
            <TextView android:id="@+id/tv_stat_tax_label" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1"
                android:textColor="@color/text_secondary" android:textSize="15sp"/>
            <TextView android:id="@+id/tv_stat_tax" android:layout_width="wrap_content" android:layout_height="wrap_content"
                android:textColor="@color/text_secondary" android:textSize="15sp" android:textStyle="bold"/>
        </LinearLayout>

    </LinearLayout>

    <Button
        android:id="@+id/btn_add_income"
        android:layout_width="match_parent"
        android:layout_height="56dp"
        android:layout_marginBottom="14dp"
        android:background="@drawable/btn_pill_primary"
        android:text="@string/add_income"
        android:textAllCaps="false"
        android:textColor="@color/text_primary"
        android:textSize="17sp"
        android:textStyle="bold"
        android:elevation="4dp"/>

    <Button
        android:id="@+id/btn_add_expense"
        android:layout_width="match_parent"
        android:layout_height="56dp"
        android:layout_marginBottom="20dp"
        android:background="@drawable/btn_pill_primary"
        android:text="@string/add_expense"
        android:textAllCaps="false"
        android:textColor="@color/text_primary"
        android:textSize="17sp"
        android:textStyle="bold"
        android:elevation="4dp"/>

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/rv_entries"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:clipToPadding="false"/>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:layout_marginTop="12dp"
        android:weightSum="2" android:baselineAligned="false">

        <Button
            android:id="@+id/btn_settings"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:minHeight="56dp"
            android:layout_weight="1"
            android:layout_marginEnd="8dp"
            android:background="@drawable/btn_pill_outline"
            android:text="@string/settings"
            android:textAllCaps="false"
            android:textColor="@color/text_primary"
            android:textSize="12sp"
            android:maxLines="2"
            android:includeFontPadding="false"
            android:paddingTop="8dp"
            android:paddingBottom="8dp"
            android:paddingStart="6dp"
            android:paddingEnd="6dp"/>

        <Button
            android:id="@+id/btn_reports"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:minHeight="56dp"
            android:layout_weight="1"
            android:layout_marginStart="8dp"
            android:background="@drawable/btn_pill_outline"
            android:text="@string/generate_report"
            android:textAllCaps="false"
            android:textColor="@color/text_primary"
            android:textSize="12sp"
            android:maxLines="2"
            android:includeFontPadding="false"
            android:paddingTop="8dp"
            android:paddingBottom="8dp"
            android:paddingStart="6dp"
            android:paddingEnd="6dp"/>

    </LinearLayout>

    <com.google.android.gms.ads.AdView
        android:id="@+id/ad_banner"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="10dp"
        android:visibility="gone"
        app:adSize="BANNER"
        app:adUnitId="ca-app-pub-3940256099942544/6300978111"/>

</LinearLayout>
XML_EOF_9
echo "OK: app/src/main/res/layout/activity_mine.xml"

mkdir -p "$(dirname "app/src/main/res/layout/activity_settings.xml")"
cat > app/src/main/res/layout/activity_settings.xml << 'XML_EOF_10'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:fillViewport="true">

<LinearLayout
    android:orientation="vertical" android:padding="24dp"
    android:layout_width="match_parent" android:layout_height="wrap_content">

    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="@string/tax_percent" android:textSize="18sp"
        android:textColor="@color/text_primary" android:layout_marginBottom="10dp"/>

    <EditText android:id="@+id/et_tax" android:layout_width="match_parent" android:layout_height="56dp"
        android:background="@drawable/input_field_bg" android:paddingStart="18dp" android:paddingEnd="18dp"
        android:textColor="@color/text_primary" android:inputType="numberDecimal"
        android:layout_marginBottom="14dp"/>

    <Button android:id="@+id/btn_auto_tax" android:layout_width="match_parent" android:layout_height="48dp"
        android:text="@string/auto_tax_button" android:textAllCaps="false" android:textSize="14sp"
        android:textColor="@color/text_primary" android:background="@drawable/btn_pill_outline"
        android:layout_marginBottom="14dp"/>

    <Button android:id="@+id/btn_save_tax" android:layout_width="match_parent" android:layout_height="56dp"
        android:text="@string/save" android:textAllCaps="false" android:textSize="16sp"
        android:textColor="@color/text_primary" android:background="@drawable/btn_pill_primary"
        android:layout_marginBottom="24dp"/>

    <View android:layout_width="match_parent" android:layout_height="1dp" android:background="#2A2E60" android:layout_marginBottom="20dp"/>

    <TextView android:id="@+id/tv_pro_status" android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="@string/pro_status_locked" android:textSize="15sp"
        android:textColor="@color/text_primary" android:layout_marginBottom="10dp"/>

    <Button android:id="@+id/btn_unlock_pro" android:layout_width="match_parent" android:layout_height="56dp"
        android:text="@string/pro_unlock_button" android:textAllCaps="false" android:textSize="16sp"
        android:textColor="@color/text_primary" android:background="@drawable/btn_pill_primary"
        android:layout_marginBottom="24dp"/>

    <View android:layout_width="match_parent" android:layout_height="1dp" android:background="#2A2E60" android:layout_marginBottom="20dp"/>

    <TextView android:id="@+id/tv_other_income_label" android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="@string/other_income_title" android:textSize="18sp"
        android:textColor="@color/text_primary" android:layout_marginBottom="6dp"/>

    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="@string/other_income_hint" android:textSize="13sp"
        android:textColor="#9AA0C0" android:layout_marginBottom="10dp"/>

    <EditText android:id="@+id/et_other_income" android:layout_width="match_parent" android:layout_height="56dp"
        android:background="@drawable/input_field_bg" android:paddingStart="18dp" android:paddingEnd="18dp"
        android:textColor="@color/text_primary" android:inputType="numberDecimal"
        android:layout_marginBottom="14dp"/>

    <Button android:id="@+id/btn_save_other_income" android:layout_width="match_parent" android:layout_height="56dp"
        android:text="@string/save" android:textAllCaps="false" android:textSize="16sp"
        android:textColor="@color/text_primary" android:background="@drawable/btn_pill_primary"
        android:layout_marginBottom="24dp"/>

    <View android:layout_width="match_parent" android:layout_height="1dp" android:background="#2A2E60" android:layout_marginBottom="20dp"/>

    <Button android:id="@+id/btn_lang_en" android:layout_width="match_parent" android:layout_height="52dp"
        android:text="English" android:textAllCaps="false" android:textColor="@color/text_primary"
        android:background="@drawable/btn_pill_outline" android:layout_marginBottom="12dp"/>
    <Button android:id="@+id/btn_lang_ru" android:layout_width="match_parent" android:layout_height="52dp"
        android:text="Русский" android:textAllCaps="false" android:textColor="@color/text_primary"
        android:background="@drawable/btn_pill_outline" android:layout_marginBottom="12dp"/>
    <Button android:id="@+id/btn_lang_pl" android:layout_width="match_parent" android:layout_height="52dp"
        android:text="Polski" android:textAllCaps="false" android:textColor="@color/text_primary"
        android:background="@drawable/btn_pill_outline"/>


    <View android:layout_width="match_parent" android:layout_height="1dp"
        android:background="#2A2E60" android:layout_marginTop="20dp" android:layout_marginBottom="20dp"/>

    <Button android:id="@+id/btn_about" android:layout_width="match_parent" android:layout_height="52dp"
        android:text="@string/about_app" android:textAllCaps="false" android:textColor="@color/text_primary"
        android:background="@drawable/btn_pill_outline"/>

</LinearLayout>
</ScrollView>
XML_EOF_10
echo "OK: app/src/main/res/layout/activity_settings.xml"

mkdir -p "$(dirname "app/src/main/res/values/strings.xml")"
cat > app/src/main/res/values/strings.xml << 'XML_EOF_11'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">FinArs</string>
    <string name="app_subtitle">FinArs</string>
    <string name="add_income">Add income</string>
    <string name="add_expense">Add expense</string>
    <string name="balance">Balance</string>
    <string name="enter_amount">Amount</string>
    <string name="enter_comment">Comment</string>
    <string name="attach_receipt">Attach receipt</string>
    <string name="save">Save</string>
    <string name="settings">Settings</string>
    <string name="tax_percent">Tax percent</string>
    <string name="other_income_label">Other income (%1$d)</string>
    <string name="other_income_title">Other income</string>
    <string name="other_income_hint">Your total taxable income this year from other sources (job, other business, etc.). Used together with income from this app to check the 30,000 zł annual tax-free limit.</string>
    <string name="saved">Saved</string>
    <string name="auto_tax_button">Calculate automatically</string>
    <string name="auto_tax_result">Suggested rate: %1$.1f%% (based on Polish PIT scale: 12%% up to 120,000 zł/year, 32%% above). You can edit it before saving.</string>
    <string name="export_report">Export report</string>
    <string name="generate_report">Generate report</string>
    <string name="select_period">Select period</string>
    <string name="month">Month</string>
    <string name="year">Year</string>
    <string name="custom_range">Custom range</string>
    <string name="from">From</string>
    <string name="to">To</string>
    <string name="no_entries">No entries</string>

    <string name="statistics">Statistics</string>
    <string name="stat_income">Income</string>
    <string name="stat_expense">Expense</string>
    <string name="stat_profit">Profit</string>
    <string name="stat_tax_format">Tax (%1$d%%)</string>

    <string name="report_col_date">Date</string>
    <string name="report_col_income">Income</string>
    <string name="report_col_expense">Expense</string>
    <string name="report_col_tax_percent">Tax %%</string>
    <string name="report_col_tax_amount">Tax amount</string>
    <string name="report_col_comment">Comment</string>
    <string name="report_sheet_name">Report</string>
    <string name="report_title_month">Report — Month</string>
    <string name="report_title_year">Report — Year</string>
    <string name="report_total_income">Total income</string>
    <string name="report_total_expense">Total expense</string>
    <string name="report_total_profit">Total profit</string>
    <string name="report_total_tax">Total tax</string>
    <string name="report_generating">Generating report…</string>
    <string name="report_ready">Report ready</string>
    <string name="report_share_title">Share report</string>
    <string name="report_error">Failed to generate report: %1$s</string>
    <string name="about_app">About the app</string>
    <string name="about_description">FinArs is a convenient app for managing the finances of unregistered business activity. Easily track income and expenses, monitor your current balance, automatically calculate taxes and generate reports. The app helps you stay within limits, track financial indicators and always have the full history of operations at hand. A simple interface and quick data entry make daily bookkeeping as convenient as possible.

Key features:
💰 Income and expense tracking.
📊 Automatic profit calculation.
🧾 Tax calculation.
📈 Monitoring of unregistered activity limits.
📄 Report generation.
🔍 Full operation history.
🌙 Modern dark interface.
🔒 All data is stored locally on the device.

Contact: p.arsenii@interia.pl</string>
    <string name="about_email">p.arsenii@interia.pl</string>
    <string name="dialog_close">Close</string>
    <string name="dialog_write">Write</string>
    <string name="pro_status_locked">Pro is locked. Unlock to get yearly/custom Excel reports.</string>
    <string name="pro_status_active">Pro unlocked. Thank you for your support!</string>
    <string name="pro_unlock_button">Unlock Pro</string>
    <string name="pro_unlock_button_price">Unlock Pro — %1$s</string>
    <string name="pro_loading">Loading price…</string>
    <string name="pro_feature_locked_title">Pro feature</string>
    <string name="pro_feature_locked_message">Yearly and custom reports are a Pro feature. Unlock Pro in Settings to use them.</string>
    <string name="pro_feature_locked_go_settings">Go to Settings</string>
    <string name="pro_purchase_error">Could not start the purchase. Check your connection and try again.</string>
    <string name="pro_info_title">Pro version</string>
    <string name="pro_info_message">Pro unlocks:\n\n• Yearly Excel report\n• Custom-period Excel report\n• No ads\n\nThis is a one-time purchase — pay once, keep it forever.</string>
    <string name="pro_info_continue">Continue to purchase</string>
    <string name="enter_code_button">Have a code?</string>
    <string name="enter_code_title">Enter code</string>
    <string name="enter_code_hint">Code</string>
    <string name="enter_code_apply">Apply</string>
    <string name="enter_code_wrong">Invalid code</string>
    <string name="enter_code_success">Pro unlocked</string>
</resources>
XML_EOF_11
echo "OK: app/src/main/res/values/strings.xml"

mkdir -p "$(dirname "app/src/main/res/values-ru/strings.xml")"
cat > app/src/main/res/values-ru/strings.xml << 'XML_EOF_12'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">FinArs</string>
    <string name="app_subtitle">FinArs</string>
    <string name="add_income">Добавить доход</string>
    <string name="add_expense">Добавить расход</string>
    <string name="balance">Баланс</string>
    <string name="enter_amount">Сумма</string>
    <string name="enter_comment">Комментарий</string>
    <string name="attach_receipt">Прикрепить чек</string>
    <string name="save">Сохранить</string>
    <string name="settings">Настройки</string>
    <string name="tax_percent">Процент налога</string>
    <string name="other_income_label">Прочие доходы (%1$d)</string>
    <string name="other_income_title">Прочие доходы</string>
    <string name="other_income_hint">Ваш общий налогооблагаемый доход за этот год из других источников (работа, другая деятельность и т.д.). Учитывается вместе с доходом из этого приложения при проверке годового необлагаемого лимита в 30 000 zł.</string>
    <string name="saved">Сохранено</string>
    <string name="auto_tax_button">Рассчитать автоматически</string>
    <string name="auto_tax_result">Предложенная ставка: %1$.1f%% (по шкале PIT: 12%% до 120 000 zł/год, 32%% свыше). Перед сохранением можно поправить вручную.</string>
    <string name="export_report">Экспорт отчёта</string>
    <string name="generate_report">Сгенерировать отчёт</string>
    <string name="select_period">Выберите период</string>
    <string name="month">Месяц</string>
    <string name="year">Год</string>
    <string name="custom_range">Произвольный период</string>
    <string name="from">От</string>
    <string name="to">До</string>
    <string name="no_entries">Нет записей</string>

    <string name="statistics">Статистика</string>
    <string name="stat_income">Доход</string>
    <string name="stat_expense">Расход</string>
    <string name="stat_profit">Прибыль</string>
    <string name="stat_tax_format">Налог (%1$d%%)</string>

    <string name="report_col_date">Дата</string>
    <string name="report_col_income">Доход</string>
    <string name="report_col_expense">Расход</string>
    <string name="report_col_tax_percent">Налог %%</string>
    <string name="report_col_tax_amount">Сумма налога</string>
    <string name="report_col_comment">Комментарий</string>
    <string name="report_sheet_name">Отчёт</string>
    <string name="report_title_month">Отчёт — Месяц</string>
    <string name="report_title_year">Отчёт — Год</string>
    <string name="report_total_income">Итого доход</string>
    <string name="report_total_expense">Итого расход</string>
    <string name="report_total_profit">Итого прибыль</string>
    <string name="report_total_tax">Итого налог</string>
    <string name="report_generating">Формирую отчёт…</string>
    <string name="report_ready">Отчёт готов</string>
    <string name="report_share_title">Поделиться отчётом</string>
    <string name="report_error">Ошибка формирования отчёта: %1$s</string>
    <string name="about_app">О приложении</string>
    <string name="about_description">FinArs — удобное приложение для ведения финансов нерегистрируемой деятельности. Легко учитывайте доходы и расходы, контролируйте текущий баланс, автоматически рассчитывайте налоги и формируйте отчёты. Приложение помогает соблюдать лимиты, отслеживать финансовые показатели и всегда иметь под рукой полную историю операций. Простой интерфейс и быстрый ввод данных делают ежедневный учёт максимально удобным.\n\nОсновные возможности:\n💰 Учёт доходов и расходов.\n📊 Автоматический расчёт прибыли.\n🧾 Расчёт налогов.\n📈 Контроль лимитов нерегистрируемой деятельности.\n📄 Генерация отчётов.\n🔍 История всех операций.\n🌙 Современный тёмный интерфейс.\n🔒 Все данные хранятся локально на устройстве.\n\nСвязь: p.arsenii@interia.pl</string>
    <string name="about_email">p.arsenii@interia.pl</string>
    <string name="dialog_close">Закрыть</string>
    <string name="dialog_write">Написать</string>
    <string name="pro_status_locked">Pro не активирован. Разблокируйте, чтобы получить годовые и произвольные отчёты в Excel.</string>
    <string name="pro_status_active">Pro активирован. Спасибо за поддержку!</string>
    <string name="pro_unlock_button">Разблокировать Pro</string>
    <string name="pro_unlock_button_price">Разблокировать Pro — %1$s</string>
    <string name="pro_loading">Загрузка цены…</string>
    <string name="pro_feature_locked_title">Функция Pro</string>
    <string name="pro_feature_locked_message">Годовые и произвольные отчёты доступны только в Pro-версии. Разблокируйте Pro в настройках.</string>
    <string name="pro_feature_locked_go_settings">Перейти в настройки</string>
    <string name="pro_purchase_error">Не удалось открыть окно оплаты. Проверьте соединение и попробуйте снова.</string>
    <string name="pro_info_title">Pro-версия</string>
    <string name="pro_info_message">Pro открывает:\n\n• Годовой отчёт в Excel\n• Отчёт за произвольный период\n• Без рекламы\n\nЭто разовая покупка — платите один раз, доступ остаётся навсегда.</string>
    <string name="pro_info_continue">Перейти к покупке</string>
    <string name="enter_code_button">Есть код?</string>
    <string name="enter_code_title">Введите код</string>
    <string name="enter_code_hint">Код</string>
    <string name="enter_code_apply">Применить</string>
    <string name="enter_code_wrong">Неверный код</string>
    <string name="enter_code_success">Pro активирован</string>
</resources>
XML_EOF_12
echo "OK: app/src/main/res/values-ru/strings.xml"

mkdir -p "$(dirname "app/src/main/res/values-pl/strings.xml")"
cat > app/src/main/res/values-pl/strings.xml << 'XML_EOF_13'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">FinArs</string>
    <string name="app_subtitle">FinArs</string>
    <string name="add_income">Dodaj przychód</string>
    <string name="add_expense">Dodaj wydatek</string>
    <string name="balance">Bilans</string>
    <string name="enter_amount">Kwota</string>
    <string name="enter_comment">Komentarz</string>
    <string name="attach_receipt">Dołącz paragon</string>
    <string name="save">Zapisz</string>
    <string name="settings">Ustawienia</string>
    <string name="tax_percent">Procent podatku</string>
    <string name="other_income_label">Inne przychody (%1$d)</string>
    <string name="other_income_title">Inne przychody</string>
    <string name="other_income_hint">Twój łączny dochód podlegający opodatkowaniu w tym roku z innych źródeł (etat, inna działalność itd.). Uwzględniany razem z dochodem z tej aplikacji przy sprawdzaniu rocznego limitu wolnego od podatku 30 000 zł.</string>
    <string name="saved">Zapisano</string>
    <string name="auto_tax_button">Oblicz automatycznie</string>
    <string name="auto_tax_result">Sugerowana stawka: %1$.1f%% (wg skali PIT: 12%% do 120 000 zł/rok, 32%% powyżej). Przed zapisaniem można poprawić ręcznie.</string>
    <string name="export_report">Eksportuj raport</string>
    <string name="generate_report">Generuj raport</string>
    <string name="select_period">Wybierz okres</string>
    <string name="month">Miesiąc</string>
    <string name="year">Rok</string>
    <string name="custom_range">Zakres niestandardowy</string>
    <string name="from">Od</string>
    <string name="to">Do</string>
    <string name="no_entries">Brak wpisów</string>

    <string name="statistics">Statystyka</string>
    <string name="stat_income">Przychód</string>
    <string name="stat_expense">Wydatek</string>
    <string name="stat_profit">Zysk</string>
    <string name="stat_tax_format">Podatek (%1$d%%)</string>

    <string name="report_col_date">Data</string>
    <string name="report_col_income">Przychód</string>
    <string name="report_col_expense">Wydatek</string>
    <string name="report_col_tax_percent">Podatek %%</string>
    <string name="report_col_tax_amount">Kwota podatku</string>
    <string name="report_col_comment">Komentarz</string>
    <string name="report_sheet_name">Raport</string>
    <string name="report_title_month">Raport — Miesiąc</string>
    <string name="report_title_year">Raport — Rok</string>
    <string name="report_total_income">Suma przychodów</string>
    <string name="report_total_expense">Suma wydatków</string>
    <string name="report_total_profit">Suma zysku</string>
    <string name="report_total_tax">Suma podatku</string>
    <string name="report_generating">Generuję raport…</string>
    <string name="report_ready">Raport gotowy</string>
    <string name="report_share_title">Udostępnij raport</string>
    <string name="report_error">Błąd generowania raportu: %1$s</string>
    <string name="about_app">O aplikacji</string>
    <string name="about_description">FinArs to wygodna aplikacja do zarządzania finansami działalności nierejestrowanej. Łatwo śledź przychody i wydatki, kontroluj bieżący bilans, automatycznie obliczaj podatki i generuj raporty. Aplikacja pomaga przestrzegać limitów, śledzić wskaźniki finansowe i mieć zawsze pod ręką pełną historię operacji. Prosty interfejs i szybkie wprowadzanie danych sprawiają, że codzienna księgowość jest maksymalnie wygodna.\n\nGłówne funkcje:\n💰 Ewidencja przychodów i wydatków.\n📊 Automatyczne obliczanie zysku.\n🧾 Obliczanie podatków.\n📈 Kontrola limitów działalności nierejestrowanej.\n📄 Generowanie raportów.\n🔍 Historia wszystkich operacji.\n🌙 Nowoczesny ciemny interfejs.\n🔒 Wszystkie dane są przechowywane lokalnie na urządzeniu.\n\nKontakt: p.arsenii@interia.pl</string>
    <string name="about_email">p.arsenii@interia.pl</string>
    <string name="dialog_close">Zamknij</string>
    <string name="dialog_write">Napisz</string>
    <string name="pro_status_locked">Pro jest zablokowane. Odblokuj, aby uzyskać roczne i niestandardowe raporty Excel.</string>
    <string name="pro_status_active">Pro odblokowane. Dziękujemy za wsparcie!</string>
    <string name="pro_unlock_button">Odblokuj Pro</string>
    <string name="pro_unlock_button_price">Odblokuj Pro — %1$s</string>
    <string name="pro_loading">Ładowanie ceny…</string>
    <string name="pro_feature_locked_title">Funkcja Pro</string>
    <string name="pro_feature_locked_message">Raporty roczne i niestandardowe są dostępne tylko w wersji Pro. Odblokuj Pro w ustawieniach.</string>
    <string name="pro_feature_locked_go_settings">Przejdź do ustawień</string>
    <string name="pro_purchase_error">Nie udało się otworzyć zakupu. Sprawdź połączenie i spróbuj ponownie.</string>
    <string name="pro_info_title">Wersja Pro</string>
    <string name="pro_info_message">Pro odblokowuje:\n\n• Raport roczny w Excelu\n• Raport za dowolny okres\n• Brak reklam\n\nTo jednorazowy zakup — płacisz raz, dostęp zostaje na zawsze.</string>
    <string name="pro_info_continue">Przejdź do zakupu</string>
    <string name="enter_code_button">Masz kod?</string>
    <string name="enter_code_title">Wprowadź kod</string>
    <string name="enter_code_hint">Kod</string>
    <string name="enter_code_apply">Zastosuj</string>
    <string name="enter_code_wrong">Nieprawidłowy kod</string>
    <string name="enter_code_success">Pro odblokowane</string>
</resources>
XML_EOF_13
echo "OK: app/src/main/res/values-pl/strings.xml"

echo ""
echo "=== Готово. Дальше: ==="
echo "1) Вставьте свой Base64 licensing key в PurchaseVerifier.kt (Play Console -> Monetization setup -> Licensing)"
echo "2) Замените тестовые AdMob ID в AndroidManifest.xml и activity_mine.xml на свои после регистрации в AdMob"
echo "3) Создайте in-app product с ID pro_unlock в Play Console"
echo "4) Соберите release-сборку и протестируйте: покупку Pro, экспорт годового отчёта, рекламный баннер"
