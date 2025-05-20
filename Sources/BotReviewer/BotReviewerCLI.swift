import Foundation
import ArgumentParser

@main
struct ReviewerCLI: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "review",
    abstract: "Fetch and review your assigned Gitlab MRs using Ollama"
  )

  @Option(name: [.customShort("u"), .long], help: "Your GitLab username")
  var username: String

  @Option(name: [.customShort("t"), .long], help: "GitLab personal access token")
  var token: String

  @Option(name: [.long], help: "Optional project ID to filter")
  var projectID: Int?

  func run() async throws {
    print("username: \(username)")
    print("token: \(token.isEmpty ? "🛑" : "✅")")

    guard !token.isEmpty else { return }

    let gitClient: GitClient = GitlabClient(
      jsonDecoder: .gitlab,
      bearerToken: token
    )

    let mergeRequests = try await gitClient.fetchMergeRequests(for: username, projectID: projectID)
    guard !mergeRequests.isEmpty else {
      print("✅ No merge requests assigned.")
      return
    }

    let localStorage: LocalStorage = JSONLocalStorage()
    let reviewedKey: String = "reviewed"

    var reviewedMRs: [Int: Date] = localStorage.get(reviewedKey, defaultValue: [:])

    for mergeRequest in mergeRequests where reviewedMRs[mergeRequest.iid] != mergeRequest.updatedAt {
      print("\n📌 Reviewing MR: \(mergeRequest.title) [\(mergeRequest.references.full)]")
      let diff = try await gitClient.fetchSwiftDiff(projectID: mergeRequest.projectID, mrIID: mergeRequest.iid)

      guard !diff.isEmpty else {
        print("ℹ️ No Swift files changed, skipping.")
        continue
      }

      let feedback = try await Reviewer.runOllama(diff: diff)
      print("\n🧠 AI REVIEW:\n\(feedback)")
      reviewedMRs[mergeRequest.iid] = mergeRequest.updatedAt
      try? localStorage.set(reviewedKey, reviewedMRs)
      print("✅ saved review state.")
    }
  }
}
