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
}
