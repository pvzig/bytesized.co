import AWSS3
import Foundation
import Smithy

struct S3ImageStore {
    private let bucketName: String
    private let client: S3Client

    init(bucketName: String) async throws {
        self.bucketName = bucketName
        self.client = try await S3Client()
    }

    func uploadImage(key: String, bytes: Data) async throws {
        let input = PutObjectInput(
            body: .data(bytes),
            bucket: bucketName,
            cacheControl: "public, max-age=31536000, immutable",
            contentLength: bytes.count,
            contentType: "image/png",
            key: key
        )

        _ = try await client.putObject(input: input)
    }

    func imageExists(key: String) async throws -> Bool {
        do {
            _ = try await client.headObject(
                input: HeadObjectInput(
                    bucket: bucketName,
                    key: key
                )
            )
            return true
        } catch is AWSS3.NotFound {
            return false
        }
    }

    func copyImage(from sourceKey: String, to destinationKey: String) async throws {
        let input = CopyObjectInput(
            bucket: bucketName,
            copySource: "\(bucketName)/\(sourceKey)",
            key: destinationKey
        )

        _ = try await client.copyObject(input: input)
    }

    func randomGeneratedImageKey(
        datePrefix: String,
        countrySuffix: String?,
    ) async throws -> String? {
        var randomNumberGenerator = SystemRandomNumberGenerator()
        var selectedPreferredKey: String?
        var seenPreferredKeyCount = 0
        var selectedKey: String?
        var seenKeyCount = 0

        for try await response in client.listObjectsV2Paginated(
            input: ListObjectsV2Input(
                bucket: bucketName,
                prefix: datePrefix
            )
        ) {
            for object in response.contents ?? [] {
                guard let key = object.key, key.hasSuffix(".png") else {
                    continue
                }

                seenKeyCount += 1
                if Int.random(in: 0..<seenKeyCount, using: &randomNumberGenerator) == 0 {
                    selectedKey = key
                }

                guard let countrySuffix, key.hasSuffix(countrySuffix) else {
                    continue
                }

                seenPreferredKeyCount += 1
                if Int.random(in: 0..<seenPreferredKeyCount, using: &randomNumberGenerator)
                    == 0
                {
                    selectedPreferredKey = key
                }
            }
        }

        return selectedPreferredKey ?? selectedKey
    }

    func countGeneratedImages(prefix: String) async throws -> Int {
        var count = 0

        for try await response in client.listObjectsV2Paginated(
            input: ListObjectsV2Input(
                bucket: bucketName,
                prefix: prefix
            )
        ) {
            count +=
                response.contents?.reduce(into: 0) { partialResult, object in
                    if object.key?.hasSuffix(".png") == true {
                        partialResult += 1
                    }
                } ?? 0
        }

        return count
    }
}
