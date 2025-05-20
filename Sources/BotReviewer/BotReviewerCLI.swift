import ArgumentParser
import Foundation

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

  @Option(name: [.long], help: "Slack webhook URL for notifications")
  var slackWebhook: String?

  @Option(name: [.long], help: "Interval in minutes to fetch merge requests (default: 5)")
  var interval: Int = 5

  func run() async throws {
    print("username: \(username)")
    print("token: \(token.isEmpty ? "🛑" : "✅")")
    print("Fetch interval: \(interval) minutes")

    guard !token.isEmpty else { return }

    let gitClient: GitClient = GitlabClient(
      jsonDecoder: .gitlab,
      bearerToken: token
    )

    while true {
      try await reviewMergeRequests(gitClient: gitClient)
      try await Task.sleep(for: .seconds(interval * 60))
    }
  }

  private func reviewMergeRequests(gitClient: GitClient) async throws {
    let mergeRequests = try await gitClient.fetchMergeRequests(for: username, projectID: projectID)
    guard !mergeRequests.isEmpty else {
      print("✅ No merge requests assigned.")
      return
    }

    let localStorage: LocalStorage = JSONLocalStorage()
    let reviewedKey = "reviewed"

    var reviewedMRs: [Int: Date] = localStorage.get(reviewedKey, defaultValue: [:])

    let slackService = slackWebhook.map { SlackService(webhookURL: $0) }

    for mergeRequest in mergeRequests where reviewedMRs[mergeRequest.iid] != mergeRequest.updatedAt {
      print("\n📌 Reviewing MR: \(mergeRequest.author.name) - \(mergeRequest.title) [\(mergeRequest.references.full)]")
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

      if let slackService {
        try await slackService.sendNotification(for: mergeRequest, feedback: feedback)
        print("✅ Sent Slack notification")
      }
    }
  }
}
