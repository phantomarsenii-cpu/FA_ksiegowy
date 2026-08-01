#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Обновление: редактирование/удаление операций + очистка всех данных ==="

# --- 1) EntryDao.kt: добавляем getById/update/delete/deleteAll ---
mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/EntryDao.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/EntryDao.kt << 'KOTLIN_EOF_DAO'
package com.example.fa_ksiegowy

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Update

@Dao
interface EntryDao {
    @Insert
    suspend fun insert(entry: Entry)

    @Update
    suspend fun update(entry: Entry)

    @Delete
    suspend fun delete(entry: Entry)

    @Query("SELECT * FROM entries WHERE id = :id LIMIT 1")
    suspend fun getById(id: Long): Entry?

    @Query("SELECT * FROM entries ORDER BY dateMillis DESC")
    suspend fun getAll(): List<Entry>

    @Query("SELECT * FROM entries WHERE dateMillis BETWEEN :from AND :to ORDER BY dateMillis ASC")
    suspend fun getBetween(from: Long, to: Long): List<Entry>

    /** Полная очистка истории — используется кнопкой "Очистить все данные" в настройках. */
    @Query("DELETE FROM entries")
    suspend fun deleteAll()
}
KOTLIN_EOF_DAO
echo "OK: app/src/main/java/com/example/fa_ksiegowy/EntryDao.kt"

# --- 2) EntryAdapter.kt: добавляем клик по элементу (для перехода в редактирование) ---
mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/EntryAdapter.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/EntryAdapter.kt << 'KOTLIN_EOF_ADAPTER'
package com.example.fa_ksiegowy
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView

class EntryAdapter(
    private val items: List<Entry>,
    private val onItemClick: (Entry) -> Unit = {}
) : RecyclerView.Adapter<EntryAdapter.VH>() {
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
        // Тап по записи — открыть её на редактирование/удаление (см. AddEntryActivity).
        holder.itemView.setOnClickListener { onItemClick(e) }
    }
    override fun getItemCount(): Int = items.size
}
KOTLIN_EOF_ADAPTER
echo "OK: app/src/main/java/com/example/fa_ksiegowy/EntryAdapter.kt"

# --- 3) HistoryActivity.kt: клик по записи открывает её в AddEntryActivity ---
mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/HistoryActivity.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/HistoryActivity.kt << 'KOTLIN_EOF_HISTORY'
package com.example.fa_ksiegowy

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/** Отдельный экран с полной историей операций (перенесено с главного экрана). */
class HistoryActivity : BaseActivity() {
    private lateinit var db: AppDatabase

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_history)
        db = AppDatabase.getInstance(this)

        findViewById<RecyclerView>(R.id.rv_history).layoutManager = LinearLayoutManager(this)
        loadData()
    }

    override fun onResume() {
        super.onResume()
        // Обновляем список при каждом возврате на экран — например, после редактирования
        // или удаления записи в AddEntryActivity.
        loadData()
    }

    private fun loadData() {
        CoroutineScope(Dispatchers.IO).launch {
            val allEntries = db.entryDao().getAll()
            withContext(Dispatchers.Main) {
                findViewById<RecyclerView>(R.id.rv_history).adapter = EntryAdapter(allEntries) { entry ->
                    startActivity(
                        Intent(this@HistoryActivity, AddEntryActivity::class.java)
                            .putExtra("entryId", entry.id)
                            .putExtra("isIncome", entry.isIncome)
                    )
                }
                findViewById<View>(R.id.tv_no_entries).visibility =
                    if (allEntries.isEmpty()) View.VISIBLE else View.GONE
            }
        }
    }
}
KOTLIN_EOF_HISTORY
echo "OK: app/src/main/java/com/example/fa_ksiegowy/HistoryActivity.kt"

# --- 4) drawable для "опасных" кнопок (удалить / очистить всё) ---
mkdir -p "$(dirname "app/src/main/res/drawable/btn_pill_danger.xml")"
cat > app/src/main/res/drawable/btn_pill_danger.xml << 'XML_EOF_DANGER'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <corners android:radius="24dp" />
    <solid android:color="#3A1020" />
    <stroke android:width="1dp" android:color="#FF5B5B" />
</shape>
XML_EOF_DANGER
echo "OK: app/src/main/res/drawable/btn_pill_danger.xml"

# --- 5) activity_add_entry.xml: переключатель типа (доход/расход) + кнопка удаления ---
mkdir -p "$(dirname "app/src/main/res/layout/activity_add_entry.xml")"
cat > app/src/main/res/layout/activity_add_entry.xml << 'XML_EOF_ADD_ENTRY'
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
        android:layout_marginBottom="20dp"
        android:text="@string/add_expense"
        android:textColor="@color/accent_cyan"
        android:textSize="26sp"
        android:textStyle="bold"/>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:layout_marginBottom="20dp"
        android:weightSum="2" android:baselineAligned="false">

        <Button
            android:id="@+id/btn_type_income"
            android:layout_width="0dp"
            android:layout_height="48dp"
            android:layout_weight="1"
            android:layout_marginEnd="8dp"
            android:background="@drawable/btn_pill_primary"
            android:text="@string/type_income"
            android:textAllCaps="false"
            android:textColor="@color/text_primary"
            android:textSize="14sp"/>

        <Button
            android:id="@+id/btn_type_expense"
            android:layout_width="0dp"
            android:layout_height="48dp"
            android:layout_weight="1"
            android:layout_marginStart="8dp"
            android:background="@drawable/btn_pill_outline"
            android:text="@string/type_expense"
            android:textAllCaps="false"
            android:textColor="@color/text_primary"
            android:textSize="14sp"/>

    </LinearLayout>

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
        android:id="@+id/btn_delete"
        android:layout_width="match_parent"
        android:layout_height="52dp"
        android:layout_marginBottom="12dp"
        android:background="@drawable/btn_pill_danger"
        android:text="@string/delete_entry"
        android:textAllCaps="false"
        android:textColor="@color/text_primary"
        android:textSize="15sp"
        android:visibility="gone"/>

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
XML_EOF_ADD_ENTRY
echo "OK: app/src/main/res/layout/activity_add_entry.xml"

# --- 6) AddEntryActivity.kt: поддержка редактирования, смены типа и удаления записи ---
mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/AddEntryActivity.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/AddEntryActivity.kt << 'KOTLIN_EOF_ADD_ENTRY_ACT'
package com.example.fa_ksiegowy

import android.app.AlertDialog
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream

/**
 * Экран добавления ИЛИ редактирования операции.
 * Если в intent передан "entryId" (id существующей записи) — режим редактирования:
 * поля предзаполняются, появляется кнопка удаления, а сохранение обновляет запись
 * вместо создания новой. Без "entryId" работает как раньше — создание новой записи.
 */
class AddEntryActivity : BaseActivity() {
    private var selectedImagePath: String? = null
    private var editingEntry: Entry? = null
    private var currentIsIncome: Boolean = true

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

        val entryId = intent.getLongExtra("entryId", -1L)
        currentIsIncome = intent.getBooleanExtra("isIncome", true)

        setupTypeToggle()
        findViewById<Button>(R.id.btn_attach).setOnClickListener { pickImage.launch("image/*") }
        findViewById<Button>(R.id.btn_delete).setOnClickListener { confirmDelete() }

        updateTypeToggleUi()
        updateTitle()

        if (entryId != -1L) {
            findViewById<Button>(R.id.btn_delete).visibility = View.VISIBLE
            CoroutineScope(Dispatchers.IO).launch {
                val entry = AppDatabase.getInstance(applicationContext).entryDao().getById(entryId)
                withContext(Dispatchers.Main) {
                    if (entry == null) {
                        Toast.makeText(this@AddEntryActivity, "Запись не найдена", Toast.LENGTH_SHORT).show()
                        finish()
                        return@withContext
                    }
                    editingEntry = entry
                    currentIsIncome = entry.isIncome
                    findViewById<EditText>(R.id.et_amount).setText(formatAmount(entry.amount))
                    findViewById<EditText>(R.id.et_comment).setText(entry.comment ?: "")
                    selectedImagePath = entry.receiptPath
                    if (entry.receiptPath != null) {
                        findViewById<Button>(R.id.btn_attach).text = getString(R.string.attach_receipt) + " ✓"
                    }
                    updateTypeToggleUi()
                    updateTitle()
                }
            }
        }

        findViewById<Button>(R.id.btn_save).setOnClickListener {
            val amt = findViewById<EditText>(R.id.et_amount).text.toString().toDoubleOrNull()
            if (amt == null || amt <= 0.0) {
                Toast.makeText(this, "Введите корректную сумму", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            val comment = findViewById<EditText>(R.id.et_comment).text.toString()
            findViewById<Button>(R.id.btn_save).isEnabled = false

            val existing = editingEntry
            CoroutineScope(Dispatchers.IO).launch {
                val dao = AppDatabase.getInstance(applicationContext).entryDao()
                if (existing != null) {
                    dao.update(
                        existing.copy(
                            amount = amt,
                            isIncome = currentIsIncome,
                            comment = comment,
                            receiptPath = selectedImagePath
                        )
                    )
                } else {
                    dao.insert(
                        Entry(
                            amount = amt,
                            isIncome = currentIsIncome,
                            comment = comment,
                            dateMillis = System.currentTimeMillis(),
                            receiptPath = selectedImagePath
                        )
                    )
                }
                withContext(Dispatchers.Main) {
                    Toast.makeText(
                        this@AddEntryActivity,
                        getString(if (existing != null) R.string.entry_updated else R.string.saved),
                        Toast.LENGTH_SHORT
                    ).show()
                    finish()
                }
            }
        }
    }

    private fun setupTypeToggle() {
        findViewById<Button>(R.id.btn_type_income).setOnClickListener {
            currentIsIncome = true
            updateTypeToggleUi()
            updateTitle()
        }
        findViewById<Button>(R.id.btn_type_expense).setOnClickListener {
            currentIsIncome = false
            updateTypeToggleUi()
            updateTitle()
        }
    }

    private fun updateTypeToggleUi() {
        val income = findViewById<Button>(R.id.btn_type_income)
        val expense = findViewById<Button>(R.id.btn_type_expense)
        income.setBackgroundResource(if (currentIsIncome) R.drawable.btn_pill_primary else R.drawable.btn_pill_outline)
        expense.setBackgroundResource(if (!currentIsIncome) R.drawable.btn_pill_primary else R.drawable.btn_pill_outline)
    }

    private fun updateTitle() {
        val isEditing = editingEntry != null
        val titleRes = when {
            isEditing && currentIsIncome -> R.string.edit_income_title
            isEditing && !currentIsIncome -> R.string.edit_expense_title
            currentIsIncome -> R.string.add_income
            else -> R.string.add_expense
        }
        findViewById<TextView>(R.id.tv_add_title).text = getString(titleRes)
    }

    private fun confirmDelete() {
        val entry = editingEntry ?: return
        AlertDialog.Builder(this)
            .setTitle(getString(R.string.delete_confirm_title))
            .setMessage(getString(R.string.delete_confirm_message))
            .setPositiveButton(getString(R.string.delete_confirm_yes)) { _, _ ->
                CoroutineScope(Dispatchers.IO).launch {
                    AppDatabase.getInstance(applicationContext).entryDao().delete(entry)
                    withContext(Dispatchers.Main) {
                        Toast.makeText(this@AddEntryActivity, getString(R.string.entry_deleted), Toast.LENGTH_SHORT).show()
                        finish()
                    }
                }
            }
            .setNegativeButton(getString(R.string.dialog_close), null)
            .show()
    }

    /** Без лишних нулей для целых сумм (100, а не 100.0), но с сохранением копеек, если они есть. */
    private fun formatAmount(v: Double): String =
        if (v == v.toLong().toDouble()) v.toLong().toString() else v.toString()
}
KOTLIN_EOF_ADD_ENTRY_ACT
echo "OK: app/src/main/java/com/example/fa_ksiegowy/AddEntryActivity.kt"

# --- 7) activity_settings.xml: добавляем секцию "Очистить все данные" перед "О приложении" ---
SETTINGS_LAYOUT="app/src/main/res/layout/activity_settings.xml"
if [ -f "$SETTINGS_LAYOUT" ] && ! grep -q 'btn_clear_all' "$SETTINGS_LAYOUT"; then
    python3 - "$SETTINGS_LAYOUT" << 'PY_EOF_SETTINGS_LAYOUT'
import sys
path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    content = f.read()

marker = '    <Button android:id="@+id/btn_about"'
insert = (
    '    <Button android:id="@+id/btn_clear_all" android:layout_width="match_parent" android:layout_height="52dp"\n'
    '        android:text="@string/clear_all_button" android:textAllCaps="false" android:textColor="@color/text_primary"\n'
    '        android:background="@drawable/btn_pill_danger" android:layout_marginBottom="24dp"/>\n'
    '\n'
    '    <View android:layout_width="match_parent" android:layout_height="1dp"\n'
    '        android:background="#2A2E60" android:layout_marginBottom="20dp"/>\n'
    '\n'
)
if marker not in content:
    print("!!! Не нашёл кнопку btn_about в activity_settings.xml — проверь вручную")
    sys.exit(1)
content = content.replace(marker, insert + marker)
with open(path, "w", encoding="utf-8") as f:
    f.write(content)
print("OK: секция очистки данных добавлена в activity_settings.xml")
PY_EOF_SETTINGS_LAYOUT
else
    echo "-- activity_settings.xml уже содержит btn_clear_all (или файл не найден), пропускаю"
fi

# --- 8) SettingsActivity.kt: обработчик кнопки очистки всех данных ---
SETTINGS_ACT="app/src/main/java/com/example/fa_ksiegowy/SettingsActivity.kt"
if [ -f "$SETTINGS_ACT" ] && ! grep -q 'btn_clear_all' "$SETTINGS_ACT"; then
    python3 - "$SETTINGS_ACT" << 'PY_EOF_SETTINGS_ACT'
import sys
path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    content = f.read()

marker = '        findViewById<Button>(R.id.btn_about).setOnClickListener {'
insert = (
    '        findViewById<Button>(R.id.btn_clear_all).setOnClickListener {\n'
    '            confirmClearAll()\n'
    '        }\n'
    '\n'
)
if marker not in content:
    print("!!! Не нашёл обработчик btn_about в SettingsActivity.kt — проверь вручную")
    sys.exit(1)
content = content.replace(marker, insert + marker)

# Добавляем метод confirmClearAll перед закрывающей скобкой класса (после setLocale)
old_tail = (
    '    private fun setLocale(code: String) {\n'
    '        LocaleHelper.setLanguage(this, code)\n'
    '        val intent = Intent(this, MineActivity::class.java)\n'
    '        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)\n'
    '        startActivity(intent)\n'
    '        finishAffinity()\n'
    '    }\n'
    '}\n'
)
new_tail = (
    '    private fun setLocale(code: String) {\n'
    '        LocaleHelper.setLanguage(this, code)\n'
    '        val intent = Intent(this, MineActivity::class.java)\n'
    '        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)\n'
    '        startActivity(intent)\n'
    '        finishAffinity()\n'
    '    }\n'
    '\n'
    '    /** Необратимо удаляет все доходы/расходы (и связанные чеки на диске не трогает,\n'
    '     *  только записи в базе — сами файлы чеков останутся в getExternalFilesDir). */\n'
    '    private fun confirmClearAll() {\n'
    '        AlertDialog.Builder(this)\n'
    '            .setTitle(getString(R.string.clear_all_confirm_title))\n'
    '            .setMessage(getString(R.string.clear_all_confirm_message))\n'
    '            .setPositiveButton(getString(R.string.clear_all_confirm_yes)) { _, _ ->\n'
    '                CoroutineScope(Dispatchers.IO).launch {\n'
    '                    AppDatabase.getInstance(applicationContext).entryDao().deleteAll()\n'
    '                    withContext(Dispatchers.Main) {\n'
    '                        Toast.makeText(this@SettingsActivity, getString(R.string.clear_all_done), Toast.LENGTH_SHORT).show()\n'
    '                    }\n'
    '                }\n'
    '            }\n'
    '            .setNegativeButton(getString(R.string.dialog_close), null)\n'
    '            .show()\n'
    '    }\n'
    '}\n'
)
if old_tail not in content:
    print("!!! Не нашёл метод setLocale в ожидаемом виде — добавь confirmClearAll() вручную")
    sys.exit(1)
content = content.replace(old_tail, new_tail)

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
print("OK: SettingsActivity.kt обновлён (кнопка очистки всех данных)")
PY_EOF_SETTINGS_ACT
else
    echo "-- SettingsActivity.kt уже содержит btn_clear_all (или файл не найден), пропускаю"
fi

# --- 9) Строки локализации ---
add_strings_block() {
    local file="$1"
    local block="$2"
    if [ -f "$file" ] && ! grep -q 'name="type_income"' "$file"; then
        python3 - "$file" << PY_EOF_INSERT
import sys
path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    content = f.read()
block = '''$block'''
content = content.replace("</resources>", block + "</resources>")
with open(path, "w", encoding="utf-8") as f:
    f.write(content)
PY_EOF_INSERT
        echo "OK: строки добавлены в $file"
    else
        echo "-- строки уже есть или файл не найден: $file"
    fi
}

add_strings_block "app/src/main/res/values/strings.xml" '    <string name="type_income">Income</string>
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
'

add_strings_block "app/src/main/res/values-ru/strings.xml" '    <string name="type_income">Доход</string>
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
'

add_strings_block "app/src/main/res/values-pl/strings.xml" '    <string name="type_income">Przychód</string>
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
'

echo ""
echo "=== Готово ==="
echo "1) Тап по записи в 'Истории операций' открывает её для редактирования"
echo "   (можно поменять сумму, комментарий, тип доход/расход, чек, либо удалить запись)."
echo "2) В настройках появилась кнопка 'Очистить все данные' с подтверждением —"
echo "   безвозвратно удаляет все доходы и расходы."
