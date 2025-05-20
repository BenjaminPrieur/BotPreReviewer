import Foundation

struct MergeRequest: Decodable {
  let iid: Int
  let title: String
  let projectID: Int
  let references: References
  let updatedAt: Date
  let author: Author
  let webUrl: String

  enum CodingKeys: String, CodingKey {
    case iid
    case title
    case projectID = "project_id"
    case references
    case updatedAt = "updated_at"
    case author
    case webUrl = "web_url"
  }

  struct References: Decodable {
    let full: String
  }

  struct Author: Decodable {
    let name: String
  }
}
