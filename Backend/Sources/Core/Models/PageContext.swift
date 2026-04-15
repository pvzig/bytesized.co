import Foundation

public struct PageContext: Codable, Equatable {
    public let pagePath: String
    public let pageType: PageType

    public init(pagePath: String, pageType: PageType) {
        self.pagePath = pagePath
        self.pageType = pageType
    }
}
