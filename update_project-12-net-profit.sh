#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Обновление: показывать чистую прибыль (после вычета налога) ==="

MINE_LAYOUT="app/src/main/res/layout/activity_mine.xml"
MINE_ACT="app/src/main/java/com/example/fa_ksiegowy/MineActivity.kt"

if [ ! -f "$MINE_LAYOUT" ] || [ ! -f "$MINE_ACT" ]; then
    echo "!!! Не найдены основные файлы (activity_mine.xml / MineActivity.kt)"
    exit 1
fi

# --- 1) Layout: переименовываем "Zysk" в "Zysk (brutto)" (через строку stat_profit)
#         и добавляем отдельную строку "Zysk netto" после строки налога ---
python3 - "$MINE_LAYOUT" << 'PY_EOF_LAYOUT'
import re, sys
path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    content = f.read()

if 'id="@+id/tv_stat_net_profit"' not in content:
    old_tax_block = (
        '        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"\n'
        '            android:orientation="horizontal">\n'
        '            <TextView android:id="@+id/tv_stat_tax_label" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1"\n'
        '                android:textColor="@color/text_secondary" android:textSize="15sp"/>\n'
        '            <TextView android:id="@+id/tv_stat_tax" android:layout_width="wrap_content" android:layout_height="wrap_content"\n'
        '                android:textColor="@color/text_secondary" android:textSize="15sp" android:textStyle="bold"/>\n'
        '        </LinearLayout>\n'
    )
    new_block = (
        '        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"\n'
        '            android:orientation="horizontal" android:layout_marginBottom="8dp">\n'
        '            <TextView android:id="@+id/tv_stat_tax_label" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1"\n'
        '                android:textColor="@color/text_secondary" android:textSize="15sp"/>\n'
        '            <TextView android:id="@+id/tv_stat_tax" android:layout_width="wrap_content" android:layout_height="wrap_content"\n'
        '                android:textColor="@color/text_secondary" android:textSize="15sp" android:textStyle="bold"/>\n'
        '        </LinearLayout>\n'
        '\n'
        '        <View android:layout_width="match_parent" android:layout_height="1dp"\n'
        '            android:background="#2A2E60" android:layout_marginTop="6dp" android:layout_marginBottom="10dp"/>\n'
        '\n'
        '        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"\n'
        '            android:orientation="horizontal">\n'
        '            <TextView android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1"\n'
        '                android:text="@string/stat_net_profit" android:textColor="@color/text_primary" android:textSize="16sp" android:textStyle="bold"/>\n'
        '            <TextView android:id="@+id/tv_stat_net_profit" android:layout_width="wrap_content" android:layout_height="wrap_content"\n'
        '                android:textColor="@color/accent_cyan" android:textSize="16sp" android:textStyle="bold"/>\n'
        '        </LinearLayout>\n'
    )
    if old_tax_block not in content:
        print("!!! Не нашёл блок налога в ожидаемом виде — проверь activity_mine.xml вручную")
    else:
        content = content.replace(old_tax_block, new_block)
        print("OK: добавлена строка 'Zysk netto' в activity_mine.xml")
else:
    print("-- строка 'Zysk netto' уже есть в activity_mine.xml, пропускаю")

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
PY_EOF_LAYOUT

# --- 2) MineActivity.kt: считаем и показываем чистую прибыль (прибыль минус налог) ---
python3 - "$MINE_ACT" << 'PY_EOF_ACT'
import sys
path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    content = f.read()

old = '                findViewById<TextView>(R.id.tv_stat_tax).text = formatMoney(taxResult.tax)\n'
new = (
    '                findViewById<TextView>(R.id.tv_stat_tax).text = formatMoney(taxResult.tax)\n'
    '                // Чистая прибыль = прибыль минус налог, рассчитанный TaxHelper\n'
    '                // (с учётом годового лимита и прочих доходов из настроек).\n'
    '                findViewById<TextView>(R.id.tv_stat_net_profit).text = formatMoney(profit - taxResult.tax)\n'
)

if 'tv_stat_net_profit' not in content:
    if old not in content:
        print("!!! Не нашёл ожидаемую строку с tv_stat_tax в MineActivity.kt — проверь вручную")
    else:
        content = content.replace(old, new)
        print("OK: MineActivity.kt считает и показывает чистую прибыль")
else:
    print("-- MineActivity.kt уже обновлён, пропускаю")

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
PY_EOF_ACT

# --- 3) Строки локализации: "Zysk" -> "Zysk (brutto)" + новая строка "Zysk netto" ---
update_strings() {
    local file="$1"
    local gross_line="$2"
    local net_line="$3"
    if [ ! -f "$file" ]; then
        echo "-- файл не найден: $file"
        return
    fi
    # Уточняем подпись валовой прибыли (если ещё не уточнена)
    python3 - "$file" "$gross_line" << 'PY_EOF_STR'
import sys
path, gross_line = sys.argv[1], sys.argv[2]
with open(path, encoding="utf-8") as f:
    content = f.read()
import re
content = re.sub(r'<string name="stat_profit">.*?</string>', gross_line, content)
with open(path, "w", encoding="utf-8") as f:
    f.write(content)
PY_EOF_STR
    if ! grep -q 'name="stat_net_profit"' "$file"; then
        sed -i "s#</resources>#    ${net_line}\n</resources>#" "$file"
        echo "OK: строки обновлены в $file"
    else
        echo "-- stat_net_profit уже есть в $file, пропускаю"
    fi
}

update_strings "app/src/main/res/values/strings.xml" \
    '<string name="stat_profit">Profit (gross)</string>' \
    '<string name="stat_net_profit">Net profit (after tax)</string>'

update_strings "app/src/main/res/values-ru/strings.xml" \
    '<string name="stat_profit">Прибыль (до налога)</string>' \
    '<string name="stat_net_profit">Чистая прибыль (после налога)</string>'

update_strings "app/src/main/res/values-pl/strings.xml" \
    '<string name="stat_profit">Zysk (brutto)</string>' \
    '<string name="stat_net_profit">Zysk netto (po podatku)</string>'

echo ""
echo "=== Готово ==="
echo "На главном экране теперь: Приход, Расход, Прибыль (до налога), Налог, разделитель,"
echo "и Чистая прибыль (после налога) = Прибыль - Налог."
