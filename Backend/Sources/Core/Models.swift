import Foundation

public enum PageType: String, Codable {
    case archive
    case article
    case index
}

public struct PageContext: Codable, Equatable {
    public let pagePath: String
    public let pageType: PageType

    public init(pagePath: String, pageType: PageType) {
        self.pagePath = pagePath
        self.pageType = pageType
    }
}

public struct GenerateRequest: Codable, Equatable {
    public let context: PageContext

    public init(context: PageContext) {
        self.context = context
    }
}

public struct GenerateResponse: Codable, Equatable {
    public let key: String
    public let url: String

    public init(key: String, url: String) {
        self.key = key
        self.url = url
    }
}
