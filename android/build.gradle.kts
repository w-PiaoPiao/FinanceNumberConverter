// 项目级 build.gradle.kts
// 声明所有插件（不应用，留给子模块 apply）

plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.kotlin.android) apply false
    alias(libs.plugins.kotlin.compose) apply false
}
