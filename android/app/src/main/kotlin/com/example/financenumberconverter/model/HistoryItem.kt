package com.example.financenumberconverter.model

import java.util.UUID

/**
 * 单条历史记录
 */
data class HistoryItem(
    val id: UUID = UUID.randomUUID(),
    val input: String,
    val output: String,
    val timestamp: Long = System.currentTimeMillis()
)
