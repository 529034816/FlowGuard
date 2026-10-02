//
//  OpenFlowAppIntent.swift
//  Shared (主 App 与 Widget 共用)
//
//  控制中心控件点击后打开主 App。
//

import AppIntents

struct OpenFlowAppIntent: AppIntent {
    static let title: LocalizedStringResource = "打开流量管家"
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}
