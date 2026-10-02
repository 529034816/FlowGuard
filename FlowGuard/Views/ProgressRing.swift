//
//  ProgressRing.swift
//  FlowGuard
//
//  渐变进度环
//

import SwiftUI

struct ProgressRing: View {
    let progress: Double
    let colors: [Color]
    var lineWidth: CGFloat = 22

    private var clamped: CGFloat {
        CGFloat(min(max(progress, 0), 1))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: max(clamped, 0.0008))
                .stroke(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .shadow(color: colors.first?.opacity(0.45) ?? .clear, radius: 7)
                .rotationEffect(.degrees(-90))
        }
        .animation(.easeInOut(duration: 0.6), value: progress)
    }
}

#Preview {
    ProgressRing(progress: 0.72, colors: [Theme.blue, Theme.cyan])
        .frame(width: 200, height: 200)
}
