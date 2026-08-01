mkdir -p app/src/main/res/{values,drawable,layout,xml}

cat > "app/src/main/res/values/colors.xml" << 'FILEEOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="bg_top">#050818</color>
    <color name="bg_glow">#2A2E8F</color>
    <color name="bg_bottom">#0A0D2A</color>

    <color name="accent_cyan">#29B6F6</color>
    <color name="accent_blue_light">#3D5DFB</color>
    <color name="accent_blue_dark">#1230A8</color>

    <color name="card_bg">#12162E</color>
    <color name="card_bg_light">#171B38</color>

    <color name="text_primary">#FFFFFF</color>
    <color name="text_secondary">#9AA0C0</color>
    <color name="text_hint">#6B7094</color>

    <color name="income_green">#4CD964</color>
    <color name="expense_red">#FF5B5B</color>
</resources>
FILEEOF

cat > "app/src/main/res/drawable/bg_gradient.xml" << 'FILEEOF'
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item>
        <shape android:shape="rectangle">
            <solid android:color="@color/bg_top" />
        </shape>
    </item>
    <item>
        <shape android:shape="oval">
            <gradient
                android:type="radial"
                android:gradientRadius="380dp"
                android:centerX="0.5"
                android:centerY="0.62"
                android:startColor="@color/bg_glow"
                android:centerColor="#1A1D5C"
                android:endColor="@color/bg_top" />
        </shape>
    </item>
</layer-list>
FILEEOF

cat > "app/src/main/res/drawable/btn_pill_primary.xml" << 'FILEEOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <corners android:radius="32dp" />
    <gradient
        android:angle="90"
        android:startColor="@color/accent_blue_light"
        android:centerColor="#2246D6"
        android:endColor="@color/accent_blue_dark" />
    <stroke android:width="1dp" android:color="#4D79FF" />
</shape>
FILEEOF

cat > "app/src/main/res/drawable/btn_pill_outline.xml" << 'FILEEOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <corners android:radius="24dp" />
    <solid android:color="#1B2050" />
    <stroke android:width="1dp" android:color="#3A4090" />
</shape>
FILEEOF

cat > "app/src/main/res/drawable/input_field_bg.xml" << 'FILEEOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <corners android:radius="16dp" />
    <solid android:color="@color/card_bg" />
</shape>
FILEEOF

cat > "app/src/main/res/drawable/card_bg.xml" << 'FILEEOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <corners android:radius="14dp" />
    <solid android:color="@color/card_bg_light" />
</shape>
FILEEOF

cat > "app/src/main/res/layout/item_entry.xml" << 'FILEEOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="horizontal"
    android:background="@drawable/card_bg"
    android:padding="14dp"
    android:layout_marginBottom="8dp"
    android:gravity="center_vertical">

    <TextView
        android:id="@+id/tv_amount"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:textSize="16sp"
        android:textStyle="bold"/>

    <TextView
        android:id="@+id/tv_comment"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_weight="1"
        android:layout_marginStart="10dp"
        android:textColor="@color/text_secondary"
        android:textSize="14sp"
        android:maxLines="1"
        android:ellipsize="end"/>

</LinearLayout>
FILEEOF

cat > "app/src/main/res/xml/file_paths.xml" << 'FILEEOF'
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-files-path name="reports" path="reports/" />
    <external-files-path name="root" path="." />
</paths>
FILEEOF

cat > "app/src/main/res/values/themes.xml" << 'FILEEOF'
<resources xmlns:tools="http://schemas.android.com/tools">
    <style name="Theme.FA" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="colorPrimary">@color/accent_blue_light</item>
        <item name="colorPrimaryVariant">@color/accent_blue_dark</item>
        <item name="colorOnPrimary">@color/text_primary</item>
        <item name="colorSecondary">@color/accent_cyan</item>
        <item name="colorSecondaryVariant">@color/accent_blue_dark</item>
        <item name="colorOnSecondary">@color/text_primary</item>
        <item name="android:statusBarColor">@color/bg_top</item>
        <item name="android:windowBackground">@drawable/bg_gradient</item>
        <item name="android:textColorPrimary">@color/text_primary</item>
        <item name="android:textColorHint">@color/text_hint</item>
    </style>
</resources>
FILEEOF

cat > "app/src/main/res/values/strings.xml" << 'FILEEOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">F.A księgowy</string>
    <string name="app_subtitle">Księgowy</string>
    <string name="add_income">Add income</string>
    <string name="add_expense">Add expense</string>
    <string name="balance">Balance</string>
    <string name="enter_amount">Amount</string>
    <string name="enter_comment">Comment</string>
    <string name="attach_receipt">Attach receipt</string>
    <string name="save">Save</string>
    <string name="settings">Settings</string>
    <string name="tax_percent">Tax percent</string>
    <string name="export_report">Export report</string>
    <string name="generate_report">Generate report</string>
    <string name="select_period">Select period</string>
    <string name="month">Month</string>
    <string name="year">Year</string>
    <string name="custom_range">Custom range</string>
    <string name="from">From</string>
    <string name="to">To</string>
    <string name="no_entries">No entries</string>
</resources>
FILEEOF

cat > "app/src/main/res/values-ru/strings.xml" << 'FILEEOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">F.A księgowy</string>
    <string name="app_subtitle">Księgowy</string>
    <string name="add_income">Добавить доход</string>
    <string name="add_expense">Добавить расход</string>
    <string name="balance">Баланс</string>
    <string name="enter_amount">Сумма</string>
    <string name="enter_comment">Комментарий</string>
    <string name="attach_receipt">Прикрепить чек</string>
    <string name="save">Сохранить</string>
    <string name="settings">Настройки</string>
    <string name="tax_percent">Процент налога</string>
    <string name="export_report">Экспорт отчёта</string>
    <string name="generate_report">Сгенерировать отчёт</string>
    <string name="select_period">Выберите период</string>
    <string name="month">Месяц</string>
    <string name="year">Год</string>
    <string name="custom_range">Произвольный период</string>
    <string name="from">От</string>
    <string name="to">До</string>
    <string name="no_entries">Нет записей</string>
</resources>
FILEEOF

cat > "app/src/main/res/values-pl/strings.xml" << 'FILEEOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">F.A księgowy</string>
    <string name="app_subtitle">Księgowy</string>
    <string name="add_income">Dodaj przychód</string>
    <string name="add_expense">Dodaj wydatek</string>
    <string name="balance">Bilans</string>
    <string name="enter_amount">Kwota</string>
    <string name="enter_comment">Komentarz</string>
    <string name="attach_receipt">Dołącz paragon</string>
    <string name="save">Zapisz</string>
    <string name="settings">Ustawienia</string>
    <string name="tax_percent">Procent podatku</string>
    <string name="export_report">Eksportuj raport</string>
    <string name="generate_report">Generuj raport</string>
    <string name="select_period">Wybierz okres</string>
    <string name="month">Miesiąc</string>
    <string name="year">Rok</string>
    <string name="custom_range">Zakres niestandardowy</string>
    <string name="from">Od</string>
    <string name="to">Do</string>
    <string name="no_entries">Brak wpisów</string>
</resources>
FILEEOF

cat > "app/src/main/res/layout/activity_mine.xml" << 'FILEEOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:paddingStart="24dp"
    android:paddingEnd="24dp"
    android:paddingTop="36dp"
    android:paddingBottom="16dp">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="center_horizontal"
        android:text="FA"
        android:textColor="@color/accent_cyan"
        android:textSize="52sp"
        android:textStyle="bold"
        android:fontFamily="sans-serif-black"
        android:letterSpacing="0.05"/>

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="center_horizontal"
        android:layout_marginTop="2dp"
        android:layout_marginBottom="20dp"
        android:text="@string/app_subtitle"
        android:textColor="@color/text_primary"
        android:textSize="24sp"
        android:textStyle="bold"/>

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="center_horizontal"
        android:text="@string/balance"
        android:textColor="@color/text_secondary"
        android:textSize="13sp"
        android:letterSpacing="0.1"/>

    <TextView
        android:id="@+id/tv_balance"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="center_horizontal"
        android:layout_marginBottom="20dp"
        android:text="0.00"
        android:textColor="@color/text_primary"
        android:textSize="34sp"
        android:textStyle="bold"/>

    <Button
        android:id="@+id/btn_add_income"
        android:layout_width="match_parent"
        android:layout_height="56dp"
        android:layout_marginBottom="14dp"
        android:background="@drawable/btn_pill_primary"
        android:text="@string/add_income"
        android:textAllCaps="false"
        android:textColor="@color/text_primary"
        android:textSize="17sp"
        android:textStyle="bold"
        android:elevation="4dp"/>

    <Button
        android:id="@+id/btn_add_expense"
        android:layout_width="match_parent"
        android:layout_height="56dp"
        android:layout_marginBottom="20dp"
        android:background="@drawable/btn_pill_primary"
        android:text="@string/add_expense"
        android:textAllCaps="false"
        android:textColor="@color/text_primary"
        android:textSize="17sp"
        android:textStyle="bold"
        android:elevation="4dp"/>

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/rv_entries"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:clipToPadding="false"/>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:layout_marginTop="12dp"
        android:weightSum="2">

        <Button
            android:id="@+id/btn_settings"
            android:layout_width="0dp"
            android:layout_height="48dp"
            android:layout_weight="1"
            android:layout_marginEnd="8dp"
            android:background="@drawable/btn_pill_outline"
            android:text="@string/settings"
            android:textAllCaps="false"
            android:textColor="@color/text_primary"
            android:textSize="14sp"/>

        <Button
            android:id="@+id/btn_reports"
            android:layout_width="0dp"
            android:layout_height="48dp"
            android:layout_weight="1"
            android:layout_marginStart="8dp"
            android:background="@drawable/btn_pill_outline"
            android:text="@string/generate_report"
            android:textAllCaps="false"
            android:textColor="@color/text_primary"
            android:textSize="14sp"/>

    </LinearLayout>

</LinearLayout>
FILEEOF

cat > "app/src/main/res/layout/activity_add_entry.xml" << 'FILEEOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:padding="24dp">

    <TextView
        android:id="@+id/tv_add_title"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="12dp"
        android:layout_marginBottom="24dp"
        android:text="@string/add_expense"
        android:textColor="@color/accent_cyan"
        android:textSize="26sp"
        android:textStyle="bold"/>

    <EditText
        android:id="@+id/et_amount"
        android:layout_width="match_parent"
        android:layout_height="56dp"
        android:layout_marginBottom="14dp"
        android:background="@drawable/input_field_bg"
        android:paddingStart="18dp"
        android:paddingEnd="18dp"
        android:hint="@string/enter_amount"
        android:textColorHint="@color/text_hint"
        android:textColor="@color/text_primary"
        android:inputType="numberDecimal"/>

    <EditText
        android:id="@+id/et_comment"
        android:layout_width="match_parent"
        android:layout_height="56dp"
        android:layout_marginBottom="14dp"
        android:background="@drawable/input_field_bg"
        android:paddingStart="18dp"
        android:paddingEnd="18dp"
        android:hint="@string/enter_comment"
        android:textColorHint="@color/text_hint"
        android:textColor="@color/text_primary"
        android:inputType="text"/>

    <Button
        android:id="@+id/btn_attach"
        android:layout_width="match_parent"
        android:layout_height="56dp"
        android:layout_marginBottom="28dp"
        android:background="@drawable/input_field_bg"
        android:text="@string/attach_receipt"
        android:textAllCaps="false"
        android:textColor="@color/accent_cyan"
        android:textSize="15sp"
        android:gravity="start|center_vertical"
        android:paddingStart="18dp"
        android:paddingEnd="18dp"/>

    <View
        android:layout_width="0dp"
        android:layout_height="0dp"
        android:layout_weight="1"/>

    <Button
        android:id="@+id/btn_save"
        android:layout_width="match_parent"
        android:layout_height="56dp"
        android:background="@drawable/btn_pill_primary"
        android:text="@string/save"
        android:textAllCaps="false"
        android:textColor="@color/text_primary"
        android:textSize="17sp"
        android:textStyle="bold"/>

</LinearLayout>
FILEEOF

cat > "app/src/main/res/layout/activity_report.xml" << 'FILEEOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical" android:padding="24dp"
    android:layout_width="match_parent" android:layout_height="match_parent">

    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="@string/select_period" android:textSize="22sp" android:textStyle="bold"
        android:textColor="@color/accent_cyan" android:layout_marginBottom="24dp"/>

    <Button android:id="@+id/btn_report_month" android:layout_width="match_parent" android:layout_height="56dp"
        android:text="@string/month" android:textAllCaps="false" android:textSize="16sp"
        android:textColor="@color/text_primary" android:background="@drawable/btn_pill_primary"
        android:layout_marginBottom="14dp"/>

    <Button android:id="@+id/btn_report_year" android:layout_width="match_parent" android:layout_height="56dp"
        android:text="@string/year" android:textAllCaps="false" android:textSize="16sp"
        android:textColor="@color/text_primary" android:background="@drawable/btn_pill_primary"
        android:layout_marginBottom="14dp"/>

    <Button android:id="@+id/btn_report_custom" android:layout_width="match_parent" android:layout_height="56dp"
        android:text="@string/custom_range" android:textAllCaps="false" android:textSize="16sp"
        android:textColor="@color/text_primary" android:background="@drawable/btn_pill_outline"/>

</LinearLayout>
FILEEOF

cat > "app/src/main/res/layout/activity_settings.xml" << 'FILEEOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical" android:padding="24dp"
    android:layout_width="match_parent" android:layout_height="match_parent">

    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="@string/tax_percent" android:textSize="18sp"
        android:textColor="@color/text_primary" android:layout_marginBottom="10dp"/>

    <EditText android:id="@+id/et_tax" android:layout_width="match_parent" android:layout_height="56dp"
        android:background="@drawable/input_field_bg" android:paddingStart="18dp" android:paddingEnd="18dp"
        android:textColor="@color/text_primary" android:inputType="numberDecimal"
        android:layout_marginBottom="14dp"/>

    <Button android:id="@+id/btn_save_tax" android:layout_width="match_parent" android:layout_height="56dp"
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

</LinearLayout>
FILEEOF

cat > "app/src/main/AndroidManifest.xml" << 'FILEEOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application android:allowBackup="true" android:label="@string/app_name" android:theme="@style/Theme.FA">
        <activity android:name=".SettingsActivity" android:exported="false" />
        <activity android:name=".AddEntryActivity" android:exported="false" />
        <activity android:name=".ReportActivity" android:exported="false" />
        <activity android:name=".MineActivity" android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths" />
        </provider>
    </application>
</manifest>
FILEEOF

cat > "app/src/main/java/com/example/fa_ksiegowy/AddEntryActivity.kt" << 'FILEEOF'
package com.example.fa_ksiegowy
import android.net.Uri
import android.os.Bundle
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import android.widget.Button
import android.widget.EditText
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream

class AddEntryActivity : AppCompatActivity() {
    private var selectedImagePath: String? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_add_entry)
        val pickImage = registerForActivityResult(ActivityResultContracts.GetContent()) { uri: Uri? ->
            if (uri == null) return@registerForActivityResult
            try {
                val input = contentResolver.openInputStream(uri)
                if (input == null) {
                    Toast.makeText(this, "Не удалось открыть файл", Toast.LENGTH_SHORT).show()
                    return@registerForActivityResult
                }
                val out = File(getExternalFilesDir(null), "receipt_${System.currentTimeMillis()}.jpg")
                FileOutputStream(out).use { fos -> input.copyTo(fos) }
                input.close()
                selectedImagePath = out.absolutePath
                findViewById<Button>(R.id.btn_attach).text = getString(R.string.attach_receipt) + " ✓"
                Toast.makeText(this, "Чек добавлен", Toast.LENGTH_SHORT).show()
            } catch (e: Exception) {
                Toast.makeText(this, "Ошибка при добавлении чека: ${e.message}", Toast.LENGTH_LONG).show()
            }
        }
        val isIncome = intent.getBooleanExtra("isIncome", true)
        findViewById<android.widget.TextView>(R.id.tv_add_title).text = getString(if (isIncome) R.string.add_income else R.string.add_expense)
        findViewById<Button>(R.id.btn_attach).setOnClickListener { pickImage.launch("image/*") }
        findViewById<Button>(R.id.btn_save).setOnClickListener {
            val amt = findViewById<EditText>(R.id.et_amount).text.toString().toDoubleOrNull()
            if (amt == null || amt <= 0.0) {
                Toast.makeText(this, "Введите корректную сумму", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            val comment = findViewById<EditText>(R.id.et_comment).text.toString()
            val entry = Entry(amount = amt, isIncome = isIncome, comment = comment, dateMillis = System.currentTimeMillis(), receiptPath = selectedImagePath)
            findViewById<Button>(R.id.btn_save).isEnabled = false
            CoroutineScope(Dispatchers.IO).launch {
                AppDatabase.getInstance(applicationContext).entryDao().insert(entry)
                withContext(Dispatchers.Main) {
                    Toast.makeText(this@AddEntryActivity, "Сохранено", Toast.LENGTH_SHORT).show()
                    finish()
                }
            }
        }
    }
}
FILEEOF

cat > "app/src/main/java/com/example/fa_ksiegowy/ReportActivity.kt" << 'FILEEOF'
package com.example.fa_ksiegowy
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.FileProvider
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream
import org.apache.poi.xssf.usermodel.XSSFWorkbook

class ReportActivity : AppCompatActivity() {
    lateinit var db: AppDatabase
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_report)
        db = AppDatabase.getInstance(this)
        findViewById<Button>(R.id.btn_report_month).setOnClickListener { generateForMonth() }
        findViewById<Button>(R.id.btn_report_year).setOnClickListener { generateForYear() }
        findViewById<Button>(R.id.btn_report_custom).setOnClickListener {
            Toast.makeText(this, "Произвольный период пока не реализован, выберите месяц или год", Toast.LENGTH_LONG).show()
        }
    }
    private fun generateForMonth() {
        val now = System.currentTimeMillis()
        val monthMs = 30L * 24 * 60 * 60 * 1000
        generateReport(now - monthMs, now)
    }
    private fun generateForYear() {
        val now = System.currentTimeMillis()
        val yearMs = 365L * 24 * 60 * 60 * 1000
        generateReport(now - yearMs, now)
    }
    private fun generateReport(from: Long, to: Long) {
        setButtonsEnabled(false)
        Toast.makeText(this, "Формирую отчёт...", Toast.LENGTH_SHORT).show()
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
                val sheet = wb.createSheet("Report")
                val header = sheet.createRow(0)
                header.createCell(0).setCellValue("Date")
                header.createCell(1).setCellValue("Income")
                header.createCell(2).setCellValue("Expense")
                header.createCell(3).setCellValue("TaxPercent")
                header.createCell(4).setCellValue("TaxAmount")
                header.createCell(5).setCellValue("Comment")
                var rown = 1
                val prefs = getSharedPreferences("settings", MODE_PRIVATE)
                val tax = prefs.getFloat("taxPercent", 12f)
                for (e in entries) {
                    val r = sheet.createRow(rown++)
                    r.createCell(0).setCellValue(e.dateMillis.toString())
                    r.createCell(1).setCellValue(if (e.isIncome) e.amount else 0.0)
                    r.createCell(2).setCellValue(if (!e.isIncome) e.amount else 0.0)
                    r.createCell(3).setCellValue(tax.toDouble())
                    val taxAmount = if (e.isIncome) e.amount * tax / 100.0 else 0.0
                    r.createCell(4).setCellValue(taxAmount)
                    r.createCell(5).setCellValue(e.comment ?: "")
                }
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
                    Toast.makeText(this@ReportActivity, "Ошибка формирования отчёта: ${e.message}", Toast.LENGTH_LONG).show()
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
        Toast.makeText(this, "Отчёт готов", Toast.LENGTH_SHORT).show()
        startActivity(Intent.createChooser(intent, "Поделиться отчётом"))
    }
}
FILEEOF

cat > "app/src/main/java/com/example/fa_ksiegowy/EntryAdapter.kt" << 'FILEEOF'
package com.example.fa_ksiegowy
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView

class EntryAdapter(private val items: List<Entry>) : RecyclerView.Adapter<EntryAdapter.VH>() {
    class VH(view: View) : RecyclerView.ViewHolder(view) {
        val tvAmount = view.findViewById<TextView>(R.id.tv_amount)
        val tvComment = view.findViewById<TextView>(R.id.tv_comment)
    }
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val v = LayoutInflater.from(parent.context).inflate(R.layout.item_entry, parent, false)
        return VH(v)
    }
    override fun onBindViewHolder(holder: VH, position: Int) {
        val e = items[position]
        val sign = if (e.isIncome) "+" else "-"
        holder.tvAmount.text = "$sign ${String.format("%.2f", e.amount)}"
        holder.tvAmount.setTextColor(
            ContextCompat.getColor(holder.itemView.context, if (e.isIncome) R.color.income_green else R.color.expense_red)
        )
        holder.tvComment.text = e.comment ?: ""
    }
    override fun getItemCount(): Int = items.size
}
FILEEOF

git add .
git commit -m "Redesign UI, fix receipt attach and report generation"
git push
