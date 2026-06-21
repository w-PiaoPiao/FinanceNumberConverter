//
//  NumberConverter.swift
//  FinanceNumberConverter
//
//  阿拉伯数字金额 → 中文财务大写金额 纯函数
//  规则参考：国标 GB/T 12402-2000《银行结算业务凭证》（简化版）
//
//  数字 → 大写：零壹贰叁肆伍陆柒捌玖
//  单位：拾佰仟（10^1/2/3）万（10^4）亿（10^8）
//  金额单位：元 角 分
//  小数规则：0 角 0 分 → 加"整"；否则不加
//

import Foundation

/// 金额转中文大写工具
///
/// 仅依赖 Foundation，无 UI 引用，便于单元测试与跨平台复用。
///
/// 算法思路：
/// 1. 拆为整数部分（最多 12 位）+ 2 位小数部分
/// 2. 整数部分按"亿 / 万 / 个"三段处理，每段内部按"仟/佰/拾/个"处理
/// 3. 段与段之间按需补"零"（前段最高位是 0 时）
/// 4. 拼接"元" + 小数部分（"整"/"X角"/"X角X分"/"零X分"）
enum NumberConverter {

    // MARK: - 查表常量

    private static let digitChars: [String] = [
        "零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖"
    ]

    /// 小单位：个 / 拾 / 佰 / 仟（按 10^0..3）
    private static let smallUnits: [String] = [
        "", "拾", "佰", "仟"
    ]

    // MARK: - 公开 API

    /// 将 Decimal 金额转换为中文大写字符串
    /// - Parameter amount: 金额（最多 2 位小数，整数部分最多 12 位；负数返回空串）
    /// - Returns: 中文大写金额，如 "壹仟贰佰叁拾肆元伍角陆分"
    static func convert(_ amount: Decimal) -> String {
        guard amount >= 0 else { return "" }

        // 拆分为整数部分 + 2 位小数（不足补 0，超过截断）
        let (intStr, decStr) = splitAmount(amount)

        let intChinese = convertIntegerPart(intStr)
        let decChinese = convertDecimalPart(decStr)

        return "\(intChinese)元\(decChinese)"
    }

    // MARK: - 拆分

    /// 把 Decimal 拆为 (整数部分字符串, 2 位小数部分字符串)
    private static func splitAmount(_ amount: Decimal) -> (String, String) {
        let nsAmount = NSDecimalNumber(decimal: amount)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.usesGroupingSeparator = false
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let str = formatter.string(from: nsAmount) ?? "0"

        if let dotIndex = str.firstIndex(of: ".") {
            let intPart = String(str[..<dotIndex])
            var decPart = String(str[str.index(after: dotIndex)...])
            // 补齐到 2 位
            while decPart.count < 2 { decPart += "0" }
            // 截断到 2 位
            decPart = String(decPart.prefix(2))
            return (intPart, decPart)
        } else {
            return (str, "00")
        }
    }

    // MARK: - 整数部分（按亿/万/个三段处理）

    /// 转换整数部分（如 "10001" → "壹万零壹"）
    private static func convertIntegerPart(_ intStr: String) -> String {
        if intStr.allSatisfy({ $0 == "0" }) {
            return "零"
        }

        // 补齐到 12 位：左补 0，得到 [亿段, 万段, 个段] 各 4 位
        let chars = Array(intStr)
        let n = chars.count
        let padded = String(repeating: "0", count: max(0, 12 - n)) + intStr

        let yiSegRaw = String(padded.prefix(4))   // 最高 4 位（10^8..10^11，即"亿"段）
        let wanSegRaw = String(padded.dropFirst(4).prefix(4))  // 10^4..10^7（"万"段）
        let geSegRaw = String(padded.suffix(4))   // 最低 4 位（"个"段）

        let yiChinese = convertSegment(yiSegRaw)
        let wanChinese = convertSegment(wanSegRaw)
        let geChinese = convertSegment(geSegRaw)

        let yiNonZero = !yiChinese.isEmpty
        let wanNonZero = !wanChinese.isEmpty
        let geNonZero = !geChinese.isEmpty

        var result = ""

        // 处理亿段
        if yiNonZero {
            result += yiChinese + "亿"
        }

        // 处理万段
        if wanNonZero {
            // 段最高位是 0 → 段前补"零"
            if !result.isEmpty && wanSegRaw.first == "0" {
                result += "零"
            }
            result += wanChinese + "万"
        } else if yiNonZero && geNonZero {
            // 万段全 0，但亿和个段都有内容 → 中间补"零"
            result += "零"
        }

        // 处理个段
        if geNonZero {
            // 段最高位是 0 → 段前补"零"（除非已经有"零"了，避免"零零"）
            if !result.isEmpty && geSegRaw.first == "0" && !result.hasSuffix("零") {
                result += "零"
            }
            result += geChinese
        }

        return result
    }

    /// 转换一个 4 位段（不含大单位）
    /// 输入：4 位字符串，如 "0001"、"2345"
    /// 输出：段内大写，如 "壹"、"贰仟叁佰肆拾伍"
    private static func convertSegment(_ segment: String) -> String {
        let chars = Array(segment)
        guard chars.count == 4 else { return "" }

        var result = ""
        var pendingZero = false

        for (i, ch) in chars.enumerated() {
            let digit = Int(String(ch)) ?? 0
            let pos = 3 - i  // 距离个位的位数（0=个, 1=拾, 2=佰, 3=仟）
            let smallUnit = smallUnits[pos]

            if digit == 0 {
                if !result.isEmpty {
                    pendingZero = true
                }
            } else {
                if pendingZero {
                    result += "零"
                    pendingZero = false
                }
                result += digitChars[digit] + smallUnit
            }
        }

        return result
    }

    // MARK: - 小数部分

    /// 转换小数部分（必须是 2 位字符串，如 "05" → "零伍分"；"50" → "伍角"；"00" → "整"）
    private static func convertDecimalPart(_ decStr: String) -> String {
        let chars = Array(decStr)
        guard chars.count == 2 else { return "整" }

        let jiao = Int(String(chars[0])) ?? 0
        let fen = Int(String(chars[1])) ?? 0

        if jiao == 0 && fen == 0 {
            return "整"
        } else if jiao == 0 {
            return "零\(digitChars[fen])分"
        } else if fen == 0 {
            return "\(digitChars[jiao])角"
        } else {
            return "\(digitChars[jiao])角\(digitChars[fen])分"
        }
    }
}
