import AsyncHTTPClient
import Core
import Foundation
import NIOCore

struct OpenAiClient {
    private let generationTimeout: TimeAmount = .seconds(120)
    private let environment: Environment
    private let httpClient: HTTPClient
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    private let generationsURL = "https://api.openai.com/v1/images/generations"

    init(
        environment: Environment,
        httpClient: HTTPClient = .shared
    ) {
        self.environment = environment
        self.httpClient = httpClient
    }

    func generateImage(prompt: String) async throws -> Data {
        let payload = ImageGenRequest(
            background: "transparent",
            model: environment.openAIModel,
            outputFormat: "png",
            prompt: prompt,
            quality: "high",
            size: "1024x1024"
        )

        let requestBody = try jsonEncoder.encode(payload)
        var request = HTTPClientRequest(url: generationsURL)
        request.method = .POST
        request.headers.add(name: "Authorization", value: "Bearer \(environment.openAIAPIKey)")
        request.headers.add(name: "Content-Type", value: "application/json")
        request.body = .bytes(ByteBuffer(bytes: requestBody))
        let response = try await httpClient.execute(request, timeout: generationTimeout)
        let body = try await response.body.collect(upTo: 10 * 1024 * 1024)
        let data = Data(body.readableBytesView)

        return try imageData(from: data, statusCode: Int(response.status.code))
    }

    func imageData(from data: Data, statusCode: Int) throws -> Data {
        switch statusCode {
        case 200..<300:
            let decoded = try jsonDecoder.decode(ImageGenResponse.self, from: data)
            guard
                let encodedImage = decoded.data.first?.base64JSON,
                let imageBytes = Data(base64Encoded: encodedImage)
            else {
                throw CoreError.terminal(
                    code: "invalid_openai_response",
                    message: "The image API did not return PNG bytes."
                )
            }

            return imageBytes
        case 400..<500 where statusCode != 429:
            let apiError = try? jsonDecoder.decode(OpenAIAPIErrorResponse.self, from: data)
            let message = apiError?.error.message ?? "The image request was rejected."

            throw CoreError.terminal(
                code: "openai_request_failed",
                message: message
            )
        default:
            throw ServerError.httpFailure(
                service: .openAIImage,
                statusCode: statusCode,
                message: String(decoding: data, as: UTF8.self)
            )
        }
    }
}

private struct OpenAIAPIErrorResponse: Decodable {
    let error: OpenAIAPIError
}

private struct OpenAIAPIError: Decodable {
    let message: String
}
