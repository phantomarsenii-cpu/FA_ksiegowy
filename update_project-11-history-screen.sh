#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Обновление: отдельный экран 'История операций' вместо списка на главной ==="

# --- 1) Новый layout экрана истории ---
mkdir -p "$(dirname "app/src/main/res/layout/activity_history.xml")"
cat > app/src/main/res/layout/activity_history.xml << 'XML_EOF_HIST_LAYOUT'
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
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="@string/transaction_history"
        android:textSize="22sp"
        android:textStyle="bold"
        android:textColor="@color/accent_cyan"
        android:layout_marginBottom="20dp"/>

    <TextView
        android:id="@+id/tv_no_entries"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="@string/no_entries"
        android:textColor="@color/text_secondary"
        android:textSize="15sp"
        android:visibility="gone"
        android:layout_marginTop="40dp"
        android:gravity="center"/>

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/rv_history"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:clipToPadding="false"/>

</LinearLayout>
XML_EOF_HIST_LAYOUT
echo "OK: app/src/main/res/layout/activity_history.xml"

# --- 2) Новая Activity истории ---
mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/HistoryActivity.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/HistoryActivity.kt << 'KOTLIN_EOF_HIST_ACT'
package com.example.fa_ksiegowy

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
        loadData()
    }

    private fun loadData() {
        CoroutineScope(Dispatchers.IO).launch {
            val allEntries = db.entryDao().getAll()
            withContext(Dispatchers.Main) {
                findViewById<RecyclerView>(R.id.rv_history).adapter = EntryAdapter(allEntries)
                findViewById<View>(R.id.tv_no_entries).visibility =
                    if (allEntries.isEmpty()) View.VISIBLE else View.GONE
            }
        }
    }
}
KOTLIN_EOF_HIST_ACT
echo "OK: app/src/main/java/com/example/fa_ksiegowy/HistoryActivity.kt"

# --- 3) activity_mine.xml: убираем RecyclerView, добавляем кнопку "История операций" ---
MINE_LAYOUT="app/src/main/res/layout/activity_mine.xml"
if [ ! -f "$MINE_LAYOUT" ]; then
    echo "!!! Не найден $MINE_LAYOUT"
    exit 1
fi

python3 - "$MINE_LAYOUT" << 'PY_EOF_MINE_LAYOUT'
import re, sys
path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    content = f.read()

if 'id="@+id/rv_entries"' in content:
    # Удаляем блок RecyclerView со списком операций целиком
    content = re.sub(
        r'\n\s*<androidx\.recyclerview\.widget\.RecyclerView\s+android:id="@\+id/rv_entries".*?/>\n',
        '\n',
        content,
        flags=re.DOTALL,
    )
    print("OK: RecyclerView rv_entries удалён из activity_mine.xml")
else:
    print("-- RecyclerView rv_entries уже отсутствует, пропускаю")

if 'id="@+id/btn_history"' not in content:
    # Добавляем кнопку "История операций" сразу после кнопки "Добавить расход"
    marker = 'android:text="@string/add_expense"'
    idx = content.find(marker)
    if idx == -1:
        print("!!! Не нашёл кнопку add_expense — вставь btn_history вручную")
    else:
        # находим конец тега <Button ... /> кнопки add_expense
        end = content.find('/>', idx) + 2
        button_xml = (
            '\n\n    <Button\n'
            '        android:id="@+id/btn_history"\n'
            '        android:layout_width="match_parent"\n'
            '        android:layout_height="56dp"\n'
            '        android:layout_marginBottom="20dp"\n'
            '        android:background="@drawable/btn_pill_outline"\n'
            '        android:text="@string/transaction_history"\n'
            '        android:textAllCaps="false"\n'
            '        android:textColor="@color/text_primary"\n'
            '        android:textSize="16sp"/>'
        )
        content = content[:end] + button_xml + content[end:]
        print("OK: кнопка btn_history добавлена в activity_mine.xml")
else:
    print("-- Кнопка btn_history уже есть, пропускаю")

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
PY_EOF_MINE_LAYOUT

# --- 4) MineActivity.kt: убираем работу с rv_entries/EntryAdapter, добавляем переход на HistoryActivity ---
MINE_ACT="app/src/main/java/com/example/fa_ksiegowy/MineActivity.kt"
if [ ! -f "$MINE_ACT" ]; then
    echo "!!! Не найден $MINE_ACT"
    exit 1
fi

python3 - "$MINE_ACT" << 'PY_EOF_MINE_ACT'
import re, sys
path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    content = f.read()

changed = False

if "findViewById<RecyclerView>(R.id.rv_entries).layoutManager" in content:
    content = content.replace(
        '\n        findViewById<RecyclerView>(R.id.rv_entries).layoutManager = LinearLayoutManager(this)\n',
        '\n'
    )
    changed = True

if 'findViewById<Button>(R.id.btn_history)' not in content:
    content = content.replace(
        'findViewById<Button>(R.id.btn_reports).setOnClickListener {\n            startActivity(Intent(this, ReportActivity::class.java))\n        }\n',
        'findViewById<Button>(R.id.btn_reports).setOnClickListener {\n            startActivity(Intent(this, ReportActivity::class.java))\n        }\n        findViewById<Button>(R.id.btn_history).setOnClickListener {\n            startActivity(Intent(this, HistoryActivity::class.java))\n        }\n'
    )
    changed = True

# Список операций больше не грузим и не показываем на главном экране,
# он используется только в HistoryActivity.
content = content.replace(
    '            // Полная история — для списка операций (не ограничена годом).\n            val allEntries = db.entryDao().getAll()\n\n            // Баланс/статистика/налог — только за текущий календарный год,',
    '            // Баланс/статистика/налог — только за текущий календарный год,'
)
content = content.replace(
    '\n                findViewById<RecyclerView>(R.id.rv_entries).adapter = EntryAdapter(allEntries)',
    ''
)

# Импорты RecyclerView/LinearLayoutManager больше не нужны в MineActivity
content = content.replace('import androidx.recyclerview.widget.LinearLayoutManager\n', '')
content = content.replace('import androidx.recyclerview.widget.RecyclerView\n', '')

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print("OK: MineActivity.kt обновлён" if changed else "-- MineActivity.kt: изменения уже применены")
PY_EOF_MINE_ACT

# --- 5) AndroidManifest.xml: регистрируем HistoryActivity ---
MANIFEST="app/src/main/AndroidManifest.xml"
if [ ! -f "$MANIFEST" ]; then
    echo "!!! Не найден $MANIFEST"
    exit 1
fi
if ! grep -q '\.HistoryActivity' "$MANIFEST"; then
    sed -i 's#<activity android:name="\.ReportActivity" android:exported="false" />#<activity android:name=".ReportActivity" android:exported="false" />\n        <activity android:name=".HistoryActivity" android:exported="false" />#' "$MANIFEST"
    echo "OK: HistoryActivity зарегистрирована в $MANIFEST"
else
    echo "-- HistoryActivity уже в манифесте, пропускаю"
fi

# --- 6) Строки локализации ---
add_string_if_missing() {
    local file="$1"
    local line="$2"
    if [ -f "$file" ] && ! grep -q 'name="transaction_history"' "$file"; then
        # Вставляем перед закрывающим </resources>
        sed -i "s#</resources>#    ${line}\n</resources>#" "$file"
        echo "OK: строка добавлена в $file"
    else
        echo "-- строка уже есть или файл не найден: $file"
    fi
}

add_string_if_missing "app/src/main/res/values/strings.xml" '<string name="transaction_history">Transaction history</string>'
add_string_if_missing "app/src/main/res/values-ru/strings.xml" '<string name="transaction_history">История операций</string>'
add_string_if_missing "app/src/main/res/values-pl/strings.xml" '<string name="transaction_history">Historia transakcji</string>'

echo ""
echo "=== Готово ==="
echo "Главный экран теперь без списка операций. Кнопка 'История операций' открывает HistoryActivity"
echo "со всей историей (используется тот же EntryAdapter, что и раньше)."
