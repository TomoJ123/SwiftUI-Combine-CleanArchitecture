struct DogListResponseItem: Decodable {
    let name: String
    let subBreed: [String]
}

struct DogListResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case dogInfo = "message"
        case status
    }
    let dogInfo: [String: [String]]
    let status: String
}

extension DogListResponseItem {
    func toDogListItem() -> DogListItem {
        return DogListItem(name: name.capitalizingFirstLetter(),
                           subBreed: subBreed)
    }
}
