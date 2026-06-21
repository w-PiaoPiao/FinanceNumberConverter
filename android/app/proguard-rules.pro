# R8 规则（ProGuard）
# 当前 release build 关闭了 minify，所以这些规则暂未生效
# 阶段 5 启用 R8 时按需添加

# 保留 Compose 相关类
-keep class androidx.compose.** { *; }

# 保留 Kotlin metadata
-keep class kotlin.Metadata { *; }
-keep class kotlin.reflect.** { *; }

# 测试
-dontwarn junit.**
