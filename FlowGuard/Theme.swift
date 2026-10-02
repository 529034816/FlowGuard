//
//  Theme.swift
//  FlowGuard
//
//  设计系统：配色、渐变、卡片样式、图标徽章、全屏背景
//

import SwiftUI

enum Theme {
    static let blue   = Color(red: 0.184, green: 0.420, blue: 1.000)
    static let cyan   = Color(red: 0.133, green: 0.827, blue: 0.933)
    static let green  = Color(red: 0.133, green: 0.773, blue: 0.369)
    static let orange = Color(red: 0.961, green: 0.620, blue: 0.043)
    static let red    = Color(red: 0.937, green: 0.267, blue: 0.267)
    static let purple = Color(red: 0.545, green: 0.361, blue: 0.965)
    static let indigo = Color(red: 0.388, green: 0.400, blue: 0.945)
    static let pink   = Color(red: 0.969, green: 0.400, blue: 0.700)
}

/// 统一卡片修饰：圆角 + 柔和阴影，深色模式自适应。
struct CardModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(scheme == .dark ? Color(.secondarySystemBackground) : Color.white)
            )
            .shadow(
                color: Color.black.opacity(scheme == .dark ? 0 : 0.07),
                radius: 14, x: 0, y: 7
            )
    }
}

extension View {
    func card() -> some View { modifier(CardModifier()) }
}

/// 彩色圆角图标徽章。
struct IconBadge: View {
    let icon: String
    let color: Color
    var size: CGFloat = 42

    init(_ icon: String, color: Color, size: CGFloat = 42) {
        self.icon = icon
        self.color = color
        self.size = size
    }

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.30, style: .continuous)
            .fill(color.opacity(0.16))
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: icon)
                    .font(.system(size: size * 0.46, weight: .semibold))
                    .foregroundStyle(color)
            )
    }
}

/// 全屏背景：分组底色 + 顶部主题色淡渐变，延伸到安全区之外（消除黑边）。
struct ScreenBackground: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
            LinearGradient(
                colors: [
                    Theme.blue.opacity(scheme == .dark ? 0.20 : 0.12),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .init(x: 0.5, y: 0.42)
            )
        }
        .ignoresSafeArea()
    }
}
