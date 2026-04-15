struct ImageGenResponse: Decodable {
    let data: [ImageData]

    struct ImageData: Decodable {
        let base64JSON: String?

        enum CodingKeys: String, CodingKey {
            case base64JSON = "b64_json"
        }
    }
}
