//
//  FlowGuardApp.swift
//  FlowGuard
//

import SwiftUI
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 后台任务必须在启动周期内注册
        BackgroundTaskManager.shared.register()
        return true
    }
}

@main
struct FlowGuardApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var monitor = TrafficMonitor.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(monitor)
                .onAppear {
                    BackgroundTaskManager.shared.scheduleNextRefresh()
                    monitor.sample()
                }
                .onChange(of: scenePhase) { phase in
                    if phase == .active || phase == .background {
                        monitor.sample()
                    }
                    if phase == .background {
                        BackgroundTaskManager.shared.scheduleNextRefresh()
                    }
                }
        }
    }
}
