import Foundation

protocol LocalStorage {
  func get<T: Codable>(_ key: String, defaultValue: T) -> T
  func set<T: Codable>(_ key: String, _ value: T) throws
}

struct JSONLocalStorage: LocalStorage {
  func get<T: Codable>(_ key: String, defaultValue: T) -> T {
    let filePath = URL(fileURLWithPath: key + ".json")
    guard
      let data = try? Data(contentsOf: filePath),
      let list = try? JSONDecoder().decode(T.self, from: data)
    else { return defaultValue }

    return list
  }

  func set<T: Codable>(_ key: String, _ value: T) throws {
    let filePath = URL(fileURLWithPath: key + ".json")
    try JSONEncoder().encode(value)
      .write(to: filePath)
  }
}
