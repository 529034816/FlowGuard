//
//  NetworkDataUsage.swift
//  FlowGuard
//

import Foundation

enum NetworkDataUsage {
    /// 读取蜂窝移动网络接口（pdp_ip* / ppp*）自系统启动以来的累计收发字节数。
    /// 该计数器由系统在内核层面维护，App 未运行期间也会持续增长；
    /// 设备重启后计数器从小值重新开始，因此重启期间（本就不产生流量）无需补差值。
    static func cellularBytes() -> UInt64 {
        var ifaddrPointer: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddrPointer) == 0, let firstAddress = ifaddrPointer else {
            return 0
        }
        defer { freeifaddrs(ifaddrPointer) }

        var total: UInt64 = 0
        var current: UnsafeMutablePointer<ifaddrs>? = firstAddress
        while let address = current {
            let interface = address.pointee

            if let socketAddress = interface.ifa_addr,
               socketAddress.pointee.sa_family == UInt8(AF_LINK),
               let dataPointer = interface.ifa_data?.assumingMemoryBound(to: if_data.self) {
                let interfaceName = String(cString: interface.ifa_name)
                // pdp_ip0~n：iPhone 蜂窝接口（4G/5G）；ppp*：个人热点等蜂窝通道。
                if interfaceName.hasPrefix("pdp_ip") || interfaceName.hasPrefix("ppp") {
                    let data = dataPointer.pointee
                    total &+= UInt64(data.ifi_ibytes)
                    total &+= UInt64(data.ifi_obytes)
                }
            }

            current = interface.ifa_next
        }
        return total
    }
}
