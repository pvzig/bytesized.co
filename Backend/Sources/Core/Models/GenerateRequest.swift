import Foundation

public struct GenerateRequest: Codable, Equatable {
    public let context: PageContext

    public init(context: PageContext) {
        self.context = context
    }
}

