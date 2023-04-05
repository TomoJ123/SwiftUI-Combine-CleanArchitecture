struct DogDetailsResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case images = "message"
    }

    let images: [String]
}

extension DogDetailsResponse {
    func toDogDetails() -> DogDetails {
        return DogDetails(images: images)
    }
}
