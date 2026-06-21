package com.example.financenumberconverter.ui.component

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.ContentCopy
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.financenumberconverter.HistoryStore
import com.example.financenumberconverter.model.HistoryItem

/**
 * 历史记录行
 */
@Composable
fun HistoryRow(
    item: HistoryItem,
    isJustCopied: Boolean,
    onCopy: () -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.surface)
            .border(
                width = 1.dp,
                color = MaterialTheme.colorScheme.outline,
                shape = RoundedCornerShape(10.dp)
            )
            .clip(RoundedCornerShape(10.dp))
            .padding(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // 左侧：输入（等宽灰） + 输出（粗体黑）
        Column(
            modifier = Modifier.weight(1f)
        ) {
            Text(
                text = item.input,
                fontSize = 13.sp,
                fontFamily = FontFamily.Monospace,
                color = MaterialTheme.colorScheme.outline
            )
            Spacer(modifier = Modifier.size(4.dp))
            Text(
                text = item.output,
                fontSize = 15.sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onSurface,
                maxLines = 2
            )
        }

        Spacer(modifier = Modifier.size(12.dp))

        // 右侧：时间 + 复制按钮
        Column(
            horizontalAlignment = Alignment.End
        ) {
            Text(
                text = HistoryStore.formatTimestamp(item.timestamp),
                fontSize = 11.sp,
                fontFamily = FontFamily.Monospace,
                color = MaterialTheme.colorScheme.outline
            )
            Spacer(modifier = Modifier.size(4.dp))
            CopyButton(
                isJustCopied = isJustCopied,
                onClick = onCopy
            )
        }
    }
}

@Composable
private fun CopyButton(
    isJustCopied: Boolean,
    onClick: () -> Unit
) {
    val borderColor = if (isJustCopied) {
        MaterialTheme.colorScheme.primary.copy(alpha = 0.4f)
    } else {
        MaterialTheme.colorScheme.outline
    }
    val textColor = if (isJustCopied) {
        MaterialTheme.colorScheme.primary
    } else {
        MaterialTheme.colorScheme.onSurface
    }

    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(8.dp))
            .border(BorderStroke(1.dp, borderColor), RoundedCornerShape(8.dp))
            .clickable(onClick = onClick)
            .padding(horizontal = 10.dp, vertical = 6.dp)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(
                imageVector = if (isJustCopied) Icons.Filled.Check else Icons.Filled.ContentCopy,
                contentDescription = null,
                tint = textColor,
                modifier = Modifier.size(12.dp)
            )
            Spacer(modifier = Modifier.size(4.dp))
            Text(
                text = if (isJustCopied) "已复制" else "复制",
                fontSize = 12.sp,
                fontWeight = FontWeight.Medium,
                color = textColor
            )
        }
    }
}
