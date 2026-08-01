
package com.example.fa_ksiegowy
import android.net.Uri
import android.os.Bundle
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import android.widget.Button
import android.widget.EditText
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.io.File
import java.io.FileOutputStream

class AddEntryActivity : AppCompatActivity() {
    private var selectedImagePath: String? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_add_entry)
        val pickImage = registerForActivityResult(ActivityResultContracts.GetContent()) { uri: Uri? ->
            uri?.let {
                val input = contentResolver.openInputStream(it)
                val out = File(getExternalFilesDir(null), "receipt_${System.currentTimeMillis()}.jpg")
                FileOutputStream(out).use { fos -> input?.copyTo(fos) }
                selectedImagePath = out.absolutePath
            }
        }
        val isIncome = intent.getBooleanExtra("isIncome", true)
        findViewById<Button>(R.id.btn_attach).setOnClickListener { pickImage.launch("image/*") }
        findViewById<Button>(R.id.btn_save).setOnClickListener {
            val amt = findViewById<EditText>(R.id.et_amount).text.toString().toDoubleOrNull() ?: 0.0
            val comment = findViewById<EditText>(R.id.et_comment).text.toString()
            val entry = Entry(amount=amt, isIncome=isIncome, comment=comment, dateMillis=System.currentTimeMillis(), receiptPath=selectedImagePath)
            CoroutineScope(Dispatchers.IO).launch { AppDatabase.getInstance(applicationContext).entryDao().insert(entry); finish() }
        }
    }
}
