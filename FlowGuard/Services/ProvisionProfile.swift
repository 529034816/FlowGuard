//
//  ProvisionProfile.swift
//  FlowGuard
//
//  解析 App 内置的 embedded.mobileprovision，读取免费签名的创建/过期时间。
//  该文件是 CMS 签名包裹的 plist，这里截取其中的 plist 段进行解析。
//

import Foundation

enum ProvisionProfile {
    static func expirationDate() -> Date? {
        value(for: "ExpirationDate")
    }

    static func creationDate() -> Date? {
        value(for: "CreationDate")
    }

    private static func value(for key: String) -> Date? {
        guard let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"),
              let data = try? Data(contentsOf: url),
              let plistData = extractPlist(from: data),
              let plist = try? PropertyListSerialization.propertyList(
                from: plistData,
                options: [],
                format: nil
              ) as? [String: Any] else {
            return nil
        }
        return plist[key] as? Date
    }

    private static func extractPlist(from data: Data) -> Data? {
        let startToken = Data("<?xml".utf8)
        let endToken = Data("</plist>".utf8)
        guard let startRange = data.range(of: startToken),
              let endRange = data.range(of: endToken, range: startRange.upperBound..<data.endIndex) else {
            return nil
        }
        return data.subdata(in: startRange.lowerBound..<endRange.upperBound)
    }
}
