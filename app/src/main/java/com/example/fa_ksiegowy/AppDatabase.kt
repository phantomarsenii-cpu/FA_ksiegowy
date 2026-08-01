
package com.example.fa_ksiegowy
import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase

@Database(entities = [Entry::class], version = 1)
abstract class AppDatabase : RoomDatabase() {
    abstract fun entryDao(): EntryDao
    companion object {
        @Volatile private var INSTANCE: AppDatabase? = null
        fun getInstance(context: Context): AppDatabase = INSTANCE ?: synchronized(this) {
            Room.databaseBuilder(context.applicationContext, AppDatabase::class.java, "fa_db").build().also { INSTANCE = it }
        }
    }
}
