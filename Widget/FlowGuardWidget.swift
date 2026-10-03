//
//  FlowGuardWidget.swift
//  FlowGuardWidget
//
//  桌面 / 锁屏小组件 + 控制中心胶囊
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - 数据条目

struct FlowEntry: TimelineEntry {
    let date: Date
    let stats: SharedStats.Snapshot
}

// MARK: - 数据提供者

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> FlowEntry {
        FlowEntry(date: Date(), stats: SharedStats.Snapshot())
    }

    func getSnapshot(in context: Context, completion: @escaping (FlowEntry) -> Void) {
        completion(FlowEntry(date: Date(), stats: SharedStats.Snapshot()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FlowEntry>) -> Void) {
        let entry = FlowEntry(date: Date(), stats: SharedStats.Snapshot())
        let next = Calendar.current.date(byAdding: .minute, value: 20, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

// MARK: - 小组件配置

@main
struct FlowGuardWidgetBundle: WidgetBundle {
    var body: some Widget {
        FlowGuardWidget()
        FlowSummaryControlWidget()
    }
}

struct FlowGuardWidget: Widget {
    let kind = "FlowGuardWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FlowWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("流量管家")
        .description("查看本月已用与剩余流量")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - 主视图

struct FlowWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: FlowEntry

    private var s: SharedStats.Snapshot { entry.stats }

    private var colors: [Color] {
        if s.isOverLimit { return [Theme.red, Theme.orange] }
        if s.progress >= 0.9 { return [Theme.red, Theme.pink] }
        if s.progress >= 0.8 { return [Theme.orange, Theme.pink] }
        return [Theme.blue, Theme.cyan]
    }

    private var isAccessory: Bool {
        family == .accessoryRectangular || family == .accessoryInline
    }

    var body: some View {
        content
            .containerBackground(for: .widget) {
                if isAccessory {
                    Color.clear
                } else {
                    widgetBackground
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemMedium:
            mediumView
        case .accessoryRectangular:
            rectangularView
        case .accessoryInline:
            inlineView
        default:
            smallView
        }
    }

    private var widgetBackground: some View {
        LinearGradient(
            colors: [Theme.blue.opacity(0.10), Color(.systemBackground)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // 锁屏：矩形（直接显示已用 / 剩余，整数避免截断）
    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: "antenna.radiowaves.left.and.right")
                Text("流量").font(.system(size: 12, weight: .semibold))
                Spacer()
                Text("剩 \(Int(s.remainingGB.rounded())) GB")
                    .font(.system(size: 12, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(Int(s.usedGB.rounded()))")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text("GB 已用").font(.system(size: 11))
                Spacer()
                Text("\(Int((s.progress * 100).rounded()))%")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // 锁屏：时钟上方单行
    private var inlineView: some View {
        Text("已用 \(Int(s.usedGB.rounded())) GB · 剩 \(Int(s.remainingGB.rounded())) GB")
    }

    // 小尺寸
    private var smallView: some View {
        VStack(spacing: 10) {
            HStack {
                Text("流量管家")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.blue)
                Spacer()
            }
            ZStack {
                WidgetRing(progress: s.progress, colors: colors, lineWidth: 11)
                Text("\(Int((s.progress * 100).rounded()))%")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(colors[0])
            }
            .frame(width: 108, height: 108)

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(String(format: "%.1f", s.usedGB))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Text("GB 已用")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(12)
    }

    // 中尺寸
    private var mediumView: some View {
        HStack(spacing: 12) {
            ZStack {
                WidgetRing(progress: s.progress, colors: colors, lineWidth: 12)
                VStack(spacing: 1) {
                    Text("\(Int((s.progress * 100).rounded()))%")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(colors[0])
                    Text("已用")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 114, height: 114)

            VStack(alignment: .leading, spacing: 8) {
                WidgetRow(label: "已用", value: String(format: "%.1f GB", s.usedGB), color: colors[0])
                WidgetRow(label: "剩余", value: String(format: "%.1f GB", s.remainingGB), color: Theme.green)
                WidgetRow(label: "日均", value: String(format: "%.2f GB", s.averageDailyGB), color: Theme.purple)
                WidgetRow(label: "距重置", value: "\(s.daysRemaining) 天", color: Theme.blue)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
    }
}

// MARK: - 小组件用环

struct WidgetRing: View {
    let progress: Double
    let colors: [Color]
    var lineWidth: CGFloat = 11

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(CGFloat(min(max(progress, 0), 1)), 0.001))
                .stroke(
                    LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - 数据行

struct WidgetRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 36, alignment: .leading)
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
            Spacer(minLength: 0)
        }
    }
}

// MARK: - 控制中心控件（iOS 18+）

struct FlowSummaryControlWidget: ControlWidget {
    let kind = "com.flowguard.traffic.control.summary"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: kind) {
            ControlWidgetButton(action: OpenFlowGuardIntent()) {
                let s = SharedStats.Snapshot()
                Label(
                    "用\(Int(s.usedGB.rounded())) 剩\(Int(s.remainingGB.rounded())) GB",
                    systemImage: "antenna.radiowaves.left.and.right"
                )
            }
            .tint(Theme.blue)
        }
        .displayName("流量用量")
        .description("控制中心显示本月已用与剩余流量，点击打开 App")
    }
}
