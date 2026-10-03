//
//  AppGroupResolver.swift
//  Shared (主 App 与 Widget 共用)
//
//  运行时确定“真实可用”的 App Group 容器。
//  AltStore 侧载时会把 App Group 注册成「声明 ID + .团队后缀」，重签名后二进制与
//  profile 的 entitlement 都使用该带后缀 ID；硬编码原始 ID 会导致主 App 与 Widget 指向
//  不同容器、数据读不到。这里收集所有候选 ID，并用 FileManager 实际探测容器是否存在，
//  返回第一个真正可用的 ID，主 App 与 Widget 即可稳定指向同一容器。
//

import Foundation

enum AppGroupResolver {
    static let fallbackID = "group.com.flowguard.shared"

    struct Info {
        let resolvedID: String
        let containerURL: URL?
        let candidates: [String]
        let profileFound: Bool
        let teamIdentifier: String?
    }

    static func info() -> Info {
        let profile = loadProfile()
        let entitlements = profile?["Entitlements"] as? [String: Any]
        let profileGroups = entitlements?["com.apple.security.application-groups"] as? [String] ?? []
        let team = (profile?["TeamIdentifier"] as? [String])?.first

        var candidates: [String] = []
        func add(_ s: String?) {
            if let s, !s.isEmpty, !candidates.contains(s) { candidates.append(s) }
        }
        // 优先：profile 里声明的（重签名后真实授权的，主 App 与 Widget 一致）
        profileGroups.forEach { add($0) }
        // 其次：显式拼团队后缀
        if let team { add(fallbackID + "." + team) }
        // 最后：原始 ID
        add(fallbackID)

        var chosen = fallbackID
        var containerURL: URL?
        for candidate in candidates {
            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: candidate) {
                chosen = candidate
                containerURL = url
                break
            }
        }

        return Info(
            resolvedID: chosen,
            containerURL: containerURL,
            candidates: candidates,
            profileFound: profile != nil,
            teamIdentifier: team
        )
    }

    static func resolvedID() -> String {
        info().resolvedID
    }

    private static func loadProfile() -> [String: Any]? {
        guard let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"),
              let data = try? Data(contentsOf: url),
              let plistData = extractPlist(from: data) else {
            return nil
        }
        return try? PropertyListSerialization.propertyList(
            from: plistData,
            options: [],
            format: nil
        ) as? [String: Any]
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
