package com.example.financenumberconverter

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

/**
 * AmountInputValidator 单元测试
 * 对应 docs/05-测试用例.md B 段
 */
class AmountInputValidatorTest {

    // ===== sanitize 清洗测试 =====

    @Test
    fun testSanitize_keepValid() {
        assertEquals("1234.56", AmountInputValidator.sanitize("1234.56"))
        assertEquals("0", AmountInputValidator.sanitize("0"))
        assertEquals("100", AmountInputValidator.sanitize("100"))
    }

    @Test
    fun testSanitize_stripInvalidChars() {
        assertEquals("123", AmountInputValidator.sanitize("1a2b3c"))
        // 多个小数点只保留第一个，后续数字保留
        assertEquals("12.345", AmountInputValidator.sanitize("12.3.4.5"))
    }

    @Test
    fun testSanitize_stripNegativeSign() {
        assertEquals("100", AmountInputValidator.sanitize("-100"))
    }

    @Test
    fun testSanitize_keepsAllFractionDigits() {
        // 阶段 5 改进：sanitize 不截断小数位
        assertEquals("1.234", AmountInputValidator.sanitize("1.234"))
        assertEquals("0.999", AmountInputValidator.sanitize("0.999"))
    }

    @Test
    fun testSanitize_truncateInteger() {
        // 超过 12 位整数自动截断
        val long = "9".repeat(20)
        assertEquals("9".repeat(12), AmountInputValidator.sanitize(long))
    }

    @Test
    fun testSanitize_allowDotOnly() {
        assertEquals(".", AmountInputValidator.sanitize("."))
        assertEquals(".5", AmountInputValidator.sanitize(".5"))
    }

    // ===== error 错误信息测试 =====

    @Test
    fun testError_emptyReturnsNull() {
        assertNull(AmountInputValidator.errorFor(""))
        assertNull(AmountInputValidator.errorFor("   "))
    }

    @Test
    fun testError_multipleDots() {
        assertEquals(
            "数字格式错误：只能有一个小数点",
            AmountInputValidator.errorFor("1.05.6")
        )
    }

    @Test
    fun testError_negative() {
        assertEquals(
            "不支持负数",
            AmountInputValidator.errorFor("-100")
        )
    }

    @Test
    fun testError_tooLarge() {
        assertEquals(
            "金额过大（最多 12 位整数）",
            AmountInputValidator.errorFor("10000000000000")
        )
    }

    @Test
    fun testError_invalidChars() {
        assertEquals(
            "仅支持数字和小数点",
            AmountInputValidator.errorFor("abc")
        )
    }

    @Test
    fun testError_validReturnsNull() {
        assertNull(AmountInputValidator.errorFor("0"))
        assertNull(AmountInputValidator.errorFor("1234.56"))
        assertNull(AmountInputValidator.errorFor(".5"))
        assertNull(AmountInputValidator.errorFor("1."))
        assertNull(AmountInputValidator.errorFor("999999999999"))
        assertNull(AmountInputValidator.errorFor("999999999999.99"))
    }

    // ===== fractionDigitCount 测试 =====

    @Test
    fun testFractionDigitCount() {
        assertEquals(0, AmountInputValidator.fractionDigitCount("1"))
        assertEquals(1, AmountInputValidator.fractionDigitCount("1.5"))
        assertEquals(2, AmountInputValidator.fractionDigitCount("1.55"))
        assertEquals(3, AmountInputValidator.fractionDigitCount("1.555"))
        assertEquals(0, AmountInputValidator.fractionDigitCount("100"))
        assertEquals(0, AmountInputValidator.fractionDigitCount("1."))
        assertEquals(1, AmountInputValidator.fractionDigitCount(".5"))
    }
}
