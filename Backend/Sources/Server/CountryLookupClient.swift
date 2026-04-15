import AsyncHTTPClient
import Foundation

struct CountryLookupClient {
    private let httpClient: HTTPClient
    private let jsonDecoder = JSONDecoder()
    private let baseURL = URL(string: "https://api.country.is")!

    init(
        httpClient: HTTPClient = .shared
    ) {
        self.httpClient = httpClient
    }

    func countryName(for ipAddress: String) async throws -> String? {
        let endpoint = baseURL.appending(path: ipAddress)
        let request = HTTPClientRequest(url: endpoint.absoluteString)
        let response = try await httpClient.execute(request, timeout: .seconds(30))
        let body = try await response.body.collect(upTo: 1024 * 1024)
        let data = Data(body.readableBytesView)
        return try countryName(from: data, statusCode: Int(response.status.code))
    }

    func countryName(from data: Data, statusCode: Int) throws -> String? {
        switch statusCode {
        case 200..<300:
            let lookup = try jsonDecoder.decode(CountryLookupResponse.self, from: data)
            let locale = Locale(identifier: "en_US_POSIX")
            return locale.localizedString(forRegionCode: lookup.country)
        case 400...404:
            return nil
        default:
            throw ServerError.httpFailure(
                service: .countryLookup,
                statusCode: statusCode,
                message: String(decoding: data, as: UTF8.self)
            )
        }
    }
}

private struct CountryLookupResponse: Decodable {
    let country: String
}
