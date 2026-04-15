import Foundation

public struct GenerateResponse: Codable, Equatable {
    public let url: String

    public init(url: String) {
        self.url = url
    }
}
