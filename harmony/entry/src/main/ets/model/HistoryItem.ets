/**
 * HistoryItem.ets
 * 单条历史记录
 */

export class HistoryItem {
  id: string;
  input: string;
  output: string;
  timestamp: number;

  constructor(input: string, output: string, timestamp: number = Date.now()) {
    this.id = `${Date.now()}_${Math.random().toString(36).substring(2, 11)}`;
    this.input = input;
    this.output = output;
    this.timestamp = timestamp;
  }
}
