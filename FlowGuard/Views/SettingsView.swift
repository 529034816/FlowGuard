//
//  SettingsView.swift
//  FlowGuard
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var monitor: TrafficMonitor
    @State private var showCalibration = false
    @State private var notificationStatusText = "未检查"
    @State private var versionText = ""
    @State private var expirationText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("每月套餐流量")
                        Spacer()
                        TextField(
                            "120",
                            value: $monitor.planGB,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                        Text("GB")
                    }
                    Picker("每月账期起始日", selection: $monitor.billingDay) {
                        ForEach(1..<29) { day in
                            Text("\(day) 日").tag(day)
                        }
                    }
                } header: {
                    Text("套餐设置")
                } footer: {
                    Text("账期起始日指运营商每月重新计算流量的日期，可在运营商 App 或扣费短信中查到。")
                }

                Section("流量提醒阈值") {
                    Toggle("已用 50% 时提醒", isOn: $monitor.alert50Enabled)
                    Toggle("已用 80% 时提醒", isOn: $monitor.alert80Enabled)
                    Toggle("已用 90% 时提醒", isOn: $monitor.alert90Enabled)
                    Toggle("已用 100% 时提醒", isOn: $monitor.alert100Enabled)
                }

                Section {
                    HStack {
                        Text("通知权限")
                        Spacer()
                        Text(notificationStatusText)
                            .foregroundStyle(.secondary)
                    }
                    Button("请求通知权限") {
                        Task {
                            let granted = await NotificationService.shared.requestAuthorization()
                            notificationStatusText = granted ? "已授权" : "未授权"
                        }
                    }
                    Button("打开系统通知设置") {
                        openSettings()
                    }
                } header: {
                    Text("通知")
                } footer: {
                    Text("收不到提醒时，请确认此处已授权，并在 系统设置 → 通用 → 后台 App 刷新 中为本 App 打开后台刷新。")
                }

                Section {
                    Button {
                        showCalibration = true
                    } label: {
                        Label("手动校准已用流量", systemImage: "slider.horizontal.3")
                    }
                } header: {
                    Text("校准")
                } footer: {
                    Text("本 App 的流量为系统接口估算，可能与运营商统计有偏差。建议每月在运营商 App 查到实际已用流量后，在此校准 1～2 次。")
                }

                Section {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text(versionText)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("签名到期时间")
                        Spacer()
                        Text(expirationText)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("关于")
                } footer: {
                    Text("免费签名有效期为 7 天，到期前一天 App 会通知你续签；续签为覆盖安装，设置与校准数据不会丢失。")
                }
            }
            .navigationTitle("设置")
            .onAppear {
                let info = Bundle.main.infoDictionary
                let shortVersion = info?["CFBundleShortVersionString"] as? String ?? "?"
                let build = info?["CFBundleVersion"] as? String ?? "?"
                versionText = "\(shortVersion)（\(build)）"

                if let expiration = ProvisionProfile.expirationDate() {
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "zh_CN")
                    formatter.dateFormat = "MM月dd日 HH:mm"
                    expirationText = formatter.string(from: expiration)
                } else {
                    expirationText = "未知"
                }

                Task {
                    let status = await NotificationService.shared.authorizationStatus()
                    switch status {
                    case .authorized, .provisional, .ephemeral:
                        notificationStatusText = "已授权"
                    case .denied:
                        notificationStatusText = "已拒绝"
                    case .notDetermined:
                        notificationStatusText = "未询问"
                    @unknown default:
                        notificationStatusText = "未知"
                    }
                }
            }
            .onChange(of: monitor.billingDay) { _ in
                monitor.settingsDidChange()
            }
            .sheet(isPresented: $showCalibration) {
                CalibrationSheet()
                    .environmentObject(monitor)
            }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

struct CalibrationSheet: View {
    @EnvironmentObject private var monitor: TrafficMonitor
    @Environment(\.dismiss) private var dismiss
    @State private var textValue = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        TextField("例如 36.5", text: $textValue)
                            .keyboardType(.decimalPad)
                        Text("GB")
                    }
                } header: {
                    Text("运营商口径的本期已用流量")
                } footer: {
                    Text("请先在运营商 App（移动/联通/电信）或发送查询短信查看本期实际已用流量，再如实填写。校准后 App 将以此为基线继续估算。")
                }
            }
            .navigationTitle("校准已用流量")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("校准") {
                        if let value = parseDecimal(textValue) {
                            monitor.calibrate(usedGB: value)
                            dismiss()
                        }
                    }
                    .disabled(parseDecimal(textValue) == nil)
                }
            }
        }
    }

    private func parseDecimal(_ text: String) -> Double? {
        let normalized = text
            .replacingOccurrences(of: "，", with: ".")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        return Double(normalized)
    }
}

#Preview {
    SettingsView()
        .environmentObject(TrafficMonitor.shared)
}
