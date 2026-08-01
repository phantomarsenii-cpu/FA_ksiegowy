package com.example.fa_ksiegowy

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.Locale

class MineActivity : AppCompatActivity() {
    private lateinit var db: AppDatabase

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_mine)
        db = AppDatabase.getInstance(this)

        findViewById<Button>(R.id.btn_add_income).setOnClickListener {
            startActivity(Intent(this, AddEntryActivity::class.java).putExtra("isIncome", true))
        }
        findViewById<Button>(R.id.btn_add_expense).setOnClickListener {
            startActivity(Intent(this, AddEntryActivity::class.java).putExtra("isIncome", false))
        }
        findViewById<Button>(R.id.btn_settings).setOnClickListener {
            startActivity(Intent(this, SettingsActivity::class.java))
        }
        findViewById<Button>(R.id.btn_reports).setOnClickListener {
            startActivity(Intent(this, ReportActivity::class.java))
        }

        findViewById<RecyclerView>(R.id.rv_entries).layoutManager = LinearLayoutManager(this)
    }

    override fun onResume() {
        super.onResume()
        loadData()
    }

    private fun loadData() {
        CoroutineScope(Dispatchers.IO).launch {
            val entries = db.entryDao().getAll()
            val income = entries.filter { it.isIncome }.sumOf { it.amount }
            val expense = entries.filter { !it.isIncome }.sumOf { it.amount }
            val profit = income - expense
            val prefs = getSharedPreferences("settings", MODE_PRIVATE)
            val taxPercent = prefs.getFloat("taxPercent", 12f)
            val tax = if (profit > 0) profit * taxPercent / 100.0 else 0.0

            withContext(Dispatchers.Main) {
                findViewById<TextView>(R.id.tv_balance).text = formatMoney(profit)
                findViewById<TextView>(R.id.tv_stat_income).text = formatMoney(income)
                findViewById<TextView>(R.id.tv_stat_expense).text = formatMoney(expense)
                findViewById<TextView>(R.id.tv_stat_profit).text = formatMoney(profit)
                findViewById<TextView>(R.id.tv_stat_tax_label).text =
                    getString(R.string.stat_tax_format, taxPercent.toInt())
                findViewById<TextView>(R.id.tv_stat_tax).text = formatMoney(tax)
                findViewById<RecyclerView>(R.id.rv_entries).adapter = EntryAdapter(entries)
            }
        }
    }

    private fun formatMoney(v: Double): String = String.format(Locale.getDefault(), "%.2f", v)
}
