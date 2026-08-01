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

    // ---- Автоподбор процента: польская прогрессивная шкала PIT ----
    // 12% на доход от 30 000 до 120 000 zł (совпадает с ANNUAL_LIMIT/calc выше),
    // 32% на часть дохода свыше 120 000 zł.
    const val SECOND_BRACKET_THRESHOLD = 120000.0
    private const val FIRST_BRACKET_RATE = 12.0
    private const val SECOND_BRACKET_RATE = 32.0

    /**
     * Предлагает процент для поля "процент налога" на основе суммарного
     * налогооблагаемого дохода (прочие доходы + прибыль из приложения за год).
     *
     * До 120 000 zł шкала однорядная — 12%, эту ставку и предлагаем.
     * Свыше 120 000 zł шкала прогрессивная (12% на часть до порога, 32% на
     * часть свыше), а в приложении используется единый процент — поэтому
     * возвращается ЭФФЕКТИВНАЯ ставка, при которой calc() выше даст ровно
     * такую же сумму налога, как официальная формула. Это оценка, которую
     * можно поправить вручную.
     */
    fun suggestTaxPercent(totalTaxableIncome: Double): Float {
        if (totalTaxableIncome <= SECOND_BRACKET_THRESHOLD) return FIRST_BRACKET_RATE.toFloat()

        val taxBase = totalTaxableIncome - ANNUAL_LIMIT
        val officialTax = (SECOND_BRACKET_THRESHOLD - ANNUAL_LIMIT) * FIRST_BRACKET_RATE / 100.0 +
            (totalTaxableIncome - SECOND_BRACKET_THRESHOLD) * SECOND_BRACKET_RATE / 100.0
        val effectiveRate = if (taxBase > 0) officialTax / taxBase * 100.0 else FIRST_BRACKET_RATE
        return effectiveRate.toFloat()
    }
}
