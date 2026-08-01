#!/usr/bin/env bash
set -e
echo "=== Оповещение о сохранении % + автоподбор ставки налога (PIT 12/32) ==="

mkdir -p "app/src/main/java/com/example/fa_ksiegowy"
cat > "app/src/main/java/com/example/fa_ksiegowy/TaxHelper.kt" << 'FAEOF'
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
FAEOF
echo 'OK: app/src/main/java/com/example/fa_ksiegowy/TaxHelper.kt'

mkdir -p "app/src/main/java/com/example/fa_ksiegowy"
cat > "app/src/main/java/com/example/fa_ksiegowy/SettingsActivity.kt" << 'FAEOF'
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

    private fun setLocale(code: String) {
        LocaleHelper.setLanguage(this, code)
        val intent = Intent(this, MineActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
        startActivity(intent)
        finishAffinity()
    }
}
FAEOF
echo 'OK: app/src/main/java/com/example/fa_ksiegowy/SettingsActivity.kt'

mkdir -p "app/src/main/res/layout"
cat > "app/src/main/res/layout/activity_settings.xml" << 'FAEOF'
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
FAEOF
echo 'OK: app/src/main/res/layout/activity_settings.xml'

mkdir -p "app/src/main/res/values"
cat > "app/src/main/res/values/strings.xml" << 'FAEOF'
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
</resources>
FAEOF
echo 'OK: app/src/main/res/values/strings.xml'

mkdir -p "app/src/main/res/values-ru"
cat > "app/src/main/res/values-ru/strings.xml" << 'FAEOF'
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
</resources>
FAEOF
echo 'OK: app/src/main/res/values-ru/strings.xml'

mkdir -p "app/src/main/res/values-pl"
cat > "app/src/main/res/values-pl/strings.xml" << 'FAEOF'
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
</resources>
FAEOF
echo 'OK: app/src/main/res/values-pl/strings.xml'

echo "--- Готово, коммичу и пушу ---"
git add -A
git commit -m "Saved-toast for tax percent + auto-suggested rate via PIT progressive scale"
git push
