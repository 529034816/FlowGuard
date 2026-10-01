//
//  InfoView.swift
//  FlowGuard
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("这个 App 能做什么") {
                    bullet("记录每月蜂窝移动网络的已用流量（系统接口估算）")
                    bullet("按设置的套餐总量和账期日计算剩余流量")
                    bullet("在 50%/80%/90%/100% 等阈值发送本地通知提醒")
                    bullet("根据当前日均用量，预测账期结束时是否会超量")
                }

                Section("它做不到什么") {
                    bullet("不能自动断网：苹果不向任何第三方 App 开放蜂窝数据开关，收到提醒后需手动在控制中心关闭")
                    bullet("不能读取运营商的实时套餐余量，只能基于系统网络接口计数器估算")
                    bullet("后台通知可能延迟：iOS 自行决定后台唤醒时机，长时间不打开 App 时，提醒可能在下次打开时才发出")
                }

                Section("如何手动断网") {
                    bullet("从屏幕右上角下拉打开控制中心（带 Home 键的机型从屏幕底部上划）")
                    bullet("长按左上角网络区域，再点按绿色的蜂窝数据图标使其变灰")
                    bullet("或：设置 → 蜂窝网络，按需关闭特定 App 的蜂窝权限")
                }

                Section("让统计更准确") {
                    bullet("安装后先在设置里正确填写套餐总量和账期起始日")
                    bullet("每月对照运营商 App 做 1～2 次手动校准")
                    bullet("在 系统设置 → 通用 → 后台 App 刷新 中允许本 App 后台刷新")
                    bullet("流量按 1 GB = 1024 MB 口径计算，如与运营商口径有差异，以运营商账单为准")
                }

                Section("签名与续签（重要）") {
                    bullet("本 App 通过免费 Apple ID 自签名安装，证书有效期为 7 天")
                    bullet("电脑上的 AltServer 与手机处于同一 WiFi 时会自动续签；也可手动打开 AltStore 刷新")
                    bullet("若 App 闪退或提示“不再可用”，重新续签即可，记录的数据不会丢失")
                }

                Section("免责声明") {
                    bullet("本应用数据仅供参考，不作为计费依据；最终流量与费用以运营商账单为准")
                    bullet("建议同时开通运营商免费的流量阈值短信提醒作为双保险")
                }
            }
            .navigationTitle("使用说明")
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .padding(.top, 7)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    InfoView()
}
