//
//  AmountInputValidator.swift
//  FinanceNumberConverter
//
//  金额输入清洗与校验工具（纯函数）
//  - sanitize: 实时清洗（去除非法字符、限制位数）
//  - error: 计算错误信息
//
//  与 UI 解耦，可独立单元测试。
//

import Foundation

enum AmountInputValidator {

    /// 最大整数位数（对应 ≤ 999,999,999,999 即 12 位）
    static let maxIntegerDigits: Int = 12

    /// 最大小数位数（财务场景固定 2 位 = 角分）
    static let maxFractionDigits: Int = 2

    // MARK: - 清洗

    /// 清洗输入：去除非法字符、限制小数点数量与位数
    /// - Returns: 清洗后的字符串
    static func sanitize(_ raw: String) -> String {
        var s = raw
        // 1. 去除负号（财务场景不支持负数）
        s = s.replacingOccurrences(of: "-", with: "")
        // 2. 只保留数字和小数点
        s = String(s.filter { "0123456789.".contains($0) })
        // 3. 限制小数点数量为 1
        if let firstDot = s.firstIndex(of: ".") {
            let before = String(s[..<firstDot])
            let afterStart = s.index(after: firstDot)
            let after = String(s[afterStart...].filter { $0 != "." })
            s = before + "." + String(after.prefix(maxFractionDigits))
        }
        // 4. 限制整数位最多 maxIntegerDigits
        if let dot = s.firstIndex(of: ".") {
            let intPart = String(s[..<dot])
            if intPart.count > maxIntegerDigits {
                s = String(intPart.prefix(maxIntegerDigits)) + String(s[dot...])
            }
        } else {
            if s.count > maxIntegerDigits {
                s = String(s.prefix(maxIntegerDigits))
            }
        }
        return s
    }

    // MARK: - 校验

    /// 计算错误信息。返回 nil 表示输入合法。
    static func error(for value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return nil }

        // 含负号 → 直接判定为"不支持负数"（优先于"仅支持数字"提示）
        if trimmed.contains("-") {
            return "不支持负数"
        }

        // 多个小数点
        let dotCount = trimmed.filter { $0 == "." }.count
        if dotCount > 1 { return "数字格式错误：只能有一个小数点" }

        // 非法字符
        let allowedChars = CharacterSet(charactersIn: "0123456789.")
        if trimmed.unicodeScalars.contains(where: { !allowedChars.contains($0) }) {
            return "仅支持数字和小数点"
        }

        // 解析
        guard let dec = Decimal(string: trimmed) else {
            return "数字格式错误"
        }

        // 负数（Decimal 解析可能识别 -，已通过上面 contains 拦截）
        if dec < 0 { return "不支持负数" }

        // 超过最大整数位
        let intDigits: Int
        if let dot = trimmed.firstIndex(of: ".") {
            intDigits = trimmed.distance(from: trimmed.startIndex, to: dot)
        } else {
            intDigits = trimmed.count
        }
        if intDigits > maxIntegerDigits {
            return "金额过大（最多 \(maxIntegerDigits) 位整数）"
        }

        return nil
    }
}
