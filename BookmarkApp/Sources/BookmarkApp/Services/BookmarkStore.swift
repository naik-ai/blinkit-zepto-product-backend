import Foundation

/// Thread-safe bookmark storage using actor isolation
/// Following Swift Concurrency Expert patterns for data-race safety
public actor BookmarkStore {
    private var bookmarks: [Bookmark] = []
    private let persistence: BookmarkPersistence

    public init(persistence: BookmarkPersistence = .live) {
        self.persistence = persistence
    }

    // MARK: - CRUD Operations

    public func loadBookmarks() async throws -> [Bookmark] {
        bookmarks = try await persistence.load()
        return bookmarks
    }

    public func getBookmarks() -> [Bookmark] {
        bookmarks
    }

    public func addBookmark(_ bookmark: Bookmark) async throws {
        bookmarks.append(bookmark)
        try await persistence.save(bookmarks)
    }

    public func updateBookmark(_ bookmark: Bookmark) async throws {
        guard let index = bookmarks.firstIndex(where: { $0.id == bookmark.id }) else {
            throw BookmarkError.notFound
        }
        bookmarks[index] = bookmark
        try await persistence.save(bookmarks)
    }

    public func deleteBookmark(id: UUID) async throws {
        guard let index = bookmarks.firstIndex(where: { $0.id == id }) else {
            throw BookmarkError.notFound
        }
        bookmarks.remove(at: index)
        try await persistence.save(bookmarks)
    }

    public func deleteBookmarks(ids: Set<UUID>) async throws {
        bookmarks.removeAll { ids.contains($0.id) }
        try await persistence.save(bookmarks)
    }

    public func toggleFavorite(id: UUID) async throws {
        guard let index = bookmarks.firstIndex(where: { $0.id == id }) else {
            throw BookmarkError.notFound
        }
        let bookmark = bookmarks[index]
        bookmarks[index] = bookmark.updated(isFavorite: !bookmark.isFavorite)
        try await persistence.save(bookmarks)
    }

    // MARK: - Queries

    public func getAllTags() -> [String] {
        Array(Set(bookmarks.flatMap { $0.tags })).sorted()
    }

    public func bookmark(with id: UUID) -> Bookmark? {
        bookmarks.first { $0.id == id }
    }
}

// MARK: - Errors

public enum BookmarkError: LocalizedError {
    case notFound
    case persistenceFailure(Error)
    case invalidURL

    public var errorDescription: String? {
        switch self {
        case .notFound:
            return "Bookmark not found"
        case .persistenceFailure(let error):
            return "Failed to save bookmarks: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid URL provided"
        }
    }
}

// MARK: - Persistence Layer

public struct BookmarkPersistence: Sendable {
    public var load: @Sendable () async throws -> [Bookmark]
    public var save: @Sendable ([Bookmark]) async throws -> Void

    public init(
        load: @escaping @Sendable () async throws -> [Bookmark],
        save: @escaping @Sendable ([Bookmark]) async throws -> Void
    ) {
        self.load = load
        self.save = save
    }
}

// MARK: - Live Persistence Implementation

public extension BookmarkPersistence {
    static let live = BookmarkPersistence(
        load: {
            let url = try fileURL()
            guard FileManager.default.fileExists(atPath: url.path) else {
                return []
            }
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Bookmark].self, from: data)
        },
        save: { bookmarks in
            let url = try fileURL()
            let data = try JSONEncoder().encode(bookmarks)
            try data.write(to: url, options: .atomic)
        }
    )

    static let preview = BookmarkPersistence(
        load: { Bookmark.samples },
        save: { _ in }
    )

    private static func fileURL() throws -> URL {
        let documentsDirectory = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return documentsDirectory.appendingPathComponent("bookmarks.json")
    }
}
