import Ollama

struct Reviewer {
  // swiftlint:disable line_length
  private static let basedPrompt = """
    You are a senior iOS engineer. Review this Swift code diff and provide feedback, including suggestions for improvements and code quality issues.
    """
  // swiftlint:enable line_length

  static func runOllama(diff: String) async throws -> String {
    let client = await Client.default
    let response = try await client.generate(
      model: "llama3.2",
      prompt: "\(basedPrompt)\n\n\(diff)",
      options: ["temperature": 0.7]
    )
    return response.response
  }
}
