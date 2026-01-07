import XCTest
@testable import BookmarkApp

final class BookmarkTests: XCTestCase {

    // MARK: - Bookmark Model Tests

    func testBookmarkCreation() {
        let url = URL(string: "https://example.com")!
        let bookmark = Bookmark(
            title: "Example",
            url: url,
            description: "Test description",
            tags: ["test", "example"],
            isFavorite: true
        )

        XCTAssertEqual(bookmark.title, "Example")
        XCTAssertEqual(bookmark.url, url)
        XCTAssertEqual(bookmark.description, "Test description")
        XCTAssertEqual(bookmark.tags, ["test", "example"])
        XCTAssertTrue(bookmark.isFavorite)
    }

    func testBookmarkUpdate() {
        let url = URL(string: "https://example.com")!
        let bookmark = Bookmark(title: "Original", url: url)

        let updated = bookmark.updated(title: "Updated")

        XCTAssertEqual(updated.id, bookmark.id)
        XCTAssertEqual(updated.title, "Updated")
        XCTAssertEqual(updated.url, url)
        XCTAssertGreaterThanOrEqual(updated.updatedAt, bookmark.createdAt)
    }

    func testBookmarkCodable() throws {
        let url = URL(string: "https://example.com")!
        let bookmark = Bookmark(
            title: "Test",
            url: url,
            tags: ["tag1", "tag2"]
        )

        let encoded = try JSONEncoder().encode(bookmark)
        let decoded = try JSONDecoder().decode(Bookmark.self, from: encoded)

        XCTAssertEqual(decoded.id, bookmark.id)
        XCTAssertEqual(decoded.title, bookmark.title)
        XCTAssertEqual(decoded.url, bookmark.url)
        XCTAssertEqual(decoded.tags, bookmark.tags)
    }

    // MARK: - Filter Tests

    func testFilterBySearchText() {
        let filter = BookmarkFilter(searchText: "swift")
        let result = filter.apply(to: Bookmark.samples)

        XCTAssertTrue(result.allSatisfy { bookmark in
            bookmark.title.lowercased().contains("swift") ||
            bookmark.description.lowercased().contains("swift") ||
            bookmark.tags.contains { $0.lowercased().contains("swift") }
        })
    }

    func testFilterByTag() {
        let filter = BookmarkFilter(selectedTag: "tutorial")
        let result = filter.apply(to: Bookmark.samples)

        XCTAssertTrue(result.allSatisfy { $0.tags.contains("tutorial") })
    }

    func testFilterFavoritesOnly() {
        let filter = BookmarkFilter(showFavoritesOnly: true)
        let result = filter.apply(to: Bookmark.samples)

        XCTAssertTrue(result.allSatisfy { $0.isFavorite })
    }

    func testSortByDateDescending() {
        let filter = BookmarkFilter(sortOrder: .dateDescending)
        let result = filter.apply(to: Bookmark.samples)

        for i in 0..<result.count - 1 {
            XCTAssertGreaterThanOrEqual(result[i].createdAt, result[i + 1].createdAt)
        }
    }

    func testSortByTitleAscending() {
        let filter = BookmarkFilter(sortOrder: .titleAscending)
        let result = filter.apply(to: Bookmark.samples)

        for i in 0..<result.count - 1 {
            XCTAssertTrue(
                result[i].title.localizedCaseInsensitiveCompare(result[i + 1].title) != .orderedDescending
            )
        }
    }

    func testCombinedFilters() {
        let filter = BookmarkFilter(
            searchText: "swift",
            showFavoritesOnly: true,
            sortOrder: .titleAscending
        )
        let result = filter.apply(to: Bookmark.samples)

        XCTAssertTrue(result.allSatisfy { $0.isFavorite })
        XCTAssertTrue(result.allSatisfy { bookmark in
            bookmark.title.lowercased().contains("swift") ||
            bookmark.description.lowercased().contains("swift") ||
            bookmark.tags.contains { $0.lowercased().contains("swift") }
        })
    }

    // MARK: - Store Tests

    func testStoreAddAndRetrieve() async throws {
        let store = BookmarkStore(persistence: .preview)
        let url = URL(string: "https://test.com")!
        let bookmark = Bookmark(title: "Test", url: url)

        try await store.addBookmark(bookmark)
        let bookmarks = await store.getBookmarks()

        XCTAssertTrue(bookmarks.contains { $0.id == bookmark.id })
    }

    func testStoreToggleFavorite() async throws {
        let store = BookmarkStore(persistence: .preview)
        _ = try await store.loadBookmarks()

        let bookmarks = await store.getBookmarks()
        guard let first = bookmarks.first else {
            XCTFail("No bookmarks loaded")
            return
        }

        let originalFavorite = first.isFavorite
        try await store.toggleFavorite(id: first.id)

        let updated = await store.bookmark(with: first.id)
        XCTAssertEqual(updated?.isFavorite, !originalFavorite)
    }

    func testStoreDelete() async throws {
        let store = BookmarkStore(persistence: .preview)
        _ = try await store.loadBookmarks()

        let bookmarks = await store.getBookmarks()
        let countBefore = bookmarks.count
        guard let first = bookmarks.first else {
            XCTFail("No bookmarks loaded")
            return
        }

        try await store.deleteBookmark(id: first.id)

        let remaining = await store.getBookmarks()
        XCTAssertEqual(remaining.count, countBefore - 1)
        XCTAssertFalse(remaining.contains { $0.id == first.id })
    }

    func testStoreGetAllTags() async throws {
        let store = BookmarkStore(persistence: .preview)
        _ = try await store.loadBookmarks()

        let tags = await store.getAllTags()

        XCTAssertFalse(tags.isEmpty)
        XCTAssertEqual(tags, tags.sorted()) // Should be sorted
    }
}
