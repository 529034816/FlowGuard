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
        // 尽早设置通知代理，保证前台也能弹横幅
        _ = NotificationService.shared
        return true
    }
}

@main
struct FlowGuardApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var monitor = TrafficMonitor.shared
    @Environment(\.scenePhase) private var scenePhase
    // 前台定时采样：每 60 秒结算一次增量，保证前台数字持续刷新
    private let foregroundTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(monitor)
                .onAppear {
                    BackgroundTaskManager.shared.scheduleNextRefresh()
                    monitor.sample()
                    RenewalReminder.schedule()
                }
                .onReceive(foregroundTimer) { _ in
                    if scenePhase == .active {
                        monitor.sample()
                    }
                }
                .onChange(of: scenePhase) { phase in
                    if phase == .active || phase == .background {
                        monitor.sample()
                    }
                    if phase == .active {
                        // 续签后过期时间会更新，回到前台时重新计算提醒
                        RenewalReminder.schedule()
                    }
                    if phase == .background {
                        BackgroundTaskManager.shared.scheduleNextRefresh()
                    }
                }
        }
    }
}
