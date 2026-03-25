import Foundation

public struct KeyFactory {
    public static let generatedImagesPrefix = "generated/v2"

    private static let utcTimeZone = TimeZone(secondsFromGMT: 0) ?? .current
    private static var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utcTimeZone
        return calendar
    }
    
    private static let machineReadableDateStyle = Date.VerbatimFormatStyle(
        format: "\(year: .defaultDigits)/\(month: .twoDigits)/\(day: .twoDigits)",
        locale: Locale(identifier: "en_US_POSIX"),
        timeZone: utcTimeZone,
        calendar: utcCalendar
    )

    public static func publicURL(baseURL: String, key: String) -> String {
        "\(baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/")))/\(key)"
    }

    public static func generatedImageKey(date: Date = .now, countryName: String? = nil) -> String {
        let countrySuffix = countryKeySuffix(countryName: countryName).map { "-\($0)" } ?? ""
        return
            "\(generatedImagePrefix(for: date))\(UUID().uuidString.lowercased())\(countrySuffix).png"
    }

    public static func generatedImagePrefix(for date: Date) -> String {
        "\(generatedImagesPrefix)/\(date.formatted(machineReadableDateStyle))/"
    }

    public static func countryKeySuffix(countryName: String?) -> String? {
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
}
