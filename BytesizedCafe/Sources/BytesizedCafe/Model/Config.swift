import Foundation
import JavaScriptKit

struct Config {
    let apiURL: URL
    let pageContext: PageContext

    init?(root: JSObject) {
        guard
            let dataset = root.dataset.object,
            let apiURLString = dataset["apiUrl"].string,
            let apiURL = URL(string: apiURLString),
            let pagePath = dataset["pagePath"].string,
            let pageType = dataset["pageType"].string
        else {
            return nil
        }

        self.apiURL = apiURL
        self.pageContext = PageContext(pagePath: pagePath, pageType: pageType)
    }
}
