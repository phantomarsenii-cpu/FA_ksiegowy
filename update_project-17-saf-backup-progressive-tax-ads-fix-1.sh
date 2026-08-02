#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Обновление 17: копия через системный выбор файла (Диск/телефон) + Pro-доступ, правильный прогрессивный налог, отладка рекламы ==="

mkdir -p "$(dirname "app/build.gradle")"
cat > app/build.gradle << 'EOF_APP_BUILD_GRADLE'
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
EOF_APP_BUILD_GRADLE
echo "OK: app/build.gradle"

mkdir -p "$(dirname "app/src/main/res/layout/activity_settings_backup.xml")"
cat > app/src/main/res/layout/activity_settings_backup.xml << 'EOF_APP_SRC_MAIN_RES_LAYOUT_ACTIVITY_SETTINGS_BACKUP_XML'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:fillViewport="true">

<LinearLayout
    android:orientation="vertical" android:padding="24dp"
    android:layout_width="match_parent" android:layout_height="wrap_content">

    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="@string/settings_menu_backup" android:textSize="22sp" android:textStyle="bold"
        android:textColor="@color/accent_cyan" android:layout_marginBottom="16dp"/>

    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="@string/backup_hint" android:textSize="13sp"
        android:textColor="@color/text_secondary" android:layout_marginBottom="20dp"/>

    <TextView android:id="@+id/tv_last_backup" android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="@string/backup_never" android:textSize="13sp"
        android:textColor="@color/text_secondary" android:layout_marginBottom="16dp"/>

    <Button android:id="@+id/btn_backup_now" android:layout_width="match_parent" android:layout_height="56dp"
        android:text="@string/backup_create" android:textAllCaps="false" android:textSize="16sp"
        android:textColor="@color/text_primary" android:background="@drawable/btn_pill_primary"
        android:layout_marginBottom="12dp"/>

    <Button android:id="@+id/btn_restore_now" android:layout_width="match_parent" android:layout_height="56dp"
        android:text="@string/backup_restore" android:textAllCaps="false" android:textSize="16sp"
        android:textColor="@color/text_primary" android:background="@drawable/btn_pill_outline"
        android:layout_marginBottom="24dp"/>

    <View android:layout_width="match_parent" android:layout_height="1dp" android:background="#2A2E60" android:layout_marginBottom="20dp"/>

    <Button android:id="@+id/btn_clear_all" android:layout_width="match_parent" android:layout_height="52dp"
        android:text="@string/clear_all_button" android:textAllCaps="false" android:textColor="@color/text_primary"
        android:background="@drawable/btn_pill_danger"/>

</LinearLayout>
</ScrollView>
EOF_APP_SRC_MAIN_RES_LAYOUT_ACTIVITY_SETTINGS_BACKUP_XML
echo "OK: app/src/main/res/layout/activity_settings_backup.xml"

mkdir -p "$(dirname "app/src/main/res/layout/activity_settings_tax.xml")"
cat > app/src/main/res/layout/activity_settings_tax.xml << 'EOF_APP_SRC_MAIN_RES_LAYOUT_ACTIVITY_SETTINGS_TAX_XML'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:fillViewport="true">

<LinearLayout
    android:orientation="vertical" android:padding="24dp"
    android:layout_width="match_parent" android:layout_height="wrap_content">

    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="@string/settings_menu_tax" android:textSize="22sp" android:textStyle="bold"
        android:textColor="@color/accent_cyan" android:layout_marginBottom="16dp"/>

    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"
        android:orientation="vertical" android:background="@drawable/card_bg" android:padding="16dp"
        android:layout_marginBottom="24dp">
        <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
            android:text="@string/tax_scale_title" android:textSize="15sp" android:textStyle="bold"
            android:textColor="@color/text_primary" android:layout_marginBottom="8dp"/>
        <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
            android:text="@string/tax_scale_description" android:textSize="13sp"
            android:textColor="@color/text_secondary"/>
    </LinearLayout>

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
        android:textColor="@color/text_primary" android:background="@drawable/btn_pill_primary"/>

</LinearLayout>
</ScrollView>
EOF_APP_SRC_MAIN_RES_LAYOUT_ACTIVITY_SETTINGS_TAX_XML
echo "OK: app/src/main/res/layout/activity_settings_tax.xml"

mkdir -p "$(dirname "app/src/main/res/layout/activity_settings.xml")"
cat > app/src/main/res/layout/activity_settings.xml << 'EOF_APP_SRC_MAIN_RES_LAYOUT_ACTIVITY_SETTINGS_XML'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:fillViewport="true">

<LinearLayout
    android:orientation="vertical" android:padding="24dp"
    android:layout_width="match_parent" android:layout_height="wrap_content">

    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="@string/settings" android:textSize="22sp" android:textStyle="bold"
        android:textColor="@color/accent_cyan" android:layout_marginBottom="24dp"/>

    <Button android:id="@+id/btn_menu_tax" android:layout_width="match_parent" android:layout_height="56dp"
        android:text="@string/settings_menu_tax" android:textAllCaps="false" android:textSize="16sp"
        android:textColor="@color/text_primary" android:background="@drawable/btn_pill_outline"
        android:layout_marginBottom="14dp"/>

    <Button android:id="@+id/btn_menu_language" android:layout_width="match_parent" android:layout_height="56dp"
        android:text="@string/settings_menu_language" android:textAllCaps="false" android:textSize="16sp"
        android:textColor="@color/text_primary" android:background="@drawable/btn_pill_outline"
        android:layout_marginBottom="14dp"/>

    <Button android:id="@+id/btn_menu_backup" android:layout_width="match_parent" android:layout_height="56dp"
        android:text="@string/settings_menu_backup" android:textAllCaps="false" android:textSize="16sp"
        android:textColor="@color/text_primary" android:background="@drawable/btn_pill_outline"
        android:layout_marginBottom="14dp"/>

    <Button android:id="@+id/btn_menu_pro" android:layout_width="match_parent" android:layout_height="56dp"
        android:text="@string/settings_menu_pro" android:textAllCaps="false" android:textSize="16sp"
        android:textColor="@color/text_primary" android:background="@drawable/btn_pill_primary"
        android:layout_marginBottom="14dp"/>

    <View android:layout_width="match_parent" android:layout_height="1dp"
        android:background="#2A2E60" android:layout_marginTop="10dp" android:layout_marginBottom="24dp"/>

    <Button android:id="@+id/btn_menu_about" android:layout_width="match_parent" android:layout_height="56dp"
        android:text="@string/about_app" android:textAllCaps="false" android:textSize="16sp"
        android:textColor="@color/text_primary" android:background="@drawable/btn_pill_outline"/>

</LinearLayout>
</ScrollView>
EOF_APP_SRC_MAIN_RES_LAYOUT_ACTIVITY_SETTINGS_XML
echo "OK: app/src/main/res/layout/activity_settings.xml"

mkdir -p "$(dirname "app/src/main/res/layout/activity_settings_language.xml")"
cat > app/src/main/res/layout/activity_settings_language.xml << 'EOF_APP_SRC_MAIN_RES_LAYOUT_ACTIVITY_SETTINGS_LANGUAGE_XML'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:fillViewport="true">

<LinearLayout
    android:orientation="vertical" android:padding="24dp"
    android:layout_width="match_parent" android:layout_height="wrap_content">

    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="@string/settings_menu_language" android:textSize="22sp" android:textStyle="bold"
        android:textColor="@color/accent_cyan" android:layout_marginBottom="24dp"/>

    <Button android:id="@+id/btn_lang_en" android:layout_width="match_parent" android:layout_height="52dp"
        android:text="English" android:textAllCaps="false" android:textColor="@color/text_primary"
        android:background="@drawable/btn_pill_outline" android:layout_marginBottom="12dp"/>
    <Button android:id="@+id/btn_lang_ru" android:layout_width="match_parent" android:layout_height="52dp"
        android:text="Русский" android:textAllCaps="false" android:textColor="@color/text_primary"
        android:background="@drawable/btn_pill_outline" android:layout_marginBottom="12dp"/>
    <Button android:id="@+id/btn_lang_pl" android:layout_width="match_parent" android:layout_height="52dp"
        android:text="Polski" android:textAllCaps="false" android:textColor="@color/text_primary"
        android:background="@drawable/btn_pill_outline"/>

</LinearLayout>
</ScrollView>
EOF_APP_SRC_MAIN_RES_LAYOUT_ACTIVITY_SETTINGS_LANGUAGE_XML
echo "OK: app/src/main/res/layout/activity_settings_language.xml"

mkdir -p "$(dirname "app/src/main/res/layout/activity_settings_pro.xml")"
cat > app/src/main/res/layout/activity_settings_pro.xml << 'EOF_APP_SRC_MAIN_RES_LAYOUT_ACTIVITY_SETTINGS_PRO_XML'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:fillViewport="true">

<LinearLayout
    android:orientation="vertical" android:padding="24dp"
    android:layout_width="match_parent" android:layout_height="wrap_content">

    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="@string/settings_menu_pro" android:textSize="22sp" android:textStyle="bold"
        android:textColor="@color/accent_cyan" android:layout_marginBottom="16dp"/>

    <TextView android:id="@+id/tv_pro_status" android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="@string/pro_status_locked" android:textSize="15sp"
        android:textColor="@color/text_primary" android:layout_marginBottom="20dp"/>

    <Button android:id="@+id/btn_unlock_pro" android:layout_width="match_parent" android:layout_height="56dp"
        android:text="@string/pro_unlock_button" android:textAllCaps="false" android:textSize="16sp"
        android:textColor="@color/text_primary" android:background="@drawable/btn_pill_primary"/>

</LinearLayout>
</ScrollView>
EOF_APP_SRC_MAIN_RES_LAYOUT_ACTIVITY_SETTINGS_PRO_XML
echo "OK: app/src/main/res/layout/activity_settings_pro.xml"

mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/SettingsBackupActivity.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/SettingsBackupActivity.kt << 'EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_SETTINGSBACKUPACTIVITY_KT'
package com.example.fa_ksiegowy

import android.app.AlertDialog
import android.net.Uri
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.zip.ZipEntry
import java.util.zip.ZipInputStream
import java.util.zip.ZipOutputStream

/**
 * Резервная копия — через системное окно "Сохранить как" / "Открыть файл" (Storage
 * Access Framework). Пользователь сам выбирает, куда сохранить: память телефона,
 * Google Диск или любое другое подключённое хранилище — система показывает это
 * стандартным окном, без входа в аккаунт и настроек в коде приложения.
 *
 * Копия — это .zip: внутри backup.json (суммы, даты, комментарии, тип операции)
 * и папка receipts/ с фотографиями чеков, которые были прикреплены к записям.
 */
class SettingsBackupActivity : BaseActivity() {

    private val dateForName = SimpleDateFormat("yyyyMMdd_HHmm", Locale.US)
    private val dateForDisplay = SimpleDateFormat("dd.MM.yyyy HH:mm", Locale.getDefault())

    private val createDocLauncher = registerForActivityResult(ActivityResultContracts.CreateDocument("application/zip")) { uri ->
        if (uri != null) writeBackupTo(uri)
    }
    private val openDocLauncher = registerForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
        if (uri != null) confirmRestore(uri)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_settings_backup)

        findViewById<Button>(R.id.btn_backup_now).setOnClickListener {
            val name = "fa_ksiegowy_backup_${dateForName.format(Date())}.zip"
            createDocLauncher.launch(name)
        }
        findViewById<Button>(R.id.btn_restore_now).setOnClickListener {
            openDocLauncher.launch(arrayOf("application/zip", "application/octet-stream", "*/*"))
        }
        findViewById<Button>(R.id.btn_clear_all).setOnClickListener { confirmClearAll() }

        showLastBackupTime()
    }

    private fun writeBackupTo(uri: Uri) {
        setButtonsEnabled(false)
        Toast.makeText(this, getString(R.string.backup_in_progress), Toast.LENGTH_SHORT).show()
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val db = AppDatabase.getInstance(applicationContext)
                val entries = db.entryDao().getAll()

                val arr = JSONArray()
                for (e in entries) {
                    val o = JSONObject()
                    o.put("amount", e.amount)
                    o.put("isIncome", e.isIncome)
                    o.put("comment", e.comment ?: "")
                    o.put("dateMillis", e.dateMillis)
                    val receiptFile = e.receiptPath?.let { File(it) }
                    if (receiptFile != null && receiptFile.exists()) {
                        o.put("receiptFile", receiptFile.name)
                    }
                    arr.put(o)
                }

                contentResolver.openOutputStream(uri)?.use { out ->
                    ZipOutputStream(out).use { zos ->
                        zos.putNextEntry(ZipEntry("backup.json"))
                        zos.write(arr.toString().toByteArray(Charsets.UTF_8))
                        zos.closeEntry()

                        val addedNames = HashSet<String>()
                        for (e in entries) {
                            val path = e.receiptPath ?: continue
                            val f = File(path)
                            if (!f.exists() || !addedNames.add(f.name)) continue
                            zos.putNextEntry(ZipEntry("receipts/${f.name}"))
                            f.inputStream().use { it.copyTo(zos) }
                            zos.closeEntry()
                        }
                    }
                } ?: throw java.io.IOException("openOutputStream returned null")

                val prefs = getSharedPreferences("settings", MODE_PRIVATE)
                prefs.edit().putLong("lastBackupMillis", System.currentTimeMillis()).apply()

                withContext(Dispatchers.Main) {
                    setButtonsEnabled(true)
                    showLastBackupTime()
                    Toast.makeText(this@SettingsBackupActivity, getString(R.string.backup_success, entries.size), Toast.LENGTH_LONG).show()
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    setButtonsEnabled(true)
                    Toast.makeText(this@SettingsBackupActivity, getString(R.string.backup_error, e.message ?: ""), Toast.LENGTH_LONG).show()
                }
            }
        }
    }

    /** Восстановление ДОБАВЛЯЕТ записи из копии к уже имеющимся на устройстве
     *  (не заменяет и не удаляет их). Для "чистого" восстановления сначала
     *  используйте "Очистить все данные" ниже, а затем восстановление. */
    private fun confirmRestore(uri: Uri) {
        AlertDialog.Builder(this)
            .setTitle(getString(R.string.backup_restore_confirm_title))
            .setMessage(getString(R.string.backup_restore_confirm_message))
            .setPositiveButton(getString(R.string.backup_restore)) { _, _ -> runRestore(uri) }
            .setNegativeButton(getString(R.string.dialog_close), null)
            .show()
    }

    private fun runRestore(uri: Uri) {
        setButtonsEnabled(false)
        Toast.makeText(this, getString(R.string.backup_in_progress), Toast.LENGTH_SHORT).show()
        CoroutineScope(Dispatchers.IO).launch {
            try {
                var jsonText: String? = null
                // оригинальное_имя_файла_в_архиве -> новый абсолютный путь на устройстве
                val restoredReceiptPaths = HashMap<String, String>()
                val receiptsDir = getExternalFilesDir(null)!!
                var receiptCounter = 0

                contentResolver.openInputStream(uri)?.use { input ->
                    ZipInputStream(input).use { zis ->
                        var entry = zis.nextEntry
                        while (entry != null) {
                            when {
                                entry.name == "backup.json" -> {
                                    jsonText = zis.readBytes().toString(Charsets.UTF_8)
                                }
                                entry.name.startsWith("receipts/") -> {
                                    val originalName = entry.name.removePrefix("receipts/")
                                    val ext = originalName.substringAfterLast('.', "jpg")
                                    receiptCounter++
                                    val newFile = File(receiptsDir, "receipt_restored_${System.currentTimeMillis()}_$receiptCounter.$ext")
                                    newFile.outputStream().use { fos -> zis.copyTo(fos) }
                                    restoredReceiptPaths[originalName] = newFile.absolutePath
                                }
                            }
                            zis.closeEntry()
                            entry = zis.nextEntry
                        }
                    }
                } ?: throw java.io.IOException("openInputStream returned null")

                val json = jsonText ?: throw IllegalStateException(getString(R.string.backup_invalid_file))
                val arr = JSONArray(json)

                val db = AppDatabase.getInstance(applicationContext)
                var restored = 0
                for (i in 0 until arr.length()) {
                    val o = arr.getJSONObject(i)
                    val receiptFile = o.optString("receiptFile", "")
                    val receiptPath = if (receiptFile.isNotEmpty()) restoredReceiptPaths[receiptFile] else null
                    db.entryDao().insert(
                        Entry(
                            amount = o.getDouble("amount"),
                            isIncome = o.getBoolean("isIncome"),
                            comment = o.optString("comment", ""),
                            dateMillis = o.getLong("dateMillis"),
                            receiptPath = receiptPath
                        )
                    )
                    restored++
                }

                withContext(Dispatchers.Main) {
                    setButtonsEnabled(true)
                    Toast.makeText(this@SettingsBackupActivity, getString(R.string.backup_restored, restored), Toast.LENGTH_LONG).show()
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    setButtonsEnabled(true)
                    Toast.makeText(this@SettingsBackupActivity, getString(R.string.backup_error, e.message ?: ""), Toast.LENGTH_LONG).show()
                }
            }
        }
    }

    private fun showLastBackupTime() {
        val prefs = getSharedPreferences("settings", MODE_PRIVATE)
        val last = prefs.getLong("lastBackupMillis", -1L)
        findViewById<TextView>(R.id.tv_last_backup).text = if (last <= 0L) {
            getString(R.string.backup_never)
        } else {
            getString(R.string.backup_last_time, dateForDisplay.format(Date(last)))
        }
    }

    private fun setButtonsEnabled(enabled: Boolean) {
        findViewById<Button>(R.id.btn_backup_now).isEnabled = enabled
        findViewById<Button>(R.id.btn_restore_now).isEnabled = enabled
    }

    /** Необратимо удаляет все доходы/расходы (только записи в базе — файлы чеков
     *  на диске не трогает). Логически относится к управлению данными приложения. */
    private fun confirmClearAll() {
        AlertDialog.Builder(this)
            .setTitle(getString(R.string.clear_all_confirm_title))
            .setMessage(getString(R.string.clear_all_confirm_message))
            .setPositiveButton(getString(R.string.clear_all_confirm_yes)) { _, _ ->
                CoroutineScope(Dispatchers.IO).launch {
                    AppDatabase.getInstance(applicationContext).entryDao().deleteAll()
                    withContext(Dispatchers.Main) {
                        Toast.makeText(this@SettingsBackupActivity, getString(R.string.clear_all_done), Toast.LENGTH_SHORT).show()
                    }
                }
            }
            .setNegativeButton(getString(R.string.dialog_close), null)
            .show()
    }
}
EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_SETTINGSBACKUPACTIVITY_KT
echo "OK: app/src/main/java/com/example/fa_ksiegowy/SettingsBackupActivity.kt"

mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/SettingsTaxActivity.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/SettingsTaxActivity.kt << 'EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_SETTINGSTAXACTIVITY_KT'
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
EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_SETTINGSTAXACTIVITY_KT
echo "OK: app/src/main/java/com/example/fa_ksiegowy/SettingsTaxActivity.kt"

mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/SettingsActivity.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/SettingsActivity.kt << 'EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_SETTINGSACTIVITY_KT'
package com.example.fa_ksiegowy

import android.app.AlertDialog
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.widget.Button

/** Главное меню настроек — теперь просто категории, сами экраны вынесены
 *  в отдельные Activity, чтобы список не занимал весь экран и было место
 *  под будущие разделы. */
class SettingsActivity : BaseActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_settings)

        findViewById<Button>(R.id.btn_menu_tax).setOnClickListener {
            startActivity(Intent(this, SettingsTaxActivity::class.java))
        }
        findViewById<Button>(R.id.btn_menu_language).setOnClickListener {
            startActivity(Intent(this, SettingsLanguageActivity::class.java))
        }
        findViewById<Button>(R.id.btn_menu_backup).setOnClickListener {
            if (BillingManager.isPro(this)) {
                startActivity(Intent(this, SettingsBackupActivity::class.java))
            } else {
                AlertDialog.Builder(this)
                    .setTitle(getString(R.string.pro_feature_locked_title))
                    .setMessage(getString(R.string.backup_pro_locked_message))
                    .setPositiveButton(getString(R.string.settings_menu_pro)) { _, _ ->
                        startActivity(Intent(this, SettingsProActivity::class.java))
                    }
                    .setNegativeButton(getString(R.string.dialog_close), null)
                    .show()
            }
        }
        findViewById<Button>(R.id.btn_menu_pro).setOnClickListener {
            startActivity(Intent(this, SettingsProActivity::class.java))
        }
        findViewById<Button>(R.id.btn_menu_about).setOnClickListener {
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
}
EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_SETTINGSACTIVITY_KT
echo "OK: app/src/main/java/com/example/fa_ksiegowy/SettingsActivity.kt"

mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/SettingsLanguageActivity.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/SettingsLanguageActivity.kt << 'EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_SETTINGSLANGUAGEACTIVITY_KT'
package com.example.fa_ksiegowy

import android.content.Intent
import android.os.Bundle
import android.widget.Button

/** Выбор языка приложения. Смена языка перезапускает MineActivity как единственный
 *  экран в задаче, чтобы весь UI (в т.ч. уже открытые экраны) пересобрался с новой локалью. */
class SettingsLanguageActivity : BaseActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_settings_language)

        findViewById<Button>(R.id.btn_lang_en).setOnClickListener { setLocale("en") }
        findViewById<Button>(R.id.btn_lang_ru).setOnClickListener { setLocale("ru") }
        findViewById<Button>(R.id.btn_lang_pl).setOnClickListener { setLocale("pl") }
    }

    private fun setLocale(code: String) {
        LocaleHelper.setLanguage(this, code)
        val intent = Intent(this, MineActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
        startActivity(intent)
        finishAffinity()
    }
}
EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_SETTINGSLANGUAGEACTIVITY_KT
echo "OK: app/src/main/java/com/example/fa_ksiegowy/SettingsLanguageActivity.kt"

mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/SettingsProActivity.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/SettingsProActivity.kt << 'EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_SETTINGSPROACTIVITY_KT'
package com.example.fa_ksiegowy

import android.app.AlertDialog
import android.os.Bundle
import android.widget.Button
import android.widget.TextView

/** Разблокировка Pro-версии (разовая покупка через Google Play Billing). */
class SettingsProActivity : BaseActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_settings_pro)
        setupProSection()
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
}
EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_SETTINGSPROACTIVITY_KT
echo "OK: app/src/main/java/com/example/fa_ksiegowy/SettingsProActivity.kt"

mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/TaxHelper.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/TaxHelper.kt << 'EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_TAXHELPER_KT'
package com.example.fa_ksiegowy

import android.content.SharedPreferences
import java.util.Calendar

/**
 * Официальная прогрессивная шкала налога (PIT) для działalność nierejestrowana:
 *
 *   • 0 – 30 000 zł/год за год        — 0%  (kwota wolna od podatku)
 *   • 30 000 – 120 000 zł/год         — 12% с суммы СВЕРХ 30 000 zł
 *   • свыше 120 000 zł/год            — 32% с суммы СВЕРХ 120 000 zł
 *
 * Важно: ставка применяется только к части дохода СВЕРХ каждого порога,
 * а не ко всей сумме целиком (раньше в приложении был плоский процент,
 * применённый ко всей налогооблагаемой сумме — это было неверно).
 *
 * "Прочие доходы" пользователя (otherIncome, вводятся вручную в настройках)
 * учитываются как занимающие нижние ступени шкалы ПЕРВЫМИ — налог, который
 * показывается в приложении, это налог именно с прибыли из приложения
 * (appProfit), рассчитанный маржинально поверх прочих доходов.
 */
object TaxHelper {

    const val ANNUAL_LIMIT = 30000.0
    const val SECOND_BRACKET_THRESHOLD = 120000.0
    private const val FIRST_BRACKET_RATE = 0.12
    private const val SECOND_BRACKET_RATE = 0.32

    data class TaxResult(
        val totalTaxable: Double,   // otherIncome + appProfit
        val taxBase: Double,        // appProfit (для обратной совместимости с UI)
        val tax: Double,            // налог, относящийся именно к прибыли из приложения
        val effectiveRatePercent: Double // эффективная ставка на appProfit, для отображения "Налог (X%)"
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

    /**
     * Официальная прогрессивная шкала PIT для действия nierejestrowana / ryczałt-подобного
     * случая, как её описал пользователь:
     *   • 0 – 30 000 zł/год       — 0% (kwota wolna od podatku)
     *   • 30 000 – 120 000 zł/год — 12% с суммы СВЕРХ 30 000 (не со всей суммы!)
     *   • свыше 120 000 zł/год    — 32% с суммы СВЕРХ 120 000, плюс фиксированные
     *                               (120 000 − 30 000) × 12% с предыдущей ступени
     * Считает налог на весь годовой налогооблагаемый доход целиком (без разбивки
     * по источникам) — используется как вспомогательная функция ниже.
     */
    private fun bracketTax(annualIncome: Double): Double {
        val income = if (annualIncome < 0) 0.0 else annualIncome
        return when {
            income <= ANNUAL_LIMIT -> 0.0
            income <= SECOND_BRACKET_THRESHOLD -> (income - ANNUAL_LIMIT) * FIRST_BRACKET_RATE
            else -> (SECOND_BRACKET_THRESHOLD - ANNUAL_LIMIT) * FIRST_BRACKET_RATE +
                (income - SECOND_BRACKET_THRESHOLD) * SECOND_BRACKET_RATE
        }
    }

    /**
     * Считаем налог, относящийся к прибыли ИЗ ПРИЛОЖЕНИЯ (appProfit), с учётом того,
     * что "прочие доходы" (otherIncome) занимают нижние ступени шкалы первыми —
     * это стандартный маржинальный подход: appProfit облагается по тем ступеням
     * шкалы, которые остаются НАД уже "использованными" прочими доходами.
     *
     * Пример (как в вопросе пользователя): appProfit = 234 400, otherIncome = 0.
     *   taxOnCombined = (120000-30000)*12% + (234400-120000)*32% = 10800 + 36608 = 47408
     *   taxOnOtherOnly = 0 (прочих доходов нет)
     *   tax = 47408 — именно эта сумма должна отображаться, а не плоские 12%.
     */
    fun calc(appProfit: Double, otherIncome: Double): TaxResult {
        val other = if (otherIncome < 0) 0.0 else otherIncome
        val app = if (appProfit < 0) 0.0 else appProfit
        val combined = other + app

        val taxOnOtherOnly = bracketTax(other)
        val taxOnCombined = bracketTax(combined)
        val tax = taxOnCombined - taxOnOtherOnly

        val effectiveRate = if (app > 0) (tax / app) * 100.0 else 0.0
        return TaxResult(combined, app, tax, effectiveRate)
    }
}
EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_TAXHELPER_KT
echo "OK: app/src/main/java/com/example/fa_ksiegowy/TaxHelper.kt"

mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/MineActivity.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/MineActivity.kt << 'EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_MINEACTIVITY_KT'
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

        // Единая кнопка добавления: выбор дохода/расхода происходит уже внутри
        // AddEntryActivity (переключатель с подсветкой выбранного варианта).
        // По умолчанию открываем на "доход", это чаще нужное действие.
        findViewById<Button>(R.id.btn_add_entry).setOnClickListener {
            startActivity(Intent(this, AddEntryActivity::class.java).putExtra("isIncome", true))
        }
        findViewById<Button>(R.id.btn_settings).setOnClickListener {
            startActivity(Intent(this, SettingsActivity::class.java))
        }
        findViewById<Button>(R.id.btn_reports).setOnClickListener {
            startActivity(Intent(this, ReportActivity::class.java))
        }
        findViewById<Button>(R.id.btn_history).setOnClickListener {
            startActivity(Intent(this, HistoryActivity::class.java))
        }


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
            // Баланс/статистика/налог — только за текущий календарный год,
            // так как лимит 30 000 zł годовой (см. TaxHelper).
            val year = TaxHelper.currentYear()
            val (yearStart, yearEndExclusive) = TaxHelper.yearRange(year)
            val yearEntries = db.entryDao().getBetween(yearStart, yearEndExclusive - 1)

            val income = yearEntries.filter { it.isIncome }.sumOf { it.amount }
            val expense = yearEntries.filter { !it.isIncome }.sumOf { it.amount }
            val profit = income - expense

            val prefs = getSharedPreferences("settings", MODE_PRIVATE)
            val otherIncome = TaxHelper.getOtherIncome(prefs, year)
            val taxResult = TaxHelper.calc(profit, otherIncome)

            withContext(Dispatchers.Main) {
                findViewById<TextView>(R.id.tv_balance).text = formatMoney(profit)
                findViewById<TextView>(R.id.tv_stat_income).text = formatMoney(income)
                findViewById<TextView>(R.id.tv_stat_expense).text = formatMoney(expense)
                findViewById<TextView>(R.id.tv_stat_profit).text = formatMoney(profit)
                // Реальная (эффективная) ставка по прогрессивной шкале, а не сохранённое
                // ранее число — раньше здесь всегда показывалось то, что было один раз
                // введено вручную (обычно 12%), даже если фактический налог был другим.
                findViewById<TextView>(R.id.tv_stat_tax_label).text =
                    getString(R.string.stat_tax_format, taxResult.effectiveRatePercent)
                findViewById<TextView>(R.id.tv_stat_tax).text = formatMoney(taxResult.tax)
                // Чистая прибыль = прибыль минус налог, рассчитанный TaxHelper
                // (с учётом годового лимита 30 000 zł, прогрессивной шкалы 12%/32%
                // и прочих доходов из настроек).
                findViewById<TextView>(R.id.tv_stat_net_profit).text = formatMoney(profit - taxResult.tax)
            }
        }
    }

    private fun formatMoney(v: Double): String = String.format(Locale.getDefault(), "%.2f", v)
}
EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_MINEACTIVITY_KT
echo "OK: app/src/main/java/com/example/fa_ksiegowy/MineActivity.kt"

mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/ReportActivity.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/ReportActivity.kt << 'EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_REPORTACTIVITY_KT'
package com.example.fa_ksiegowy

import android.app.DatePickerDialog
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.FileProvider
import java.util.Calendar
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
            runIfPro { showCustomRangePicker() }
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

    /**
     * Произвольный период: два DatePickerDialog подряd — сначала выбираем дату "от",
     * затем "до". Лимит 30 000 zł к произвольному периоду не применяем (как и к
     * месячному отчёту) — он корректно применим только к целому календарному году.
     */
    private fun showCustomRangePicker() {
        val cal = Calendar.getInstance()
        DatePickerDialog(
            this,
            { _, fromYear, fromMonth, fromDay ->
                val fromCal = Calendar.getInstance()
                fromCal.set(fromYear, fromMonth, fromDay, 0, 0, 0)
                fromCal.set(Calendar.MILLISECOND, 0)
                val fromMillis = fromCal.timeInMillis

                DatePickerDialog(
                    this,
                    { _, toYear, toMonth, toDay ->
                        val toCal = Calendar.getInstance()
                        toCal.set(toYear, toMonth, toDay, 23, 59, 59)
                        toCal.set(Calendar.MILLISECOND, 999)
                        val toMillis = toCal.timeInMillis

                        if (toMillis < fromMillis) {
                            Toast.makeText(this, getString(R.string.custom_range_invalid), Toast.LENGTH_LONG).show()
                            return@DatePickerDialog
                        }
                        generateReport(fromMillis, toMillis, getString(R.string.report_title_custom), applyAnnualLimit = false)
                    },
                    cal.get(Calendar.YEAR), cal.get(Calendar.MONTH), cal.get(Calendar.DAY_OF_MONTH)
                ).apply { setTitle(getString(R.string.to)) }.show()
            },
            cal.get(Calendar.YEAR), cal.get(Calendar.MONTH), cal.get(Calendar.DAY_OF_MONTH)
        ).apply { setTitle(getString(R.string.from)) }.show()
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
                for (c in 0..3) titleRow.createCell(c).cellStyle = titleStyle
                titleRow.getCell(0).setCellValue(title)
                sheet.addMergedRegion(org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 3))

                // ---- header row ----
                // Столбцов налога на каждую отдельную операцию больше нет: с прогрессивной
                // шкалой (0% до 30 000 zł, 12% с 30 000 до 120 000 zł, 32% свыше) налог
                // считается по совокупному годовому доходу, а не по отдельной операции —
                // делить его поровну между записями было бы некорректно и вводило в
                // заблуждение. Итоговый налог за период показан ниже, в строке "Итого".
                val headers = listOf(
                    getString(R.string.report_col_date),
                    getString(R.string.report_col_income),
                    getString(R.string.report_col_expense),
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

                for (e in entries) {
                    val r = sheet.createRow(rowN++)

                    val dateCell = r.createCell(0)
                    dateCell.setCellValue(dateFmt.format(Date(e.dateMillis)))
                    dateCell.cellStyle = dataStyle

                    val incomeVal = if (e.isIncome) e.amount else 0.0
                    val expenseVal = if (!e.isIncome) e.amount else 0.0

                    val incomeCell = r.createCell(1)
                    incomeCell.setCellValue(incomeVal)
                    incomeCell.cellStyle = incomeStyle

                    val expenseCell = r.createCell(2)
                    expenseCell.setCellValue(expenseVal)
                    expenseCell.cellStyle = expenseStyle

                    val commentCell = r.createCell(3)
                    commentCell.setCellValue(e.comment ?: "")
                    commentCell.cellStyle = dataStyle

                    totalIncome += incomeVal
                    totalExpense += expenseVal
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

                // Налог считаем от прибыли (доход - расход) по официальной прогрессивной
                // шкале — так же, как на главном экране приложения (TaxHelper.calc), а
                // не плоским процентом от суммы доходов — иначе итог в отчёте не совпадает
                // с балансом в приложении и не соответствует реальной шкале PIT.
                //
                // Для годового отчёта учитываются прочие доходы (они "занимают" нижние
                // ступени шкалы первыми). Для отчёта за месяц/произвольный период прочие
                // доходы не учитываются — 30 000 zł порог годовой, применять его к части
                // года было бы некорректно.
                val totalProfitForTax = totalIncome - totalExpense
                val otherIncomeForTax = if (applyAnnualLimit) TaxHelper.getOtherIncome(prefs, year) else 0.0
                val correctedTotalTax = TaxHelper.calc(totalProfitForTax, otherIncomeForTax).tax

                val taxRow = sheet.createRow(rowN++)
                taxRow.createCell(0).also { it.setCellValue(getString(R.string.report_total_tax)); it.cellStyle = totalLabelStyle }
                taxRow.createCell(1).also { it.setCellValue(correctedTotalTax); it.cellStyle = totalValueStyle }

                // Чистая прибыль = прибыль минус налог — тот же показатель, что и
                // "tv_stat_net_profit" на главном экране приложения.
                val netProfit = totalProfitForTax - correctedTotalTax
                val netProfitRow = sheet.createRow(rowN)
                netProfitRow.createCell(0).also { it.setCellValue(getString(R.string.report_total_net_profit)); it.cellStyle = totalLabelStyle }
                netProfitRow.createCell(1).also { it.setCellValue(netProfit); it.cellStyle = totalValueStyle }

                // ---- column widths (manual — avoids java.awt dependency on Android) ----
                sheet.setColumnWidth(0, 20 * 256)
                sheet.setColumnWidth(1, 14 * 256)
                sheet.setColumnWidth(2, 14 * 256)
                sheet.setColumnWidth(3, 36 * 256)

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
EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_REPORTACTIVITY_KT
echo "OK: app/src/main/java/com/example/fa_ksiegowy/ReportActivity.kt"

mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/AdsManager.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/AdsManager.kt << 'EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_ADSMANAGER_KT'
package com.example.fa_ksiegowy

import android.app.Activity
import android.content.pm.ApplicationInfo
import android.util.Log
import android.view.View
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.MobileAds
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.UserMessagingPlatform

/**
 * Показ баннера только для пользователей без Pro.
 * Перед первым запросом рекламы сначала получаем согласие через UMP
 * (обязательно для пользователей EEA/UK по требованиям Google и GDPR).
 *
 * ВАЖНО (если баннер вообще не появляется): почти всегда причина не в коде,
 * а в том, что в консоли AdMob (admob.google.com -> Privacy & messaging)
 * не создано и не ОПУБЛИКОВАНО сообщение о согласии на сбор данных (EU/UK).
 * Без этого consentInformation.canRequestAds() никогда не станет true для
 * пользователей из Польши/ЕС, и loadAd() просто никогда не вызывается —
 * без единой ошибки, тихо. Это нужно настроить один раз в консоли AdMob.
 * Дополнительно баннер может не показываться первые часы/дни после создания
 * нового рекламного блока — Google ещё не успел заполнить инвентарь ("no fill").
 */
object AdsManager {

    private var sdkInitialized = false
    private const val TEST_BANNER_UNIT_ID = "ca-app-pub-3940256099942544/6300978111"

    fun setupAndLoadBanner(activity: Activity, adView: AdView) {
        if (BillingManager.isPro(activity)) {
            adView.visibility = View.GONE
            return
        }

        // В debug-сборке (это то, что собирается в Termux через debug.keystore)
        // подставляем официальный тестовый рекламный блок Google — он гарантированно
        // показывает рекламу и не зависит ни от согласия UMP, ни от заполнения
        // инвентаря, ни от статуса модерации приложения в AdMob. Это позволяет сразу
        // увидеть, что баннер технически работает, независимо от настроек AdMob.
        val isDebuggable = (activity.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
        if (isDebuggable) {
            adView.adUnitId = TEST_BANNER_UNIT_ID
            Log.i("AdsManager", "Debug build — using Google TEST banner ad unit instead of production one")
        }

        val consentInformation = UserMessagingPlatform.getConsentInformation(activity)

        // ВАЖНО для тестирования формы согласия на своём устройстве: раскомментируйте
        // и подставьте свой тестовый device ID (печатается в logcat при первом запуске).
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
                    } else {
                        Log.w("AdsManager", "canRequestAds() == false after consent flow — ad will NOT load. Check AdMob console -> Privacy & messaging (must be published).")
                    }
                }
            },
            { requestError ->
                Log.w("AdsManager", "Consent info update error: ${requestError.message}")
                // Не удалось получить статус согласия — на всякий случай не грузим рекламу,
                // КРОМЕ debug-тестового блока, который не требует согласия.
                if (isDebuggable) initAndLoad(activity, adView)
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
        adView.adListener = object : AdListener() {
            override fun onAdLoaded() {
                Log.i("AdsManager", "Banner ad loaded OK")
            }
            override fun onAdFailedToLoad(error: LoadAdError) {
                // errorCode 3 = ERROR_CODE_NO_FILL — самая частая причина для новых
                // рекламных блоков: у Google пока нет рекламы для показа именно вам.
                Log.w("AdsManager", "Banner failed to load: code=${error.code} message=${error.message}")
            }
        }
        adView.loadAd(AdRequest.Builder().build())
    }

    /** Вызывать сразу после успешной покупки Pro, чтобы мгновенно убрать баннер без перезапуска экрана. */
    fun hideBanner(adView: AdView) {
        adView.visibility = View.GONE
        adView.pause()
    }
}
EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_ADSMANAGER_KT
echo "OK: app/src/main/java/com/example/fa_ksiegowy/AdsManager.kt"

mkdir -p "$(dirname "app/src/main/res/values/strings.xml")"
cat > app/src/main/res/values/strings.xml << 'EOF_APP_SRC_MAIN_RES_VALUES_STRINGS_XML'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">FinArs</string>
    <string name="app_subtitle">FinArs</string>
    <string name="add_income">Add income</string>
    <string name="add_expense">Add expense</string>
    <string name="add_entry">Add +</string>
    <string name="balance">Balance</string>
    <string name="enter_amount">Amount</string>
    <string name="enter_comment">Comment</string>
    <string name="attach_receipt">Attach receipt</string>
    <string name="save">Save</string>
    <string name="settings">Settings</string>
    <string name="tax_percent">Tax percent</string>
    <string name="other_income_label">Other income (%1$d)</string>
    <string name="tax_scale_title">Tax is calculated automatically</string>
    <string name="tax_scale_description" formatted="false">0% up to 30,000 zł/year · 12% on the part between 30,000 and 120,000 zł · 32% on the part above 120,000 zł. The rate applies only to the amount above each threshold, not to the whole sum.</string>
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
    <string name="stat_profit">Profit (gross)</string>
    <string name="stat_tax_format">Tax (%1$.1f%%)</string>

    <string name="report_col_date">Date</string>
    <string name="report_col_income">Income</string>
    <string name="report_col_expense">Expense</string>
    <string name="report_col_tax_percent">Tax %%</string>
    <string name="report_col_tax_amount">Tax amount</string>
    <string name="report_col_comment">Comment</string>
    <string name="report_sheet_name">Report</string>
    <string name="report_title_month">Report — Month</string>
    <string name="report_title_year">Report — Year</string>
    <string name="report_title_custom">Report — Custom period</string>
    <string name="custom_range_invalid">The end date must be after the start date</string>
    <string name="report_total_income">Total income</string>
    <string name="report_total_expense">Total expense</string>
    <string name="report_total_profit">Total profit</string>
    <string name="report_total_tax">Total tax</string>
    <string name="report_total_net_profit">Net profit (after tax)</string>
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
    <string name="backup_pro_locked_message">Backup and restore is a Pro feature. Unlock Pro to keep your data safe with a backup file.</string>
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
    <string name="transaction_history">Transaction history</string>
    <string name="stat_net_profit">Net profit (after tax)</string>
    <string name="type_income">Income</string>
    <string name="type_expense">Expense</string>
    <string name="edit_income_title">Edit income</string>
    <string name="edit_expense_title">Edit expense</string>
    <string name="delete_entry">Delete</string>
    <string name="delete_confirm_title">Delete entry?</string>
    <string name="delete_confirm_message">This entry will be permanently deleted. This cannot be undone.</string>
    <string name="delete_confirm_yes">Delete</string>
    <string name="entry_updated">Updated</string>
    <string name="entry_deleted">Deleted</string>
    <string name="clear_all_button">Clear all data</string>
    <string name="clear_all_confirm_title">Are you sure?</string>
    <string name="clear_all_confirm_message">All income and expense entries will be permanently deleted. This cannot be undone.</string>
    <string name="clear_all_confirm_yes">Delete all</string>
    <string name="clear_all_done">All data has been deleted</string>

    <string name="settings_menu_tax">Tax and limits</string>
    <string name="settings_menu_language">Language</string>
    <string name="settings_menu_backup">Backup (Pro)</string>
    <string name="settings_menu_pro">Pro version</string>

    <string name="backup_hint">Save a backup of your income/expense entries — including amounts, dates, comments and attached receipt photos — as a file. In the save dialog you can choose phone storage or Google Drive (if the Drive app is installed). Keep this file safe: it\'s the only way to restore your data if you lose the phone or reinstall the app.</string>
    <string name="backup_in_progress">Working…</string>
    <string name="backup_create">Create backup</string>
    <string name="backup_restore">Restore from backup</string>
    <string name="backup_success">Backup saved (%1$d entries)</string>
    <string name="backup_error">Error: %1$s</string>
    <string name="backup_restore_confirm_title">Restore from backup?</string>
    <string name="backup_restore_confirm_message">Entries from the backup file will be added to what you already have on this device (existing entries are not deleted or overwritten). If you want a clean restore, use \"Clear all data\" first, then restore.</string>
    <string name="backup_invalid_file">This does not look like a valid FinArs backup file</string>
    <string name="backup_restored">Restored %1$d entries</string>
    <string name="backup_never">Last backup: never</string>
    <string name="backup_last_time">Last backup: %1$s</string>
</resources>
EOF_APP_SRC_MAIN_RES_VALUES_STRINGS_XML
echo "OK: app/src/main/res/values/strings.xml"

mkdir -p "$(dirname "app/src/main/res/values-ru/strings.xml")"
cat > app/src/main/res/values-ru/strings.xml << 'EOF_APP_SRC_MAIN_RES_VALUES-RU_STRINGS_XML'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">FinArs</string>
    <string name="app_subtitle">FinArs</string>
    <string name="add_income">Добавить доход</string>
    <string name="add_expense">Добавить расход</string>
    <string name="add_entry">Добавить +</string>
    <string name="balance">Баланс</string>
    <string name="enter_amount">Сумма</string>
    <string name="enter_comment">Комментарий</string>
    <string name="attach_receipt">Прикрепить чек</string>
    <string name="save">Сохранить</string>
    <string name="settings">Настройки</string>
    <string name="tax_percent">Процент налога</string>
    <string name="other_income_label">Прочие доходы (%1$d)</string>
    <string name="tax_scale_title">Налог считается автоматически</string>
    <string name="tax_scale_description" formatted="false">0% до 30 000 zł/год · 12% с суммы от 30 000 до 120 000 zł · 32% с суммы свыше 120 000 zł. Ставка применяется только к части сверх каждого порога, а не ко всей сумме.</string>
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
    <string name="stat_profit">Прибыль (до налога)</string>
    <string name="stat_tax_format">Налог (%1$.1f%%)</string>

    <string name="report_col_date">Дата</string>
    <string name="report_col_income">Доход</string>
    <string name="report_col_expense">Расход</string>
    <string name="report_col_tax_percent">Налог %%</string>
    <string name="report_col_tax_amount">Сумма налога</string>
    <string name="report_col_comment">Комментарий</string>
    <string name="report_sheet_name">Отчёт</string>
    <string name="report_title_month">Отчёт — Месяц</string>
    <string name="report_title_year">Отчёт — Год</string>
    <string name="report_title_custom">Отчёт — Произвольный период</string>
    <string name="custom_range_invalid">Дата окончания должна быть позже даты начала</string>
    <string name="report_total_income">Итого доход</string>
    <string name="report_total_expense">Итого расход</string>
    <string name="report_total_profit">Итого прибыль</string>
    <string name="report_total_tax">Итого налог</string>
    <string name="report_total_net_profit">Чистая прибыль (после налога)</string>
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
    <string name="backup_pro_locked_message">Резервное копирование и восстановление — Pro-функция. Разблокируйте Pro, чтобы сохранить данные в файл на случай потери.</string>
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
    <string name="transaction_history">История операций</string>
    <string name="stat_net_profit">Чистая прибыль (после налога)</string>
    <string name="type_income">Доход</string>
    <string name="type_expense">Расход</string>
    <string name="edit_income_title">Редактировать доход</string>
    <string name="edit_expense_title">Редактировать расход</string>
    <string name="delete_entry">Удалить</string>
    <string name="delete_confirm_title">Удалить запись?</string>
    <string name="delete_confirm_message">Запись будет удалена без возможности восстановления.</string>
    <string name="delete_confirm_yes">Удалить</string>
    <string name="entry_updated">Обновлено</string>
    <string name="entry_deleted">Удалено</string>
    <string name="clear_all_button">Очистить все данные</string>
    <string name="clear_all_confirm_title">Вы уверены?</string>
    <string name="clear_all_confirm_message">Все доходы и расходы будут безвозвратно удалены. Это действие нельзя отменить.</string>
    <string name="clear_all_confirm_yes">Удалить всё</string>
    <string name="clear_all_done">Все данные удалены</string>

    <string name="settings_menu_tax">Налог и лимиты</string>
    <string name="settings_menu_language">Язык</string>
    <string name="settings_menu_backup">Резервная копия (Pro)</string>
    <string name="settings_menu_pro">Pro версия</string>

    <string name="backup_hint">Сохраните резервную копию доходов/расходов — суммы, даты, комментарии и прикреплённые фото чеков — в виде файла. В окне сохранения можно выбрать память телефона или Google Диск (если установлено приложение Диска). Храните этот файл в надёжном месте — только по нему можно восстановить данные при потере телефона или переустановке приложения.</string>
    <string name="backup_in_progress">Выполняется…</string>
    <string name="backup_create">Создать резервную копию</string>
    <string name="backup_restore">Восстановить из копии</string>
    <string name="backup_success">Копия сохранена (%1$d записей)</string>
    <string name="backup_error">Ошибка: %1$s</string>
    <string name="backup_restore_confirm_title">Восстановить из копии?</string>
    <string name="backup_restore_confirm_message">Записи из файла копии будут добавлены к тем, что уже есть на этом устройстве (существующие записи не удаляются и не перезаписываются). Если нужно "чистое" восстановление — сначала используйте "Очистить все данные", затем восстановление.</string>
    <string name="backup_invalid_file">Это не похоже на файл резервной копии FinArs</string>
    <string name="backup_restored">Восстановлено записей: %1$d</string>
    <string name="backup_never">Последняя копия: никогда</string>
    <string name="backup_last_time">Последняя копия: %1$s</string>
</resources>
EOF_APP_SRC_MAIN_RES_VALUES-RU_STRINGS_XML
echo "OK: app/src/main/res/values-ru/strings.xml"

mkdir -p "$(dirname "app/src/main/res/values-pl/strings.xml")"
cat > app/src/main/res/values-pl/strings.xml << 'EOF_APP_SRC_MAIN_RES_VALUES-PL_STRINGS_XML'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">FinArs</string>
    <string name="app_subtitle">FinArs</string>
    <string name="add_income">Dodaj przychód</string>
    <string name="add_expense">Dodaj wydatek</string>
    <string name="add_entry">Dodaj +</string>
    <string name="balance">Bilans</string>
    <string name="enter_amount">Kwota</string>
    <string name="enter_comment">Komentarz</string>
    <string name="attach_receipt">Dołącz paragon</string>
    <string name="save">Zapisz</string>
    <string name="settings">Ustawienia</string>
    <string name="tax_percent">Procent podatku</string>
    <string name="other_income_label">Inne przychody (%1$d)</string>
    <string name="tax_scale_title">Podatek liczony jest automatycznie</string>
    <string name="tax_scale_description" formatted="false">0% do 30 000 zł/rok · 12% od kwoty od 30 000 do 120 000 zł · 32% od kwoty powyżej 120 000 zł. Stawka dotyczy tylko części ponad każdy próg, a nie całej kwoty.</string>
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
    <string name="stat_profit">Zysk (brutto)</string>
    <string name="stat_tax_format">Podatek (%1$.1f%%)</string>

    <string name="report_col_date">Data</string>
    <string name="report_col_income">Przychód</string>
    <string name="report_col_expense">Wydatek</string>
    <string name="report_col_tax_percent">Podatek %%</string>
    <string name="report_col_tax_amount">Kwota podatku</string>
    <string name="report_col_comment">Komentarz</string>
    <string name="report_sheet_name">Raport</string>
    <string name="report_title_month">Raport — Miesiąc</string>
    <string name="report_title_year">Raport — Rok</string>
    <string name="report_title_custom">Raport — Zakres niestandardowy</string>
    <string name="custom_range_invalid">Data końcowa musi być późniejsza niż data początkowa</string>
    <string name="report_total_income">Suma przychodów</string>
    <string name="report_total_expense">Suma wydatków</string>
    <string name="report_total_profit">Suma zysku</string>
    <string name="report_total_tax">Suma podatku</string>
    <string name="report_total_net_profit">Zysk netto (po podatku)</string>
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
    <string name="backup_pro_locked_message">Kopia zapasowa i przywracanie to funkcja Pro. Odblokuj Pro, aby zabezpieczyć swoje dane plikiem kopii zapasowej.</string>
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
    <string name="transaction_history">Historia transakcji</string>
    <string name="stat_net_profit">Zysk netto (po podatku)</string>
    <string name="type_income">Przychód</string>
    <string name="type_expense">Wydatek</string>
    <string name="edit_income_title">Edytuj przychód</string>
    <string name="edit_expense_title">Edytuj wydatek</string>
    <string name="delete_entry">Usuń</string>
    <string name="delete_confirm_title">Usunąć wpis?</string>
    <string name="delete_confirm_message">Wpis zostanie trwale usunięty. Tej czynności nie można cofnąć.</string>
    <string name="delete_confirm_yes">Usuń</string>
    <string name="entry_updated">Zaktualizowano</string>
    <string name="entry_deleted">Usunięto</string>
    <string name="clear_all_button">Wyczyść wszystkie dane</string>
    <string name="clear_all_confirm_title">Na pewno?</string>
    <string name="clear_all_confirm_message">Wszystkie przychody i wydatki zostaną trwale usunięte. Tej czynności nie można cofnąć.</string>
    <string name="clear_all_confirm_yes">Usuń wszystko</string>
    <string name="clear_all_done">Wszystkie dane zostały usunięte</string>

    <string name="settings_menu_tax">Podatek i limity</string>
    <string name="settings_menu_language">Język</string>
    <string name="settings_menu_backup">Kopia zapasowa (Pro)</string>
    <string name="settings_menu_pro">Wersja Pro</string>

    <string name="backup_hint">Zapisz kopię zapasową przychodów/wydatków — kwoty, daty, komentarze i załączone zdjęcia paragonów — jako plik. W oknie zapisu możesz wybrać pamięć telefonu lub Dysk Google (jeśli aplikacja Dysku jest zainstalowana). Przechowuj ten plik w bezpiecznym miejscu — to jedyny sposób odzyskania danych w razie utraty telefonu lub reinstalacji aplikacji.</string>
    <string name="backup_in_progress">Trwa…</string>
    <string name="backup_create">Utwórz kopię zapasową</string>
    <string name="backup_restore">Przywróć z kopii</string>
    <string name="backup_success">Kopia zapisana (%1$d wpisów)</string>
    <string name="backup_error">Błąd: %1$s</string>
    <string name="backup_restore_confirm_title">Przywrócić z kopii?</string>
    <string name="backup_restore_confirm_message">Wpisy z pliku kopii zostaną dodane do tych, które już są na tym urządzeniu (istniejące wpisy nie są usuwane ani nadpisywane). Jeśli potrzebujesz "czystego" przywrócenia — najpierw użyj "Wyczyść wszystkie dane", a potem przywróć kopię.</string>
    <string name="backup_invalid_file">To nie wygląda na poprawny plik kopii zapasowej FinArs</string>
    <string name="backup_restored">Przywrócono wpisów: %1$d</string>
    <string name="backup_never">Ostatnia kopia: nigdy</string>
    <string name="backup_last_time">Ostatnia kopia: %1$s</string>
</resources>
EOF_APP_SRC_MAIN_RES_VALUES-PL_STRINGS_XML
echo "OK: app/src/main/res/values-pl/strings.xml"

# --- Регистрируем новые Settings*-экраны в AndroidManifest.xml ---
MANIFEST="app/src/main/AndroidManifest.xml"
if [ ! -f "$MANIFEST" ]; then
    echo "!!! Не найден $MANIFEST"
    exit 1
fi
for ACT in SettingsTaxActivity SettingsLanguageActivity SettingsBackupActivity SettingsProActivity; do
    if ! grep -q "\.${ACT}\"" "$MANIFEST"; then
        sed -i "s#<activity android:name=\"\\.SettingsActivity\" android:exported=\"false\" />#<activity android:name=\".SettingsActivity\" android:exported=\"false\" />\n        <activity android:name=\".${ACT}\" android:exported=\"false\" />#" "$MANIFEST"
        echo "OK: ${ACT} зарегистрирована в $MANIFEST"
    else
        echo "-- ${ACT} уже в манифесте, пропускаю"
    fi
done

echo "=== Готово. Теперь: git add -A && git commit -m 'SAF backup pro-gated, correct progressive tax, ad debug fallback' && git push ==="
