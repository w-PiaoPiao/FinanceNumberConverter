package com.example.financenumberconverter

/**
 * 金额输入清洗与校验工具（纯函数）
 * - sanitize: 实时清洗（去除非法字符、限制位数）
 * - error: 计算错误信息
 *
 * 与 UI 解耦，可独立单元测试。
 */
object AmountInputValidator {

    /** 最大整数位数（对应 ≤ 999,999,999,999 即 12 位） */
    const val MAX_INTEGER_DIGITS: Int = 12

    /** 最大小数位数（财务场景固定 2 位 = 角分） */
    const val MAX_FRACTION_DIGITS: Int = 2

    /**
     * 清洗输入：去除非法字符、限制小数点数量
     * - 注意：小数位**不**截断，保留用户输入的全部小数位
     *   让 UI 能动态显示"只支持 2 位小数"提示
     *   真正的截断在 NumberConverter 内部（按金额规则处理）
     */
    fun sanitize(raw: String): String {
        var s = raw
        // 1. 去除负号（财务场景不支持负数）
        s = s.replace("-", "")
        // 2. 只保留数字和小数点
        s = s.filter { it.isDigit() || it == '.' }
        // 3. 限制小数点数量为 1（保留所有小数位）
        val firstDot = s.indexOf('.')
        if (firstDot >= 0) {
            val before = s.substring(0, firstDot)
            val afterStart = firstDot + 1
            val after = s.substring(afterStart).filter { it != '.' }
            s = "$before.$after"
        }
        // 4. 限制整数位最多 MAX_INTEGER_DIGITS
        val dotIdx = s.indexOf('.')
        if (dotIdx >= 0) {
            val intPart = s.substring(0, dotIdx)
            if (intPart.length > MAX_INTEGER_DIGITS) {
                s = intPart.substring(0, MAX_INTEGER_DIGITS) + s.substring(dotIdx)
            }
        } else {
            if (s.length > MAX_INTEGER_DIGITS) {
                s = s.substring(0, MAX_INTEGER_DIGITS)
            }
        }
        return s
    }

    /**
     * 获取小数位数（如 "1" → 0, "1.5" → 1, "1.55" → 2, "1.555" → 3）
     */
    fun fractionDigitCount(value: String): Int {
        val dot = value.indexOf('.')
        if (dot < 0) return 0
        val afterStart = dot + 1
        return value.length - afterStart
    }

    /**
     * 计算错误信息。返回 null 表示输入合法。
     */
    fun errorFor(value: String): String? {
        val trimmed = value.trim()
        if (trimmed.isEmpty()) return null

        // 含负号 → 直接判定为"不支持负数"（优先于"仅支持数字"提示）
        if (trimmed.contains("-")) return "不支持负数"

        // 多个小数点
        val dotCount = trimmed.count { it == '.' }
        if (dotCount > 1) return "数字格式错误：只能有一个小数点"

        // 非法字符
        val allowedChars = "0123456789."
        if (trimmed.any { it !in allowedChars }) {
            return "仅支持数字和小数点"
        }

        // 解析
        val dec = trimmed.toBigDecimalOrNull() ?: return "数字格式错误"

        // 负数（Decimal 解析可能识别 -，已通过上面 contains 拦截）
        if (dec.signum() < 0) return "不支持负数"

        // 超过最大整数位
        val intDigits = trimmed.indexOf('.').let { if (it < 0) trimmed.length else it }
        if (intDigits > MAX_INTEGER_DIGITS) {
            return "金额过大（最多 $MAX_INTEGER_DIGITS 位整数）"
        }

        return null
    }
}
