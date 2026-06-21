//
//  ContentView.swift
//  FinanceNumberConverter
//
//  主界面：单屏完成"输入 → 转换 → 复制"全流程
//  设计风格：Premium Utilitarian Minimalism（克制、编辑风、留白）
//

import SwiftUI
import UIKit

struct ContentView: View {

    // MARK: - 状态

    @State private var input: String = ""
    @State private var result: String = ""
    @State private var errorMessage: String? = nil
    @State private var isCopied: Bool = false
    @State private var isShowingClearConfirm: Bool = false

    @FocusState private var isInputFocused: Bool

    private let sampleNumber = "1234.56"

    /// 实时校验：当前输入是否有错
    private var hasInputError: Bool {
        AmountInputValidator.error(for: input) != nil
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // 背景：暖白系统色
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    inputSection
                    actionButtons
                    divider
                    resultSectionOrHint
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            // 短暂延迟确保视图已上屏
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isInputFocused = true
            }
        }
        .alert("清除全部内容？", isPresented: $isShowingClearConfirm) {
            Button("取消", role: .cancel) {}
            Button("清除", role: .destructive, action: clearAll)
        } message: {
            Text("输入和结果都将被清空。")
        }
    }

    // MARK: - Sections

    /// 顶部标题区
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("财务大写转换")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color(.label))
            Text("阿拉伯数字一键转中文大写")
                .font(.system(size: 13))
                .foregroundStyle(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 12)
    }

    /// 输入框 + 错误/帮助提示
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("请输入金额", text: $input)
                .font(.system(size: 24, weight: .regular))
                .keyboardType(.decimalPad)
                .focused($isInputFocused)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(
                            hasInputError ? Color(.systemRed).opacity(0.5) : Color(.separator),
                            lineWidth: 1
                        )
                )
                .onChange(of: input) { _, newValue in
                    // 实时清洗：去除非法字符、限制位数
                    // 注意：不在 onChange 中设置 errorMessage，避免与 performConvert 冲突
                    let sanitized = AmountInputValidator.sanitize(newValue)
                    if sanitized != newValue {
                        input = sanitized
                    }
                }
                .onSubmit { performConvert() }

            // 错误或帮助提示
            HStack(spacing: 4) {
                if let error = errorMessage {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 12))
                    Text(error)
                        .font(.system(size: 13))
                } else if hasInputError {
                    // 实时校验失败（如超过 12 位整数）
                    if let err = AmountInputValidator.error(for: input) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 12))
                        Text(err)
                            .font(.system(size: 13))
                    }
                } else {
                    Text("支持小数，最多 2 位")
                        .font(.system(size: 12))
                }
            }
            .foregroundStyle(
                (errorMessage != nil || hasInputError) ? Color(.systemRed) : Color(.tertiaryLabel)
            )
            .padding(.leading, 4)
        }
    }

    /// 主操作按钮：转换 + 试试看 + 清除
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // 主按钮：转换为大写（深色实心）
            Button(action: performConvert) {
                Text("转换为大写")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(.systemBackground))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(.label))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .disabled(input.isEmpty)

            // 次要按钮：试试看 / 清除
            HStack(spacing: 12) {
                SecondaryButton(title: "试试看", action: loadSample)
                SecondaryButton(
                    title: "清除",
                    action: { isShowingClearConfirm = true },
                    disabled: input.isEmpty && result.isEmpty
                )
            }
        }
    }

    /// 分割线
    private var divider: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(height: 1)
            .padding(.vertical, 4)
    }

    /// 结果区：有结果时显示大写，没结果时显示提示
    @ViewBuilder
    private var resultSectionOrHint: some View {
        if !result.isEmpty {
            resultSection
        } else {
            emptyHint
        }
    }

    /// 结果展示 + 复制按钮
    private var resultSection: some View {
        VStack(spacing: 16) {
            // 结果文字
            Text(result)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color(.label))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color(.separator), lineWidth: 1)
                )

            // 复制按钮
            Button(action: performCopy) {
                HStack(spacing: 6) {
                    Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 14, weight: .medium))
                    Text(isCopied ? "已复制" : "一键复制")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(isCopied ? Color(.systemGreen) : Color(.label))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(
                            isCopied ? Color(.systemGreen).opacity(0.4) : Color(.separator),
                            lineWidth: 1
                        )
                )
            }
        }
    }

    /// 空结果提示
    private var emptyHint: some View {
        VStack(spacing: 12) {
            Image(systemName: "yensign.circle")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Color(.tertiaryLabel))
            Text("输入金额后点击「转换为大写」")
                .font(.system(size: 13))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    // MARK: - 输入处理

    // 校验逻辑已抽离到 AmountInputValidator

    // MARK: - Actions

    /// 执行转换
    private func performConvert() {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        // 优先用 AmountInputValidator.error，保证 UI 提示一致
        if let err = AmountInputValidator.error(for: trimmed) {
            errorMessage = err
            return
        }
        guard !trimmed.isEmpty else {
            errorMessage = "请输入金额"
            return
        }
        guard let amount = Decimal(string: trimmed) else {
            errorMessage = "数字格式错误"
            return
        }
        result = NumberConverter.convert(amount)
        errorMessage = nil
        isInputFocused = false  // 转换后收起键盘
    }

    /// 加载示例
    private func loadSample() {
        input = sampleNumber
        performConvert()
    }

    /// 清除全部
    private func clearAll() {
        input = ""
        result = ""
        errorMessage = nil
        isCopied = false
    }

    /// 复制到剪贴板
    private func performCopy() {
        guard !result.isEmpty else { return }
        UIPasteboard.general.string = result
        isCopied = true
        // 2 秒后恢复按钮文字
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isCopied = false
        }
    }
}

// MARK: - 次要按钮（描边样式）

private struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var disabled: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(disabled ? Color(.tertiaryLabel) : Color(.label))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(
                            disabled ? Color(.separator).opacity(0.5) : Color(.separator),
                            lineWidth: 1
                        )
                )
        }
        .disabled(disabled)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
