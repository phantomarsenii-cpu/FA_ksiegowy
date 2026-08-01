
package com.example.fa_ksiegowy
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface EntryDao {
    @Query("SELECT * FROM entries ORDER BY dateMillis DESC")
    fun getAll(): Flow<List<Entry>>

    @Query("SELECT * FROM entries WHERE dateMillis BETWEEN :from AND :to ORDER BY dateMillis DESC")
    fun getBetween(from: Long, to: Long): List<Entry>

    @Insert
    suspend fun insert(e: Entry)
}
