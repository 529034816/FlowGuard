//
//  TrafficMonitor.swift
//  FlowGuard
//

import Foundation
import SwiftUI
import WidgetKit

@MainActor
final class TrafficMonitor: ObservableObject {
    static let shared = TrafficMonitor()

    static let gib: Double = 1024 * 1024 * 1024

    // MARK: - 套餐设置

    @Published var planGB: Double {
        didSet { defaults.set(planGB, forKey: Keys.planGB) }
    }
    @Published var billingDay: Int {
        didSet { defaults.set(billingDay, forKey: Keys.billingDay) }
    }
    @Published var alert50Enabled: Bool {
        didSet { defaults.set(alert50Enabled, forKey: Keys.alert50) }
    }
    @Published var alert80Enabled: Bool {
        didSet { defaults.set(alert80Enabled, forKey: Keys.alert80) }
    }
    @Published var alert90Enabled: Bool {
        didSet { defaults.set(alert90Enabled, forKey: Keys.alert90) }
    }
    @Published var alert100Enabled: Bool {
        didSet { defaults.set(alert100Enabled, forKey: Keys.alert100) }
    }

    // MARK: - 本期统计状态

    @Published private(set) var usedBytes: UInt64 = 0
    @Published private(set) var lastRawValue: UInt64? = nil
    @Published private(set) var periodStartDate: Date = Date()
    @Published private(set) var firedAlertKeys: Set<String> = []
    @Published private(set) var lastSampleDate: Date? = nil

    private let defaults = UserDefaults.standard
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        return calendar
    }()

    private enum Keys {
        static let planGB = "planGB"
        static let billingDay = "billingDay"
        static let alert50 = "alert50"
        static let alert80 = "alert80"
        static let alert90 = "alert90"
        static let alert100 = "alert100"
        static let usedBytes = "usedBytes"
        static let lastRawValue = "lastRawValue"
        static let hasLastRaw = "hasLastRaw"
        static let periodStartDate = "periodStartDate"
        static let firedAlerts = "firedAlerts"
        static let lastSampleDate = "lastSampleDate"
    }

    // MARK: - Init

    private init() {
        planGB = defaults.object(forKey: Keys.planGB) as? Double ?? 120
        billingDay = defaults.object(forKey: Keys.billingDay) as? Int ?? 1
        alert50Enabled = defaults.object(forKey: Keys.alert50) as? Bool ?? false
        alert80Enabled = defaults.object(forKey: Keys.alert80) as? Bool ?? true
        alert90Enabled = defaults.object(forKey: Keys.alert90) as? Bool ?? true
        alert100Enabled = defaults.object(forKey: Keys.alert100) as? Bool ?? true

        usedBytes = UInt64(bitPattern: defaults.object(forKey: Keys.usedBytes) as? Int64 ?? 0)
        if defaults.bool(forKey: Keys.hasLastRaw) {
            lastRawValue = UInt64(bitPattern: defaults.object(forKey: Keys.lastRawValue) as? Int64 ?? 0)
        }
        if let savedStart = defaults.object(forKey: Keys.periodStartDate) as? Date {
            periodStartDate = savedStart
        } else {
            periodStartDate = TrafficMonitor.computePeriodStart(
                billingDay: billingDay,
                date: Date(),
                calendar: calendar
            )
        }
        if let savedFired = defaults.array(forKey: Keys.firedAlerts) as? [String] {
            firedAlertKeys = Set(savedFired)
        }
        lastSampleDate = defaults.object(forKey: Keys.lastSampleDate) as? Date
    }

    // MARK: - 采样与校准

    /// 读取一次系统计数器并结算增量；同时处理账期滚动与阈值提醒。
    func sample() {
        rolloverPeriodIfNeeded()

        let raw = NetworkDataUsage.cellularBytes()
        if let last = lastRawValue {
            if raw >= last {
                usedBytes = usedBytes &+ (raw - last)
            }
            // raw < last：设备重启导致计数器重置；重启期间不产生流量，不补差值。
        }
        // 首次运行（无历史基线）：不把设备启动以来的历史值计入本期，仅建立基线。
        lastRawValue = raw
        lastSampleDate = Date()

        persistState()
        checkThresholds()
    }

    /// 用运营商口径的实际已用流量校准（单位 GB），校准后以此为基线继续估算。
    func calibrate(usedGB value: Double) {
        rolloverPeriodIfNeeded()
        let safeValue = max(0, value)
        usedBytes = UInt64(safeValue * Self.gib)
        lastRawValue = NetworkDataUsage.cellularBytes()
        firedAlertKeys = []
        lastSampleDate = Date()
        persistState()
        checkThresholds()
    }

    /// 设置项变化后调用：重新判定账期与阈值。
    func settingsDidChange() {
        rolloverPeriodIfNeeded()
        checkThresholds()
        persistState()
    }

    // MARK: - 账期

    private func rolloverPeriodIfNeeded() {
        let expectedStart = Self.computePeriodStart(
            billingDay: billingDay,
            date: Date(),
            calendar: calendar
        )
        if !calendar.isDate(expectedStart, inSameDayAs: periodStartDate) {
            periodStartDate = expectedStart
            usedBytes = 0
            firedAlertKeys = []
            // lastRawValue 保留：系统计数器连续，跨账期后的增量计入新周期。
            persistState()
        }
    }

    private static func computePeriodStart(
        billingDay: Int,
        date: Date,
        calendar: Calendar
    ) -> Date {
        let day = min(max(billingDay, 1), 28)
        let monthStart = calendar.date(
            from: calendar.dateComponents([.year, .month], from: date)
        )!
        let thisMonthBilling = calendar.date(bySetting: .day, value: day, of: monthStart)!
        if date >= thisMonthBilling {
            return calendar.startOfDay(for: thisMonthBilling)
        } else {
            let previousMonthBilling = calendar.date(
                byAdding: .month,
                value: -1,
                to: thisMonthBilling
            )!
            return calendar.startOfDay(for: previousMonthBilling)
        }
    }

    var periodEndDate: Date {
        calendar.date(byAdding: .month, value: 1, to: periodStartDate)!
    }

    // MARK: - 派生统计

    var usedGB: Double { Double(usedBytes) / Self.gib }
    var remainingGB: Double { max(planGB - usedGB, 0) }
    var progress: Double { planGB > 0 ? usedGB / planGB : 0 }
    var isOverLimit: Bool { planGB > 0 && usedGB > planGB }

    var totalDaysInPeriod: Int {
        max(calendar.dateComponents([.day], from: periodStartDate, to: periodEndDate).day ?? 30, 1)
    }

    var dayOfPeriod: Int {
        let elapsed = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: periodStartDate),
            to: calendar.startOfDay(for: Date())
        ).day ?? 0
        return min(max(elapsed + 1, 1), totalDaysInPeriod)
    }

    var daysRemaining: Int {
        max(totalDaysInPeriod - dayOfPeriod + 1, 1)
    }

    var averageDailyGB: Double {
        usedGB / Double(dayOfPeriod)
    }

    /// 按本期至今的日均用量，推算账期结束时的总用量。
    var projectedUsageGB: Double {
        averageDailyGB * Double(totalDaysInPeriod)
    }

    var projectedWillExceed: Bool {
        planGB > 0 && projectedUsageGB > planGB
    }

    // MARK: - 阈值提醒

    private struct Threshold {
        let key: String
        let value: Double
        let enabled: Bool
    }

    private func checkThresholds() {
        guard planGB > 0 else { return }
        let thresholds = [
            Threshold(key: "50", value: 0.50, enabled: alert50Enabled),
            Threshold(key: "80", value: 0.80, enabled: alert80Enabled),
            Threshold(key: "90", value: 0.90, enabled: alert90Enabled),
            Threshold(key: "100", value: 1.00, enabled: alert100Enabled)
        ]
        for threshold in thresholds where threshold.enabled {
            if usedGB >= planGB * threshold.value && !firedAlertKeys.contains(threshold.key) {
                firedAlertKeys.insert(threshold.key)
                NotificationService.shared.sendThresholdAlert(
                    percentage: threshold.value,
                    usedGB: usedGB,
                    planGB: planGB
                )
            }
        }
    }

    // MARK: - 持久化

    private func persistState() {
        defaults.set(Int64(bitPattern: usedBytes), forKey: Keys.usedBytes)
        if let raw = lastRawValue {
            defaults.set(Int64(bitPattern: raw), forKey: Keys.lastRawValue)
            defaults.set(true, forKey: Keys.hasLastRaw)
        } else {
            defaults.set(false, forKey: Keys.hasLastRaw)
        }
        defaults.set(periodStartDate, forKey: Keys.periodStartDate)
        defaults.set(Array(firedAlertKeys), forKey: Keys.firedAlerts)
        defaults.set(lastSampleDate, forKey: Keys.lastSampleDate)

        publishShared()
    }

    /// 同步给桌面 Widget（经 App Group）。
    private func publishShared() {
        SharedStats.publish(
            usedGB: usedGB,
            planGB: planGB,
            remainingGB: remainingGB,
            progress: progress,
            daysRemaining: daysRemaining,
            dayOfPeriod: dayOfPeriod,
            totalDays: totalDaysInPeriod,
            isOverLimit: isOverLimit,
            projectedWillExceed: projectedWillExceed,
            averageDailyGB: averageDailyGB
        )

        // 让桌面 / 锁屏小组件立即重新读取共享数据（校准、采样、设置变化后即时生效）。
        WidgetCenter.shared.reloadAllTimelines()
    }
}
