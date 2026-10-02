//
//  RenewalReminder.swift
//  FlowGuard
//
//  根据签名过期时间安排本地通知，提醒打开 AltStore 续签。
//  本地通知一旦调度，由系统按时呈现，不依赖 App 正在运行（即使 App 已过期，已调度的通知仍会弹出）。
//

import Foundation
import UserNotifications

enum RenewalReminder {
    static let dayBeforeID = "flowguard-renewal-daybefore"
    static let finalID = "flowguard-renewal-final"

    static func schedule() {
        guard let expiration = ProvisionProfile.expirationDate() else { return }
        let center = UNUserNotificationCenter.current()
        let cal = Calendar.current

        // 提醒 1：到期“前一天”的上午 9:15
        guard let dayBefore = cal.date(byAdding: .day, value: -1, to: expiration) else { return }
        var c1 = cal.dateComponents([.year, .month, .day], from: dayBefore)
        c1.hour = 9
        c1.minute = 15
        var fire1 = cal.date(from: c1) ?? expiration.addingTimeInterval(-24 * 3600)
        // 若已过前一天 9:15，改为到期前 6 小时
        if fire1 <= Date() { fire1 = expiration.addingTimeInterval(-6 * 3600) }

        // 提醒 2：到期前 3 小时（最后兜底）
        let fire2 = expiration.addingTimeInterval(-3 * 3600)

        center.removePendingNotificationRequests(withIdentifiers: [dayBeforeID, finalID])

        if fire1 > Date() {
            let content = UNMutableNotificationContent()
            content.title = "流量管家明天到期，请续签"
            content.body = "免费签名明天过期，不续签 App 将打不开、小组件停止刷新。请在电脑运行 AltServer、手机连同一 WiFi 时，打开 AltStore → My Apps → Refresh All。"
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: cal.dateComponents([.year, .month, .day, .hour, .minute], from: fire1),
                repeats: false
            )
            center.add(UNNotificationRequest(identifier: dayBeforeID, content: content, trigger: trigger))
        }

        if fire2 > Date() {
            let content = UNMutableNotificationContent()
            content.title = "流量管家约 3 小时后到期，请尽快续签"
            content.body = "电脑运行 AltServer、手机连同一 WiFi，打开 AltStore → My Apps → Refresh All。"
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: cal.dateComponents([.year, .month, .day, .hour, .minute], from: fire2),
                repeats: false
            )
            center.add(UNNotificationRequest(identifier: finalID, content: content, trigger: trigger))
        }
    }
}
