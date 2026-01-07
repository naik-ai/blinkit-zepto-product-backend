import Foundation

/// A bookmark model representing a saved URL with metadata
/// Following Swift Concurrency best practices: Sendable conformance for thread safety
public struct Bookmark: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var title: String
    public var url: URL
    public var description: String
    public var tags: [String]
    public var isFavorite: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        url: URL,
        description: String = "",
        tags: [String] = [],
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.description = description
        self.tags = tags
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Creates a copy with updated modification date
    public func updated(
        title: String? = nil,
        url: URL? = nil,
        description: String? = nil,
        tags: [String]? = nil,
        isFavorite: Bool? = nil
    ) -> Bookmark {
        Bookmark(
            id: self.id,
            title: title ?? self.title,
            url: url ?? self.url,
            description: description ?? self.description,
            tags: tags ?? self.tags,
            isFavorite: isFavorite ?? self.isFavorite,
            createdAt: self.createdAt,
            updatedAt: Date()
        )
    }
}

// MARK: - Sample Data

public extension Bookmark {
    static let samples: [Bookmark] = [
        Bookmark(
            title: "Apple Developer",
            url: URL(string: "https://developer.apple.com")!,
            description: "Official Apple developer documentation and resources",
            tags: ["development", "apple", "ios"],
            isFavorite: true
        ),
        Bookmark(
            title: "Swift.org",
            url: URL(string: "https://swift.org")!,
            description: "The Swift programming language official site",
            tags: ["swift", "programming", "opensource"]
        ),
        Bookmark(
            title: "SwiftUI Tutorials",
            url: URL(string: "https://developer.apple.com/tutorials/swiftui")!,
            description: "Learn SwiftUI with interactive tutorials",
            tags: ["swiftui", "tutorial", "apple"],
            isFavorite: true
        ),
        Bookmark(
            title: "GitHub",
            url: URL(string: "https://github.com")!,
            description: "Code hosting platform for version control",
            tags: ["git", "code", "opensource"]
        ),
        Bookmark(
            title: "Hacking with Swift",
            url: URL(string: "https://www.hackingwithswift.com")!,
            description: "Free Swift tutorials and courses",
            tags: ["swift", "tutorial", "learning"]
        )
    ]
}
