package com.example.financenumberconverter

import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.ui.Modifier
import com.example.financenumberconverter.ui.screen.ConverterScreen
import com.example.financenumberconverter.ui.theme.FinanceNumberConverterTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        try {
            enableEdgeToEdge()
            setContent {
                FinanceNumberConverterTheme {
                    Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                        androidx.compose.foundation.layout.Box(
                            modifier = Modifier.padding(innerPadding)
                        ) {
                            ConverterScreen()
                        }
                    }
                }
            }
        } catch (e: Throwable) {
            // 防御：避免因 setContent 异常导致静默崩溃
            Log.e("MainActivity", "App init failed", e)
            Toast.makeText(
                this,
                "启动失败：${e.javaClass.simpleName}\n${e.message}",
                Toast.LENGTH_LONG
            ).show()
        }
    }
}
