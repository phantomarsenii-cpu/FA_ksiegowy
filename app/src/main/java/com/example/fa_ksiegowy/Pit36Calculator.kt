package com.example.fa_ksiegowy

/**
 * Считает итоговые цифры для PIT-36 по данным за один календарный год:
 * Przychód (сумма всех доходов), Koszty (сумма всех расходов), Dochód (разница),
 * и налог, относящийся именно к прибыли из приложения — той же маржинальной
 * логикой, что уже используется на главном экране (см. TaxHelper).
 *
 * Это НЕ официальный расчёт налоговой — только вспомогательная оценка на основе
 * введённых пользователем данных, чтобы не считать вручную перед подачей PIT-36.
 */
object Pit36Calculator {

    data class Result(
        val year: Int,
        val przychod: Double,
        val koszty: Double,
        val dochod: Double,
        val otherIncome: Double,
        val tax: TaxHelper.TaxResult
    )

    fun calculate(entries: List<Entry>, year: Int, otherIncome: Double): Result {
        val przychod = entries.filter { it.isIncome }.sumOf { it.amount }
        val koszty = entries.filter { !it.isIncome }.sumOf { it.amount }
        val dochod = przychod - koszty
        val tax = TaxHelper.calc(dochod, otherIncome)
        return Result(year, przychod, koszty, dochod, otherIncome, tax)
    }
}
