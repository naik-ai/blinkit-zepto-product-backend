import Foundation
import SwiftUI

/// Observable view model for bookmark management
/// Following SwiftUI UI Patterns: @Observable for modern state management
/// Following SwiftUI View Refactor: Models own business logic, views are lightweight
@Observable
@MainActor
public final class BookmarkViewModel {
    // MARK: - State

    public private(set) var bookmarks: [Bookmark] = []
    public private(set) var filteredBookmarks: [Bookmark] = []
    public private(set) var allTags: [String] = []
    public private(set) var isLoading = false
    public private(set) var error: BookmarkError?

    public var filter = BookmarkFilter() {
        didSet { applyFilter() }
    }

    // MARK: - Dependencies

    private let store: BookmarkStore

    // MARK: - Initialization

    public init(store: BookmarkStore) {
        self.store = store
    }

    // MARK: - Actions

    public func loadBookmarks() async {
        isLoading = true
        error = nil

        do {
            bookmarks = try await store.loadBookmarks()
            allTags = await store.getAllTags()
            applyFilter()
        } catch let bookmarkError as BookmarkError {
            error = bookmarkError
        } catch {
            self.error = .persistenceFailure(error)
        }

        isLoading = false
    }

    public func addBookmark(
        title: String,
        urlString: String,
        description: String = "",
        tags: [String] = []
    ) async {
        guard let url = URL(string: urlString), url.scheme != nil else {
            error = .invalidURL
            return
        }

        let bookmark = Bookmark(
            title: title.isEmpty ? urlString : title,
            url: url,
            description: description,
            tags: tags
        )

        do {
            try await store.addBookmark(bookmark)
            bookmarks = await store.getBookmarks()
            allTags = await store.getAllTags()
            applyFilter()
        } catch let bookmarkError as BookmarkError {
            error = bookmarkError
        } catch {
            self.error = .persistenceFailure(error)
        }
    }

    public func updateBookmark(_ bookmark: Bookmark) async {
        do {
            try await store.updateBookmark(bookmark)
            bookmarks = await store.getBookmarks()
            allTags = await store.getAllTags()
            applyFilter()
        } catch let bookmarkError as BookmarkError {
            error = bookmarkError
        } catch {
            self.error = .persistenceFailure(error)
        }
    }

    public func deleteBookmark(_ bookmark: Bookmark) async {
        do {
            try await store.deleteBookmark(id: bookmark.id)
            bookmarks = await store.getBookmarks()
            allTags = await store.getAllTags()
            applyFilter()
        } catch let bookmarkError as BookmarkError {
            error = bookmarkError
        } catch {
            self.error = .persistenceFailure(error)
        }
    }

    public func deleteBookmarks(_ bookmarks: [Bookmark]) async {
        let ids = Set(bookmarks.map { $0.id })
        do {
            try await store.deleteBookmarks(ids: ids)
            self.bookmarks = await store.getBookmarks()
            allTags = await store.getAllTags()
            applyFilter()
        } catch let bookmarkError as BookmarkError {
            error = bookmarkError
        } catch {
            self.error = .persistenceFailure(error)
        }
    }

    public func toggleFavorite(_ bookmark: Bookmark) async {
        do {
            try await store.toggleFavorite(id: bookmark.id)
            bookmarks = await store.getBookmarks()
            applyFilter()
        } catch let bookmarkError as BookmarkError {
            error = bookmarkError
        } catch {
            self.error = .persistenceFailure(error)
        }
    }

    public func clearError() {
        error = nil
    }

    // MARK: - Private

    /// Precompute filtered results following SwiftUI Performance patterns
    private func applyFilter() {
        filteredBookmarks = filter.apply(to: bookmarks)
    }
}

// MARK: - Preview Support

public extension BookmarkViewModel {
    static var preview: BookmarkViewModel {
        let store = BookmarkStore(persistence: .preview)
        let viewModel = BookmarkViewModel(store: store)
        viewModel.bookmarks = Bookmark.samples
        viewModel.filteredBookmarks = Bookmark.samples
        viewModel.allTags = Array(Set(Bookmark.samples.flatMap { $0.tags })).sorted()
        return viewModel
    }
}
