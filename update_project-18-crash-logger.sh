#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Обновление 18: диагностика — сохраняем текст краша в Загрузки, чтобы прочитать его через Termux ==="

mkdir -p "$(dirname "app/src/main/java/com/example/fa_ksiegowy/FaApp.kt")"
cat > app/src/main/java/com/example/fa_ksiegowy/FaApp.kt << 'EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_FAAPP_KT'
package com.example.fa_ksiegowy

import android.app.Application
import android.content.ContentValues
import android.content.Context
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import java.io.File
import java.io.FileOutputStream
import java.io.PrintWriter
import java.io.StringWriter
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Application-класс: ставит глобальный обработчик необработанных исключений.
 * Сохраняет полный текст краша (стектрейс) в файл в папке "Загрузки"
 * (finars_crash_ГГГГММДД_ЧЧММСС.txt), чтобы его можно было прочитать через
 * Termux (cat /storage/emulated/0/Download/finars_crash_*.txt) — обычный
 * logcat не показывает логи чужого приложения без прав root.
 *
 * После записи лога вызывается стандартный обработчик системы — поведение
 * приложения при краше (закрытие) не меняется, только добавляется файл.
 */
class FaApp : Application() {

    override fun onCreate() {
        super.onCreate()
        val defaultHandler = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            try {
                saveCrashLog(this, throwable)
            } catch (e: Throwable) {
                // Если даже запись лога не удалась — не мешаем системному обработчику
            }
            defaultHandler?.uncaughtException(thread, throwable)
        }
    }

    private fun saveCrashLog(context: Context, throwable: Throwable) {
        val sw = StringWriter()
        throwable.printStackTrace(PrintWriter(sw))
        val text = "FinArs crash log\n" +
            SimpleDateFormat("dd.MM.yyyy HH:mm:ss", Locale.US).format(Date()) + "\n\n" +
            sw.toString()
        val fileName = "finars_crash_" +
            SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(Date()) + ".txt"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                put(MediaStore.Downloads.MIME_TYPE, "text/plain")
                put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
            }
            val uri = context.contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            if (uri != null) {
                context.contentResolver.openOutputStream(uri)?.use { it.write(text.toByteArray()) }
            }
        } else {
            @Suppress("DEPRECATION")
            val downloads = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            downloads.mkdirs()
            val file = File(downloads, fileName)
            FileOutputStream(file).use { it.write(text.toByteArray()) }
        }
    }
}
EOF_APP_SRC_MAIN_JAVA_COM_EXAMPLE_FA_KSIEGOWY_FAAPP_KT
echo "OK: app/src/main/java/com/example/fa_ksiegowy/FaApp.kt"

# --- Регистрируем FaApp как Application-класс и разрешение для старых Android (<=28) ---
MANIFEST="app/src/main/AndroidManifest.xml"
if [ ! -f "$MANIFEST" ]; then
    echo "!!! Не найден $MANIFEST"
    exit 1
fi

if ! grep -q 'android:name="\.FaApp"' "$MANIFEST"; then
    sed -i 's#<application#<application\n        android:name=".FaApp"#' "$MANIFEST"
    echo "OK: FaApp зарегистрирован как Application в $MANIFEST"
else
    echo "-- FaApp уже зарегистрирован в манифесте, пропускаю"
fi

if ! grep -q 'WRITE_EXTERNAL_STORAGE' "$MANIFEST"; then
    sed -i 's#<uses-permission android:name="android.permission.INTERNET" />#<uses-permission android:name="android.permission.INTERNET" />\n    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />#' "$MANIFEST"
    echo "OK: разрешение WRITE_EXTERNAL_STORAGE (maxSdkVersion 28) добавлено в $MANIFEST"
else
    echo "-- разрешение уже есть, пропускаю"
fi

echo "=== Готово. Теперь: git add -A && git commit -m 'Add crash logger to Downloads for diagnostics' && git push ==="
