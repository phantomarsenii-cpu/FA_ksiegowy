#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Обновление: главный экран в ScrollView (чтобы низ не обрезался) ==="

MINE_LAYOUT="app/src/main/res/layout/activity_mine.xml"
if [ ! -f "$MINE_LAYOUT" ]; then
    echo "!!! Не найден $MINE_LAYOUT"
    exit 1
fi

python3 - "$MINE_LAYOUT" << 'PY_EOF_SCROLL'
import sys
path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    content = f.read()

if content.lstrip().startswith("<ScrollView"):
    print("-- activity_mine.xml уже обёрнут в ScrollView, пропускаю")
else:
    old_header = (
        '<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"\n'
        '    xmlns:app="http://schemas.android.com/apk/res-auto"\n'
        '    android:orientation="vertical"\n'
        '    android:layout_width="match_parent"\n'
        '    android:layout_height="match_parent"\n'
        '    android:paddingStart="24dp"\n'
        '    android:paddingEnd="24dp"\n'
        '    android:paddingTop="36dp"\n'
        '    android:paddingBottom="16dp">\n'
    )
    new_header = (
        '<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"\n'
        '    xmlns:app="http://schemas.android.com/apk/res-auto"\n'
        '    android:layout_width="match_parent"\n'
        '    android:layout_height="match_parent"\n'
        '    android:fillViewport="true">\n'
        '\n'
        '<LinearLayout\n'
        '    android:orientation="vertical"\n'
        '    android:layout_width="match_parent"\n'
        '    android:layout_height="wrap_content"\n'
        '    android:paddingStart="24dp"\n'
        '    android:paddingEnd="24dp"\n'
        '    android:paddingTop="36dp"\n'
        '    android:paddingBottom="16dp">\n'
    )

    if old_header not in content:
        print("!!! Не нашёл ожидаемый заголовок корневого LinearLayout — проверь activity_mine.xml вручную")
        sys.exit(1)

    content = content.replace(old_header, new_header, 1)

    # Закрывающий тег последнего элемента в файле — это закрытие корневого LinearLayout.
    stripped = content.rstrip()
    if not stripped.endswith("</LinearLayout>"):
        print("!!! Файл не заканчивается на </LinearLayout> — проверь activity_mine.xml вручную")
        sys.exit(1)

    content = stripped + "\n</ScrollView>\n"

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print("OK: activity_mine.xml обёрнут в ScrollView")
PY_EOF_SCROLL

echo ""
echo "=== Готово ==="
echo "Главный экран теперь прокручивается, если контент не помещается на экран —"
echo "кнопки 'Ustawienia' / 'Generuj raport' и рекламный баннер больше не будут обрезаться."
