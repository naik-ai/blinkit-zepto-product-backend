import Foundation

/// Filter and sort options for bookmarks
/// Value type for Sendable safety
public struct BookmarkFilter: Sendable, Equatable {
    public var searchText: String
    public var selectedTag: String?
    public var showFavoritesOnly: Bool
    public var sortOrder: SortOrder

    public init(
        searchText: String = "",
        selectedTag: String? = nil,
        showFavoritesOnly: Bool = false,
        sortOrder: SortOrder = .dateDescending
    ) {
        self.searchText = searchText
        self.selectedTag = selectedTag
        self.showFavoritesOnly = showFavoritesOnly
        self.sortOrder = sortOrder
    }

    public enum SortOrder: String, CaseIterable, Sendable {
        case dateDescending = "Newest First"
        case dateAscending = "Oldest First"
        case titleAscending = "Title A-Z"
        case titleDescending = "Title Z-A"
    }

    /// Apply filter to a collection of bookmarks
    /// Precomputed filtering following SwiftUI Performance patterns
    public func apply(to bookmarks: [Bookmark]) -> [Bookmark] {
        var result = bookmarks

        // Filter by search text
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { bookmark in
                bookmark.title.lowercased().contains(query) ||
                bookmark.description.lowercased().contains(query) ||
                bookmark.url.absoluteString.lowercased().contains(query) ||
                bookmark.tags.contains { $0.lowercased().contains(query) }
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
        }
    }
}
