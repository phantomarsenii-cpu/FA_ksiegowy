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
