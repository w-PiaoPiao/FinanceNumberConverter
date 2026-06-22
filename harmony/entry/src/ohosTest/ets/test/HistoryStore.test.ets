/**
 * HistoryStore.test.ets
 */

import { describe, it, expect } from '@ohos/hypium';
import { HistoryStore } from '../../../main/ets/converter/HistoryStore';
import { HistoryItem } from '../../../main/ets/model/HistoryItem';

export default function historyStoreTest() {
  describe('HistoryStore.add', () => {
    it('should_add_new', 0, () => {
      const h: HistoryItem[] = [];
      const item: HistoryItem = new HistoryItem('100', '壹佰元整');
      const newList: HistoryItem[] = HistoryStore.add(item, h);
      expect(newList.length).assertEqual(1);
      expect(newList[0].input).assertEqual('100');
    });

    it('should_add_to_front', 0, () => {
      const old: HistoryItem[] = [new HistoryItem('100', '壹佰元整')];
      const newList: HistoryItem[] = HistoryStore.add(
        new HistoryItem('200', '贰佰元整'),
        old
      );
      expect(newList.length).assertEqual(2);
      expect(newList[0].input).assertEqual('200');
      expect(newList[1].input).assertEqual('100');
    });

    it('should_deduplicate', 0, () => {
      const old: HistoryItem[] = [
        new HistoryItem('100', '壹佰元整'),
        new HistoryItem('200', '贰佰元整')
      ];
      const newList: HistoryItem[] = HistoryStore.add(
        new HistoryItem('100', '壹佰元整'),
        old
      );
      expect(newList.length).assertEqual(2);
      expect(newList[0].input).assertEqual('100');
      expect(newList[1].input).assertEqual('200');
    });

    it('should_limit_max_items', 0, () => {
      let h: HistoryItem[] = [];
      for (let i: number = 1; i <= 10; i++) {
        h = HistoryStore.add(
          new HistoryItem(`${i}`, `金额${i}`),
          h
        );
      }
      expect(h.length).assertEqual(10);

      const newer: HistoryItem[] = HistoryStore.add(
        new HistoryItem('11', '金额11'),
        h
      );
      expect(newer.length).assertEqual(10);
      expect(newer[0].input).assertEqual('11');
      // 最旧的"1"被移除
      const hasOne: boolean = newer.some(it => it.input === '1');
      expect(hasOne).assertEqual(false);
    });
  });

  describe('HistoryStore.clear', () => {
    it('should_return_empty', 0, () => {
      expect(HistoryStore.clear().length).assertEqual(0);
    });
  });

  describe('HistoryStore.formatTimestamp', () => {
    it('should_format_hh_mm', 0, () => {
      // 2026-06-21 14:30
      const ts: number = new Date(2026, 5, 21, 14, 30, 0).getTime();
      expect(HistoryStore.formatTimestamp(ts)).assertEqual('14:30');
    });
  });
}
