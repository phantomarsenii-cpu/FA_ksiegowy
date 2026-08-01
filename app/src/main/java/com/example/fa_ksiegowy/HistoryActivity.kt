package com.example.fa_ksiegowy

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/** Отдельный экран с полной историей операций (перенесено с главного экрана). */
class HistoryActivity : BaseActivity() {
    private lateinit var db: AppDatabase

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_history)
        db = AppDatabase.getInstance(this)

        findViewById<RecyclerView>(R.id.rv_history).layoutManager = LinearLayoutManager(this)
        loadData()
    }

    override fun onResume() {
        super.onResume()
        // Обновляем список при каждом возврате на экран — например, после редактирования
        // или удаления записи в AddEntryActivity.
        loadData()
    }

    private fun loadData() {
        CoroutineScope(Dispatchers.IO).launch {
            val allEntries = db.entryDao().getAll()
            withContext(Dispatchers.Main) {
                findViewById<RecyclerView>(R.id.rv_history).adapter = EntryAdapter(allEntries) { entry ->
                    startActivity(
                        Intent(this@HistoryActivity, AddEntryActivity::class.java)
                            .putExtra("entryId", entry.id)
                            .putExtra("isIncome", entry.isIncome)
                    )
                }
                findViewById<View>(R.id.tv_no_entries).visibility =
                    if (allEntries.isEmpty()) View.VISIBLE else View.GONE
            }
        }
    }
}
