
package com.example.fa_ksiegowy
import android.app.AlertDialog
import android.content.Intent
import android.net.Uri
import android.content.SharedPreferences
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import androidx.appcompat.app.AppCompatActivity
import java.util.Locale

class SettingsActivity : AppCompatActivity() {
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
        }
        findViewById<Button>(R.id.btn_lang_ru).setOnClickListener { setLocale("ru") }
        findViewById<Button>(R.id.btn_lang_pl).setOnClickListener { setLocale("pl") }
        findViewById<Button>(R.id.btn_lang_en).setOnClickListener { setLocale("en") }
        findViewById<Button>(R.id.btn_about).setOnClickListener {
            AlertDialog.Builder(this)
                .setTitle(getString(R.string.about_app))
                .setMessage(getString(R.string.about_description))
                .setPositiveButton("Написать") { _, _ ->
                    val intent = Intent(Intent.ACTION_SENDTO).apply {
                        data = Uri.parse("mailto:" + getString(R.string.about_email))
                    }
                    startActivity(intent)
                }
                .setNegativeButton("Закрыть", null)
                .show()
        }
    }
    private fun setLocale(code: String) {
        val locale = Locale(code)
        Locale.setDefault(locale)
        val config = resources.configuration
        config.setLocale(locale)
        resources.updateConfiguration(config, resources.displayMetrics)
        startActivity(Intent(this, MineActivity::class.java))
        finishAffinity()
    }
}
