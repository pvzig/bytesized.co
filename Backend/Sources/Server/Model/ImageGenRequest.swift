struct ImageGenRequest: Encodable {
    let model: String
    let outputFormat: String
    let prompt: String
    let quality: String
    let size: String

    enum CodingKeys: String, CodingKey {
        case model
        case outputFormat = "output_format"
        case prompt
        case quality
        case size
    }
}
