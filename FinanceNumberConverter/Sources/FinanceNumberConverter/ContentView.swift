//
//  ContentView.swift
//  FinanceNumberConverter
//
//  阶段 1 占位视图，显示默认 Hello World 界面。阶段 3 替换为完整 UI。
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
