#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Обновление: подстановка реальных AdMob ID вместо тестовых ==="

REAL_APP_ID="ca-app-pub-9218963926031039~6835956339"
REAL_BANNER_UNIT_ID="ca-app-pub-9218963926031039/4293553475"

MANIFEST="app/src/main/AndroidManifest.xml"
LAYOUT="app/src/main/res/layout/activity_mine.xml"

if [ ! -f "$MANIFEST" ]; then
    echo "!!! Не найден $MANIFEST — сначала примени update_project-9-billing-ads.sh"
    exit 1
fi
if [ ! -f "$LAYOUT" ]; then
    echo "!!! Не найден $LAYOUT — сначала примени update_project-9-billing-ads.sh"
    exit 1
fi

# --- App ID в манифесте ---
if grep -q "ca-app-pub-3940256099942544~3347511713" "$MANIFEST"; then
    sed -i "s|ca-app-pub-3940256099942544~3347511713|${REAL_APP_ID}|g" "$MANIFEST"
    echo "OK: App ID заменён в $MANIFEST"
elif grep -q "$REAL_APP_ID" "$MANIFEST"; then
    echo "-- App ID уже реальный, пропускаю"
else
    echo "!!! Не нашёл тестовый App ID в $MANIFEST — проверь файл вручную"
fi

# --- Ad Unit ID в layout баннера ---
if grep -q "ca-app-pub-3940256099942544/6300978111" "$LAYOUT"; then
    sed -i "s|ca-app-pub-3940256099942544/6300978111|${REAL_BANNER_UNIT_ID}|g" "$LAYOUT"
    echo "OK: Ad Unit ID заменён в $LAYOUT"
elif grep -q "$REAL_BANNER_UNIT_ID" "$LAYOUT"; then
    echo "-- Ad Unit ID уже реальный, пропускаю"
else
    echo "!!! Не нашёл тестовый Ad Unit ID в $LAYOUT — проверь файл вручную"
fi

echo ""
echo "=== Готово ==="
echo "App ID:      $REAL_APP_ID"
echo "Ad Unit ID:  $REAL_BANNER_UNIT_ID"
echo ""
echo "ВАЖНО:"
echo "1) Реклама в AdMob обычно начинает показываться боевыми объявлениями не сразу"
echo "   (может пройти до 24-48 часов) — первое время может показываться пусто, это нормально."
echo "2) Перед публикацией собери release-сборку и проверь, что баннер реально грузится"
echo "   на реальном устройстве (не в эмуляторе с тестовым Google-аккаунтом)."
echo "3) Не кликай сам по своей рекламе и не проси об этом других — Google банит аккаунт за инвалид-трафик."
