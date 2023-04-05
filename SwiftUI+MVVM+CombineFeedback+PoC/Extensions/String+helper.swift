extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    func decapitalizingFirstLetter() -> String {
        return prefix(1).lowercased() + dropFirst()
    }
}
