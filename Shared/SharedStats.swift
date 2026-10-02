//
//  SharedStats.swift
//  Shared (主 App 与 Widget 共用)
//
//  通过 App Group 让 Widget 读取主 App 的流量统计。
//

import Foundation

struct SharedStats {
    /// 必须与两个 target 的 entitlements 中声明的 App Group 一致。
    static let appGroupID = "group.com.flowguard.traffic"
    static var suite: UserDefaults? { UserDefaults(suiteName: appGroupID) }

    enum Key {
        static let usedGB = "shared.usedGB"
        static let planGB = "shared.planGB"
        static let remainingGB = "shared.remainingGB"
        static let progress = "shared.progress"
        static let daysRemaining = "shared.daysRemaining"
        static let dayOfPeriod = "shared.dayOfPeriod"
        static let totalDays = "shared.totalDays"
        static let isOverLimit = "shared.isOverLimit"
        static let projectedWillExceed = "shared.projectedWillExceed"
        static let averageDailyGB = "shared.averageDailyGB"
        static let updatedAt = "shared.updatedAt"
    }

    /// 主 App 在统计更新后调用，把 Widget 需要的字段写入共享容器。
    static func publish(
        usedGB: Double,
        planGB: Double,
        remainingGB: Double,
        progress: Double,
        daysRemaining: Int,
        dayOfPeriod: Int,
        totalDays: Int,
        isOverLimit: Bool,
        projectedWillExceed: Bool,
        averageDailyGB: Double
    ) {
        guard let d = suite else { return }
        d.set(usedGB, forKey: Key.usedGB)
        d.set(planGB, forKey: Key.planGB)
        d.set(remainingGB, forKey: Key.remainingGB)
        d.set(progress, forKey: Key.progress)
        d.set(daysRemaining, forKey: Key.daysRemaining)
        d.set(dayOfPeriod, forKey: Key.dayOfPeriod)
        d.set(totalDays, forKey: Key.totalDays)
        d.set(isOverLimit, forKey: Key.isOverLimit)
        d.set(projectedWillExceed, forKey: Key.projectedWillExceed)
        d.set(averageDailyGB, forKey: Key.averageDailyGB)
        d.set(Date(), forKey: Key.updatedAt)
    }

    /// Widget 读取的只读快照。
    struct Snapshot {
        var usedGB: Double = 0
        var planGB: Double = 120
        var remainingGB: Double = 120
        var progress: Double = 0
        var daysRemaining: Int = 30
        var dayOfPeriod: Int = 1
        var totalDays: Int = 30
        var isOverLimit: Bool = false
        var projectedWillExceed: Bool = false
        var averageDailyGB: Double = 0
        var updatedAt: Date?

        init() {
            guard let d = SharedStats.suite else { return }
            usedGB = d.double(forKey: Key.usedGB)
            planGB = d.object(forKey: Key.planGB) as? Double ?? 120
            remainingGB = d.object(forKey: Key.remainingGB) as? Double ?? planGB
            progress = d.double(forKey: Key.progress)
            daysRemaining = d.object(forKey: Key.daysRemaining) as? Int ?? 30
            dayOfPeriod = d.object(forKey: Key.dayOfPeriod) as? Int ?? 1
            totalDays = d.object(forKey: Key.totalDays) as? Int ?? 30
            isOverLimit = d.bool(forKey: Key.isOverLimit)
            projectedWillExceed = d.bool(forKey: Key.projectedWillExceed)
            averageDailyGB = d.double(forKey: Key.averageDailyGB)
            updatedAt = d.object(forKey: Key.updatedAt) as? Date
        }
    }
}
