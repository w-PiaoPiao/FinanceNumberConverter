package com.example.financenumberconverter.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val LightColors = lightColorScheme(
    primary = TextPrimary,            // 主色用近黑（minimalist-ui 风格）
    onPrimary = Surface,
    secondary = TextSecondary,
    onSecondary = Surface,
    background = Background,
    onBackground = TextPrimary,
    surface = Surface,
    onSurface = TextPrimary,
    surfaceVariant = Background,
    onSurfaceVariant = TextSecondary,
    error = ErrorRed,
    onError = Surface,
    outline = Divider,
    outlineVariant = TextTertiary,
)

private val DarkColors = darkColorScheme(
    primary = TextPrimaryDark,
    onPrimary = BackgroundDark,
    secondary = TextSecondary,
    background = BackgroundDark,
    onBackground = TextPrimaryDark,
    surface = SurfaceDark,
    onSurface = TextPrimaryDark,
    error = ErrorRed,
    outline = TextTertiary,
)

@Composable
fun FinanceNumberConverterTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colors = if (darkTheme) DarkColors else LightColors
    MaterialTheme(
        colorScheme = colors,
        typography = AppTypography,
        content = content
    )
}
