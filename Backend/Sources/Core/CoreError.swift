public enum CoreError: Error, Equatable {
    case invalidPagePath
    case invalidPort(String)
    case missingEnvironmentValue(String)
    case noFallbackImageAvailable
    case terminal(code: String, message: String)
}
