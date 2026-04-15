import Configuration
import Foundation

public struct Environment: Sendable, Equatable {
    public let awsRegion: String
    public let generatedImagesBucket: String
    public let generatedImagesPrefix: String
    public let hostname: String
    public let openAIAPIKey: String
    public let openAIModel: String
    public let port: Int

    public var publicBaseURL: String {
        "https://\(generatedImagesBucket).s3.\(awsRegion).amazonaws.com"
    }

    enum Keys: String {
        case awsRegion = "AWS_REGION"
        case backendHost = "BACKEND_HOST"
        case backendPort = "BACKEND_PORT"
        case generatedImagesBucket = "GENERATED_IMAGES_BUCKET"
        case host = "HOST"
        case imageGenPrefix = "IMAGE_GEN_PREFIX"
        case openAiKey = "OPENAI_API_KEY"
        case openAiModel = "OPENAI_IMAGE_MODEL"
        case port = "PORT"
    }

    public static func load(from values: [String: String] = ProcessInfo.processInfo.environment)
        throws -> Self
    {
        let configuration = ConfigReader(
            provider: EnvironmentVariablesProvider(
                environmentVariables: values,
                secretsSpecifier: .specific([Keys.openAiKey.rawValue])
            )
        )

        return try Self.load(from: configuration)
    }

    private static func load(from configuration: ConfigReader) throws -> Self {
        Self(
            awsRegion: try Self.requiredValue(
                for: .awsRegion,
                in: configuration
            ),
            generatedImagesBucket: try Self.requiredValue(
                for: .generatedImagesBucket,
                in: configuration
            ),
            generatedImagesPrefix: try Self.generatedImagesPrefix(from: configuration),
            hostname: try Self.hostname(from: configuration),
            openAIAPIKey: try Self.requiredValue(
                for: .openAiKey,
                in: configuration,
                isSecret: true
            ),
            openAIModel: try Self.requiredValue(
                for: .openAiModel,
                in: configuration
            ),
            port: try Self.port(from: configuration)
        )
    }

    private static func requiredValue(
        for key: Keys,
        aliases: [Keys] = [],
        in configuration: ConfigReader,
        isSecret: Bool = false
    ) throws -> String {
        for candidateKey in [key] + aliases {
            guard
                let value = configuration.string(
                    forKey: ConfigKey(candidateKey.rawValue),
                    isSecret: isSecret
                ),
                !value.isEmpty
            else {
                continue
            }

            return value
        }

        throw CoreError.missingEnvironmentValue(
            ([key] + aliases)
                .map(\.rawValue)
                .joined(separator: " or ")
        )
    }

    private static func generatedImagesPrefix(from configuration: ConfigReader) throws -> String {
        let normalizedPrefix = try requiredValue(for: .imageGenPrefix, in: configuration)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard !normalizedPrefix.isEmpty else {
            throw CoreError.missingEnvironmentValue(Keys.imageGenPrefix.rawValue)
        }

        return normalizedPrefix
    }

    private static func hostname(from configuration: ConfigReader) throws -> String {
        try requiredValue(
            for: .host,
            aliases: [.backendHost],
            in: configuration
        )
    }

    private static func port(from configuration: ConfigReader) throws -> Int {
        let portValue = try requiredValue(
            for: .port,
            aliases: [.backendPort],
            in: configuration
        )
        guard let port = Int(portValue) else {
            throw CoreError.invalidPort(portValue)
        }

        return port
    }
}
