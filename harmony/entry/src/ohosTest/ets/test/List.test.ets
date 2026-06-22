/**
 * List.test.ets
 * 测试入口文件（DevEco Studio 自动识别）
 * 列出所有测试模块
 */

import numberConverterTest from './NumberConverter.test.ets';
import amountInputValidatorTest from './AmountInputValidator.test.ets';
import historyStoreTest from './HistoryStore.test.ets';

export default function testsuite() {
  numberConverterTest();
  amountInputValidatorTest();
  historyStoreTest();
}
