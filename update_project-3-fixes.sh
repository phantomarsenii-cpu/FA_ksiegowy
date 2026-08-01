#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Исправления: кнопка 'Сгенерировать отчёт', расхождение налога, обновление без переустановки ==="

# -----------------------------------------------------------------
# 1) Кнопка "Сгенерировать отчёт" — обрезается при длинном тексте
#    (например на русском/польском). Причина: autoSizeText вместе
#    с layout_height="wrap_content" на некоторых версиях Android
#    неправильно пересчитывает высоту кнопки. Убираем autoSize,
#    ставим фиксированный некрупный размер шрифта и увеличиваем
#    отступы/минимальную высоту, чтобы 2 строки текста помещались.
# -----------------------------------------------------------------
python3 - << 'PYEOF'
import re
path = "app/src/main/res/layout/activity_mine.xml"
with open(path, encoding="utf-8") as f:
    content = f.read()

old_block_re = re.compile(
    r'<Button\s+android:id="@\+id/btn_settings".*?/>\s*'
    r'<Button\s+android:id="@\+id/btn_reports".*?/>',
    re.DOTALL
)

new_block = '''<Button
            android:id="@+id/btn_settings"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:minHeight="56dp"
            android:layout_weight="1"
            android:layout_marginEnd="8dp"
            android:background="@drawable/btn_pill_outline"
            android:text="@string/settings"
            android:textAllCaps="false"
            android:textColor="@color/text_primary"
            android:textSize="12sp"
            android:maxLines="2"
            android:includeFontPadding="false"
            android:paddingTop="8dp"
            android:paddingBottom="8dp"
            android:paddingStart="6dp"
            android:paddingEnd="6dp"/>

        <Button
            android:id="@+id/btn_reports"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:minHeight="56dp"
            android:layout_weight="1"
            android:layout_marginStart="8dp"
            android:background="@drawable/btn_pill_outline"
            android:text="@string/generate_report"
            android:textAllCaps="false"
            android:textColor="@color/text_primary"
            android:textSize="12sp"
            android:maxLines="2"
            android:includeFontPadding="false"
            android:paddingTop="8dp"
            android:paddingBottom="8dp"
            android:paddingStart="6dp"
            android:paddingEnd="6dp"/>'''

new_content, n = old_block_re.subn(new_block, content)
if n != 1:
    raise SystemExit(f"ERROR: ожидался 1 заменённый блок в {path}, найдено {n}")

with open(path, "w", encoding="utf-8") as f:
    f.write(new_content)
print("OK: activity_mine.xml — кнопки Settings/Report исправлены")
PYEOF

# -----------------------------------------------------------------
# 2) Расхождение налога между главным экраном и отчётом.
#    На главном экране налог считается от ПРИБЫЛИ (доход - расход).
#    В отчёте налог считался от каждого дохода отдельно (без вычета
#    расходов), поэтому итоговая сумма налога в файле отличалась.
#    Приводим итоговую строку "Итого налог" в отчёте к той же формуле,
#    что и на главном экране (от прибыли).
# -----------------------------------------------------------------
python3 - << 'PYEOF'
import re
path = "app/src/main/java/com/example/fa_ksiegowy/ReportActivity.kt"
with open(path, encoding="utf-8") as f:
    content = f.read()

old = '''                val taxRow = sheet.createRow(rowN)
                taxRow.createCell(0).also { it.setCellValue(getString(R.string.report_total_tax)); it.cellStyle = totalLabelStyle }
                taxRow.createCell(1).also { it.setCellValue(totalTax); it.cellStyle = totalValueStyle }'''

new = '''                // Налог считаем от прибыли (доход - расход), так же как на главном
                // экране приложения, а не от суммы отдельных доходов — иначе итог
                // в отчёте не совпадает с балансом в приложении.
                val totalProfitForTax = totalIncome - totalExpense
                val correctedTotalTax = if (totalProfitForTax > 0) totalProfitForTax * taxPercent / 100.0 else 0.0

                val taxRow = sheet.createRow(rowN)
                taxRow.createCell(0).also { it.setCellValue(getString(R.string.report_total_tax)); it.cellStyle = totalLabelStyle }
                taxRow.createCell(1).also { it.setCellValue(correctedTotalTax); it.cellStyle = totalValueStyle }'''

if old not in content:
    raise SystemExit(f"ERROR: не найден блок для замены в {path}")

content = content.replace(old, new)

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
print("OK: ReportActivity.kt — итоговый налог теперь считается от прибыли")
PYEOF

# -----------------------------------------------------------------
# 3) Чтобы приложение можно было ПРОСТО ОБНОВИТЬ (поверх старой
#    версии), а не удалять и ставить заново — APK должен каждый раз
#    подписываться ОДНИМ И ТЕМ ЖЕ ключом. Если ключ отладки (debug
#    keystore) каждый раз генерируется заново на CI/сборочной машине,
#    подписи не совпадают и Android требует удалить старую версию.
#
#    Решение: держим один и тот же debug-keystore в репозитории и
#    явно указываем его в build.gradle, чтобы каждая сборка
#    подписывалась одинаково.
# -----------------------------------------------------------------
KEYSTORE_PATH="app/debug.keystore"
if [ ! -f "$KEYSTORE_PATH" ]; then
    echo "--- Создаю постоянный debug-keystore (используется во всех последующих сборках) ---"
    keytool -genkeypair -v \
        -keystore "$KEYSTORE_PATH" \
        -alias fa_ksiegowy_debug \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -storepass fa_ksiegowy_debug \
        -keypass fa_ksiegowy_debug \
        -dname "CN=FA Ksiegowy, OU=Dev, O=FA, L=City, S=State, C=PL"
    echo "!!! ВАЖНО: закоммить $KEYSTORE_PATH в git — если он потеряется,"
    echo "    один раз снова придётся переустановить приложение."
else
    echo "--- debug-keystore уже существует, использую его ---"
fi

GRADLE_FILE=""
for f in app/build.gradle app/build.gradle.kts; do
    [ -f "$f" ] && GRADLE_FILE="$f"
done

if [ -z "$GRADLE_FILE" ]; then
    echo "!!! Не найден app/build.gradle(.kts) — добавь signingConfig вручную:"
    echo '    signingConfigs {'
    echo '        debug {'
    echo '            storeFile file("debug.keystore")'
    echo '            storePassword "fa_ksiegowy_debug"'
    echo '            keyAlias "fa_ksiegowy_debug"'
    echo '            keyPassword "fa_ksiegowy_debug"'
    echo '        }'
    echo '    }'
    echo '    buildTypes { debug { signingConfig signingConfigs.debug } }'
else
    if grep -q "fa_ksiegowy_debug" "$GRADLE_FILE"; then
        echo "--- $GRADLE_FILE уже содержит нужный signingConfig, пропускаю ---"
    else
        python3 - "$GRADLE_FILE" << 'PYEOF'
import sys, re
path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    content = f.read()

is_kts = path.endswith(".kts")

if is_kts:
    signing_block = '''
    signingConfigs {
        getByName("debug") {
            storeFile = file("debug.keystore")
            storePassword = "fa_ksiegowy_debug"
            keyAlias = "fa_ksiegowy_debug"
            keyPassword = "fa_ksiegowy_debug"
        }
    }
'''
else:
    signing_block = '''
    signingConfigs {
        debug {
            storeFile file("debug.keystore")
            storePassword "fa_ksiegowy_debug"
            keyAlias "fa_ksiegowy_debug"
            keyPassword "fa_ksiegowy_debug"
        }
    }
'''

m = re.search(r'android\s*\{', content)
if not m:
    raise SystemExit(f"ERROR: не найден блок android {{ в {path}")

insert_at = m.end()
new_content = content[:insert_at] + signing_block + content[insert_at:]

with open(path, "w", encoding="utf-8") as f:
    f.write(new_content)
print(f"OK: {path} — добавлен постоянный signingConfig для debug")
PYEOF
    fi
fi

echo "--- Готово, коммичу и пушу ---"

git add .
git commit -m "Fix report button clipping, fix tax mismatch in report, persist debug signing key for in-place updates"
git push
