public enum CoreError: Error, Equatable {
    case invalidPagePath
    case invalidPort(String)
    case missingEnvironmentValue(String)
    case terminal(code: String, message: String)
}
