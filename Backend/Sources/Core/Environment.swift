import Foundation

public struct Environment: Sendable, Equatable {
    public let bucketName: String
    public let hostname: String
    public let openAIAPIKey: String
    public let openAIModel: String
    public let port: Int
    public let publicBaseURL: String

    enum Keys: String {
        case bucket = "BUCKET_NAME"
        case openAiKey = "OPENAI_API_KEY"
        case openAiModel = "OPENAI_IMAGE_MODEL"
        case baseUrl = "PUBLIC_BASE_URL"
        case host = "HOST"
        case port = "PORT"
    }
    
    public init(
        bucketName: String,
        hostname: String = "0.0.0.0",
        openAIAPIKey: String,
        openAIModel: String,
        port: Int = 8080,
        publicBaseURL: String
    ) {
        self.bucketName = bucketName
        self.hostname = hostname
        self.openAIAPIKey = openAIAPIKey
        self.openAIModel = openAIModel
        self.port = port
        self.publicBaseURL = publicBaseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    public static func load(from values: [String: String] = ProcessInfo.processInfo.environment)
        throws -> Self
    {
        Self(
            bucketName: try Self.requiredValue(for: Keys.bucket.rawValue, in: values),
            hostname: Self.hostname(from: values),
            openAIAPIKey: try Self.requiredValue(for: Keys.openAiKey.rawValue, in: values),
            openAIModel: Self.openAIModel(from: values),
            port: try Self.port(from: values),
            publicBaseURL: try Self.requiredValue(for: Keys.baseUrl.rawValue, in: values)
        )
    }

    private static func requiredValue(for key: String, in values: [String: String]) throws -> String
    {
        guard let value = values[key], !value.isEmpty else {
            throw CoreError.missingEnvironmentValue(key)
        }

        return value
    }

    private static func openAIModel(from values: [String: String]) -> String {
        values[Keys.openAiModel.rawValue] ?? "gpt-image-1.5"
    }

    private static func hostname(from values: [String: String]) -> String {
        values[Keys.host.rawValue] ?? "0.0.0.0"
    }

    private static func port(from values: [String: String]) throws -> Int {
        let portValue = values[Keys.port.rawValue] ?? "8080"
        guard let port = Int(portValue) else {
            throw CoreError.invalidPort(portValue)
        }

        return port
    }
}
