/**
 * NumberConverter.test.ets
 * 单元测试（Hypium）
 * 覆盖 docs/05-测试用例.md A 段
 */

import { describe, it, expect } from '@ohos/hypium';
import { NumberConverter } from '../../../main/ets/converter/NumberConverter';

export default function numberConverterTest() {
  describe('NumberConverter', () => {
    // ===== A.1 基本数字 =====

    it('should_convert_zero', 0, () => {
      expect(NumberConverter.convert(0)).assertEqual('零元整');
      expect(NumberConverter.convert(0.0)).assertEqual('零元整');
    });

    it('should_convert_one', 0, () => {
      expect(NumberConverter.convert(1)).assertEqual('壹元整');
      expect(NumberConverter.convert(1.5)).assertEqual('壹元伍角');
      expect(NumberConverter.convert(1.05)).assertEqual('壹元零伍分');
    });

    it('should_convert_five', 0, () => {
      expect(NumberConverter.convert(5)).assertEqual('伍元整');
    });

    // ===== A.2 整数部分 =====

    it('should_convert_single_digit', 0, () => {
      expect(NumberConverter.convert(10)).assertEqual('壹拾元整');
      expect(NumberConverter.convert(20)).assertEqual('贰拾元整');
    });

    it('should_convert_hundred', 0, () => {
      expect(NumberConverter.convert(100)).assertEqual('壹佰元整');
    });

    it('should_convert_thousand', 0, () => {
      expect(NumberConverter.convert(1000)).assertEqual('壹仟元整');
    });

    it('should_convert_ten_thousand', 0, () => {
      expect(NumberConverter.convert(10000)).assertEqual('壹万元整');
    });

    it('should_convert_continuous_zero', 0, () => {
      expect(NumberConverter.convert(10001)).assertEqual('壹万零壹元整');
      expect(NumberConverter.convert(10010)).assertEqual('壹万零壹拾元整');
      expect(NumberConverter.convert(10100)).assertEqual('壹万零壹佰元整');
      expect(NumberConverter.convert(11000)).assertEqual('壹万壹仟元整');
    });

    it('should_convert_larger', 0, () => {
      expect(NumberConverter.convert(100000)).assertEqual('壹拾万元整');
      expect(NumberConverter.convert(1000000)).assertEqual('壹佰万元整');
      expect(NumberConverter.convert(10000000)).assertEqual('壹仟万元整');
      expect(NumberConverter.convert(100000000)).assertEqual('壹亿元整');
    });

    it('should_convert_billion_plus', 0, () => {
      expect(NumberConverter.convert(1000000000)).assertEqual('壹拾亿元整');
      expect(NumberConverter.convert(10000000000)).assertEqual('壹佰亿元整');
      expect(NumberConverter.convert(100000000000)).assertEqual('壹仟亿元整');
    });

    // ===== A.3 大数（亿级）=====

    it('should_convert_100M_plus_1', 0, () => {
      expect(NumberConverter.convert(100000001)).assertEqual('壹亿零壹元整');
    });

    it('should_convert_100M_10K_1', 0, () => {
      expect(NumberConverter.convert(100010001)).assertEqual('壹亿零壹万零壹元整');
    });

    it('should_convert_complex_large', 0, () => {
      expect(NumberConverter.convert(100100100)).assertEqual('壹亿零壹拾万零壹佰元整');
    });

    it('should_convert_canonical_large', 0, () => {
      expect(NumberConverter.convert(123456789)).assertEqual('壹亿贰仟叁佰肆拾伍万陆仟柒佰捌拾玖元整');
    });

    // ===== A.4 小数部分 =====

    it('should_convert_under_one_yuan', 0, () => {
      expect(NumberConverter.convert(0.05)).assertEqual('零元零伍分');
      expect(NumberConverter.convert(0.5)).assertEqual('零元伍角');
      expect(NumberConverter.convert(0.55)).assertEqual('零元伍角伍分');
    });

    it('should_convert_one_yuan_decimal', 0, () => {
      expect(NumberConverter.convert(1.23)).assertEqual('壹元贰角叁分');
    });

    it('should_convert_100_decimal', 0, () => {
      expect(NumberConverter.convert(100.05)).assertEqual('壹佰元零伍分');
      expect(NumberConverter.convert(100.55)).assertEqual('壹佰元伍角伍分');
    });

    // ===== A.5 综合 =====

    it('should_convert_canonical_1234_56', 0, () => {
      expect(NumberConverter.convert(1234.56)).assertEqual('壹仟贰佰叁拾肆元伍角陆分');
    });

    it('should_convert_100M_99', 0, () => {
      expect(NumberConverter.convert(100000000.99)).assertEqual('壹亿元玖角玖分');
    });

    it('should_convert_10001_01', 0, () => {
      expect(NumberConverter.convert(10001.01)).assertEqual('壹万零壹元零壹分');
    });

    it('should_convert_10010_10', 0, () => {
      expect(NumberConverter.convert(10010.10)).assertEqual('壹万零壹拾元壹角');
    });

    it('should_convert_90M_09', 0, () => {
      expect(NumberConverter.convert(90000000.09)).assertEqual('玖仟万元零玖分');
    });

    // ===== 健壮性 =====

    it('should_return_empty_for_negative', 0, () => {
      expect(NumberConverter.convert(-100)).assertEqual('');
    });

    it('should_handle_max_supported', 0, () => {
      expect(NumberConverter.convert(999999999999.99))
        .assertEqual('玖仟玖佰玖拾玖亿玖仟玖佰玖拾玖万玖仟玖佰玖拾玖元玖角玖分');
    });
  });
}
