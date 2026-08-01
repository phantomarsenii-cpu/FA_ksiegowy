
package com.example.fa_ksiegowy
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

class EntryAdapter(private val items: List<Entry>) : RecyclerView.Adapter<EntryAdapter.VH>() {
    class VH(view: View) : RecyclerView.ViewHolder(view) { val tv = view.findViewById<TextView>(android.R.id.text1) }
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val v = LayoutInflater.from(parent.context).inflate(android.R.layout.simple_list_item_1, parent, false)
        return VH(v)
    }
    override fun onBindViewHolder(holder: VH, position: Int) {
        val e = items[position]; val sign = if (e.isIncome) "+" else "-"; holder.tv.text = "$sign ${String.format("%.2f", e.amount)} ${e.comment ?: ""}"
    }
    override fun getItemCount(): Int = items.size
}
