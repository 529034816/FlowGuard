//
//  RootView.swift
//  FlowGuard
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("用量", systemImage: "speedometer")
                }
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
            InfoView()
                .tabItem {
                    Label("说明", systemImage: "info.circle")
                }
        }
        .tint(Color("AccentColor"))
    }
}

#Preview {
    RootView()
        .environmentObject(TrafficMonitor.shared)
}
