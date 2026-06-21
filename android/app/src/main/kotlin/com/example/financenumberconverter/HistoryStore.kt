package com.example.financenumberconverter

import com.example.financenumberconverter.model.HistoryItem
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * 历史记录管理（不可变操作，每次返回新列表）
 * - 最多保留 maxItems 条（默认 10）
 * - 重复输入（已存在）移到最前（更新输出和时间戳）
 * - 最新的记录在 index 0
 */
object HistoryStore {

    /** 最大保留条数 */
    const val MAX_ITEMS: Int = 10

    /**
     * 添加一条记录
     * - 若已存在相同 input，移除旧记录，插入到最前
     * - 若超过 MAX_ITEMS，移除最旧的
     */
    fun add(item: HistoryItem, to: List<HistoryItem>): List<HistoryItem> {
        // 1. 去重：移除相同 input 的旧记录
        val newList = to.filter { it.input != item.input }.toMutableList()
        // 2. 插入到最前
        newList.add(0, item)
        // 3. 限制条数
        return if (newList.size > MAX_ITEMS) newList.subList(0, MAX_ITEMS) else newList
    }

    /** 清空所有记录 */
    fun clear(): List<HistoryItem> = emptyList()

    /** 格式化时间戳（HH:mm） */
    fun formatTimestamp(timestamp: Long): String {
        val formatter = SimpleDateFormat("HH:mm", Locale("zh", "CN"))
        return formatter.format(Date(timestamp))
    }
}
