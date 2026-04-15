import Foundation

public struct PromptBuilder {
    public static func prompt(countryName: String?) -> String {
        let localized: String
        if let countryName {
            localized = "in the country of \(countryName)"
        } else {
            localized = "anywhere in the world"
        }
        return
            "random food item popular \(localized), in the style of Overcooked, transparent background"
    }
}
