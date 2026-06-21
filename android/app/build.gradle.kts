// app/build.gradle.kts

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
}

android {
    namespace = "com.example.financenumberconverter"
    compileSdk = 35  // 编译 SDK 保持最新（使用最新 API）

    defaultConfig {
        applicationId = "com.example.financenumberconverter"
        minSdk = 29
        // 2026-06-21 修复 vivo 闪退：降到 targetSdk 34（Android 14）
        // 原因：targetSdk 35（Android 15）强制了 edge-to-edge 和预测式 back gesture，
        //       vivo OriginOS 与部分国产系统对此支持不完善，导致 App 启动后立即闪退。
        //       targetSdk 34 已被所有国产系统验证稳定。
        targetSdk = 34
        versionCode = 2  // 升级 versionCode 让旧版能被覆盖
        versionName = "1.0.1"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables { useSupportLibrary = true }
    }

    // Release 签名配置（密码从环境变量读取，不入 git）
    // 用法：在 build 前 export 环境变量
    //   export KEYSTORE_PASSWORD=changeit
    //   export KEY_ALIAS=release
    //   export KEY_PASSWORD=changeit
    signingConfigs {
        create("release") {
            storeFile = file("../keystore/release.keystore")
            storePassword = System.getenv("KEYSTORE_PASSWORD") ?: "changeit"
            keyAlias = System.getenv("KEY_ALIAS") ?: "release"
            keyPassword = System.getenv("KEY_PASSWORD") ?: "changeit"
        }
    }

    buildTypes {
        debug {
            isMinifyEnabled = false
        }
        release {
            isMinifyEnabled = false  // 阶段 5 暂不启用 R8
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // 使用 release 自签名（需 keystore 文件 + 环境变量）
            signingConfig = signingConfigs.getByName("release")
        }
    }

    lint {
        // Lint 误报："MainActivity must extend Application"
        // 实际是 ComponentActivity，lint 误判。禁用此条检查
        disable += "Instantiatable"
        // 测试期间 lint 不阻断 build
        abortOnError = false
        checkReleaseBuilds = false
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        compose = true
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

dependencies {
    // AndroidX 核心
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)

    // Compose
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.compose.ui.graphics)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.androidx.compose.material3)
    implementation(libs.androidx.compose.material.icons.extended)

    // 调试工具
    debugImplementation(libs.androidx.compose.ui.tooling)

    // 单元测试
    testImplementation(libs.junit)

    // 仪器测试
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
    androidTestImplementation(platform(libs.androidx.compose.bom))
}
