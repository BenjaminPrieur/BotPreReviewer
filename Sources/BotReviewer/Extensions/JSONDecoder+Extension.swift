import Foundation

extension JSONDecoder {
  static var gitlab: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let dateStr = try container.decode(String.self)
      guard let date = ISO8601DateFormatter.gitlabDateFormatter.date(from: dateStr) else {
        throw DecodingError.dataCorruptedError(
          in: container,
          debugDescription: "Invalid date format: \(dateStr)"
        )
      }
      return date
    }
    return decoder
  }
}

extension ISO8601DateFormatter: @unchecked @retroactive Sendable {
  static let gitlabDateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }()
}
