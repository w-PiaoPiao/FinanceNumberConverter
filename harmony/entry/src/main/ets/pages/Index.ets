/**
 * Index.ets
 * 财务大写转换 App 主页面
 * 设计风格：Premium Utilitarian Minimalism
 *
 * 布局（按用户最终版）：
 * 1. 标题
 * 2. 副标题行（副标题 + 作者声明）
 * 3. 输入框 + 帮助/错误
 * 4. 主按钮
 * 5. 结果区 + 复制按钮
 * 6. 次要按钮（试试看 / 清除）
 * 7. 历史记录
 */

import { NumberConverter } from '../converter/NumberConverter';
import { AmountInputValidator } from '../converter/AmountInputValidator';
import { HistoryStore } from '../converter/HistoryStore';
import { HistoryItem } from '../model/HistoryItem';
import { ClipboardUtil } from '../utils/Clipboard';

const BG_COLOR: string = '#F2F2F7';
const SURFACE_COLOR: string = '#FFFFFF';
const TEXT_PRIMARY: string = '#000000';
const TEXT_SECONDARY: string = '#8E8E93';
const TEXT_TERTIARY: string = '#C7C7CC';
const DIVIDER_COLOR: string = '#C6C6C8';
const ERROR_COLOR: string = '#FF3B30';
const SUCCESS_COLOR: string = '#34C759';

@Entry
@Component
struct Index {
  @State input: string = '';
  @State result: string = '';
  @State errorMessage: string = '';
  @State isCopied: boolean = false;
  @State showClearConfirm: boolean = false;
  @State showHistoryClearConfirm: boolean = false;
  @State history: HistoryItem[] = [];
  @State copiedHistoryId: string = '';
  @State showFractionHint: boolean = false;

  private sampleNumber: string = '1234.56';

  aboutToAppear() {
    // 启动时聚焦输入框
    setTimeout(() => {
      focusControl.requestFocus('inputField');
    }, 100);
  }

  // 帮助文字
  private get helpText(): string {
    if (this.errorMessage.length > 0) {
      return this.errorMessage;
    }
    const err: string | null = AmountInputValidator.errorFor(this.input);
    if (err !== null) {
      return err;
    }
    if (AmountInputValidator.fractionDigitCount(this.input) > AmountInputValidator.MAX_FRACTION_DIGITS) {
      return '只支持 2 位小数';
    }
    return '支持小数，最多 2 位';
  }

  private get helpIsError(): boolean {
    if (this.errorMessage.length > 0) {
      return true;
    }
    if (AmountInputValidator.errorFor(this.input) !== null) {
      return true;
    }
    if (AmountInputValidator.fractionDigitCount(this.input) > AmountInputValidator.MAX_FRACTION_DIGITS) {
      return true;
    }
    return false;
  }

  // 操作
  private performConvert(): void {
    const trimmed: string = this.input.trim();
    const err: string | null = AmountInputValidator.errorFor(trimmed);
    if (err !== null) {
      this.errorMessage = err;
      return;
    }
    if (trimmed.length === 0) {
      this.errorMessage = '请输入金额';
      return;
    }
    const amount: number = parseFloat(trimmed);
    if (isNaN(amount)) {
      this.errorMessage = '数字格式错误';
      return;
    }
    const converted: string = NumberConverter.convert(amount);
    this.result = converted;
    this.errorMessage = '';
    // 写入历史
    const item: HistoryItem = new HistoryItem(trimmed, converted);
    this.history = HistoryStore.add(item, this.history);
  }

  private loadSample(): void {
    this.input = this.sampleNumber;
    this.performConvert();
  }

  private clearAll(): void {
    this.input = '';
    this.result = '';
    this.errorMessage = '';
    this.isCopied = false;
  }

  private async copyResult(): Promise<void> {
    if (this.result.length === 0) {
      return;
    }
    await ClipboardUtil.copy(this.result);
    this.isCopied = true;
    setTimeout(() => {
      this.isCopied = false;
    }, 2000);
  }

  private async copyHistoryItem(item: HistoryItem): Promise<void> {
    await ClipboardUtil.copy(item.output);
    this.copiedHistoryId = item.id;
    setTimeout(() => {
      this.copiedHistoryId = '';
    }, 2000);
  }

  // ===== 标题 =====
  @Builder
  HeaderSection() {
    Column() {
      Text('财务大写转换')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(TEXT_PRIMARY)
      Row() {
        Text('金额大写转换')
          .fontSize(13)
          .fontColor(TEXT_SECONDARY)
        Blank()
        Text('Designed by Piao · Powered by opencode')
          .fontSize(10)
          .fontColor(TEXT_TERTIARY)
          .maxLines(1)
      }
      .width('100%')
      .margin({ top: 6 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 12 })
  }

  // ===== 输入框 =====
  @Builder
  InputSection() {
    Column() {
      TextInput({ placeholder: '请输入金额', text: this.input })
        .id('inputField')
        .type(InputType.Decimal)
        .fontSize(24)
        .fontColor(TEXT_PRIMARY)
        .placeholderColor(TEXT_TERTIARY)
        .backgroundColor(SURFACE_COLOR)
        .borderRadius(10)
        .borderWidth(1)
        .borderColor(this.helpIsError ? ERROR_COLOR : DIVIDER_COLOR)
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .width('100%')
        .onChange((value: string) => {
          this.input = AmountInputValidator.sanitize(value);
        })

      Text(this.helpText)
        .fontSize(this.helpIsError ? 13 : 12)
        .fontColor(this.helpIsError ? ERROR_COLOR : TEXT_TERTIARY)
        .margin({ top: 8, left: 4 })
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // ===== 主按钮 =====
  @Builder
  PrimaryButtonSection() {
    Button('转换为大写')
      .fontSize(17)
      .fontWeight(FontWeight.Medium)
      .fontColor(SURFACE_COLOR)
      .backgroundColor(this.input.length > 0 ? TEXT_PRIMARY : TEXT_TERTIARY)
      .borderRadius(10)
      .width('100%')
      .height(50)
      .enabled(this.input.length > 0)
      .onClick(() => {
        this.performConvert();
      })
  }

  // ===== 结果区 =====
  @Builder
  ResultSection() {
    Column() {
      // 结果文字
      Text(this.result)
        .fontSize(28)
        .fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY)
        .textAlign(TextAlign.Center)
        .lineHeight(32)
        .padding(20)
        .width('100%')
        .backgroundColor(SURFACE_COLOR)
        .borderRadius(10)
        .borderWidth(1)
        .borderColor(DIVIDER_COLOR)

      // 复制按钮
      Row() {
        Text(this.isCopied ? '已复制' : '一键复制')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isCopied ? SUCCESS_COLOR : TEXT_PRIMARY)
      }
      .width('100%')
      .height(44)
      .justifyContent(FlexAlign.Center)
      .borderRadius(10)
      .borderWidth(1)
      .borderColor(this.isCopied ? SUCCESS_COLOR : DIVIDER_COLOR)
      .margin({ top: 16 })
      .onClick(() => {
        this.copyResult();
      })
    }
    .width('100%')
  }

  // ===== 空结果提示 =====
  @Builder
  EmptyResult() {
    Column() {
      Text('¥')
        .fontSize(48)
        .fontWeight(FontWeight.Lighter)
        .fontColor(TEXT_TERTIARY)
      Text('输入金额后点击「转换为大写」')
        .fontSize(13)
        .fontColor(TEXT_TERTIARY)
        .margin({ top: 12 })
    }
    .width('100%')
    .padding(48)
    .alignItems(HorizontalAlign.Center)
  }

  // ===== 次要按钮 =====
  @Builder
  SecondaryButtons() {
    Row() {
      Button('试试看')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY)
        .backgroundColor('#00000000')
        .borderRadius(10)
        .borderWidth(1)
        .borderColor(DIVIDER_COLOR)
        .layoutWeight(1)
        .height(44)
        .onClick(() => {
          this.loadSample();
        })
      Button('清除')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor((this.input.length > 0 || this.result.length > 0) ? TEXT_PRIMARY : TEXT_TERTIARY)
        .backgroundColor('#00000000')
        .borderRadius(10)
        .borderWidth(1)
        .borderColor(DIVIDER_COLOR)
        .layoutWeight(1)
        .height(44)
        .margin({ left: 12 })
        .enabled(this.input.length > 0 || this.result.length > 0)
        .onClick(() => {
          this.showClearConfirm = true;
        })
    }
    .width('100%')
  }

  // ===== 历史记录 =====
  @Builder
  HistoryRowView(item: HistoryItem) {
    Row() {
      Column() {
        Text(item.input)
          .fontSize(13)
          .fontColor(TEXT_TERTIARY)
          .fontFamily('monospace')
        Text(item.output)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(TEXT_PRIMARY)
          .maxLines(2)
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text(HistoryStore.formatTimestamp(item.timestamp))
          .fontSize(11)
          .fontColor(TEXT_TERTIARY)
          .fontFamily('monospace')
        Row() {
          Text(this.copiedHistoryId === item.id ? '已复制' : '复制')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.copiedHistoryId === item.id ? SUCCESS_COLOR : TEXT_PRIMARY)
        }
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .borderRadius(8)
        .borderWidth(1)
        .borderColor(this.copiedHistoryId === item.id ? SUCCESS_COLOR : DIVIDER_COLOR)
        .margin({ top: 4 })
        .onClick(() => {
          this.copyHistoryItem(item);
        })
      }
      .alignItems(HorizontalAlign.End)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(SURFACE_COLOR)
    .borderRadius(10)
    .borderWidth(1)
    .borderColor(DIVIDER_COLOR)
  }

  @Builder
  HistorySection() {
    Column() {
      Row() {
        Text('历史记录')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(TEXT_PRIMARY)
        Blank()
        Text(`最多 ${HistoryStore.MAX_ITEMS} 条`)
          .fontSize(12)
          .fontColor(TEXT_TERTIARY)
        Text('清空')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(ERROR_COLOR)
          .margin({ left: 8 })
          .onClick(() => {
            this.showHistoryClearConfirm = true;
          })
      }
      .width('100%')
      .padding({ left: 4, right: 4, top: 0, bottom: 8 })

      ForEach(this.history, (item: HistoryItem) => {
        this.HistoryRowView(item)
      }, (item: HistoryItem) => item.id)
    }
    .width('100%')
  }

  build() {
    Stack() {
      Column() {
        Scroll() {
          Column() {
            this.HeaderSection()
            this.InputSection()
            Blank().height(24)
            this.PrimaryButtonSection()
            Blank().height(24)
            if (this.result.length > 0) {
              this.ResultSection()
            } else {
              this.EmptyResult()
            }
            Blank().height(24)
            this.SecondaryButtons()
            if (this.history.length > 0) {
              Blank().height(24)
              this.HistorySection()
            }
            Blank().height(32)
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 8 })
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(BG_COLOR)

      // 清除确认
      if (this.showClearConfirm) {
        this.AlertDialogView(
          '清除全部内容？',
          '输入和结果都将被清空。',
          '清除',
          () => {
            this.clearAll();
            this.showClearConfirm = false;
          }
        )
      }

      // 历史清空确认
      if (this.showHistoryClearConfirm) {
        this.AlertDialogView(
          '清空历史记录？',
          `所有 ${this.history.length} 条历史记录都将被删除。`,
          '清空',
          () => {
            this.history = HistoryStore.clear();
            this.showHistoryClearConfirm = false;
          }
        )
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AlertDialogView(title: string, message: string, confirmText: string, onConfirm: () => void) {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000080')
        Column() {
          Text(title)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor(TEXT_PRIMARY)
            .margin({ bottom: 8 })
          Text(message)
            .fontSize(13)
            .fontColor(TEXT_SECONDARY)
            .margin({ bottom: 16 })
          Row() {
            Text('取消')
              .fontSize(15)
              .fontColor(TEXT_SECONDARY)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .onClick(() => {
                this.showClearConfirm = false;
                this.showHistoryClearConfirm = false;
              })
            Text(confirmText)
              .fontSize(15)
              .fontColor(ERROR_COLOR)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .onClick(() => {
                onConfirm();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
        }
        .width('80%')
        .padding(20)
        .backgroundColor(SURFACE_COLOR)
        .borderRadius(14)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}
