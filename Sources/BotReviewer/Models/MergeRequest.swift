import Foundation

struct MergeRequest: Decodable {
  let iid: Int
  let title: String
  let projectID: Int
  let references: References
  let updatedAt: Date

  enum CodingKeys: String, CodingKey {
    case iid
    case title
    case projectID = "project_id"
    case references
    case updatedAt = "updated_at"
  }

  struct References: Decodable {
    let full: String
  }
}
