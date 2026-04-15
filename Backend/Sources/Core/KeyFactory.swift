import Foundation

public struct KeyFactory: Sendable {
    public init() {}

    private let utcTimeZone = TimeZone(secondsFromGMT: 0) ?? .current

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utcTimeZone
        return calendar
    }

    private var dateStyle: Date.VerbatimFormatStyle {
        return Date.VerbatimFormatStyle(
            format: "\(year: .defaultDigits)/\(month: .twoDigits)/\(day: .twoDigits)",
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: utcTimeZone,
            calendar: utcCalendar
        )
    }

    public func publicURL(baseURL: String, key: String) -> String {
        "\(baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/")))/\(key)"
    }

    public func generatedImageKey(
        prefix: String,
        date: Date = .now,
        countryName: String? = nil
    ) -> String {
        let countrySuffix = countryKeySuffix(countryName: countryName).map { "-\($0)" } ?? ""
        return
            "\(generatedImagePrefix(prefix: prefix, for: date))\(UUID().uuidString.lowercased())\(countrySuffix).png"
    }

    public func pageImageKey(
        prefix: String,
        context: PageContext,
        countryName: String? = nil
    ) -> String {
        let normalizedPagePath = normalizedPagePathComponents(for: context.pagePath)
            .joined(separator: "/")
        let countryComponent = countryKeySuffix(countryName: countryName) ?? "anywhere"

        return
            "\(trimmedPrefix(prefix))/page-cache/\(context.pageType.rawValue)/\(normalizedPagePath)-\(countryComponent).png"
    }

    public func generatedImagePrefix(prefix: String, for date: Date) -> String {
        return "\(trimmedPrefix(prefix))/\(date.formatted(dateStyle))/"
    }

    public func countryKeySuffix(countryName: String?) -> String? {
        guard
            let countryName = countryName?.trimmingCharacters(in: .whitespacesAndNewlines),
            !countryName.isEmpty
        else {
            return nil
        }

        let normalizedCountryName =
            countryName
            .folding(
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: .init(identifier: "en_US_POSIX")
            )
            .lowercased()
        let parts = normalizedCountryName.split(
            whereSeparator: { character in
                character.unicodeScalars.allSatisfy { scalar in
                    !CharacterSet.alphanumerics.contains(scalar)
                }
            }
        )
        let suffix = parts.joined(separator: "-")

        return suffix.isEmpty ? nil : suffix
    }

    private func trimmedPrefix(_ prefix: String) -> String {
        prefix.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    private func normalizedPagePathComponents(for pagePath: String) -> [String] {
        let trimmedPagePath = pagePath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        guard !trimmedPagePath.isEmpty else {
            return ["root"]
        }

        return trimmedPagePath.split(separator: "/").map { component in
            keyPathComponent(from: String(component))
        }
    }

    private func keyPathComponent(from value: String) -> String {
        let normalizedValue =
            value
            .folding(
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: .init(identifier: "en_US_POSIX")
            )
            .lowercased()
        let parts = normalizedValue.split(
            whereSeparator: { character in
                character.unicodeScalars.allSatisfy { scalar in
                    !CharacterSet.alphanumerics.contains(scalar)
                }
            }
        )
        let keyPathComponent = parts.joined(separator: "-")

        return keyPathComponent.isEmpty ? "page" : keyPathComponent
    }
}
