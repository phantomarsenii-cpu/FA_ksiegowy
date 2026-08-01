package com.example.fa_ksiegowy

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query

@Dao
interface EntryDao {
    @Insert
    suspend fun insert(entry: Entry)

    @Query("SELECT * FROM entries ORDER BY dateMillis DESC")
    suspend fun getAll(): List<Entry>

    @Query("SELECT * FROM entries WHERE dateMillis BETWEEN :from AND :to ORDER BY dateMillis ASC")
    suspend fun getBetween(from: Long, to: Long): List<Entry>
}
