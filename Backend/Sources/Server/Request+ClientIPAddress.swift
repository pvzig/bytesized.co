import Foundation
import HTTPTypes
import Hummingbird

extension Request {
    func clientIPAddress() -> String? {
        ClientIPAddressResolver.resolve(
            xForwardedFor: headers[.xForwardedFor],
            xRealIP: headers[.xRealIP]
        )
    }
}

struct ClientIPAddressResolver {
    static func resolve(xForwardedFor: String?, xRealIP: String?) -> String? {
        // Railway exposes the originating client address via X-Real-IP.
        if let clientIPAddress = normalizedIPAddress(from: xRealIP) {
            return clientIPAddress
        }

        if let clientIPAddress = forwardedClientIPAddress(from: xForwardedFor) {
            return clientIPAddress
        }

        return nil
    }

    private static func forwardedClientIPAddress(from xForwardedFor: String?) -> String? {
        let forwardedIPs = normalizedIPAddresses(from: xForwardedFor)
        guard !forwardedIPs.isEmpty else {
            return nil
        }

        return forwardedIPs[0]
    }

    private static func normalizedIPAddresses(from rawValue: String?) -> [String] {
        guard let rawValue else {
            return []
        }

        return
            rawValue
            .split(separator: ",")
            .compactMap { candidate in
                normalizedIPAddress(from: String(candidate))
            }
    }

    private static func normalizedIPAddress(from rawValue: String?) -> String? {
        let normalizedValue = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let normalizedValue,
            !normalizedValue.isEmpty
        else {
            return nil
        }

        return normalizedValue
    }
}

extension HTTPField.Name {
    fileprivate static let xForwardedFor = Self("X-Forwarded-For")!
    fileprivate static let xRealIP = Self("X-Real-IP")!
}
