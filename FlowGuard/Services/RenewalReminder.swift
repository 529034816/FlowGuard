//
//  RenewalReminder.swift
//  FlowGuard
//
//  根据签名过期时间，安排“到期前一天”的本地通知，提醒打开 AltStore 续签。
//  本地通知一旦调度，由系统按时呈现，不依赖 App 正在运行。
//

import Foundation
import UserNotifications

enum RenewalReminder {
    static let identifier = "flowguard-renewal-reminder"

    static func schedule() {
        guard let expiration = ProvisionProfile.expirationDate() else { return }
        let center = UNUserNotificationCenter.current()
        let cal = Calendar.current

        // 到期“前一天”的上午 9:15 提醒
        guard let dayBefore = cal.date(byAdding: .day, value: -1, to: expiration) else { return }
        var comps = cal.dateComponents([.year, .month, .day], from: dayBefore)
        comps.hour = 9
        comps.minute = 15
        var fireDate = cal.date(from: comps) ?? expiration.addingTimeInterval(-24 * 3600)

        // 若距到期已不足一天，改为到期前 6 小时提醒
        if fireDate <= Date() {
            fireDate = expiration.addingTimeInterval(-6 * 3600)
        }
        // 连 6 小时都不足，就不再调度（避免立即弹出过期通知）
        if fireDate <= Date() { return }

        let content = UNMutableNotificationContent()
        content.title = "流量管家明天到期，请续签"
        content.body = "免费签名即将过期，不续签 App 将无法打开、小组件停止刷新。请在电脑运行 AltServer、手机连同一 WiFi 时，打开 AltStore → My Apps → Refresh All。"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: cal.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate),
            repeats: false
        )
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.add(request)
    }
}
