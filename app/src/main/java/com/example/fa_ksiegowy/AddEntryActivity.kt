package com.example.fa_ksiegowy
import android.net.Uri
import android.os.Bundle
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import android.widget.Button
import android.widget.EditText
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream

class AddEntryActivity : BaseActivity() {
    private var selectedImagePath: String? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_add_entry)
        val pickImage = registerForActivityResult(ActivityResultContracts.GetContent()) { uri: Uri? ->
            if (uri == null) return@registerForActivityResult
            try {
                val input = contentResolver.openInputStream(uri)
                if (input == null) {
                    Toast.makeText(this, "Не удалось открыть файл", Toast.LENGTH_SHORT).show()
                    return@registerForActivityResult
                }
                val out = File(getExternalFilesDir(null), "receipt_${System.currentTimeMillis()}.jpg")
                FileOutputStream(out).use { fos -> input.copyTo(fos) }
                input.close()
                selectedImagePath = out.absolutePath
                findViewById<Button>(R.id.btn_attach).text = getString(R.string.attach_receipt) + " ✓"
                Toast.makeText(this, "Чек добавлен", Toast.LENGTH_SHORT).show()
            } catch (e: Exception) {
                Toast.makeText(this, "Ошибка при добавлении чека: ${e.message}", Toast.LENGTH_LONG).show()
            }
        }
        val isIncome = intent.getBooleanExtra("isIncome", true)
        findViewById<android.widget.TextView>(R.id.tv_add_title).text = getString(if (isIncome) R.string.add_income else R.string.add_expense)
        findViewById<Button>(R.id.btn_attach).setOnClickListener { pickImage.launch("image/*") }
        findViewById<Button>(R.id.btn_save).setOnClickListener {
            val amt = findViewById<EditText>(R.id.et_amount).text.toString().toDoubleOrNull()
            if (amt == null || amt <= 0.0) {
                Toast.makeText(this, "Введите корректную сумму", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            val comment = findViewById<EditText>(R.id.et_comment).text.toString()
            val entry = Entry(amount = amt, isIncome = isIncome, comment = comment, dateMillis = System.currentTimeMillis(), receiptPath = selectedImagePath)
            findViewById<Button>(R.id.btn_save).isEnabled = false
            CoroutineScope(Dispatchers.IO).launch {
                AppDatabase.getInstance(applicationContext).entryDao().insert(entry)
                withContext(Dispatchers.Main) {
                    Toast.makeText(this@AddEntryActivity, "Сохранено", Toast.LENGTH_SHORT).show()
                    finish()
                }
            }
        }
    }
}
