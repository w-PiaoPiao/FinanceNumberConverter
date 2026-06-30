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
import dataPreferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';


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
  @State showPrivacyDialog: boolean = false;
  @State showPrivacyDetail: boolean = false;

  private sampleNumber: string = '1234.56';

  aboutToAppear() {
    this.checkPrivacyAccepted();
  }

  // 帮助文字
  private helpText(): string {
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

  private helpIsError(): boolean {
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

  private performShare(): void {
    if (this.result.length === 0) {
      return;
    }
    let shareText = `财务大写转换：${this.input} → ${this.result}`;
    let want = {
      action: 'ohos.want.action.sendData',
      type: 'text/plain',
      parameters: {
        'ability.params.stream': shareText
      }
    };
    (getContext() as common.UIAbilityContext).startAbility(want);
  }

  private async copyHistoryItem(item: HistoryItem): Promise<void> {
    await ClipboardUtil.copy(item.output);
    this.copiedHistoryId = item.id;
    setTimeout(() => {
      this.copiedHistoryId = '';
    }, 2000);
  }

  private checkPrivacyAccepted(): void {
    let preferences = dataPreferences.getPreferencesSync(getContext(), { name: 'fnc_prefs' });
    let accepted = preferences.getSync('privacy_policy_accepted', false) as boolean;
    this.showPrivacyDialog = !accepted;
  }

  private acceptPrivacyPolicy(): void {
    let preferences = dataPreferences.getPreferencesSync(getContext(), { name: 'fnc_prefs' });
    preferences.putSync('privacy_policy_accepted', true);
    preferences.flushSync();
    this.showPrivacyDialog = false;
  }

  private exitApp(): void {
    (getContext() as common.UIAbilityContext).terminateSelf();
  }

  // ===== 标题 =====
  @Builder
  HeaderSection() {
    Column() {
      Text('财务大写转换')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.font_primary'))
      Row() {
        Text('金额大写转换')
          .fontSize(13)
          .fontColor($r('app.color.font_secondary'))
        Blank()
        Text('Designed by Piao · Powered by opencode')
          .fontSize(10)
          .fontColor($r('app.color.font_tertiary'))
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
      TextInput({ placeholder: '请输入金额', text: $$this.input })
        .id('inputField')
        .type(InputType.Normal)
        .defaultFocus(true)
        .fontSize(24)
        .fontColor($r('app.color.font_primary'))
        .placeholderColor($r('app.color.font_tertiary'))
        .backgroundColor($r('app.color.surface'))
        .borderRadius(10)
        .borderWidth(1)
        .borderColor(this.helpIsError() ? $r('app.color.error') : $r('app.color.divider'))
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .width('100%')
        .onChange((value: string) => {
          const sanitized: string = AmountInputValidator.sanitize(value);
          if (this.input !== sanitized) {
            this.input = sanitized;
          }
        })

      Text(this.helpText())
        .fontSize(14)
        .fontColor(this.helpIsError() ? $r('app.color.error') : $r('app.color.font_primary'))
        .fontWeight(this.helpIsError() ? FontWeight.Medium : FontWeight.Regular)
        .backgroundColor(this.helpIsError() ? $r('app.color.help_error_bg') : $r('app.color.help_bg'))
        .borderRadius(4)
        .padding({ top: 6, bottom: 6, left: 8, right: 8 })
        .width('100%')
        .constraintSize({ minHeight: 28 })
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
      .fontColor($r('app.color.surface'))
      .backgroundColor(this.input.length > 0 ? $r('app.color.font_primary') : $r('app.color.font_tertiary'))
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
        .fontColor($r('app.color.font_primary'))
        .textAlign(TextAlign.Center)
        .lineHeight(32)
        .padding(20)
        .width('100%')
        .backgroundColor($r('app.color.surface'))
        .borderRadius(10)
        .borderWidth(1)
        .borderColor($r('app.color.divider'))

      // 操作按钮行
      Row() {
        // 复制按钮
        Row() {
          Text(this.isCopied ? '已复制' : '一键复制')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.isCopied ? $r('app.color.success') : $r('app.color.font_primary'))
        }
        .layoutWeight(1)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .borderRadius(10)
        .borderWidth(1)
        .borderColor(this.isCopied ? $r('app.color.success') : $r('app.color.divider'))
        .onClick(() => {
          this.copyResult();
        })

        Blank().width(12)

        // 分享按钮
        Row() {
          Text('↗')
            .fontSize(20)
            .fontColor($r('app.color.font_primary'))
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .borderRadius(10)
        .borderWidth(1)
        .borderColor($r('app.color.divider'))
        .onClick(() => {
          this.performShare();
        })
      }
      .width('100%')
      .margin({ top: 16 })
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
        .fontColor($r('app.color.font_tertiary'))
      Text('输入金额后点击「转换为大写」')
        .fontSize(13)
        .fontColor($r('app.color.font_tertiary'))
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
        .fontColor($r('app.color.font_primary'))
        .backgroundColor(Color.Transparent)
        .borderRadius(10)
        .borderWidth(1)
        .borderColor($r('app.color.divider'))
        .layoutWeight(1)
        .height(44)
        .onClick(() => {
          this.loadSample();
        })
      Button('清除')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor((this.input.length > 0 || this.result.length > 0) ? $r('app.color.font_primary') : $r('app.color.font_tertiary'))
        .backgroundColor(Color.Transparent)
        .borderRadius(10)
        .borderWidth(1)
        .borderColor($r('app.color.divider'))
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
          .fontColor($r('app.color.font_tertiary'))
          .fontFamily('monospace')
        Text(item.output)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.font_primary'))
          .maxLines(2)
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text(HistoryStore.formatTimestamp(item.timestamp))
          .fontSize(11)
          .fontColor($r('app.color.font_tertiary'))
          .fontFamily('monospace')
        Row() {
          Text(this.copiedHistoryId === item.id ? '已复制' : '复制')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.copiedHistoryId === item.id ? $r('app.color.success') : $r('app.color.font_primary'))
        }
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .borderRadius(8)
        .borderWidth(1)
        .borderColor(this.copiedHistoryId === item.id ? $r('app.color.success') : $r('app.color.divider'))
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
    .backgroundColor($r('app.color.surface'))
    .borderRadius(10)
    .borderWidth(1)
    .borderColor($r('app.color.divider'))
  }

  @Builder
  HistorySection() {
    Column() {
      Row() {
        Text('历史记录')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.font_primary'))
        Blank()
        Text(`最多 ${HistoryStore.MAX_ITEMS} 条`)
          .fontSize(12)
          .fontColor($r('app.color.font_tertiary'))
        Text('清空')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.error'))
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
            Blank().height(16)
            Text('隐私政策')
              .fontSize(12)
              .fontColor($r('app.color.font_tertiary'))
              .onClick(() => {
                this.showPrivacyDetail = true;
              })
            Blank().height(16)
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 8 })
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.app_bg'))

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

      if (this.showPrivacyDialog) {
        this.PrivacyPolicyDialog()
      }

      if (this.showPrivacyDetail) {
        this.PrivacyDetailDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AlertDialogView(title: string, message: string, confirmText: string, onConfirm: () => void) {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.mask'))
      Column() {
        Text(title)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.font_primary'))
          .margin({ bottom: 8 })
        Text(message)
          .fontSize(13)
          .fontColor($r('app.color.font_secondary'))
          .margin({ bottom: 16 })
        Row() {
          Text('取消')
            .fontSize(15)
            .fontColor($r('app.color.font_secondary'))
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .onClick(() => {
              this.showClearConfirm = false;
              this.showHistoryClearConfirm = false;
            })
          Text(confirmText)
            .fontSize(15)
            .fontColor($r('app.color.error'))
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
      .backgroundColor($r('app.color.surface'))
      .borderRadius(14)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  PrivacyPolicyDialog() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.mask'))
      Column() {
        Text('隐私政策')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.font_primary'))
          .margin({ bottom: 16 })
        Scroll() {
          Column() {
            Text('本应用尊重并保护您的隐私。请您仔细阅读以下条款：')
              .fontSize(14)
              .fontColor($r('app.color.font_primary'))
              .lineHeight(22)
            Blank().height(12)
            Text('• 不收集姓名、身份证号、手机号等身份信息')
              .fontSize(13)
              .fontColor($r('app.color.font_secondary'))
              .lineHeight(20)
            Text('• 不收集设备信息、位置信息')
              .fontSize(13)
              .fontColor($r('app.color.font_secondary'))
              .lineHeight(20)
            Text('• 不集成任何第三方 SDK')
              .fontSize(13)
              .fontColor($r('app.color.font_secondary'))
              .lineHeight(20)
            Text('• 不进行任何网络通信')
              .fontSize(13)
              .fontColor($r('app.color.font_secondary'))
              .lineHeight(20)
            Text('• 所有数据仅存储设备本地')
              .fontSize(13)
              .fontColor($r('app.color.font_secondary'))
              .lineHeight(20)
            Text('• 剪贴板权限仅用于「一键复制」')
              .fontSize(13)
              .fontColor($r('app.color.font_secondary'))
              .lineHeight(20)
          }
          .width('100%')
        }
        .constraintSize({ maxHeight: 240 })
        .width('100%')
        .padding({ bottom: 16 })
        Text('点击下方「同意并继续」即表示您已阅读并同意以上条款。')
          .fontSize(12)
          .fontColor($r('app.color.font_tertiary'))
          .lineHeight(18)
          .margin({ bottom: 16 })
        Button('同意并继续')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.surface'))
          .backgroundColor($r('app.color.font_primary'))
          .borderRadius(10)
          .width('100%')
          .height(48)
          .onClick(() => {
            this.acceptPrivacyPolicy();
          })
        Blank().height(12)
        Text('不同意并退出')
          .fontSize(14)
          .fontColor($r('app.color.font_secondary'))
          .onClick(() => {
            this.exitApp();
          })
      }
      .width('85%')
      .padding(24)
      .backgroundColor($r('app.color.surface'))
      .borderRadius(14)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  PrivacyDetailDialog() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.mask'))
      Column() {
        Row() {
          Text('隐私政策')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.font_primary'))
          Blank()
          Text('关闭')
            .fontSize(14)
            .fontColor($r('app.color.font_secondary'))
            .onClick(() => {
              this.showPrivacyDetail = false;
            })
        }
        .width('100%')
        .margin({ bottom: 16 })
        Scroll() {
          Column() {
            Text('最后更新：2026-06-22')
              .fontSize(12)
              .fontColor($r('app.color.font_tertiary'))
              .margin({ bottom: 12 })
            Text('本应用（以下简称"本 App"）由个人开发者 Piao 开发，深知个人信息保护的重要性，特此向用户说明本 App 如何收集、使用、存储和保护用户信息。请用户在使用本 App 前仔细阅读本政策。')
              .fontSize(14)
              .fontColor($r('app.color.font_primary'))
              .lineHeight(22)
              .margin({ bottom: 12 })
            Text('一、本 App 不收集的信息')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.font_primary'))
              .margin({ bottom: 8 })
            Text('本 App 不会收集、存储、上传以下任何信息：')
              .fontSize(13)
              .fontColor($r('app.color.font_secondary'))
              .lineHeight(20)
            Text('• 用户身份信息（姓名、身份证号、手机号、邮箱等）')
              .fontSize(13)
              .fontColor($r('app.color.font_secondary'))
              .lineHeight(20)
            Text('• 设备信息（设备型号、IMEI、MAC 地址等）')
              .fontSize(13)
              .fontColor($r('app.color.font_secondary'))
              .lineHeight(20)
            Text('• 位置信息（GPS、IP 定位等）')
              .fontSize(13)
              .fontColor($r('app.color.font_secondary'))
              .lineHeight(20)
            Text('• 任何形式的网络请求数据')
              .fontSize(13)
              .fontColor($r('app.color.font_secondary'))
              .lineHeight(20)
            Text('• 任何第三方 SDK 的数据共享')
              .fontSize(13)
              .fontColor($r('app.color.font_secondary'))
              .lineHeight(20)
              .margin({ bottom: 12 })
            Text('二、使用的系统权限')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.font_primary'))
              .margin({ bottom: 8 })
            Text('剪贴板访问：仅用于「一键复制」功能，用户主动点击按钮时触发。本 App 不会主动读取剪贴板内容。')
              .fontSize(13)
              .fontColor($r('app.color.font_secondary'))
              .lineHeight(20)
              .margin({ bottom: 12 })
            Text('三、数据处理方式')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.font_primary'))
              .margin({ bottom: 8 })
            Text('所有用户输入和转换结果仅存储在设备内存中，不写本地数据库、不写文件、不写 SharedPreferences。历史记录最多 10 条，重启 App 后清空。')
              .fontSize(13)
              .fontColor($r('app.color.font_secondary'))
              .lineHeight(20)
              .margin({ bottom: 12 })
            Text('四、网络行为')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.font_primary'))
              .margin({ bottom: 8 })
            Text('本 App 完全不进行任何网络通信：不发起 HTTP/HTTPS 请求，不连接任何服务器，不使用任何第三方网络 SDK，不使用任何统计分析、崩溃上报、推送服务。')
              .fontSize(13)
              .fontColor($r('app.color.font_secondary'))
              .lineHeight(20)
              .margin({ bottom: 12 })
            Text('五、联系方式')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.font_primary'))
              .margin({ bottom: 8 })
            Text('邮箱：w_PiaoPiao2026@163.com')
              .fontSize(13)
              .fontColor($r('app.color.font_secondary'))
              .lineHeight(20)
            Text('GitHub：github.com/w-PiaoPiao/FinanceNumberConverter')
              .fontSize(13)
              .fontColor($r('app.color.font_secondary'))
              .lineHeight(20)
          }
          .width('100%')
        }
        .width('100%')
        .height(420)
      }
      .width('85%')
      .constraintSize({ maxHeight: 560 })
      .padding(24)
      .backgroundColor($r('app.color.surface'))
      .borderRadius(14)
    }
    .width('100%')
    .height('100%')
  }
}
