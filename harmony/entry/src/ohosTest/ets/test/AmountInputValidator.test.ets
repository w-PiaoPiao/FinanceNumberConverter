/**
 * AmountInputValidator.test.ets
 */

import { describe, it, expect } from '@ohos/hypium';
import { AmountInputValidator } from '../../../main/ets/converter/AmountInputValidator';

export default function amountInputValidatorTest() {
  describe('AmountInputValidator.sanitize', () => {
    it('should_keep_valid', 0, () => {
      expect(AmountInputValidator.sanitize('1234.56')).assertEqual('1234.56');
      expect(AmountInputValidator.sanitize('0')).assertEqual('0');
      expect(AmountInputValidator.sanitize('100')).assertEqual('100');
    });

    it('should_strip_invalid_chars', 0, () => {
      expect(AmountInputValidator.sanitize('1a2b3c')).assertEqual('123');
      expect(AmountInputValidator.sanitize('12.3.4.5')).assertEqual('12.345');
    });

    it('should_strip_negative_sign', 0, () => {
      expect(AmountInputValidator.sanitize('-100')).assertEqual('100');
    });

    it('should_truncate_fraction_to_2', 0, () => {
      expect(AmountInputValidator.sanitize('1.234')).assertEqual('1.23');
      expect(AmountInputValidator.sanitize('0.999')).assertEqual('0.99');
      expect(AmountInputValidator.sanitize('1.2')).assertEqual('1.2');
      expect(AmountInputValidator.sanitize('1.')).assertEqual('1.');
    });

    it('should_truncate_integer', 0, () => {
      const longStr: string = '9'.repeat(20);
      expect(AmountInputValidator.sanitize(longStr)).assertEqual('9'.repeat(12));
    });

    it('should_allow_dot_only', 0, () => {
      expect(AmountInputValidator.sanitize('.')).assertEqual('.');
      expect(AmountInputValidator.sanitize('.5')).assertEqual('.5');
    });
  });

  describe('AmountInputValidator.errorFor', () => {
    it('should_return_null_for_empty', 0, () => {
      expect(AmountInputValidator.errorFor('')).assertEqual(null);
      expect(AmountInputValidator.errorFor('   ')).assertEqual(null);
    });

    it('should_detect_multiple_dots', 0, () => {
      expect(AmountInputValidator.errorFor('1.05.6'))
        .assertEqual('数字格式错误：只能有一个小数点');
    });

    it('should_detect_negative', 0, () => {
      expect(AmountInputValidator.errorFor('-100'))
        .assertEqual('不支持负数');
    });

    it('should_detect_too_large', 0, () => {
      expect(AmountInputValidator.errorFor('10000000000000'))
        .assertEqual('金额过大（最多 12 位整数）');
    });

    it('should_detect_invalid_chars', 0, () => {
      expect(AmountInputValidator.errorFor('abc'))
        .assertEqual('仅支持数字和小数点');
    });

    it('should_return_null_for_valid', 0, () => {
      expect(AmountInputValidator.errorFor('0')).assertEqual(null);
      expect(AmountInputValidator.errorFor('1234.56')).assertEqual(null);
      expect(AmountInputValidator.errorFor('.5')).assertEqual(null);
      expect(AmountInputValidator.errorFor('1.')).assertEqual(null);
      expect(AmountInputValidator.errorFor('999999999999')).assertEqual(null);
    });
  });

  describe('AmountInputValidator.fractionDigitCount', () => {
    it('should_count_correctly', 0, () => {
      expect(AmountInputValidator.fractionDigitCount('1')).assertEqual(0);
      expect(AmountInputValidator.fractionDigitCount('1.5')).assertEqual(1);
      expect(AmountInputValidator.fractionDigitCount('1.55')).assertEqual(2);
      expect(AmountInputValidator.fractionDigitCount('1.555')).assertEqual(3);
      expect(AmountInputValidator.fractionDigitCount('100')).assertEqual(0);
      expect(AmountInputValidator.fractionDigitCount('1.')).assertEqual(0);
      expect(AmountInputValidator.fractionDigitCount('.5')).assertEqual(1);
    });
  });
}
