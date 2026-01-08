import Foundation
import SwiftUI

/// A collection for organizing bookmarks into knowledge categories
/// Collections can be nested to create a hierarchical knowledge base
public struct Collection: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var name: String
    public var description: String
    public var icon: String
    public var color: CollectionColor
    public var parentID: UUID?
    public var createdAt: Date
    public var updatedAt: Date

    /// Smart collection filter (nil for regular collections)
    public var smartFilter: SmartFilter?

    public init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        icon: String = "folder",
        color: CollectionColor = .blue,
        parentID: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        smartFilter: SmartFilter? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.color = color
        self.parentID = parentID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.smartFilter = smartFilter
    }

    /// Check if this is a smart collection
    public var isSmart: Bool {
        smartFilter != nil
    }
}

// MARK: - Collection Color

public enum CollectionColor: String, Codable, Sendable, CaseIterable {
    case red, orange, yellow, green, blue, purple, pink, gray

    public var color: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .blue: return .blue
        case .purple: return .purple
        case .pink: return .pink
        case .gray: return .gray
        }
    }
}

// MARK: - Smart Filter

/// Filter criteria for smart collections
public struct SmartFilter: Codable, Sendable, Hashable {
    public var tags: [String]
    public var readStatus: ReadStatus?
    public var isFavorite: Bool?
    public var hasNotes: Bool?
    public var hasHighlights: Bool?
    public var siteName: String?
    public var dateRange: DateRange?

    public init(
        tags: [String] = [],
        readStatus: ReadStatus? = nil,
        isFavorite: Bool? = nil,
        hasNotes: Bool? = nil,
        hasHighlights: Bool? = nil,
        siteName: String? = nil,
        dateRange: DateRange? = nil
    ) {
        self.tags = tags
        self.readStatus = readStatus
        self.isFavorite = isFavorite
        self.hasNotes = hasNotes
        self.hasHighlights = hasHighlights
        self.siteName = siteName
        self.dateRange = dateRange
    }

    /// Apply filter to bookmarks
    public func apply(to bookmarks: [Bookmark]) -> [Bookmark] {
        bookmarks.filter { bookmark in
            // Tags filter
            if !tags.isEmpty && !tags.allSatisfy({ bookmark.tags.contains($0) }) {
                return false
            }

            // Read status filter
            if let status = readStatus, bookmark.readStatus != status {
                return false
            }

            // Favorite filter
            if let fav = isFavorite, bookmark.isFavorite != fav {
                return false
            }

            // Has notes filter
            if let notes = hasNotes {
                let bookmarkHasNotes = bookmark.notes != nil && !bookmark.notes!.isEmpty
                if bookmarkHasNotes != notes {
                    return false
                }
            }

            // Has highlights filter
            if let highlights = hasHighlights {
                let bookmarkHasHighlights = !bookmark.highlights.isEmpty
                if bookmarkHasHighlights != highlights {
                    return false
                }
            }

            // Site name filter
            if let site = siteName, bookmark.siteName != site {
                return false
            }

            // Date range filter
            if let range = dateRange {
                if !range.contains(bookmark.createdAt) {
                    return false
                }
            }

            return true
        }
    }
}

// MARK: - Date Range

public struct DateRange: Codable, Sendable, Hashable {
    public var start: Date?
    public var end: Date?

    public init(start: Date? = nil, end: Date? = nil) {
        self.start = start
        self.end = end
    }

    public func contains(_ date: Date) -> Bool {
        if let start = start, date < start {
            return false
        }
        if let end = end, date > end {
            return false
        }
        return true
    }

    // Convenience presets
    public static var today: DateRange {
        DateRange(start: Calendar.current.startOfDay(for: Date()))
    }

    public static var thisWeek: DateRange {
        let now = Date()
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)
        return DateRange(start: weekAgo)
    }

    public static var thisMonth: DateRange {
        let now = Date()
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)
        return DateRange(start: monthAgo)
    }
}

// MARK: - Sample Collections

public extension Collection {
    static let samples: [Collection] = [
        Collection(
            name: "Swift Development",
            description: "Articles about Swift programming",
            icon: "swift",
            color: .orange
        ),
        Collection(
            name: "SwiftUI",
            description: "SwiftUI tutorials and best practices",
            icon: "rectangle.3.group",
            color: .blue
        ),
        Collection(
            name: "Architecture",
            description: "App architecture and design patterns",
            icon: "building.columns",
            color: .purple
        ),
        Collection(
            name: "Performance",
            description: "Performance optimization articles",
            icon: "gauge.with.needle",
            color: .green
        ),
        // Smart collections
        Collection(
            name: "Unread Articles",
            description: "All unread articles",
            icon: "book.closed",
            color: .red,
            smartFilter: SmartFilter(readStatus: .unread)
        ),
        Collection(
            name: "Favorites",
            description: "All favorited articles",
            icon: "star.fill",
            color: .yellow,
            smartFilter: SmartFilter(isFavorite: true)
        ),
        Collection(
            name: "With Notes",
            description: "Articles with personal notes",
            icon: "note.text",
            color: .pink,
            smartFilter: SmartFilter(hasNotes: true)
        ),
        Collection(
            name: "Highlighted",
            description: "Articles with highlights",
            icon: "highlighter",
            color: .orange,
            smartFilter: SmartFilter(hasHighlights: true)
        )
    ]
}
