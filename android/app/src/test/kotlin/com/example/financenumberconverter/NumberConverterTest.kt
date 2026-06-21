package com.example.financenumberconverter

import org.junit.Assert.assertEquals
import org.junit.Test
import java.math.BigDecimal

/**
 * NumberConverter 单元测试
 * 覆盖 docs/05-测试用例.md A 段所有用例
 */
class NumberConverterTest {

    // 辅助：字符串 → BigDecimal
    private fun dec(s: String) = BigDecimal(s)

    // 辅助：断言转换结果
    private fun assertConvert(input: String, expected: String) {
        val actual = NumberConverter.convert(dec(input))
        assertEquals(
            "输入 $input：期望 '$expected'，实际 '$actual'",
            expected, actual
        )
    }

    // ===== A.1 基本数字 =====

    @Test
    fun testA1_zero() {
        assertConvert("0", "零元整")
        assertConvert("0.0", "零元整")
        assertConvert("0.00", "零元整")
    }

    @Test
    fun testA1_one() {
        assertConvert("1", "壹元整")
        assertConvert("1.5", "壹元伍角")
        assertConvert("1.05", "壹元零伍分")
        assertConvert("1.50", "壹元伍角")
    }

    @Test
    fun testA1_five() {
        assertConvert("5", "伍元整")
    }

    // ===== A.2 整数部分 =====

    @Test
    fun testA2_singleDigit() {
        assertConvert("10", "壹拾元整")
        assertConvert("20", "贰拾元整")
    }

    @Test
    fun testA2_hundred() {
        assertConvert("100", "壹佰元整")
    }

    @Test
    fun testA2_thousand() {
        assertConvert("1000", "壹仟元整")
    }

    @Test
    fun testA2_tenThousand() {
        assertConvert("10000", "壹万元整")
    }

    @Test
    fun testA2_continuousZero() {
        assertConvert("10001", "壹万零壹元整")
        assertConvert("10010", "壹万零壹拾元整")
        assertConvert("10100", "壹万零壹佰元整")
        assertConvert("11000", "壹万壹仟元整")
    }

    @Test
    fun testA2_hundredThousand() {
        assertConvert("100000", "壹拾万元整")
    }

    @Test
    fun testA2_million() {
        assertConvert("1000000", "壹佰万元整")
    }

    @Test
    fun testA2_tenMillion() {
        assertConvert("10000000", "壹仟万元整")
    }

    @Test
    fun testA2_hundredMillion() {
        assertConvert("100000000", "壹亿元整")
    }

    @Test
    fun testA2_billion() {
        assertConvert("1000000000", "壹拾亿元整")
    }

    @Test
    fun testA2_tenBillion() {
        assertConvert("10000000000", "壹佰亿元整")
    }

    @Test
    fun testA2_hundredBillion() {
        assertConvert("100000000000", "壹仟亿元整")
    }

    // ===== A.3 大数（亿级）=====

    @Test
    fun testA3_100M_plus_1() {
        assertConvert("100000001", "壹亿零壹元整")
    }

    @Test
    fun testA3_100M_10K_1() {
        assertConvert("100010001", "壹亿零壹万零壹元整")
    }

    @Test
    fun testA3_complexLarge() {
        assertConvert("100100100", "壹亿零壹拾万零壹佰元整")
    }

    @Test
    fun testA3_canonicalLarge() {
        assertConvert("123456789", "壹亿贰仟叁佰肆拾伍万陆仟柒佰捌拾玖元整")
    }

    // ===== A.4 小数部分 =====

    @Test
    fun testA4_underOneYuan() {
        assertConvert("0.05", "零元零伍分")
        assertConvert("0.5", "零元伍角")
        assertConvert("0.50", "零元伍角")
        assertConvert("0.55", "零元伍角伍分")
    }

    @Test
    fun testA4_oneYuanWithDecimal() {
        assertConvert("1.23", "壹元贰角叁分")
    }

    @Test
    fun testA4_100WithDecimal() {
        assertConvert("100.05", "壹佰元零伍分")
        assertConvert("100.50", "壹佰元伍角")
        assertConvert("100.55", "壹佰元伍角伍分")
    }

    // ===== A.5 综合 =====

    @Test
    fun testA5_canonical() {
        assertConvert("1234.56", "壹仟贰佰叁拾肆元伍角陆分")
    }

    @Test
    fun testA5_hundredMWithDecimal() {
        assertConvert("100000000.99", "壹亿元玖角玖分")
    }

    @Test
    fun testA5_10001_01() {
        assertConvert("10001.01", "壹万零壹元零壹分")
    }

    @Test
    fun testA5_10010_10() {
        assertConvert("10010.10", "壹万零壹拾元壹角")
    }

    @Test
    fun testA5_90M_09() {
        assertConvert("90000000.09", "玖仟万元零玖分")
    }

    // ===== 额外健壮性测试 =====

    @Test
    fun testNegativeReturnsEmpty() {
        assertEquals("", NumberConverter.convert(dec("-100")))
    }

    @Test
    fun testMaxSupported() {
        // 12 位整数（9999 亿）+ 2 位小数
        assertConvert(
            "999999999999.99",
            "玖仟玖佰玖拾玖亿玖仟玖佰玖拾玖万玖仟玖佰玖拾玖元玖角玖分"
        )
    }
}
