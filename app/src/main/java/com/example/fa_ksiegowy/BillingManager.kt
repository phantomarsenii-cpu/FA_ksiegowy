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
