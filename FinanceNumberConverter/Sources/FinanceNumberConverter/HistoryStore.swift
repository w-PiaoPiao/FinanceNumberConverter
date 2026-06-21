//
//  HistoryStore.swift
//  FinanceNumberConverter
//
//  历史记录管理（纯逻辑，无 UI 依赖）
//  - 最多保留 maxItems 条（默认 10）
//  - 重复输入（已存在）移到最前（更新输出和时间戳）
//  - 最新的记录在 index 0
//

import Foundation

/// 单条历史记录
struct HistoryItem: Equatable, Identifiable {
    let id: UUID
    let input: String
    let output: String
    let timestamp: Date

    init(input: String, output: String, timestamp: Date = Date()) {
        self.id = UUID()
        self.input = input
        self.output = output
        self.timestamp = timestamp
    }
}

/// 历史记录存储（不可变操作，每次返回新数组）
enum HistoryStore {

    /// 最大保留条数
    static let maxItems: Int = 10

    /// 添加一条记录
    /// - 若已存在相同 input，移除旧记录，插入到最前
    /// - 若超过 maxItems，移除最旧的
    /// - 返回新的数组
    static func add(_ item: HistoryItem, to history: [HistoryItem]) -> [HistoryItem] {
        // 1. 去重：移除相同 input 的旧记录
        var new = history.filter { $0.input != item.input }
        // 2. 插入到最前
        new.insert(item, at: 0)
        // 3. 限制条数
        if new.count > maxItems {
            new = Array(new.prefix(maxItems))
        }
        return new
    }

    /// 清空所有记录
    static func clear() -> [HistoryItem] {
        return []
    }

    /// 格式化时间戳（用于 UI 展示）
    static func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
