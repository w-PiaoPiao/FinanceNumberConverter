/**
 * AmountInputValidator.ets
 * 金额输入清洗与校验工具（纯函数，1:1 翻译自 iOS Swift / Android Kotlin）
 */

export class AmountInputValidator {
  /** 最大整数位数 */
  static readonly MAX_INTEGER_DIGITS: number = 12;
  /** 最大小数位数（不限，但 UI 提示） */
  static readonly MAX_FRACTION_DIGITS: number = 2;

  /**
   * 清洗输入：去除非法字符、限制小数点数量
   * 注意：小数位**不**截断，保留用户输入的全部小数位
   */
  static sanitize(raw: string): string {
    let s: string = raw;
    // 1. 去除负号
    s = s.replace(/-/g, '');
    // 2. 只保留数字和小数点
    s = s.split('').filter(c => (c >= '0' && c <= '9') || c === '.').join('');
    // 3. 限制小数点数量为 1
    const firstDotIdx: number = s.indexOf('.');
    if (firstDotIdx >= 0) {
      const before: string = s.substring(0, firstDotIdx);
      const after: string = s.substring(firstDotIdx + 1).split('').filter(c => c !== '.').join('');
      s = `${before}.${after}`;
    }
    // 4. 限制整数位最多 MAX_INTEGER_DIGITS
    const dotIdx: number = s.indexOf('.');
    if (dotIdx >= 0) {
      const intPart: string = s.substring(0, dotIdx);
      if (intPart.length > AmountInputValidator.MAX_INTEGER_DIGITS) {
        s = intPart.substring(0, AmountInputValidator.MAX_INTEGER_DIGITS) + s.substring(dotIdx);
      }
    } else {
      if (s.length > AmountInputValidator.MAX_INTEGER_DIGITS) {
        s = s.substring(0, AmountInputValidator.MAX_INTEGER_DIGITS);
      }
    }
    return s;
  }

  /**
   * 获取小数位数
   */
  static fractionDigitCount(value: string): number {
    const dot: number = value.indexOf('.');
    if (dot < 0) {
      return 0;
    }
    return value.length - dot - 1;
  }

  /**
   * 计算错误信息。返回 null 表示输入合法。
   */
  static errorFor(value: string): string | null {
    const trimmed: string = value.trim();
    if (trimmed.length === 0) {
      return null;
    }

    // 含负号
    if (trimmed.indexOf('-') >= 0) {
      return '不支持负数';
    }

    // 多个小数点
    const dotCount: number = trimmed.split('').filter(c => c === '.').length;
    if (dotCount > 1) {
      return '数字格式错误：只能有一个小数点';
    }

    // 非法字符
    for (let i = 0; i < trimmed.length; i++) {
      const c: string = trimmed.charAt(i);
      if (!(c >= '0' && c <= '9') && c !== '.') {
        return '仅支持数字和小数点';
      }
    }

    // 解析
    const dec: number = parseFloat(trimmed);
    if (isNaN(dec)) {
      return '数字格式错误';
    }

    // 负数
    if (dec < 0) {
      return '不支持负数';
    }

    // 超过最大整数位
    const dotIdx: number = trimmed.indexOf('.');
    const intDigits: number = dotIdx < 0 ? trimmed.length : dotIdx;
    if (intDigits > AmountInputValidator.MAX_INTEGER_DIGITS) {
      return `金额过大（最多 ${AmountInputValidator.MAX_INTEGER_DIGITS} 位整数）`;
    }

    return null;
  }
}
