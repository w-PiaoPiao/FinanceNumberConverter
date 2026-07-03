package com.example.financenumberconverter.ui.screen

import android.app.Activity
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.view.inputmethod.InputMethodManager
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.selection.SelectionContainer
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.ContentCopy
import androidx.compose.material.icons.filled.ErrorOutline
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.financenumberconverter.AmountInputValidator
import com.example.financenumberconverter.HistoryStore
import com.example.financenumberconverter.NumberConverter
import com.example.financenumberconverter.R
import com.example.financenumberconverter.model.HistoryItem
import com.example.financenumberconverter.ui.component.HistoryRow
import com.example.financenumberconverter.ui.component.SecondaryButton
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * 主界面：输入 → 转换 → 复制 + 历史
 * 设计风格：Premium Utilitarian Minimalism
 */
@Composable
fun ConverterScreen() {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()

    // 状态
    var input by remember { mutableStateOf("") }
    var result by remember { mutableStateOf("") }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var isCopied by remember { mutableStateOf(false) }
    var isShowingClearConfirm by remember { mutableStateOf(false) }
    var isShowingHistoryClearConfirm by remember { mutableStateOf(false) }
    var history by remember { mutableStateOf<List<HistoryItem>>(emptyList()) }
    var copiedHistoryId by remember { mutableStateOf<String?>(null) }
    var showPrivacyDialog by remember { mutableStateOf(false) }
    var showPrivacyDetail by remember { mutableStateOf(false) }
    var showTutorial by remember { mutableStateOf(false) }
    var tutorialStep by remember { mutableStateOf(0) }

    // 计算属性
    val fractionDigits by remember(input) {
        derivedStateOf { AmountInputValidator.fractionDigitCount(input) }
    }
    val hasInputError by remember(input) {
        derivedStateOf { AmountInputValidator.errorFor(input) != null }
    }

    // 显示在输入框下方的提示
    val helpText = when {
        errorMessage != null -> errorMessage!!
        hasInputError -> AmountInputValidator.errorFor(input)!!
        fractionDigits > AmountInputValidator.MAX_FRACTION_DIGITS -> "只支持 2 位小数"
        else -> "支持小数，最多 2 位"
    }
    val helpIsError = errorMessage != null || hasInputError || fractionDigits > AmountInputValidator.MAX_FRACTION_DIGITS

    // 复制反馈自动恢复
    LaunchedEffect(isCopied) {
        if (isCopied) {
            delay(2000)
            isCopied = false
        }
    }
    LaunchedEffect(copiedHistoryId) {
        if (copiedHistoryId != null) {
            delay(2000)
            copiedHistoryId = null
        }
    }

    LaunchedEffect(Unit) {
        val prefs = context.getSharedPreferences("fnc_prefs", Context.MODE_PRIVATE)
        val accepted = prefs.getBoolean("privacy_policy_accepted", false)
        val tutorialShown = prefs.getBoolean("has_shown_tutorial", false)
        if (!accepted) {
            showPrivacyDialog = true
        } else if (!tutorialShown) {
            showTutorial = true
        }
    }

    // Actions
    fun performConvert() {
        val trimmed = input.trim()
        AmountInputValidator.errorFor(trimmed)?.let {
            errorMessage = it
            return
        }
        if (trimmed.isEmpty()) {
            errorMessage = "请输入金额"
            return
        }
        val amount = trimmed.toBigDecimalOrNull()
        if (amount == null) {
            errorMessage = "数字格式错误"
            return
        }
        val converted = NumberConverter.convert(amount)
        result = converted
        errorMessage = null
        val imm = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        (context as? Activity)?.currentFocus?.windowToken?.let {
            imm.hideSoftInputFromWindow(it, 0)
        }
        // 写入历史
        val item = HistoryItem(input = trimmed, output = converted)
        history = HistoryStore.add(item, history)
    }

    fun loadSample() {
        input = "1234.56"
        performConvert()
    }

    fun clearAll() {
        input = ""
        result = ""
        errorMessage = null
        isCopied = false
    }

    fun copyResult() {
        if (result.isNotEmpty()) {
            copyToClipboard(context, result)
            isCopied = true
        }
    }

    fun copyHistoryItem(item: HistoryItem) {
        copyToClipboard(context, item.output)
        copiedHistoryId = item.id.toString()
    }

    fun acceptPrivacyPolicy() {
        val prefs = context.getSharedPreferences("fnc_prefs", Context.MODE_PRIVATE)
        prefs.edit().putBoolean("privacy_policy_accepted", true).apply()
        showPrivacyDialog = false
        if (!prefs.getBoolean("has_shown_tutorial", false)) {
            showTutorial = true
        }
    }

    fun exitApp() {
        (context as? Activity)?.finishAffinity()
    }

    fun shareResult() {
        if (result.isEmpty()) return
        val shareText = "财务大写转换：${input} → ${result}"
        val intent = Intent().apply {
            action = Intent.ACTION_SEND
            putExtra(Intent.EXTRA_TEXT, shareText)
            type = "text/plain"
        }
        context.startActivity(Intent.createChooser(intent, "分享到"))
    }

    // ===== UI =====
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp, vertical = 8.dp),
        verticalArrangement = Arrangement.spacedBy(24.dp)
    ) {
        // 1. 标题 + 副标题
        HeaderSection()

        // 2. 输入
        InputSection(
            input = input,
            onInputChange = {
                val sanitized = AmountInputValidator.sanitize(it)
                input = sanitized
            },
            helpText = helpText,
            helpIsError = helpIsError,
            hasInputError = hasInputError,
        )

        // 3. 主按钮
        PrimaryButton(
            text = "转换为大写",
            enabled = input.isNotEmpty(),
            onClick = ::performConvert
        )

        // 4. 结果 + 复制
        AnimatedVisibility(
            visible = result.isNotEmpty(),
            enter = fadeIn() + slideInVertically { it / 2 },
            exit = fadeOut() + slideOutVertically { it / 2 }
        ) {
            ResultSection(
                result = result,
                isCopied = isCopied,
                onCopy = ::copyResult,
                onShare = ::shareResult
            )
        }
        if (result.isEmpty()) {
            EmptyResultHint()
        }

        // 5. 次要按钮
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            SecondaryButton(
                text = "试试看",
                onClick = ::loadSample,
                modifier = Modifier.weight(1f)
            )
            SecondaryButton(
                text = "清除",
                onClick = { isShowingClearConfirm = true },
                enabled = input.isNotEmpty() || result.isNotEmpty(),
                modifier = Modifier.weight(1f)
            )
        }

        // 6. 历史
        if (history.isNotEmpty()) {
            HistoryList(
                history = history,
                copiedHistoryId = copiedHistoryId,
                onCopyItem = ::copyHistoryItem,
                onClearAll = { isShowingHistoryClearConfirm = true }
            )
        }

        // 隐私政策链接
        Text(
            text = "隐私政策",
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.outline,
            modifier = Modifier.clickable { showPrivacyDetail = true }
        )

        // 底部留白
        Spacer(modifier = Modifier.size(32.dp))
    }

    // ===== Dialogs =====

    if (isShowingClearConfirm) {
        AlertDialog(
            onDismissRequest = { isShowingClearConfirm = false },
            title = { Text("清除全部内容？") },
            text = { Text("输入和结果都将被清空。") },
            confirmButton = {
                TextButton(
                    onClick = {
                        clearAll()
                        isShowingClearConfirm = false
                    }
                ) { Text("清除", color = MaterialTheme.colorScheme.error) }
            },
            dismissButton = {
                TextButton(onClick = { isShowingClearConfirm = false }) {
                    Text("取消")
                }
            }
        )
    }

    if (isShowingHistoryClearConfirm) {
        AlertDialog(
            onDismissRequest = { isShowingHistoryClearConfirm = false },
            title = { Text("清空历史记录？") },
            text = { Text("所有 ${history.size} 条历史记录都将被删除。") },
            confirmButton = {
                TextButton(
                    onClick = {
                        history = HistoryStore.clear()
                        isShowingHistoryClearConfirm = false
                    }
                ) { Text("清空", color = MaterialTheme.colorScheme.error) }
            },
            dismissButton = {
                TextButton(onClick = { isShowingHistoryClearConfirm = false }) {
                    Text("取消")
                }
            }
        )
    }

    if (showPrivacyDialog) {
        AlertDialog(
            onDismissRequest = {},
            title = { Text("隐私政策") },
            text = {
                Column(Modifier.verticalScroll(rememberScrollState())) {
                    Text("本应用尊重并保护您的隐私。请您仔细阅读以下条款：",
                        fontSize = 14.sp)
                    Spacer(Modifier.height(12.dp))
                    Text("• 不收集姓名、身份证号、手机号等身份信息",
                        fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Text("• 不收集设备信息、位置信息",
                        fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Text("• 不集成任何第三方 SDK",
                        fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Text("• 不进行任何网络通信",
                        fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Text("• 所有数据仅存储设备本地",
                        fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Text("• 剪贴板权限仅用于「一键复制」",
                        fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Spacer(Modifier.height(12.dp))
                    Text("点击下方「同意并继续」即表示您已阅读并同意以上条款。",
                        fontSize = 12.sp, color = MaterialTheme.colorScheme.outline)
                }
            },
            confirmButton = {
                TextButton(onClick = ::acceptPrivacyPolicy) {
                    Text("同意并继续")
                }
            },
            dismissButton = {
                TextButton(onClick = ::exitApp) {
                    Text("不同意并退出", color = MaterialTheme.colorScheme.error)
                }
            }
        )
    }

    if (showPrivacyDetail) {
        AlertDialog(
            onDismissRequest = { showPrivacyDetail = false },
            title = { Text("隐私政策") },
            text = {
                Column(Modifier.verticalScroll(rememberScrollState())) {
                    Text("最后更新：2026-06-22",
                        fontSize = 12.sp, color = MaterialTheme.colorScheme.outline)
                    Spacer(Modifier.height(12.dp))
                    Text("本应用（以下简称\"本 App\"）由个人开发者 Piao 开发，深知个人信息保护的重要性，特此向用户说明本 App 如何收集、使用、存储和保护用户信息。请用户在使用本 App 前仔细阅读本政策。")
                    Spacer(Modifier.height(12.dp))
                    Text("一、本 App 不收集的信息",
                        fontWeight = FontWeight.Medium)
                    Spacer(Modifier.height(8.dp))
                    Text("本 App 不会收集、存储、上传以下任何信息：",
                        fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Text("• 用户身份信息（姓名、身份证号、手机号、邮箱等）",
                        fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Text("• 设备信息（设备型号、IMEI、MAC 地址等）",
                        fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Text("• 位置信息（GPS、IP 定位等）",
                        fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Text("• 任何形式的网络请求数据",
                        fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Text("• 任何第三方 SDK 的数据共享",
                        fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Spacer(Modifier.height(12.dp))
                    Text("二、使用的系统权限",
                        fontWeight = FontWeight.Medium)
                    Spacer(Modifier.height(8.dp))
                    Text("剪贴板访问：仅用于「一键复制」功能，用户主动点击按钮时触发。本 App 不会主动读取剪贴板内容。",
                        fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Spacer(Modifier.height(12.dp))
                    Text("三、数据处理方式",
                        fontWeight = FontWeight.Medium)
                    Spacer(Modifier.height(8.dp))
                    Text("所有用户输入和转换结果仅存储在设备内存中，不写本地数据库、不写文件。历史记录最多 10 条，重启 App 后清空。",
                        fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Spacer(Modifier.height(12.dp))
                    Text("四、网络行为",
                        fontWeight = FontWeight.Medium)
                    Spacer(Modifier.height(8.dp))
                    Text("本 App 完全不进行任何网络通信：不发起 HTTP/HTTPS 请求，不连接任何服务器，不使用任何第三方网络 SDK，不使用任何统计分析、崩溃上报、推送服务。",
                        fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Spacer(Modifier.height(12.dp))
                    Text("五、联系方式",
                        fontWeight = FontWeight.Medium)
                    Spacer(Modifier.height(8.dp))
                    Text("邮箱：w_PiaoPiao2026@163.com",
                        fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Text("GitHub：github.com/w-PiaoPiao/FinanceNumberConverter",
                        fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            },
            confirmButton = {
                TextButton(onClick = { showPrivacyDetail = false }) {
                    Text("关闭")
                }
            }
        )
    }

    if (showTutorial) {
        val tutorialSteps = listOf(
            "在输入框中输入金额数字，\n例如 1234.56",
            "点击「转换为大写」按钮\n查看转换结果",
            "结果可一键复制，\n也可分享给其他应用"
        )
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color.Black.copy(alpha = 0.45f))
                .clickable {
                    if (tutorialStep < 2) {
                        tutorialStep++
                    } else {
                        showTutorial = false
                        context.getSharedPreferences("fnc_prefs", Context.MODE_PRIVATE)
                            .edit().putBoolean("has_shown_tutorial", true).apply()
                    }
                },
            contentAlignment = Alignment.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.padding(32.dp)
            ) {
                Text(
                    text = "步骤 ${tutorialStep + 1}/3",
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                Spacer(Modifier.height(12.dp))
                Text(
                    text = tutorialSteps[tutorialStep],
                    fontSize = 16.sp,
                    color = Color.White.copy(alpha = 0.9f),
                    textAlign = TextAlign.Center,
                    lineHeight = 24.sp
                )
                Spacer(Modifier.height(24.dp))
                Button(
                    onClick = {
                        if (tutorialStep < 2) {
                            tutorialStep++
                        } else {
                            showTutorial = false
                            context.getSharedPreferences("fnc_prefs", Context.MODE_PRIVATE)
                                .edit().putBoolean("has_shown_tutorial", true).apply()
                        }
                    },
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Text(
                        text = if (tutorialStep == 2) "开始使用" else "下一步",
                        fontSize = 17.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
        }
    }
}

// ===== 子组件 =====

@Composable
private fun HeaderSection() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 12.dp),
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Text(
            text = "财务大写转换",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onBackground
        )
        // 副标题行：副标题 + Spacer + 作者声明
        Row(
            verticalAlignment = Alignment.Bottom,
            horizontalArrangement = Arrangement.SpaceBetween,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(
                text = "金额大写转换",
                fontSize = 13.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                text = "Designed by Piao · Powered by opencode",
                fontSize = 10.sp,
                color = MaterialTheme.colorScheme.outline,
                maxLines = 1
            )
        }
    }
}

@Composable
private fun InputSection(
    input: String,
    onInputChange: (String) -> Unit,
    helpText: String,
    helpIsError: Boolean,
    hasInputError: Boolean,
) {
    val borderColor = if (hasInputError) {
        MaterialTheme.colorScheme.error.copy(alpha = 0.5f)
    } else {
        MaterialTheme.colorScheme.outline
    }

    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        BasicTextField(
            value = input,
            onValueChange = onInputChange,
            textStyle = TextStyle(
                fontSize = 24.sp,
                color = MaterialTheme.colorScheme.onSurface
            ),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
            singleLine = true,
            cursorBrush = androidx.compose.ui.graphics.SolidColor(MaterialTheme.colorScheme.primary),
            decorationBox = { innerTextField ->
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(MaterialTheme.colorScheme.surface)
                        .border(1.dp, borderColor, RoundedCornerShape(10.dp))
                        .clip(RoundedCornerShape(10.dp))
                        .padding(horizontal = 16.dp, vertical = 16.dp),
                    contentAlignment = Alignment.CenterStart
                ) {
                    if (input.isEmpty()) {
                        Text(
                            text = "请输入金额",
                            fontSize = 24.sp,
                            color = MaterialTheme.colorScheme.outline
                        )
                    }
                    innerTextField()
                }
            }
        )

        // 帮助/错误提示
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(4.dp),
            modifier = Modifier.padding(start = 4.dp)
        ) {
            if (helpIsError) {
                Icon(
                    imageVector = Icons.Filled.ErrorOutline,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.error,
                    modifier = Modifier.size(12.dp)
                )
            }
            Text(
                text = helpText,
                fontSize = if (helpIsError) 13.sp else 12.sp,
                color = if (helpIsError) {
                    MaterialTheme.colorScheme.error
                } else {
                    MaterialTheme.colorScheme.outline
                }
            )
        }
    }
}

@Composable
private fun PrimaryButton(
    text: String,
    enabled: Boolean,
    onClick: () -> Unit
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()

    Button(
        onClick = onClick,
        enabled = enabled,
        interactionSource = interactionSource,
        shape = RoundedCornerShape(10.dp),
        modifier = Modifier
            .fillMaxWidth()
            .height(50.dp)
            .graphicsLayer {
                scaleX = if (isPressed) 0.97f else 1f
                scaleY = if (isPressed) 0.97f else 1f
            },
        colors = ButtonDefaults.buttonColors(
            containerColor = MaterialTheme.colorScheme.onSurface,
            contentColor = MaterialTheme.colorScheme.surface,
            disabledContainerColor = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.3f),
            disabledContentColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.6f),
        )
    ) {
        Text(
            text = text,
            fontSize = 17.sp,
            fontWeight = FontWeight.SemiBold
        )
    }
}

@Composable
private fun ResultSection(
    result: String,
    isCopied: Boolean,
    onCopy: () -> Unit,
    onShare: () -> Unit
) {
    val borderColor = if (isCopied) {
        MaterialTheme.colorScheme.primary.copy(alpha = 0.4f)
    } else {
        MaterialTheme.colorScheme.outline
    }
    val textColor = if (isCopied) {
        MaterialTheme.colorScheme.primary
    } else {
        MaterialTheme.colorScheme.onSurface
    }
    val copyInteractionSource = remember { MutableInteractionSource() }
    val isCopyPressed by copyInteractionSource.collectIsPressedAsState()
    val shareInteractionSource = remember { MutableInteractionSource() }
    val isSharePressed by shareInteractionSource.collectIsPressedAsState()

    Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
        // 结果文字
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(MaterialTheme.colorScheme.surface)
                    .border(1.dp, MaterialTheme.colorScheme.outline, RoundedCornerShape(10.dp))
                    .clip(RoundedCornerShape(10.dp))
                    .padding(horizontal = 16.dp, vertical = 20.dp),
                contentAlignment = Alignment.Center
            ) {
                SelectionContainer {
                    Text(
                        text = result,
                        fontSize = 28.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = MaterialTheme.colorScheme.onSurface,
                        textAlign = TextAlign.Center,
                        lineHeight = 32.sp
                    )
                }
            }

        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            // 复制按钮
            Row(
                modifier = Modifier
                    .weight(1f)
                    .height(44.dp)
                    .border(1.dp, borderColor, RoundedCornerShape(10.dp))
                    .clip(RoundedCornerShape(10.dp))
                    .graphicsLayer {
                        scaleX = if (isCopyPressed) 0.97f else 1f
                        scaleY = if (isCopyPressed) 0.97f else 1f
                    }
                    .clickable(
                        interactionSource = copyInteractionSource,
                        indication = null,
                        onClick = onCopy
                    ),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = if (isCopied) Icons.Filled.Check else Icons.Filled.ContentCopy,
                    contentDescription = null,
                    tint = textColor,
                    modifier = Modifier.size(14.dp)
                )
                Spacer(modifier = Modifier.size(6.dp))
                Text(
                    text = if (isCopied) "已复制" else "一键复制",
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Medium,
                    color = textColor
                )
            }

            // 分享按钮
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .border(1.dp, MaterialTheme.colorScheme.outline, RoundedCornerShape(10.dp))
                    .clip(RoundedCornerShape(10.dp))
                    .graphicsLayer {
                        scaleX = if (isSharePressed) 0.97f else 1f
                        scaleY = if (isSharePressed) 0.97f else 1f
                    }
                    .clickable(
                        interactionSource = shareInteractionSource,
                        indication = null,
                        onClick = onShare
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Filled.Share,
                    contentDescription = "分享",
                    tint = MaterialTheme.colorScheme.onSurface,
                    modifier = Modifier.size(20.dp)
                )
            }
        }
    }
}

@Composable
private fun EmptyResultHint() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 48.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text(
            text = "¥",
            fontSize = 48.sp,
            fontWeight = FontWeight.Light,
            color = MaterialTheme.colorScheme.outline
        )
        Text(
            text = "输入金额后点击「转换为大写」",
            fontSize = 13.sp,
            color = MaterialTheme.colorScheme.outline
        )
    }
}

@Composable
private fun HistoryList(
    history: List<HistoryItem>,
    copiedHistoryId: String?,
    onCopyItem: (HistoryItem) -> Unit,
    onClearAll: () -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        // 标题 + 清空
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 4.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = "历史记录",
                fontSize = 15.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text(
                    text = "最多 ${HistoryStore.MAX_ITEMS} 条",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.outline
                )
                Text(
                    text = "清空",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Medium,
                    color = MaterialTheme.colorScheme.error,
                    modifier = Modifier.clickable(onClick = onClearAll)
                )
            }
        }

        // 列表
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            history.forEach { item ->
                HistoryRow(
                    item = item,
                    isJustCopied = copiedHistoryId == item.id.toString(),
                    onCopy = { onCopyItem(item) }
                )
            }
        }
    }
}

// ===== 工具 =====

private fun copyToClipboard(context: Context, text: String) {
    val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
    val clip = ClipData.newPlainText("财务大写", text)
    clipboard.setPrimaryClip(clip)
}
