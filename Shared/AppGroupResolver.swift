//
//  AppGroupResolver.swift
//  Shared (主 App 与 Widget 共用)
//
//  从 embedded.mobileprovision 读取“重签名后真实生效”的 App Group ID。
//  AltStore 侧载时可能给 App Group ID 追加团队后缀，硬编码会导致主 App 与 Widget
//  指向不同容器、数据读不到。改为运行时按签名里的真实 ID 解析，可自动适配。
//

import Foundation

enum AppGroupResolver {
    static let fallbackID = "group.com.flowguard.shared"

    /// 当前二进制签名中真实生效的第一个 App Group ID。
    static func resolvedID() -> String {
        guard let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"),
              let data = try? Data(contentsOf: url),
              let plistData = extractPlist(from: data),
              let plist = try? PropertyListSerialization.propertyList(
                from: plistData,
                options: [],
                format: nil
              ) as? [String: Any],
              let entitlements = plist["Entitlements"] as? [String: Any],
              let groups = entitlements["com.apple.security.application-groups"] as? [String],
              let group = groups.first else {
            return fallbackID
        }
        return group
    }

    private static func extractPlist(from data: Data) -> Data? {
        let startToken = Data("<?xml".utf8)
        let endToken = Data("</plist>".utf8)
        guard let startRange = data.range(of: startToken),
              let endRange = data.range(of: endToken) else {
            return nil
        }
        return data.subdata(in: startRange.lowerBound..<endRange.upperBound)
    }
}
