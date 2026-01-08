import Foundation

/// Filter and sort options for bookmarks
/// Enhanced for knowledge base with read status, full-text search, and more
/// Value type for Sendable safety
public struct BookmarkFilter: Sendable, Equatable {
    public var searchText: String
    public var selectedTag: String?
    public var showFavoritesOnly: Bool
    public var sortOrder: SortOrder

    // MARK: - Knowledge Base Filters

    /// Filter by read status
    public var readStatus: ReadStatus?

    /// Filter by collection ID
    public var collectionID: UUID?

    /// Filter by site/source
    public var siteName: String?

    /// Only show articles with notes
    public var hasNotes: Bool?

    /// Only show articles with highlights
    public var hasHighlights: Bool?

    /// Enable full-text search in article content
    public var searchInContent: Bool

    public init(
        searchText: String = "",
        selectedTag: String? = nil,
        showFavoritesOnly: Bool = false,
        sortOrder: SortOrder = .dateDescending,
        readStatus: ReadStatus? = nil,
        collectionID: UUID? = nil,
        siteName: String? = nil,
        hasNotes: Bool? = nil,
        hasHighlights: Bool? = nil,
        searchInContent: Bool = true
    ) {
        self.searchText = searchText
        self.selectedTag = selectedTag
        self.showFavoritesOnly = showFavoritesOnly
        self.sortOrder = sortOrder
        self.readStatus = readStatus
        self.collectionID = collectionID
        self.siteName = siteName
        self.hasNotes = hasNotes
        self.hasHighlights = hasHighlights
        self.searchInContent = searchInContent
    }

    public enum SortOrder: String, CaseIterable, Sendable {
        case dateDescending = "Newest First"
        case dateAscending = "Oldest First"
        case titleAscending = "Title A-Z"
        case titleDescending = "Title Z-A"
        case readingTime = "Reading Time"
        case publishedDate = "Published Date"
    }

    /// Apply filter to a collection of bookmarks
    /// Precomputed filtering following SwiftUI Performance patterns
    public func apply(to bookmarks: [Bookmark]) -> [Bookmark] {
        var result = bookmarks

        // Filter by search text (full-text search across all fields)
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { bookmark in
                // Basic fields
                if bookmark.title.lowercased().contains(query) { return true }
                if bookmark.description.lowercased().contains(query) { return true }
                if bookmark.url.absoluteString.lowercased().contains(query) { return true }
                if bookmark.tags.contains(where: { $0.lowercased().contains(query) }) { return true }

                // Knowledge base fields
                if let author = bookmark.author?.lowercased(), author.contains(query) { return true }
                if let site = bookmark.siteName?.lowercased(), site.contains(query) { return true }
                if let excerpt = bookmark.excerpt?.lowercased(), excerpt.contains(query) { return true }
                if let notes = bookmark.notes?.lowercased(), notes.contains(query) { return true }

                // Full-text content search
                if searchInContent, let content = bookmark.articleContent?.lowercased(), content.contains(query) {
                    return true
                }

                // Search in highlights
                if bookmark.highlights.contains(where: { $0.text.lowercased().contains(query) }) {
                    return true
                }

                return false
            }
        }

        // Filter by tag
        if let tag = selectedTag {
            result = result.filter { $0.tags.contains(tag) }
        }

        // Filter favorites
        if showFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }

        // Filter by read status
        if let status = readStatus {
            result = result.filter { $0.readStatus == status }
        }

        // Filter by collection
        if let collectionID = collectionID {
            result = result.filter { $0.collectionIDs.contains(collectionID) }
        }

        // Filter by site name
        if let site = siteName {
            result = result.filter { $0.siteName == site }
        }

        // Filter by has notes
        if let notes = hasNotes {
            result = result.filter { bookmark in
                let bookmarkHasNotes = bookmark.notes != nil && !bookmark.notes!.isEmpty
                return bookmarkHasNotes == notes
            }
        }

        // Filter by has highlights
        if let highlights = hasHighlights {
            result = result.filter { bookmark in
                let bookmarkHasHighlights = !bookmark.highlights.isEmpty
                return bookmarkHasHighlights == highlights
            }
        }

        // Sort
        result = sort(result)

        return result
    }

    private func sort(_ bookmarks: [Bookmark]) -> [Bookmark] {
        switch sortOrder {
        case .dateDescending:
            return bookmarks.sorted { $0.createdAt > $1.createdAt }
        case .dateAscending:
            return bookmarks.sorted { $0.createdAt < $1.createdAt }
        case .titleAscending:
            return bookmarks.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleDescending:
            return bookmarks.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        case .readingTime:
            return bookmarks.sorted { ($0.readingTime ?? 0) < ($1.readingTime ?? 0) }
        case .publishedDate:
            return bookmarks.sorted { ($0.publishedDate ?? .distantPast) > ($1.publishedDate ?? .distantPast) }
        }
    }

    /// Reset all filters
    public mutating func reset() {
        searchText = ""
        selectedTag = nil
        showFavoritesOnly = false
        readStatus = nil
        collectionID = nil
        siteName = nil
        hasNotes = nil
        hasHighlights = nil
    }

    /// Check if any filters are active
    public var hasActiveFilters: Bool {
        !searchText.isEmpty ||
        selectedTag != nil ||
        showFavoritesOnly ||
        readStatus != nil ||
        collectionID != nil ||
        siteName != nil ||
        hasNotes != nil ||
        hasHighlights != nil
    }
}

// MARK: - Quick Filter Presets

public extension BookmarkFilter {
    /// Unread articles
    static var unread: BookmarkFilter {
        BookmarkFilter(readStatus: .unread)
    }

    /// Currently reading
    static var reading: BookmarkFilter {
        BookmarkFilter(readStatus: .reading)
    }

    /// Completed articles
    static var read: BookmarkFilter {
        BookmarkFilter(readStatus: .read)
    }

    /// Articles with notes
    static var withNotes: BookmarkFilter {
        BookmarkFilter(hasNotes: true)
    }

    /// Articles with highlights
    static var withHighlights: BookmarkFilter {
        BookmarkFilter(hasHighlights: true)
    }

    /// Favorites only
    static var favorites: BookmarkFilter {
        BookmarkFilter(showFavoritesOnly: true)
    }
}
