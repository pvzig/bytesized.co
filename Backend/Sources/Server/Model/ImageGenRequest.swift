struct ImageGenRequest: Encodable {
    let background: String
    let model: String
    let outputFormat: String
    let prompt: String
    let quality: String
    let size: String

    enum CodingKeys: String, CodingKey {
        case background
        case model
        case outputFormat = "output_format"
        case prompt
        case quality
        case size
    }
}
