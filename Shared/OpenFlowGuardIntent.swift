import AppIntents

/// 控制中心按钮点击后打开主 App。
/// 放在 Shared 目录，同时编译进 App 与 Widget Extension（打开 App 的必要条件）。
struct OpenFlowGuardIntent: AppIntent {
    static let title: LocalizedStringResource = "打开流量管家"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
