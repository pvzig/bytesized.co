import Core
import Hummingbird

extension GenerateResponse: ResponseEncodable {}

@main
struct Server {
    static func main() async throws {
        let environment = try Environment.load()
        let imageStore = try await S3ImageStore(bucketName: environment.generatedImagesBucket)
        let countryLookupClient = CountryLookupClient()
        let openAiClient = OpenAiClient(environment: environment)
        let keyFactory = KeyFactory()
        let imageGenService = ImageGenService(
            environment: environment,
            keyFactory: keyFactory,
            s3ImageStore: imageStore,
            openAiClient: openAiClient
        )

        let router = Router(context: BasicRequestContext.self)
        router.addMiddleware {
            CORSMiddleware(
                allowOrigin: .originBased,
                allowHeaders: [.contentType, .origin],
                allowMethods: [.get, .post, .options]
            )
        }
        router.addMiddleware {
            LogRequestsMiddleware(.info)
        }

        router.get("/health") { _, _ -> HTTPResponse.Status in
            .ok
        }

        router.post("/api/cafe/generate") {
            request,
            context -> GenerateResponse in
            let generateRequest = try await request.decode(
                as: GenerateRequest.self,
                context: context
            )
            let countryName: String?
            if let clientIPAddress = request.clientIPAddress() {
                countryName = try await countryLookupClient.countryName(
                    for: clientIPAddress
                )
            } else {
                countryName = nil
            }
            return try await imageGenService.handle(
                request: generateRequest, countryName: countryName)
        }

        let app = Application(
            router: router,
            configuration: .init(
                address: .hostname(environment.hostname, port: environment.port)
            )
        )

        try await app.runService()
    }
}
