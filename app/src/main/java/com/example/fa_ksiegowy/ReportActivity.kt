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
