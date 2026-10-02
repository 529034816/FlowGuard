//
//  OpenFlowAppIntent.swift
//  Shared (主 App 与 Widget 共用)
//
//  控制中心控件点击后打开流量管家。
//

import AppIntents

struct OpenFlowAppIntent: AppIntent {
    static var title: LocalizedStringResource = "打开流量管家"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
