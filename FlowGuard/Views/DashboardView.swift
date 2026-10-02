//
//  DashboardView.swift
//  FlowGuard
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var monitor: TrafficMonitor

    // MARK: 颜色状态

    private var ringColors: [Color] {
        if monitor.isOverLimit { return [Theme.red, Theme.orange] }
        switch monitor.progress {
        case 0.9...:   return [Theme.red, Theme.pink]
        case 0.8...:   return [Theme.orange, Theme.pink]
        default:       return [Theme.blue, Theme.cyan]
        }
    }

    private var accent: Color {
        if monitor.isOverLimit { return .red }
        switch monitor.progress {
        case 0.8...: return .orange
        default:     return Theme.blue
        }
    }

    var body: some View {
        ZStack {
            ScreenBackground()

            ScrollView {
                VStack(spacing: 18) {
                    header
                    ringSection
                    statusBanner
                    statsGrid
                    forecastCard
                    footer
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 18)
            }
        }
    }

    // MARK: 顶部

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("流量管家")
                    .font(.title2.weight(.bold))
                Text("账期第 \(monitor.dayOfPeriod) 天 · 还剩 \(monitor.daysRemaining) 天")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                monitor.sample()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.blue)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(.white))
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            }
            .accessibilityLabel("刷新统计")
        }
    }

    // MARK: 进度环

    private var ringSection: some View {
        ZStack {
            ProgressRing(progress: monitor.progress, colors: ringColors, lineWidth: 23)
                .frame(width: 252, height: 252)

            VStack(spacing: 3) {
                Text("已用 \(Int((monitor.progress * 100).rounded()))%")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(accent.opacity(0.14)))

                Text(String(format: "%.1f", monitor.usedGB))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .padding(.top, 6)

                Text("GB 已用")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("剩余 \(String(format: "%.1f", monitor.remainingGB)) GB")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.green)
                    .padding(.top, 6)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: 状态横幅

    private var statusBanner: some View {
        if monitor.isOverLimit {
            StatusBanner(
                icon: "exclamationmark.octagon.fill",
                title: "已超出套餐",
                message: "本期已超出 \(String(format: "%.1f", monitor.usedGB - monitor.planGB)) GB，请立即在控制中心关闭蜂窝数据。",
                color: .red
            )
        } else if monitor.projectedWillExceed {
            StatusBanner(
                icon: "exclamationmark.triangle.fill",
                title: "预计将超出套餐",
                message: "按当前用量预计超出 \(String(format: "%.1f", monitor.projectedUsageGB - monitor.planGB)) GB，建议减少视频、热点等高耗流量使用。",
                color: .orange
            )
        } else {
            StatusBanner(
                icon: "checkmark.seal.fill",
                title: "用量正常",
                message: "按当前节奏，账期结束时预计使用 \(String(format: "%.1f", monitor.projectedUsageGB)) GB，不会超出套餐。",
                color: .green
            )
        }
    }

    // MARK: 数据网格

    private var statsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
            spacing: 14
        ) {
            MetricCell(
                title: "剩余可用",
                value: String(format: "%.1f GB", monitor.remainingGB),
                icon: "internaldrive",
                color: Theme.green
            )
            MetricCell(
                title: "距账期重置",
                value: "\(monitor.daysRemaining) 天",
                icon: "calendar",
                color: Theme.blue
            )
            MetricCell(
                title: "本期日均",
                value: String(format: "%.2f GB", monitor.averageDailyGB),
                icon: "chart.bar.fill",
                color: Theme.purple
            )
            MetricCell(
                title: "账期进度",
                value: "\(monitor.dayOfPeriod)/\(monitor.totalDaysInPeriod) 天",
                icon: "calendar.day.timeline.left",
                color: Theme.indigo
            )
        }
    }

    // MARK: 预测卡片

    private var forecastCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                IconBadge("crystalball", color: Theme.indigo, size: 36)
                Text("用量预测").font(.headline)
                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(String(format: "%.1f", monitor.projectedUsageGB))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.indigo)
                Text("GB").font(.subheadline).foregroundStyle(.secondary)
                Spacer()
                Text("套餐 \(String(format: "%.0f", monitor.planGB)) GB")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(forecastDescription)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .card()
    }

    private var forecastDescription: String {
        if monitor.isOverLimit {
            return "本期已超出套餐，建议立即关闭蜂窝数据，避免产生额外费用。"
        }
        if monitor.projectedWillExceed {
            return "按日均 \(String(format: "%.2f", monitor.averageDailyGB)) GB 推算，账期结束时预计超出 \(String(format: "%.1f", monitor.projectedUsageGB - monitor.planGB)) GB。"
        }
        return "按日均 \(String(format: "%.2f", monitor.averageDailyGB)) GB 推算，账期结束时不会超出套餐。"
    }

    // MARK: 底部

    @ViewBuilder
    private var footer: some View {
        if let date = monitor.lastSampleDate {
            Text("上次更新 \(date.formatted(date: .omitted, time: .shortened)) · 1 GB = 1024 MB")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 2)
        }
    }
}

// MARK: - 状态横幅

struct StatusBanner: View {
    let icon: String
    let title: String
    let message: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(icon, color: color, size: 38)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(color)
                Text(message).font(.caption).foregroundStyle(.primary.opacity(0.75))
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(color.opacity(0.12))
        )
    }
}

// MARK: - 指标卡片

struct MetricCell: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 11) {
            IconBadge(icon, color: color, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(13)
        .card()
    }
}

#Preview {
    DashboardView()
        .environmentObject(TrafficMonitor.shared)
}
