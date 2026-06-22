/**
 * HistoryStore.ets
 * 历史记录管理（不可变操作，每次返回新数组）
 * - 最多保留 maxItems 条（默认 10）
 * - 重复输入移到最前
 * - 最新的在 index 0
 */

import { HistoryItem } from '../model/HistoryItem';

export class HistoryStore {
  static readonly MAX_ITEMS: number = 10;

  /**
   * 添加一条记录
   */
  static add(item: HistoryItem, to: HistoryItem[]): HistoryItem[] {
    // 1. 去重：移除相同 input 的旧记录
    let newList: HistoryItem[] = to.filter(it => it.input !== item.input);
    // 2. 插入到最前
    newList = [item, ...newList];
    // 3. 限制条数
    if (newList.length > HistoryStore.MAX_ITEMS) {
      newList = newList.slice(0, HistoryStore.MAX_ITEMS);
    }
    return newList;
  }

  /**
   * 清空所有记录
   */
  static clear(): HistoryItem[] {
    return [];
  }

  /**
   * 格式化时间戳（HH:mm）
   */
  static formatTimestamp(timestamp: number): string {
    const d: Date = new Date(timestamp);
    const hh: string = d.getHours().toString().padStart(2, '0');
    const mm: string = d.getMinutes().toString().padStart(2, '0');
    return `${hh}:${mm}`;
  }
}
