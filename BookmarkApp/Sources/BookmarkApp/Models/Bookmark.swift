import Foundation

/// A bookmark model representing a saved URL with metadata
/// Enhanced for knowledge base functionality with article support
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

    // MARK: - Article Metadata (Knowledge Base)

    /// The article's author name
    public var author: String?

    /// When the article was published
    public var publishedDate: Date?

    /// The website/publication name
    public var siteName: String?

    /// Short excerpt or summary of the article
    public var excerpt: String?

    /// Estimated reading time in minutes
    public var readingTime: Int?

    /// Hero/featured image URL
    public var imageURL: URL?

    /// Full extracted article content for offline reading and search
    public var articleContent: String?

    // MARK: - Knowledge Base Features

    /// User's personal notes about this article
    public var notes: String?

    /// Highlighted passages from the article
    public var highlights: [Highlight]

    /// Reading status for tracking progress
    public var readStatus: ReadStatus

    /// Collection IDs this bookmark belongs to
    public var collectionIDs: [UUID]

    public init(
        id: UUID = UUID(),
        title: String,
        url: URL,
        description: String = "",
        tags: [String] = [],
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        author: String? = nil,
        publishedDate: Date? = nil,
        siteName: String? = nil,
        excerpt: String? = nil,
        readingTime: Int? = nil,
        imageURL: URL? = nil,
        articleContent: String? = nil,
        notes: String? = nil,
        highlights: [Highlight] = [],
        readStatus: ReadStatus = .unread,
        collectionIDs: [UUID] = []
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.description = description
        self.tags = tags
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.author = author
        self.publishedDate = publishedDate
        self.siteName = siteName
        self.excerpt = excerpt
        self.readingTime = readingTime
        self.imageURL = imageURL
        self.articleContent = articleContent
        self.notes = notes
        self.highlights = highlights
        self.readStatus = readStatus
        self.collectionIDs = collectionIDs
    }

    /// Creates a copy with updated modification date
    public func updated(
        title: String? = nil,
        url: URL? = nil,
        description: String? = nil,
        tags: [String]? = nil,
        isFavorite: Bool? = nil,
        author: String?? = nil,
        publishedDate: Date?? = nil,
        siteName: String?? = nil,
        excerpt: String?? = nil,
        readingTime: Int?? = nil,
        imageURL: URL?? = nil,
        articleContent: String?? = nil,
        notes: String?? = nil,
        highlights: [Highlight]? = nil,
        readStatus: ReadStatus? = nil,
        collectionIDs: [UUID]? = nil
    ) -> Bookmark {
        Bookmark(
            id: self.id,
            title: title ?? self.title,
            url: url ?? self.url,
            description: description ?? self.description,
            tags: tags ?? self.tags,
            isFavorite: isFavorite ?? self.isFavorite,
            createdAt: self.createdAt,
            updatedAt: Date(),
            author: author ?? self.author,
            publishedDate: publishedDate ?? self.publishedDate,
            siteName: siteName ?? self.siteName,
            excerpt: excerpt ?? self.excerpt,
            readingTime: readingTime ?? self.readingTime,
            imageURL: imageURL ?? self.imageURL,
            articleContent: articleContent ?? self.articleContent,
            notes: notes ?? self.notes,
            highlights: highlights ?? self.highlights,
            readStatus: readStatus ?? self.readStatus,
            collectionIDs: collectionIDs ?? self.collectionIDs
        )
    }

    /// Computed property for display-friendly reading time
    public var readingTimeFormatted: String? {
        guard let minutes = readingTime else { return nil }
        if minutes < 1 {
            return "< 1 min read"
        } else if minutes == 1 {
            return "1 min read"
        } else {
            return "\(minutes) min read"
        }
    }

    /// Check if article content has been fetched
    public var hasArticleContent: Bool {
        articleContent != nil && !articleContent!.isEmpty
    }
}

// MARK: - Highlight

/// A highlighted passage from an article
public struct Highlight: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var text: String
    public var note: String?
    public var color: HighlightColor
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        text: String,
        note: String? = nil,
        color: HighlightColor = .yellow,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.note = note
        self.color = color
        self.createdAt = createdAt
    }
}

/// Available highlight colors
public enum HighlightColor: String, Codable, Sendable, CaseIterable {
    case yellow
    case green
    case blue
    case pink
    case purple
}

// MARK: - Read Status

/// Reading progress status
public enum ReadStatus: String, Codable, Sendable, CaseIterable {
    case unread = "Unread"
    case reading = "Reading"
    case read = "Read"
    case archived = "Archived"
}

// MARK: - Sample Data

public extension Bookmark {
    static let samples: [Bookmark] = [
        Bookmark(
            title: "Understanding Swift Concurrency",
            url: URL(string: "https://developer.apple.com/swift/concurrency")!,
            description: "A deep dive into async/await, actors, and structured concurrency in Swift",
            tags: ["swift", "concurrency", "async", "ios"],
            isFavorite: true,
            author: "Apple Developer Documentation",
            publishedDate: Date().addingTimeInterval(-86400 * 30),
            siteName: "Apple Developer",
            excerpt: "Swift concurrency provides a modern approach to handling asynchronous code...",
            readingTime: 15,
            readStatus: .reading,
            collectionIDs: []
        ),
        Bookmark(
            title: "SwiftUI State Management Best Practices",
            url: URL(string: "https://www.hackingwithswift.com/swiftui-state")!,
            description: "Learn how to effectively manage state in SwiftUI applications",
            tags: ["swiftui", "state", "tutorial", "ios"],
            isFavorite: true,
            author: "Paul Hudson",
            publishedDate: Date().addingTimeInterval(-86400 * 14),
            siteName: "Hacking with Swift",
            excerpt: "State management is crucial for building responsive SwiftUI apps...",
            readingTime: 12,
            highlights: [
                Highlight(text: "@State is designed for simple value types owned by a single view", color: .yellow),
                Highlight(text: "Use @Observable for reference types that need to be shared", note: "Important for complex apps", color: .green)
            ],
            readStatus: .read,
            collectionIDs: []
        ),
        Bookmark(
            title: "Building a Design System in Swift",
            url: URL(string: "https://www.swiftbysundell.com/design-system")!,
            description: "How to create a scalable and maintainable design system for iOS apps",
            tags: ["design", "architecture", "swift", "ui"],
            author: "John Sundell",
            publishedDate: Date().addingTimeInterval(-86400 * 7),
            siteName: "Swift by Sundell",
            readingTime: 20,
            notes: "Great patterns for theming - implement in current project",
            readStatus: .unread,
            collectionIDs: []
        ),
        Bookmark(
            title: "The Complete Guide to Navigation in SwiftUI",
            url: URL(string: "https://developer.apple.com/tutorials/swiftui/navigation")!,
            description: "Master NavigationStack, NavigationSplitView, and programmatic navigation",
            tags: ["swiftui", "navigation", "tutorial", "apple"],
            isFavorite: true,
            author: "Apple",
            siteName: "Apple Developer",
            readingTime: 25,
            readStatus: .unread,
            collectionIDs: []
        ),
        Bookmark(
            title: "Performance Optimization Techniques for iOS",
            url: URL(string: "https://www.avanderlee.com/ios-performance")!,
            description: "Essential techniques to improve your iOS app's performance",
            tags: ["performance", "optimization", "ios", "instruments"],
            author: "Antoine van der Lee",
            publishedDate: Date().addingTimeInterval(-86400 * 3),
            siteName: "SwiftLee",
            excerpt: "Performance is key to user satisfaction. Learn how to profile and optimize...",
            readingTime: 18,
            readStatus: .archived,
            collectionIDs: []
        )
    ]
}
