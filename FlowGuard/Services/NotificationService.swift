//
//  NotificationService.swift
//  FlowGuard
//

import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                continuation.resume(returning: settings.authorizationStatus)
            }
        }
    }

    /// 发送阈值本地通知。identifier 固定为对应阈值，重复触发时自动覆盖旧通知。
    func sendThresholdAlert(percentage: Double, usedGB: Double, planGB: Double) {
        let content = UNMutableNotificationContent()
        content.sound = .default
        let usedText = String(format: "%.1f", usedGB)
        let planText = String(format: "%.0f", planGB)

        if percentage >= 1.0 {
            content.title = "流量已用完，请手动关闭蜂窝数据"
            content.body = "本期已用 \(usedText)GB / \(planText)GB。iPhone 不允许第三方 App 自动断网，请下拉控制中心，长按蜂窝数据图标手动关闭。"
            content.interruptionLevel = .timeSensitive
        } else {
            let percentText = String(format: "%.0f", percentage * 100)
            content.title = "流量已用 \(percentText)%，注意控制"
            content.body = "本期已用 \(usedText)GB / \(planText)GB。"
        }

        let request = UNNotificationRequest(
            identifier: "flowguard-threshold-\(String(format: "%.0f", percentage * 100))",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
