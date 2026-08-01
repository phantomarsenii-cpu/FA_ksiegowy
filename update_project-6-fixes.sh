#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Язык приложения (system-first, fallback EN) + перевод кнопок диалога ==="

cat > app/src/main/java/com/example/fa_ksiegowy/LocaleHelper.kt << 'KOTLIN_EOF'
package com.example.fa_ksiegowy

import android.content.Context
import java.util.Locale

object LocaleHelper {
    private const val PREFS_NAME = "settings"
    private const val KEY_LANG = "appLang"
    private val SUPPORTED = setOf("ru", "pl", "en")

    fun applyLocale(context: Context): Context {
        val lang = getOrInitLanguage(context)
        return updateContextLocale(context, lang)
    }

    fun setLanguage(context: Context, code: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString(KEY_LANG, code).apply()
    }

    private fun getOrInitLanguage(context: Context): String {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val saved = prefs.getString(KEY_LANG, null)
        if (saved != null) return saved
        val systemLang = Locale.getDefault().language
        val initial = if (SUPPORTED.contains(systemLang)) systemLang else "en"
        prefs.edit().putString(KEY_LANG, initial).apply()
        return initial
    }

    private fun updateContextLocale(context: Context, lang: String): Context {
        val locale = Locale(lang)
        Locale.setDefault(locale)
        val config = context.resources.configuration
        config.setLocale(locale)
        return context.createConfigurationContext(config)
    }
}
KOTLIN_EOF
echo "OK: LocaleHelper.kt"

cat > app/src/main/java/com/example/fa_ksiegowy/BaseActivity.kt << 'KOTLIN_EOF'
package com.example.fa_ksiegowy

import android.content.Context
import androidx.appcompat.app.AppCompatActivity

open class BaseActivity : AppCompatActivity() {
    override fun attachBaseContext(newBase: Context) {
        super.attachBaseContext(LocaleHelper.applyLocale(newBase))
    }
}
KOTLIN_EOF
echo "OK: BaseActivity.kt"

for f in MineActivity AddEntryActivity ReportActivity SettingsActivity; do
  path="app/src/main/java/com/example/fa_ksiegowy/$f.kt"
  if [ -f "$path" ]; then
    sed -i 's/: AppCompatActivity()/: BaseActivity()/' "$path"
    echo "OK: $f.kt -> BaseActivity"
  fi
done

cat > app/src/main/java/com/example/fa_ksiegowy/SettingsActivity.kt << 'KOTLIN_EOF'
package com.example.fa_ksiegowy

import android.app.AlertDialog
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.widget.Button
import android.widget.EditText

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
KOTLIN_EOF
echo "OK: SettingsActivity.kt"

python3 - << 'PYEOF'
def add_strings(path, entries):
    with open(path, encoding="utf-8") as f:
        content = f.read()
    added = False
    for name, value in entries.items():
        if f'name="{name}"' not in content:
            block = f'    <string name="{name}">{value}</string>\n'
            content = content.replace("</resources>", block + "</resources>")
            added = True
    if added:
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"OK: {path}")
    else:
        print(f"-- уже есть: {path}")

add_strings("app/src/main/res/values/strings.xml", {"dialog_close": "Close", "dialog_write": "Write"})
add_strings("app/src/main/res/values-ru/strings.xml", {"dialog_close": "Закрыть", "dialog_write": "Написать"})
add_strings("app/src/main/res/values-pl/strings.xml", {"dialog_close": "Zamknij", "dialog_write": "Napisz"})
PYEOF

echo "--- Готово, коммичу и пушу ---"
git add .
git commit -m "Add per-app language persistence (system-first, fallback EN) and translate dialog buttons"
git push
