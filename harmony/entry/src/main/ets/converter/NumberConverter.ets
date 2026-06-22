/**
 * NumberConverter.ets
 * 阿拉伯数字金额 → 中文财务大写金额（1:1 翻译自 iOS Swift / Android Kotlin）
 *
 * 规则：
 * - 数字：零壹贰叁肆伍陆柒捌玖
 * - 单位：拾佰仟（10^1/2/3）万（10^4）亿（10^8）
 * - 金额单位：元 角 分
 * - 小数规则：0 角 0 分 → 加"整"；否则不加
 *
 * 算法：按"亿 / 万 / 个"三段处理整数，每段内部按"仟/佰/拾/个"处理。
 */

const DIGIT_CHARS: string[] = ['零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖'];
const SMALL_UNITS: string[] = ['', '拾', '佰', '仟'];
const BIG_UNITS: string[] = ['', '万', '亿'];

export class NumberConverter {
  /**
   * 将 number 金额转换为中文大写字符串
   * @param amount 金额（非负，最多 2 位小数，整数部分最多 12 位）
   * @returns 中文大写金额
   */
  static convert(amount: number): string {
    if (amount < 0) {
      return '';
    }
    // 截断到 2 位小数（避免浮点精度问题）
    const truncated: number = Math.round(amount * 100) / 100;
    const split: [string, string] = NumberConverter.splitAmount(truncated);
    const intStr: string = split[0];
    const decStr: string = split[1];

    const intChinese: string = NumberConverter.convertIntegerPart(intStr);
    const decChinese: string = NumberConverter.convertDecimalPart(decStr);

    return `${intChinese}元${decChinese}`;
  }

  private static splitAmount(amount: number): [string, string] {
    // 格式化为字符串，保留最多 2 位小数
    const str: string = amount.toFixed(2);
    const dotIdx: number = str.indexOf('.');
    if (dotIdx >= 0) {
      const intPart: string = str.substring(0, dotIdx);
      const decPart: string = str.substring(dotIdx + 1);
      return [intPart, decPart];
    }
    return [str, '00'];
  }

  private static convertIntegerPart(intStr: string): string {
    // 边界：全 0
    if (intStr.split('').every(c => c === '0')) {
      return '零';
    }

    // 补齐到 12 位
    const padded: string = '0'.repeat(Math.max(0, 12 - intStr.length)) + intStr;

    // 分段（每段 4 位）
    const yiSegRaw: string = padded.substring(0, 4);
    const wanSegRaw: string = padded.substring(4, 8);
    const geSegRaw: string = padded.substring(8, 12);

    const yiChinese: string = NumberConverter.convertSegment(yiSegRaw);
    const wanChinese: string = NumberConverter.convertSegment(wanSegRaw);
    const geChinese: string = NumberConverter.convertSegment(geSegRaw);

    const yiNonZero: boolean = yiChinese.length > 0;
    const wanNonZero: boolean = wanChinese.length > 0;
    const geNonZero: boolean = geChinese.length > 0;

    let result: string = '';

    // 处理亿段
    if (yiNonZero) {
      result += yiChinese + '亿';
    }

    // 处理万段
    if (wanNonZero) {
      if (result.length > 0 && wanSegRaw.charAt(0) === '0') {
        result += '零';
      }
      result += wanChinese + '万';
    } else if (yiNonZero && geNonZero) {
      result += '零';
    }

    // 处理个段
    if (geNonZero) {
      if (result.length > 0 && geSegRaw.charAt(0) === '0' && !result.endsWith('零')) {
        result += '零';
      }
      result += geChinese;
    }

    return result;
  }

  private static convertSegment(segment: string): string {
    if (segment.length !== 4) {
      return '';
    }

    let result: string = '';
    let pendingZero: boolean = false;

    for (let i = 0; i < 4; i++) {
      const digit: number = parseInt(segment.charAt(i), 10);
      const pos: number = 3 - i; // 0=个, 1=拾, 2=佰, 3=仟
      const smallUnit: string = SMALL_UNITS[pos];

      if (digit === 0) {
        if (result.length > 0) {
          pendingZero = true;
        }
      } else {
        if (pendingZero) {
          result += '零';
          pendingZero = false;
        }
        result += DIGIT_CHARS[digit] + smallUnit;
      }
    }

    return result;
  }

  private static convertDecimalPart(decStr: string): string {
    if (decStr.length !== 2) {
      return '整';
    }

    const jiao: number = parseInt(decStr.charAt(0), 10);
    const fen: number = parseInt(decStr.charAt(1), 10);

    if (jiao === 0 && fen === 0) {
      return '整';
    } else if (jiao === 0) {
      return `零${DIGIT_CHARS[fen]}分`;
    } else if (fen === 0) {
      return `${DIGIT_CHARS[jiao]}角`;
    } else {
      return `${DIGIT_CHARS[jiao]}角${DIGIT_CHARS[fen]}分`;
    }
  }
}
