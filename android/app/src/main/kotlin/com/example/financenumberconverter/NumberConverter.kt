package com.example.financenumberconverter

import java.math.BigDecimal
import java.math.RoundingMode
import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.util.Locale

/**
 * 阿拉伯数字金额 → 中文财务大写金额 工具
 *
 * 规则参考：国标 GB/T 12402-2000《银行结算业务凭证》（简化版）
 *
 * 数字 → 大写：零壹贰叁肆伍陆柒捌玖
 * 单位：拾佰仟（10^1/2/3）万（10^4）亿（10^8）
 * 金额单位：元 角 分
 * 小数规则：0 角 0 分 → 加"整"；否则不加
 *
 * 算法思路：
 * 1. 拆为整数部分（最多 12 位）+ 2 位小数部分
 * 2. 整数部分按"亿 / 万 / 个"三段处理，每段内部按"仟/佰/拾/个"处理
 * 3. 段与段之间按需补"零"（前段最高位是 0 时）
 * 4. 拼接"元" + 小数部分
 */
object NumberConverter {

    // 查表常量（私有）
    private val DIGIT_CHARS = arrayOf("零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖")

    /** 小单位：个 / 拾 / 佰 / 仟（按 10^0..3） */
    private val SMALL_UNITS = arrayOf("", "拾", "佰", "仟")

    /** 大单位：万 / 亿（按 10^4, 10^8） */
    private val BIG_UNITS = arrayOf("", "万", "亿")

    // 数字格式化器（线程安全：每次新建）
    private fun decimalFormat(): DecimalFormat {
        val symbols = DecimalFormatSymbols(Locale("en_US_POSIX"))
        val f = DecimalFormat("#.##", symbols)
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 0
        f.minimumIntegerDigits = 1
        f.isGroupingUsed = false
        f.roundingMode = RoundingMode.DOWN
        return f
    }

    /**
     * 将 BigDecimal 金额转换为中文大写字符串
     * @param amount 金额（最多 2 位小数，整数部分最多 12 位；负数返回空串）
     * @return 中文大写金额，如 "壹仟贰佰叁拾肆元伍角陆分"
     */
    fun convert(amount: BigDecimal): String {
        if (amount.signum() < 0) return ""

        // 拆分为整数部分 + 2 位小数（不足补 0，超过截断）
        val (intStr, decStr) = splitAmount(amount)

        val intChinese = convertIntegerPart(intStr)
        val decChinese = convertDecimalPart(decStr)

        return "${intChinese}元${decChinese}"
    }

    // ============ 拆分 ============

    /** 把 BigDecimal 拆为 (整数部分字符串, 2 位小数部分字符串) */
    private fun splitAmount(amount: BigDecimal): Pair<String, String> {
        val str = decimalFormat().format(amount)

        val dotIdx = str.indexOf('.')
        return if (dotIdx >= 0) {
            val intPart = str.substring(0, dotIdx)
            var decPart = str.substring(dotIdx + 1)
            // 补齐到 2 位
            while (decPart.length < 2) decPart += "0"
            // 截断到 2 位
            decPart = decPart.substring(0, 2)
            intPart to decPart
        } else {
            str to "00"
        }
    }

    // ============ 整数部分 ============

    /**
     * 转换整数部分（如 "10001" → "壹万零壹"）
     */
    private fun convertIntegerPart(intStr: String): String {
        // 边界：全 0
        if (intStr.all { it == '0' }) return "零"

        val chars = intStr.toCharArray()
        val n = chars.size

        // 补齐到 12 位
        val padded = "0".repeat(maxOf(0, 12 - n)) + intStr

        val yiSegRaw = padded.substring(0, 4)    // 最高 4 位（亿段）
        val wanSegRaw = padded.substring(4, 8)   // 万段
        val geSegRaw = padded.substring(8, 12)   // 个段

        val yiChinese = convertSegment(yiSegRaw)
        val wanChinese = convertSegment(wanSegRaw)
        val geChinese = convertSegment(geSegRaw)

        val yiNonZero = yiChinese.isNotEmpty()
        val wanNonZero = wanChinese.isNotEmpty()
        val geNonZero = geChinese.isNotEmpty()

        var result = ""

        // 处理亿段
        if (yiNonZero) {
            result += yiChinese + "亿"
        }

        // 处理万段
        if (wanNonZero) {
            if (result.isNotEmpty() && wanSegRaw[0] == '0') {
                result += "零"
            }
            result += wanChinese + "万"
        } else if (yiNonZero && geNonZero) {
            result += "零"
        }

        // 处理个段
        if (geNonZero) {
            if (result.isNotEmpty() && geSegRaw[0] == '0' && !result.endsWith("零")) {
                result += "零"
            }
            result += geChinese
        }

        return result
    }

    /**
     * 转换一个 4 位段（不含大单位）
     * 输入：4 位字符串，如 "0001"、"2345"
     * 输出：段内大写，如 "壹"、"贰仟叁佰肆拾伍"
     */
    private fun convertSegment(segment: String): String {
        val chars = segment.toCharArray()
        if (chars.size != 4) return ""

        var result = ""
        var pendingZero = false

        for ((i, ch) in chars.withIndex()) {
            val digit = ch.digitToInt()
            val pos = 3 - i  // 距离个位的位数（0=个, 1=拾, 2=佰, 3=仟）
            val smallUnit = SMALL_UNITS[pos]

            if (digit == 0) {
                if (result.isNotEmpty()) {
                    pendingZero = true
                }
            } else {
                if (pendingZero) {
                    result += "零"
                    pendingZero = false
                }
                result += DIGIT_CHARS[digit] + smallUnit
            }
        }

        return result
    }

    // ============ 小数部分 ============

    /**
     * 转换小数部分（必须是 2 位字符串）
     * "00" → "整"
     * "05" → "零伍分"
     * "50" → "伍角"
     * "99" → "玖角玖分"
     */
    private fun convertDecimalPart(decStr: String): String {
        if (decStr.length != 2) return "整"

        val jiao = decStr[0].digitToInt()
        val fen = decStr[1].digitToInt()

        return when {
            jiao == 0 && fen == 0 -> "整"
            jiao == 0 -> "零${DIGIT_CHARS[fen]}分"
            fen == 0 -> "${DIGIT_CHARS[jiao]}角"
            else -> "${DIGIT_CHARS[jiao]}角${DIGIT_CHARS[fen]}分"
        }
    }
}
