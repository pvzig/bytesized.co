import Core
import Foundation

struct ImageGenService: Sendable {
    private let dailyGenerationLimit = 15

    private let environment: Environment
    private let keyFactory: KeyFactory
    private let s3ImageStore: S3ImageStore
    private let openAiClient: OpenAiClient

    init(
        environment: Environment,
        keyFactory: KeyFactory,
        s3ImageStore: S3ImageStore,
        openAiClient: OpenAiClient,
    ) {
        self.environment = environment
        self.keyFactory = keyFactory
        self.s3ImageStore = s3ImageStore
        self.openAiClient = openAiClient
    }

    public func handle(
        request: GenerateRequest,
        countryName: String?
    ) async throws
        -> GenerateResponse
    {
        guard !request.context.pagePath.isEmpty else {
            throw CoreError.invalidPagePath
        }

        let currentDate = Date()
        let countrySuffix = keyFactory.countryKeySuffix(countryName: countryName)
        let pageImageKey = keyFactory.pageImageKey(
            prefix: environment.generatedImagesPrefix,
            context: request.context,
            countryName: countryName
        )
        let pageImageURL = keyFactory.publicURL(
            baseURL: environment.publicBaseURL,
            key: pageImageKey
        )

        if try await s3ImageStore.imageExists(key: pageImageKey) {
            return GenerateResponse(url: pageImageURL)
        }

        let datePrefix = keyFactory.generatedImagePrefix(
            prefix: environment.generatedImagesPrefix,
            for: currentDate
        )
        let generatedImageCount = try await s3ImageStore.countGeneratedImages(prefix: datePrefix)

        if generatedImageCount < dailyGenerationLimit {
            let prompt = PromptBuilder.prompt(countryName: countryName)
            let imageKey = keyFactory.generatedImageKey(
                prefix: environment.generatedImagesPrefix,
                date: currentDate,
                countryName: countryName
            )
            let imageBytes = try await openAiClient.generateImage(prompt: prompt)
            try await s3ImageStore.uploadImage(key: imageKey, bytes: imageBytes)
            try await s3ImageStore.uploadImage(key: pageImageKey, bytes: imageBytes)
            return GenerateResponse(url: pageImageURL)
        } else {
            guard
                let imageKey = try await s3ImageStore.randomGeneratedImageKey(
                    datePrefix: datePrefix,
                    countrySuffix: countrySuffix
                )
            else {
                throw ServerError.noValidImageFallback
            }

            try await s3ImageStore.copyImage(from: imageKey, to: pageImageKey)
            return GenerateResponse(url: pageImageURL)
        }
    }
}
