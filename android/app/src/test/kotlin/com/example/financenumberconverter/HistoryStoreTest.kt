package com.example.financenumberconverter

import com.example.financenumberconverter.model.HistoryItem
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.util.Calendar
import java.util.GregorianCalendar

class HistoryStoreTest {

    @Test
    fun testAddNew() {
        val h = emptyList<HistoryItem>()
        val item = HistoryItem(input = "100", output = "壹佰元整")
        val new = HistoryStore.add(item, h)
        assertEquals(1, new.size)
        assertEquals("100", new[0].input)
    }

    @Test
    fun testAddToFront() {
        val old = listOf(HistoryItem(input = "100", output = "壹佰元整"))
        val new = HistoryStore.add(HistoryItem(input = "200", output = "贰佰元整"), old)
        assertEquals(2, new.size)
        assertEquals("200", new[0].input)  // 最新在最前
        assertEquals("100", new[1].input)
    }

    @Test
    fun testDeduplicate() {
        val old = listOf(
            HistoryItem(input = "100", output = "壹佰元整"),
            HistoryItem(input = "200", output = "贰佰元整")
        )
        // 重复输入 100 → 应移到最前，不增加条数
        val new = HistoryStore.add(HistoryItem(input = "100", output = "壹佰元整"), old)
        assertEquals(2, new.size)
        assertEquals("100", new[0].input)
        assertEquals("200", new[1].input)
    }

    @Test
    fun testLimitMaxItems() {
        // 准备 10 条
        var h = emptyList<HistoryItem>()
        for (i in 1..10) {
            h = HistoryStore.add(
                HistoryItem(input = "$i", output = "金额$i"),
                h
            )
        }
        assertEquals(10, h.size)

        // 再加一条 → 应移除最旧的
        val newer = HistoryStore.add(HistoryItem(input = "11", output = "金额11"), h)
        assertEquals(10, newer.size)
        assertEquals("11", newer[0].input)
        assertFalse(newer.any { it.input == "1" })  // 最旧的"1"被移除
    }

    @Test
    fun testClear() {
        val h = listOf(HistoryItem(input = "1", output = "壹元整"))
        assertEquals(0, HistoryStore.clear().size)
        assertTrue(HistoryStore.clear().isEmpty())
    }

    @Test
    fun testFormatTimestamp() {
        val cal = GregorianCalendar(2026, Calendar.JUNE, 21, 14, 30, 0)
        val timestamp = cal.timeInMillis
        assertEquals("14:30", HistoryStore.formatTimestamp(timestamp))
    }
}
