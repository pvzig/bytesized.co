import Foundation
import Core

struct ImageGenService: Sendable {
    private let dailyGenerationLimit = 50

    private let environment: Environment
    private let s3ImageStore: S3ImageStore
    private let openAiClient: OpenAiClient
    
    init(
        environment: Environment,
        s3ImageStore: S3ImageStore,
        openAiClient: OpenAiClient
    ) {
        self.environment = environment
        self.s3ImageStore = s3ImageStore
        self.openAiClient = openAiClient
    }

    public func handle(
        request: GenerateRequest,
        countryName: String
    ) async throws
        -> GenerateResponse
    {
        guard !request.context.pagePath.isEmpty else {
            throw CoreError.invalidPagePath
        }

        let currentDate = Date()
        let countrySuffix = KeyFactory.countryKeySuffix(countryName: countryName)
        let datePrefix = KeyFactory.generatedImagePrefix(for: currentDate)
        let generatedImageCount = try await s3ImageStore.countGeneratedImages(prefix: datePrefix)

        if generatedImageCount < dailyGenerationLimit {
            let prompt = PromptBuilder.prompt(countryName: countryName)
            let imageKey = KeyFactory.generatedImageKey(
                date: currentDate,
                countryName: countryName
            )
            let imageURL = KeyFactory.publicURL(
                baseURL: environment.publicBaseURL,
                key: imageKey
            )
            let imageBytes = try await openAiClient.generateImage(prompt: prompt)
            try await s3ImageStore.uploadImage(key: imageKey, bytes: imageBytes)
            return GenerateResponse(key: imageKey, url: imageURL)
        } else {
            // At generation limit, go get a generated one randomly
            do {
                guard let imageKey = try await s3ImageStore.randomGeneratedImageKey(datePrefix: datePrefix, countrySuffix: countrySuffix) else {
                    throw ServerError.noValidImageFallback
                }
                
                let imageURL = KeyFactory.publicURL(
                    baseURL: environment.publicBaseURL,
                    key: imageKey
                )
                
                return GenerateResponse(key: imageKey, url: imageURL)
            } catch {
                throw error
            }
        }
    }
}
