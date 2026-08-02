package com.example.fa_ksiegowy

import android.content.SharedPreferences
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast

/**
 * Налог теперь всегда считается автоматически по официальной прогрессивной
 * шкале (см. TaxHelper.calc) — ручного ввода процента больше нет, чтобы
 * исключить ситуацию, когда на главном экране показывался неверный
 * (устаревший/введённый вручную) процент вместо реального.
 *
 * Единственное, что здесь настраивается — "прочие доходы" (заработок вне
 * этого приложения), которые тоже занимают нижние ступени шкалы и влияют
 * на то, какая часть прибыли из приложения облагается по 12%, а какая — по 32%.
 */
class SettingsTaxActivity : BaseActivity() {
    private lateinit var prefs: SharedPreferences

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_settings_tax)
        prefs = getSharedPreferences("settings", MODE_PRIVATE)

        val year = TaxHelper.currentYear()
        findViewById<TextView>(R.id.tv_other_income_label).text =
            getString(R.string.other_income_label, year)

        val etOtherIncome = findViewById<EditText>(R.id.et_other_income)
        etOtherIncome.setText(TaxHelper.getOtherIncome(prefs, year).toString())
        findViewById<Button>(R.id.btn_save_other_income).setOnClickListener {
            val v = etOtherIncome.text.toString().toDoubleOrNull() ?: 0.0
            TaxHelper.setOtherIncome(prefs, year, v)
            Toast.makeText(this, getString(R.string.saved), Toast.LENGTH_SHORT).show()
        }
    }
}
