#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Оставшиеся шаги: постоянный debug-keystore + коммит/пуш ==="

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
