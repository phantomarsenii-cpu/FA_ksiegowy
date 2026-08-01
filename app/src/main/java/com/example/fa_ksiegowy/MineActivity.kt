
package com.example.fa_ksiegowy
import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch
import android.widget.Button
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

class MineActivity : AppCompatActivity() {
    private val scope = MainScope()
    lateinit var db: AppDatabase
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_mine)
        db = AppDatabase.getInstance(this)
        val rv = findViewById<RecyclerView>(R.id.rv_entries)
        rv.layoutManager = LinearLayoutManager(this)
        val tvBalance = findViewById<TextView>(R.id.tv_balance)
        findViewById<Button>(R.id.btn_add_income).setOnClickListener {
            val i = Intent(this, AddEntryActivity::class.java); i.putExtra("isIncome", true); startActivity(i)
        }
        findViewById<Button>(R.id.btn_add_expense).setOnClickListener {
            val i = Intent(this, AddEntryActivity::class.java); i.putExtra("isIncome", false); startActivity(i)
        }
        findViewById<Button>(R.id.btn_settings).setOnClickListener { startActivity(Intent(this, SettingsActivity::class.java)) }
        findViewById<Button>(R.id.btn_reports).setOnClickListener { startActivity(Intent(this, ReportActivity::class.java)) }

        scope.launch {
            db.entryDao().getAll().collect { list ->
                rv.adapter = EntryAdapter(list)
                val balance = list.fold(0.0) { acc, e -> acc + if (e.isIncome) e.amount else -e.amount }
                tvBalance.text = String.format("%.2f", balance)
            }
        }
    }
}
