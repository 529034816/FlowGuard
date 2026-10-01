//
//  BackgroundTaskManager.swift
//  FlowGuard
//

import Foundation
import BackgroundTasks

final class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    private init() {}

    let refreshTaskIdentifier = "com.flowguard.traffic.refresh"

    /// 必须在 App 启动周期内调用（见 AppDelegate.didFinishLaunching）。
    func register() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: refreshTaskIdentifier,
            using: nil
        ) { task in
            Task { @MainActor in
                TrafficMonitor.shared.sample()
                BackgroundTaskManager.shared.scheduleNextRefresh()
                task.setTaskCompleted(success: true)
            }
        }
    }

    func scheduleNextRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 20 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // 提交失败（重复提交或运行环境不支持）可安全忽略
        }
    }
}
