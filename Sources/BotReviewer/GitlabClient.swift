import Foundation

protocol GitClient {
  func fetchMergeRequests(for username: String, projectID: Int?) async throws -> [MergeRequest]
  func fetchSwiftDiff(projectID: Int, mrIID: Int) async throws -> String
}

struct GitlabClient: GitClient {
  let apiBase = "https://gitlab.com/api/v4"
  let session: URLSession
  let jsonDecoder: JSONDecoder
  let bearerToken: String

  init(
    session: URLSession = URLSession(configuration: .default),
    jsonDecoder: JSONDecoder,
    bearerToken: String
  ) {
    self.session = session
    self.jsonDecoder = jsonDecoder
    self.bearerToken = bearerToken
  }

  func fetchMergeRequests(for username: String, projectID: Int?) async throws -> [MergeRequest] {
    var components = URLComponents(
      string: projectID != nil
      ? "\(apiBase)/projects/\(projectID!)/merge_requests"
      : "\(apiBase)/merge_requests"
    )!

    components.queryItems = [
      .init(name: "scope", value: "all"),
      .init(name: "state", value: "opened"),
      .init(name: "reviewer_username", value: username)
    ]

    var request = URLRequest(url: components.url!)
    request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await session.data(for: request)
//    print(String(data: data, encoding: .utf8))
    return try jsonDecoder.decode([MergeRequest].self, from: data)
  }

  func fetchSwiftDiff(projectID: Int, mrIID: Int) async throws -> String {
    let url = URL(string: "\(apiBase)/projects/\(projectID)/merge_requests/\(mrIID)/changes")!
    var request = URLRequest(url: url)
    request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await session.data(for: request)
    let changes = try jsonDecoder.decode(ChangeList.self, from: data).changes
    let swiftChanges = changes.filter { $0.newPath.hasSuffix(".swift") }
    return swiftChanges.map(\.diff).joined(separator: "\n")
  }
}
