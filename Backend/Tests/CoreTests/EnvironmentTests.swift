import Testing

@testable import Core

struct EnvironmentTests {
    @Test func loadsCanonicalRuntimeVariables() throws {
        let environment = try Environment.load(
            from: [
                "AWS_REGION": "us-east-1",
                "GENERATED_IMAGES_BUCKET": "bytesized-generated-images",
                "HOST": "127.0.0.1",
                "IMAGE_GEN_PREFIX": "/generated/v2/",
                "OPENAI_API_KEY": "secret",
                "OPENAI_IMAGE_MODEL": "gpt-image-1.5",
                "PORT": "8080",
            ]
        )

        #expect(environment.awsRegion == "us-east-1")
        #expect(environment.generatedImagesBucket == "bytesized-generated-images")
        #expect(environment.generatedImagesPrefix == "generated/v2")
        #expect(environment.hostname == "127.0.0.1")
        #expect(environment.openAIAPIKey == "secret")
        #expect(environment.openAIModel == "gpt-image-1.5")
        #expect(environment.port == 8080)
    }

    @Test func loadsLocalBackendHostAliases() throws {
        let environment = try Environment.load(
            from: [
                "AWS_REGION": "us-east-1",
                "BACKEND_HOST": "127.0.0.1",
                "BACKEND_PORT": "9000",
                "GENERATED_IMAGES_BUCKET": "bytesized-generated-images",
                "IMAGE_GEN_PREFIX": "generated/v2",
                "OPENAI_API_KEY": "secret",
                "OPENAI_IMAGE_MODEL": "gpt-image-1.5",
            ]
        )

        #expect(environment.hostname == "127.0.0.1")
        #expect(environment.port == 9000)
    }

    @Test func throwsHelpfulErrorWhenHostValuesAreMissing() {
        #expect(throws: CoreError.missingEnvironmentValue("HOST or BACKEND_HOST")) {
            try Environment.load(
                from: [
                    "AWS_REGION": "us-east-1",
                    "GENERATED_IMAGES_BUCKET": "bytesized-generated-images",
                    "IMAGE_GEN_PREFIX": "generated/v2",
                    "OPENAI_API_KEY": "secret",
                    "OPENAI_IMAGE_MODEL": "gpt-image-1.5",
                    "PORT": "8080",
                ]
            )
        }
    }

    @Test func throwsInvalidPortForAliasValues() {
        #expect(throws: CoreError.invalidPort("not-a-port")) {
            try Environment.load(
                from: [
                    "AWS_REGION": "us-east-1",
                    "BACKEND_HOST": "127.0.0.1",
                    "BACKEND_PORT": "not-a-port",
                    "GENERATED_IMAGES_BUCKET": "bytesized-generated-images",
                    "IMAGE_GEN_PREFIX": "generated/v2",
                    "OPENAI_API_KEY": "secret",
                    "OPENAI_IMAGE_MODEL": "gpt-image-1.5",
                ]
            )
        }
    }
}
