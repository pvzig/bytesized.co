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
        if let clientIPAddress = cloudRunClientIPAddress(from: xForwardedFor) {
            return clientIPAddress
        }

        if let clientIPAddress = normalizedIPAddress(from: xRealIP) {
            return clientIPAddress
        }

        return nil
    }

    private static func cloudRunClientIPAddress(from xForwardedFor: String?) -> String? {
        let forwardedIPs = normalizedIPAddresses(from: xForwardedFor)
        guard !forwardedIPs.isEmpty else {
            return nil
        }

        // Google Cloud appends "<client-ip>,<load-balancer-ip>" to X-Forwarded-For.
        // Any values before those may have been supplied by the client, so prefer the
        // second-to-last IP when present instead of trusting the first entry.
        if forwardedIPs.count >= 2 {
            return forwardedIPs[forwardedIPs.count - 2]
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
