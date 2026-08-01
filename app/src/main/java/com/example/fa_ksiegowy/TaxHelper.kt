package com.example.fa_ksiegowy

import android.content.SharedPreferences
import java.util.Calendar

/**
 * Логика годового необлагаемого лимита (по умолчанию 30 000 zł).
 *
 * Лимит применяется к СУММЕ прибыли за текущий календарный год из этого
 * приложения ("appProfit") и прочих доходов пользователя за тот же год
 * ("otherIncome", вводится вручную в настройках). Налог считается не со
 * всей прибыли, а только с суммы превышения лимита:
 *
 *   totalTaxable = otherIncome + appProfit
 *   taxBase      = max(0, totalTaxable - LIMIT)
 *   tax          = taxBase * taxPercent / 100
 *
 * Если прочие доходы сами по себе уже покрывают/превышают лимит, вся
 * прибыль из приложения облагается налогом полностью — формула это
 * учитывает автоматически.
 */
object TaxHelper {

    const val ANNUAL_LIMIT = 30000.0

    data class TaxResult(
        val totalTaxable: Double, // otherIncome + appProfit
        val taxBase: Double,      // сумма, попадающая под налог
        val tax: Double           // итоговый налог
    )

    fun currentYear(): Int = Calendar.getInstance().get(Calendar.YEAR)

    /** Границы календарного года: [начало 1 января, начало 1 января следующего года). */
    fun yearRange(year: Int): Pair<Long, Long> {
        val start = Calendar.getInstance().apply {
            clear()
            set(year, Calendar.JANUARY, 1, 0, 0, 0)
        }.timeInMillis
        val end = Calendar.getInstance().apply {
            clear()
            set(year + 1, Calendar.JANUARY, 1, 0, 0, 0)
        }.timeInMillis
        return start to end
    }

    private fun otherIncomeKey(year: Int) = "otherIncome_$year"

    fun getOtherIncome(prefs: SharedPreferences, year: Int = currentYear()): Double =
        prefs.getFloat(otherIncomeKey(year), 0f).toDouble()

    fun setOtherIncome(prefs: SharedPreferences, year: Int, value: Double) {
        prefs.edit().putFloat(otherIncomeKey(year), value.toFloat()).apply()
    }

    fun calc(appProfit: Double, otherIncome: Double, taxPercent: Float): TaxResult {
        val totalTaxable = otherIncome + appProfit
        val taxBase = if (totalTaxable > ANNUAL_LIMIT) totalTaxable - ANNUAL_LIMIT else 0.0
        // Прибыль из приложения не может «отдать» под налог больше, чем сама составляет
        // (превышение может целиком образовываться прочими доходами).
        val taxableFromApp = if (appProfit <= 0) 0.0 else minOf(taxBase, appProfit)
        val tax = taxableFromApp * taxPercent / 100.0
        return TaxResult(totalTaxable, taxBase, tax)
    }
}
