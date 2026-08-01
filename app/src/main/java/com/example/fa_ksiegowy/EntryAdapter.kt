package com.example.fa_ksiegowy
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView

class EntryAdapter(private val items: List<Entry>) : RecyclerView.Adapter<EntryAdapter.VH>() {
    class VH(view: View) : RecyclerView.ViewHolder(view) {
        val tvAmount = view.findViewById<TextView>(R.id.tv_amount)
        val tvComment = view.findViewById<TextView>(R.id.tv_comment)
    }
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val v = LayoutInflater.from(parent.context).inflate(R.layout.item_entry, parent, false)
        return VH(v)
    }
    override fun onBindViewHolder(holder: VH, position: Int) {
        val e = items[position]
        val sign = if (e.isIncome) "+" else "-"
        holder.tvAmount.text = "$sign ${String.format("%.2f", e.amount)}"
        holder.tvAmount.setTextColor(
            ContextCompat.getColor(holder.itemView.context, if (e.isIncome) R.color.income_green else R.color.expense_red)
        )
        holder.tvComment.text = e.comment ?: ""
    }
    override fun getItemCount(): Int = items.size
}
