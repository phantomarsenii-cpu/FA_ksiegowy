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
import org.apache.poi.ss.usermodel.BorderStyle
import org.apache.poi.ss.usermodel.CellStyle
import org.apache.poi.ss.usermodel.FillPatternType
import org.apache.poi.ss.usermodel.HorizontalAlignment
import org.apache.poi.ss.usermodel.IndexedColors
import org.apache.poi.xssf.usermodel.XSSFWorkbook
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

class ReportActivity : AppCompatActivity() {
    lateinit var db: AppDatabase

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_report)
        db = AppDatabase.getInstance(this)
        findViewById<Button>(R.id.btn_report_month).setOnClickListener { generateForMonth() }
        findViewById<Button>(R.id.btn_report_year).setOnClickListener { generateForYear() }
        findViewById<Button>(R.id.btn_report_custom).setOnClickListener {
            Toast.makeText(this, "—", Toast.LENGTH_LONG).show()
        }
    }

    private fun generateForMonth() {
        val now = System.currentTimeMillis()
        val monthMs = 30L * 24 * 60 * 60 * 1000
        generateReport(now - monthMs, now, getString(R.string.report_title_month))
    }

    private fun generateForYear() {
        val now = System.currentTimeMillis()
        val yearMs = 365L * 24 * 60 * 60 * 1000
        generateReport(now - yearMs, now, getString(R.string.report_title_year))
    }

    private fun generateReport(from: Long, to: Long, title: String) {
        setButtonsEnabled(false)
        Toast.makeText(this, getString(R.string.report_generating), Toast.LENGTH_SHORT).show()
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
                val sheet = wb.createSheet(getString(R.string.report_sheet_name))

                val dateFmt = SimpleDateFormat("dd.MM.yyyy HH:mm", Locale.getDefault())
                val prefs = getSharedPreferences("settings", MODE_PRIVATE)
                val taxPercent = prefs.getFloat("taxPercent", 12f)

                // ---- styles ----
                val titleFont = wb.createFont().apply {
                    bold = true
                    fontHeightInPoints = 14
                    color = IndexedColors.WHITE.index
                }
                val titleStyle: CellStyle = wb.createCellStyle().apply {
                    setFont(titleFont)
                    fillForegroundColor = IndexedColors.ROYAL_BLUE.index
                    fillPattern = FillPatternType.SOLID_FOREGROUND
                    alignment = HorizontalAlignment.CENTER
                }

                val headerFont = wb.createFont().apply {
                    bold = true
                    color = IndexedColors.WHITE.index
                }
                val headerStyle: CellStyle = wb.createCellStyle().apply {
                    setFont(headerFont)
                    fillForegroundColor = IndexedColors.BLUE_GREY.index
                    fillPattern = FillPatternType.SOLID_FOREGROUND
                    alignment = HorizontalAlignment.CENTER
                    borderBottom = BorderStyle.THIN
                    borderTop = BorderStyle.THIN
                    borderLeft = BorderStyle.THIN
                    borderRight = BorderStyle.THIN
                }

                val cellStyle: CellStyle = wb.createCellStyle().apply {
                    borderBottom = BorderStyle.THIN
                    borderTop = BorderStyle.THIN
                    borderLeft = BorderStyle.THIN
                    borderRight = BorderStyle.THIN
                }

                val moneyFormat = wb.createDataFormat().getFormat("#,##0.00")
                val moneyStyle: CellStyle = wb.createCellStyle().apply {
                    cloneStyleFrom(cellStyle)
                    dataFormat = moneyFormat
                }

                val incomeStyle: CellStyle = wb.createCellStyle().apply {
                    cloneStyleFrom(moneyStyle)
                    setFont(wb.createFont().apply { color = IndexedColors.GREEN.index })
                }
                val expenseStyle: CellStyle = wb.createCellStyle().apply {
                    cloneStyleFrom(moneyStyle)
                    setFont(wb.createFont().apply { color = IndexedColors.RED.index })
                }

                val totalLabelFont = wb.createFont().apply { bold = true }
                val totalLabelStyle: CellStyle = wb.createCellStyle().apply {
                    setFont(totalLabelFont)
                    borderTop = BorderStyle.THIN
                }
                val totalValueStyle: CellStyle = wb.createCellStyle().apply {
                    setFont(totalLabelFont)
                    dataFormat = moneyFormat
                    borderTop = BorderStyle.THIN
                }

                // ---- title row ----
                val titleRow = sheet.createRow(0)
                titleRow.heightInPoints = 24f
                for (c in 0..5) titleRow.createCell(c).cellStyle = titleStyle
                titleRow.getCell(0).setCellValue(title)
                sheet.addMergedRegion(org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 5))

                // ---- header row ----
                val headers = listOf(
                    getString(R.string.report_col_date),
                    getString(R.string.report_col_income),
                    getString(R.string.report_col_expense),
                    getString(R.string.report_col_tax_percent),
                    getString(R.string.report_col_tax_amount),
                    getString(R.string.report_col_comment)
                )
                val headerRow = sheet.createRow(1)
                for ((i, h) in headers.withIndex()) {
                    val cell = headerRow.createCell(i)
                    cell.setCellValue(h)
                    cell.cellStyle = headerStyle
                }

                // ---- data rows ----
                var rowN = 2
                var totalIncome = 0.0
                var totalExpense = 0.0
                var totalTax = 0.0

                for (e in entries) {
                    val r = sheet.createRow(rowN++)

                    val dateCell = r.createCell(0)
                    dateCell.setCellValue(dateFmt.format(Date(e.dateMillis)))
                    dateCell.cellStyle = cellStyle

                    val incomeVal = if (e.isIncome) e.amount else 0.0
                    val expenseVal = if (!e.isIncome) e.amount else 0.0
                    val taxAmount = if (e.isIncome) e.amount * taxPercent / 100.0 else 0.0

                    val incomeCell = r.createCell(1)
                    incomeCell.setCellValue(incomeVal)
                    incomeCell.cellStyle = incomeStyle

                    val expenseCell = r.createCell(2)
                    expenseCell.setCellValue(expenseVal)
                    expenseCell.cellStyle = expenseStyle

                    val taxPercentCell = r.createCell(3)
                    taxPercentCell.setCellValue(taxPercent.toDouble())
                    taxPercentCell.cellStyle = moneyStyle

                    val taxAmountCell = r.createCell(4)
                    taxAmountCell.setCellValue(taxAmount)
                    taxAmountCell.cellStyle = moneyStyle

                    val commentCell = r.createCell(5)
                    commentCell.setCellValue(e.comment ?: "")
                    commentCell.cellStyle = cellStyle

                    totalIncome += incomeVal
                    totalExpense += expenseVal
                    totalTax += taxAmount
                }

                // ---- totals ----
                rowN++
                val profitRow = sheet.createRow(rowN++)
                profitRow.createCell(0).apply { setCellValue(getString(R.string.report_total_profit)); cellStyle = totalLabelStyle }
                profitRow.createCell(1).apply { setCellValue(totalIncome - totalExpense); cellStyle = totalValueStyle }

                val incomeRow = sheet.createRow(rowN++)
                incomeRow.createCell(0).apply { setCellValue(getString(R.string.report_total_income)); cellStyle = totalLabelStyle }
                incomeRow.createCell(1).apply { setCellValue(totalIncome); cellStyle = totalValueStyle }

                val expenseRow = sheet.createRow(rowN++)
                expenseRow.createCell(0).apply { setCellValue(getString(R.string.report_total_expense)); cellStyle = totalLabelStyle }
                expenseRow.createCell(1).apply { setCellValue(totalExpense); cellStyle = totalValueStyle }

                val taxRow = sheet.createRow(rowN)
                taxRow.createCell(0).apply { setCellValue(getString(R.string.report_total_tax)); cellStyle = totalLabelStyle }
                taxRow.createCell(1).apply { setCellValue(totalTax); cellStyle = totalValueStyle }

                // ---- column widths (manual — avoids java.awt dependency on Android) ----
                sheet.setColumnWidth(0, 20 * 256)
                sheet.setColumnWidth(1, 13 * 256)
                sheet.setColumnWidth(2, 13 * 256)
                sheet.setColumnWidth(3, 11 * 256)
                sheet.setColumnWidth(4, 14 * 256)
                sheet.setColumnWidth(5, 32 * 256)

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
                    Toast.makeText(this@ReportActivity, getString(R.string.report_error, e.message ?: ""), Toast.LENGTH_LONG).show()
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
        Toast.makeText(this, getString(R.string.report_ready), Toast.LENGTH_SHORT).show()
        startActivity(Intent.createChooser(intent, getString(R.string.report_share_title)))
    }
}
