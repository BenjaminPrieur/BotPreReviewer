import Foundation

class SlackService {
  private let webhookURL: String

  init(webhookURL: String) {
    self.webhookURL = webhookURL
  }

  func sendNotification(for mergeRequest: MergeRequest, feedback: String) async throws {
    let message = """
    🚀 New Merge Request
    Title: \(mergeRequest.title)
    Author: \(mergeRequest.author.name)
    URL: \(mergeRequest.webUrl)
    Feedback: \(feedback)
    """

    let payload = ["text": message]
    let jsonData = try JSONSerialization.data(withJSONObject: payload)

    guard let url = URL(string: webhookURL) else {
      throw URLError(.badURL)
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData

    let (_, response) = try await URLSession.shared.data(for: request)

    guard
      let httpResponse = response as? HTTPURLResponse,
      (200 ... 299).contains(httpResponse.statusCode)
    else {
      throw URLError(.badServerResponse)
    }
  }
}
