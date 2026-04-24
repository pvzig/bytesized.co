import Foundation

public struct PromptBuilder {
    public static func prompt(countryName: String?) -> String {
        let location: String
        if let countryName {
            location = "in the country of \(countryName)"
        } else {
            location = "somewhere in the world"
        }
        return
            """
            Create an image of one randomly chosen prepared dish, snack, pastry, or street food 
            that is genuinely eaten \(location), in the style of Overcooked, transparent background. 
            Favor specific regional, city, market, bakery, holiday, breakfast, dessert, or 
            home-cooked foods over the first national stereotype. Show exactly one hero item; 
            no combo meals, side dishes, drinks, menus, flags, labels, or text. 
            Avoid defaulting to globally common fast food such as hamburgers, fries, pizza, or hot dogs 
            unless the subject is a distinctive named local variation.
            """
    }
}
