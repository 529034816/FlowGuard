//
//  DashboardView.swift
//  FlowGuard
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var monitor: TrafficMonitor

    private var ringColor: Color {
        if monitor.isOverLimit { return .red }
        switch monitor.progress {
        case ..<0.8: return Color("AccentColor")
        case ..<1.0: return .orange
        default: return .red
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ring
                    statsGrid
                    projectionCard
                    Button {
                        monitor.sample()
                    } label: {
                        Label("立即刷新统计", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    if let date = monitor.lastSampleDate {
                        Text("上次统计：\(date.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("流量管家")
        }
    }

    private var ring: some View {
        ProgressRing(progress: monitor.progress, color: ringColor)
            .frame(width: 230, height: 230)
            .overlay {
                VStack(spacing: 6) {
                    Text(monitor.usedGB, format: .number.precision(.fractionLength(1)))
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundStyle(ringColor)
                    Text("已用 GB")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("套餐 \(String(format: "%.0f", monitor.planGB)) GB")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 8)
    }

    private var statsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 14
        ) {
            StatCard(
                title: "剩余可用",
                value: String(format: "%.1f GB", monitor.remainingGB),
                icon: "internaldrive",
                color: .green
            )
            StatCard(
                title: "距账期重置",
                value: "\(monitor.daysRemaining) 天",
                icon: "calendar",
                color: .blue
            )
            StatCard(
                title: "本期日均",
                value: String(format: "%.2f GB", monitor.averageDailyGB),
                icon: "chart.line.uptrend.xyaxis",
                color: .purple
            )
            StatCard(
                title: "账期进度",
                value: "第 \(monitor.dayOfPeriod)/\(monitor.totalDaysInPeriod) 天",
                icon: "calendar.day.timeline.left",
                color: .indigo
            )
        }
    }

    private var projectionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("用量预测", systemImage: "crystalball")
                .font(.headline)
            Text("按当前日均 \(String(format: "%.2f", monitor.averageDailyGB)) GB 推算，账期结束时预计使用 \(String(format: "%.1f", monitor.projectedUsageGB)) GB。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if monitor.isOverLimit {
                Label("已超出套餐 \(String(format: "%.1f", monitor.usedGB - monitor.planGB)) GB，请尽快在控制中心关闭蜂窝数据。",
                      systemImage: "exclamationmark.octagon.fill")
                    .font(.footnote)
                    .foregroundStyle(.red)
            } else if monitor.projectedWillExceed {
                Label("预计将超出约 \(String(format: "%.1f", monitor.projectedUsageGB - monitor.planGB)) GB，建议减少视频、热点等高耗流量使用。",
                      systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote)
                    .foregroundStyle(.orange)
            } else {
                Label("按当前节奏不会超出套餐。", systemImage: "checkmark.seal.fill")
                    .font(.footnote)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    DashboardView()
        .environmentObject(TrafficMonitor.shared)
}
