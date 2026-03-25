import Core
import Hummingbird

extension GenerateResponse: ResponseEncodable {}

@main
struct Server {
    static func main() async throws {
        let environment = try Environment.load()
        let imageStore = try await S3ImageStore(bucketName: environment.bucketName)
        let countryLookupClient = CountryLookupClient()
        let openAiClient = OpenAiClient(environment: environment)
        let imageGenService = ImageGenService(
            environment: environment,
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
            let countryName = try await countryLookupClient.countryName(for: request.clientIPAddress() ?? "142.251.211.110") ?? "US"
            return try await imageGenService.handle(request: generateRequest, countryName: countryName)
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
