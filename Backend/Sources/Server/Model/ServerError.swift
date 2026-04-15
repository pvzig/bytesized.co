enum ServerError: Error, Sendable, Equatable {
    case httpFailure(service: Service, statusCode: Int, message: String)
    case noValidImageFallback

    enum Service: String, Sendable {
        case countryLookup
        case openAIImage
    }
}
