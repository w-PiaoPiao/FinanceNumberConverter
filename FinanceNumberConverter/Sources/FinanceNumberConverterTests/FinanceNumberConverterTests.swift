//
//  FinanceNumberConverterTests.swift
//  FinanceNumberConverterTests
//
//  覆盖 docs/05-测试用例.md A 段所有用例
//

import XCTest
@testable import FinanceNumberConverter

final class FinanceNumberConverterTests: XCTestCase {

    // MARK: - 辅助

    /// 把字符串转 Decimal（支持 "1.05"、"0.50" 等）
    private func dec(_ s: String) -> Decimal {
        Decimal(string: s) ?? Decimal(0)
    }

    /// 断言转换结果
    private func assertConvert(
        _ input: String,
        _ expected: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let actual = NumberConverter.convert(dec(input))
        XCTAssertEqual(
            actual, expected,
            "输入 \(input)：期望 '\(expected)'，实际 '\(actual)'",
            file: file, line: line
        )
    }

    // MARK: - A.0 字符对照（隐式覆盖在所有用例中）

    // MARK: - A.1 基本数字

    func testA1_zero() {
        assertConvert("0", "零元整")
        assertConvert("0.0", "零元整")
        assertConvert("0.00", "零元整")
    }

    func testA1_one() {
        assertConvert("1", "壹元整")
        assertConvert("1.5", "壹元伍角")
        assertConvert("1.05", "壹元零伍分")
        assertConvert("1.50", "壹元伍角")
    }

    func testA1_five() {
        assertConvert("5", "伍元整")
    }

    // MARK: - A.2 整数部分（个拾佰仟万）

    func testA2_singleDigit() {
        assertConvert("10", "壹拾元整")
        assertConvert("20", "贰拾元整")
    }

    func testA2_hundred() {
        assertConvert("100", "壹佰元整")
    }

    func testA2_thousand() {
        assertConvert("1000", "壹仟元整")
    }

    func testA2_tenThousand() {
        assertConvert("10000", "壹万元整")
    }

    func testA2_continuousZero() {
        assertConvert("10001", "壹万零壹元整")
        assertConvert("10010", "壹万零壹拾元整")
        assertConvert("10100", "壹万零壹佰元整")
        assertConvert("11000", "壹万壹仟元整")
    }

    func testA2_hundredThousand() {
        assertConvert("100000", "壹拾万元整")
    }

    func testA2_million() {
        assertConvert("1000000", "壹佰万元整")
    }

    func testA2_tenMillion() {
        assertConvert("10000000", "壹仟万元整")
    }

    func testA2_hundredMillion() {
        assertConvert("100000000", "壹亿元整")
    }

    func testA2_billion() {
        assertConvert("1000000000", "壹拾亿元整")
    }

    func testA2_tenBillion() {
        assertConvert("10000000000", "壹佰亿元整")
    }

    func testA2_hundredBillion() {
        assertConvert("100000000000", "壹仟亿元整")
    }

    // MARK: - A.3 大数（亿级）

    func testA3_100M_plus_1() {
        assertConvert("100000001", "壹亿零壹元整")
    }

    func testA3_100M_10K_1() {
        assertConvert("100010001", "壹亿零壹万零壹元整")
    }

    func testA3_complexLarge() {
        assertConvert("100100100", "壹亿零壹拾万零壹佰元整")
    }

    func testA3_canonicalLarge() {
        assertConvert("123456789", "壹亿贰仟叁佰肆拾伍万陆仟柒佰捌拾玖元整")
    }

    // MARK: - A.4 小数部分

    func testA4_underOneYuan() {
        assertConvert("0.05", "零元零伍分")
        assertConvert("0.5", "零元伍角")
        assertConvert("0.50", "零元伍角")
        assertConvert("0.55", "零元伍角伍分")
    }

    func testA4_oneYuanWithDecimal() {
        assertConvert("1.23", "壹元贰角叁分")
    }

    func testA4_100WithDecimal() {
        assertConvert("100.05", "壹佰元零伍分")
        assertConvert("100.50", "壹佰元伍角")
        assertConvert("100.55", "壹佰元伍角伍分")
    }

    // MARK: - A.5 综合

    func testA5_canonical() {
        assertConvert("1234.56", "壹仟贰佰叁拾肆元伍角陆分")
    }

    func testA5_hundredMWithDecimal() {
        assertConvert("100000000.99", "壹亿元玖角玖分")
    }

    func testA5_10001_01() {
        assertConvert("10001.01", "壹万零壹元零壹分")
    }

    func testA5_10010_10() {
        assertConvert("10010.10", "壹万零壹拾元壹角")
    }

    func testA5_90M_09() {
        assertConvert("90000000.09", "玖仟万元零玖分")
    }

    // MARK: - 额外健壮性测试

    func testNegativeReturnsEmpty() {
        XCTAssertEqual(NumberConverter.convert(dec("-100")), "")
    }

    func testMaxSupported() {
        // 12 位整数（9999 亿）+ 2 位小数
        assertConvert("999999999999.99", "玖仟玖佰玖拾玖亿玖仟玖佰玖拾玖万玖仟玖佰玖拾玖元玖角玖分")
    }

    // MARK: - B 段 · AmountInputValidator 校验

    // B.1 sanitize: 清洗输入

    func testSanitize_keepValid() {
        XCTAssertEqual(AmountInputValidator.sanitize("1234.56"), "1234.56")
        XCTAssertEqual(AmountInputValidator.sanitize("0"), "0")
        XCTAssertEqual(AmountInputValidator.sanitize("100"), "100")
    }

    func testSanitize_stripInvalidChars() {
        XCTAssertEqual(AmountInputValidator.sanitize("1a2b3c"), "123")
        // 多个小数点只保留第一个，后续数字保留
        XCTAssertEqual(AmountInputValidator.sanitize("12.3.4.5"), "12.345")
    }

    func testSanitize_stripNegativeSign() {
        XCTAssertEqual(AmountInputValidator.sanitize("-100"), "100")
    }

    func testSanitize_keepsAllFractionDigits() {
        // 阶段 5 改进：sanitize 不截断小数位（让 UI 实时提示"只支持 2 位小数"）
        XCTAssertEqual(AmountInputValidator.sanitize("1.234"), "1.234")
        XCTAssertEqual(AmountInputValidator.sanitize("0.999"), "0.999")
    }

    func testSanitize_truncateInteger() {
        // 超过 12 位整数自动截断
        let long = String(repeating: "9", count: 20)
        XCTAssertEqual(
            AmountInputValidator.sanitize(long),
            String(repeating: "9", count: 12)
        )
    }

    func testSanitize_allowDotOnly() {
        XCTAssertEqual(AmountInputValidator.sanitize("."), ".")
        XCTAssertEqual(AmountInputValidator.sanitize(".5"), ".5")
    }

    // B.2 error: 计算错误信息

    func testError_emptyReturnsNil() {
        XCTAssertNil(AmountInputValidator.error(for: ""))
        XCTAssertNil(AmountInputValidator.error(for: "   "))
    }

    func testError_multipleDots() {
        XCTAssertEqual(
            AmountInputValidator.error(for: "1.05.6"),
            "数字格式错误：只能有一个小数点"
        )
    }

    func testError_negative() {
        XCTAssertEqual(
            AmountInputValidator.error(for: "-100"),
            "不支持负数"
        )
    }

    func testError_tooLarge() {
        XCTAssertEqual(
            AmountInputValidator.error(for: "10000000000000"),
            "金额过大（最多 12 位整数）"
        )
    }

    func testError_invalidChars() {
        XCTAssertEqual(
            AmountInputValidator.error(for: "abc"),
            "仅支持数字和小数点"
        )
    }

    func testError_validReturnsNil() {
        XCTAssertNil(AmountInputValidator.error(for: "0"))
        XCTAssertNil(AmountInputValidator.error(for: "1234.56"))
        XCTAssertNil(AmountInputValidator.error(for: ".5"))
        XCTAssertNil(AmountInputValidator.error(for: "1."))
        XCTAssertNil(AmountInputValidator.error(for: "999999999999"))
        XCTAssertNil(AmountInputValidator.error(for: "999999999999.99"))
    }

    // MARK: - B 段 · AmountInputValidator.sanitize 不截断小数位

    func testSanitize_keepsFractionDigits2() {
        // 阶段 5 改进：sanitize 不再截断小数位，让 UI 显示完整输入
        XCTAssertEqual(AmountInputValidator.sanitize("1.234"), "1.234")
        XCTAssertEqual(AmountInputValidator.sanitize("0.999"), "0.999")
    }

    // MARK: - AmountInputValidator.fractionDigitCount

    func testFractionDigitCount() {
        XCTAssertEqual(AmountInputValidator.fractionDigitCount(of: "1"), 0)
        XCTAssertEqual(AmountInputValidator.fractionDigitCount(of: "1.5"), 1)
        XCTAssertEqual(AmountInputValidator.fractionDigitCount(of: "1.55"), 2)
        XCTAssertEqual(AmountInputValidator.fractionDigitCount(of: "1.555"), 3)
        XCTAssertEqual(AmountInputValidator.fractionDigitCount(of: "100"), 0)
        XCTAssertEqual(AmountInputValidator.fractionDigitCount(of: "1."), 0)  // 小数点后无字符
        XCTAssertEqual(AmountInputValidator.fractionDigitCount(of: ".5"), 1)
    }

    // MARK: - HistoryStore

    func testHistoryStore_addNew() {
        let h: [HistoryItem] = []
        let item = HistoryItem(input: "100", output: "壹佰元整")
        let new = HistoryStore.add(item, to: h)
        XCTAssertEqual(new.count, 1)
        XCTAssertEqual(new[0].input, "100")
    }

    func testHistoryStore_addToFront() {
        let old = [HistoryItem(input: "100", output: "壹佰元整")]
        let new = HistoryStore.add(HistoryItem(input: "200", output: "贰佰元整"), to: old)
        XCTAssertEqual(new.count, 2)
        XCTAssertEqual(new[0].input, "200")  // 最新在最前
        XCTAssertEqual(new[1].input, "100")
    }

    func testHistoryStore_deduplicate() {
        let old = [
            HistoryItem(input: "100", output: "壹佰元整"),
            HistoryItem(input: "200", output: "贰佰元整")
        ]
        // 重复输入 100 → 应移到最前，不增加条数
        let new = HistoryStore.add(HistoryItem(input: "100", output: "壹佰元整"), to: old)
        XCTAssertEqual(new.count, 2)
        XCTAssertEqual(new[0].input, "100")
        XCTAssertEqual(new[1].input, "200")
    }

    func testHistoryStore_limitMaxItems() {
        // 准备 10 条
        var h: [HistoryItem] = []
        for i in 1...10 {
            h = HistoryStore.add(
                HistoryItem(input: "\(i)", output: "金额\(i)"),
                to: h
            )
        }
        XCTAssertEqual(h.count, 10)

        // 再加一条 → 应移除最旧的（第 10 条变成第 9 条前移）
        let newer = HistoryStore.add(HistoryItem(input: "11", output: "金额11"), to: h)
        XCTAssertEqual(newer.count, 10)
        XCTAssertEqual(newer[0].input, "11")  // 最新
        XCTAssertFalse(newer.contains { $0.input == "1" })  // 最旧的"1"被移除
    }

    func testHistoryStore_clear() {
        let h = [HistoryItem(input: "1", output: "壹元整")]
        XCTAssertEqual(HistoryStore.clear().count, 0)
        XCTAssertTrue(HistoryStore.clear().isEmpty)
    }

    func testHistoryStore_formatTimestamp() {
        // 用一个固定时间测试
        var components = DateComponents()
        components.year = 2026
        components.month = 6
        components.day = 21
        components.hour = 14
        components.minute = 30
        let date = Calendar(identifier: .gregorian).date(from: components)!
        XCTAssertEqual(HistoryStore.formatTimestamp(date), "14:30")
    }
}
