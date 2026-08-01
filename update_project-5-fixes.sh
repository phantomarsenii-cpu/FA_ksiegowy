#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Исправления: локализация 'О приложении' + имя FinArs во всех языках ==="

python3 - << 'PYEOF'
import re

# -----------------------------------------------------------------
# EN (значения по умолчанию, values/strings.xml)
# -----------------------------------------------------------------
path = "app/src/main/res/values/strings.xml"
with open(path, encoding="utf-8") as f:
    content = f.read()

about_en_description = (
    "FinArs is a convenient app for managing the finances of unregistered "
    "business activity. Easily track income and expenses, monitor your "
    "current balance, automatically calculate taxes and generate reports. "
    "The app helps you stay within limits, track financial indicators and "
    "always have the full history of operations at hand. A simple interface "
    "and quick data entry make daily bookkeeping as convenient as possible.\\n\\n"
    "Key features:\\n"
    "💰 Income and expense tracking.\\n"
    "📊 Automatic profit calculation.\\n"
    "🧾 Tax calculation.\\n"
    "📈 Monitoring of unregistered activity limits.\\n"
    "📄 Report generation.\\n"
    "🔍 Full operation history.\\n"
    "🌙 Modern dark interface.\\n"
    "🔒 All data is stored locally on the device.\\n\\n"
    "Contact: p.arsenii@interia.pl"
)

pattern = re.compile(
    r'<string name="about_app">.*?</string>\s*'
    r'<string name="about_description">.*?</string>\s*'
    r'<string name="about_email">.*?</string>',
    re.DOTALL
)
new_block = (
    '<string name="about_app">About the app</string>\n'
    f'    <string name="about_description">{about_en_description}</string>\n'
    '    <string name="about_email">p.arsenii@interia.pl</string>'
)
new_content, n = pattern.subn(new_block, content, count=1)
if n != 1:
    raise SystemExit(f"ERROR: не найден блок about_* в {path}")
content = new_content
with open(path, "w", encoding="utf-8") as f:
    f.write(content)
print("OK: values/strings.xml (EN) — about-текст переведён на английский")

# -----------------------------------------------------------------
# RU (values-ru/strings.xml)
# -----------------------------------------------------------------
path = "app/src/main/res/values-ru/strings.xml"
with open(path, encoding="utf-8") as f:
    content = f.read()

old_name = '<string name="app_name">F.A księgowy</string>'
if old_name in content:
    content = content.replace(old_name, '<string name="app_name">FinArs</string>')
    print("OK: values-ru/strings.xml — app_name -> FinArs")

if 'name="about_app"' not in content:
    about_ru_description = (
        "FinArs — удобное приложение для ведения финансов нерегистрируемой "
        "деятельности. Легко учитывайте доходы и расходы, контролируйте "
        "текущий баланс, автоматически рассчитывайте налоги и формируйте "
        "отчёты. Приложение помогает соблюдать лимиты, отслеживать "
        "финансовые показатели и всегда иметь под рукой полную историю "
        "операций. Простой интерфейс и быстрый ввод данных делают "
        "ежедневный учёт максимально удобным.\\n\\n"
        "Основные возможности:\\n"
        "💰 Учёт доходов и расходов.\\n"
        "📊 Автоматический расчёт прибыли.\\n"
        "🧾 Расчёт налогов.\\n"
        "📈 Контроль лимитов нерегистрируемой деятельности.\\n"
        "📄 Генерация отчётов.\\n"
        "🔍 История всех операций.\\n"
        "🌙 Современный тёмный интерфейс.\\n"
        "🔒 Все данные хранятся локально на устройстве.\\n\\n"
        "Связь: p.arsenii@interia.pl"
    )
    about_block = (
        '    <string name="about_app">О приложении</string>\n'
        f'    <string name="about_description">{about_ru_description}</string>\n'
        '    <string name="about_email">p.arsenii@interia.pl</string>\n'
    )
    marker = "</resources>"
    if marker not in content:
        raise SystemExit(f"ERROR: не найден закрывающий тег resources в {path}")
    content = content.replace(marker, about_block + marker)
    print("OK: values-ru/strings.xml — добавлен русский текст 'О приложении'")

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

# -----------------------------------------------------------------
# PL (values-pl/strings.xml)
# -----------------------------------------------------------------
path = "app/src/main/res/values-pl/strings.xml"
with open(path, encoding="utf-8") as f:
    content = f.read()

old_name = '<string name="app_name">F.A księgowy</string>'
if old_name in content:
    content = content.replace(old_name, '<string name="app_name">FinArs</string>')
    print("OK: values-pl/strings.xml — app_name -> FinArs")

if 'name="about_app"' not in content:
    about_pl_description = (
        "FinArs to wygodna aplikacja do zarządzania finansami działalności "
        "nierejestrowanej. Łatwo śledź przychody i wydatki, kontroluj "
        "bieżący bilans, automatycznie obliczaj podatki i generuj raporty. "
        "Aplikacja pomaga przestrzegać limitów, śledzić wskaźniki finansowe "
        "i mieć zawsze pod ręką pełną historię operacji. Prosty interfejs i "
        "szybkie wprowadzanie danych sprawiają, że codzienna księgowość "
        "jest maksymalnie wygodna.\\n\\n"
        "Główne funkcje:\\n"
        "💰 Ewidencja przychodów i wydatków.\\n"
        "📊 Automatyczne obliczanie zysku.\\n"
        "🧾 Obliczanie podatków.\\n"
        "📈 Kontrola limitów działalności nierejestrowanej.\\n"
        "📄 Generowanie raportów.\\n"
        "🔍 Historia wszystkich operacji.\\n"
        "🌙 Nowoczesny ciemny interfejs.\\n"
        "🔒 Wszystkie dane są przechowywane lokalnie na urządzeniu.\\n\\n"
        "Kontakt: p.arsenii@interia.pl"
    )
    about_block = (
        '    <string name="about_app">O aplikacji</string>\n'
        f'    <string name="about_description">{about_pl_description}</string>\n'
        '    <string name="about_email">p.arsenii@interia.pl</string>\n'
    )
    marker = "</resources>"
    if marker not in content:
        raise SystemExit(f"ERROR: не найден закрывающий тег resources в {path}")
    content = content.replace(marker, about_block + marker)
    print("OK: values-pl/strings.xml — добавлен польский текст 'O aplikacji'")

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
PYEOF

echo "--- Готово, коммичу и пушу ---"

git add .
git commit -m "Localize About screen (EN/RU/PL) and fix FinArs app name in all language files"
git push
