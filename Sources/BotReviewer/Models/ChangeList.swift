struct ChangeList: Decodable {
  struct Change: Decodable {
    let diff: String
    let newPath: String

    // swiftlint:disable:next nesting
    enum CodingKeys: String, CodingKey {
      case diff
      case newPath = "new_path"
    }
  }

  let changes: [Change]
}
