/**
 * Clipboard.ets
 * 鸿蒙复制工具
 */

import { pasteboard } from '@kit.BasicServicesKit';

export class ClipboardUtil {
  /**
   * 复制文本到剪贴板
   */
  static async copy(text: string): Promise<boolean> {
    try {
      const pb: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
      const data: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
      await pb.setData(data);
      return true;
    } catch (e) {
      console.error('ClipboardUtil.copy failed', JSON.stringify(e));
      return false;
    }
  }
}
