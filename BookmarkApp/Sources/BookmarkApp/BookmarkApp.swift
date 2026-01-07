import SwiftUI

/// Main entry point for the Bookmark App
/// Following SwiftUI UI Patterns: TabView + NavigationStack app scaffolding
/// Following SwiftUI View Refactor: Non-optional @State initialization
@main
public struct BookmarkApp: App {
    // MARK: - State

    /// Non-optional state following swiftui-view-refactor skill
    /// "Replace optional view models with non-optional @State"
    @State private var store: BookmarkStore
    @State private var viewModel: BookmarkViewModel
    @State private var router = Router()

    // MARK: - Initialization

    public init() {
        let store = BookmarkStore(persistence: .live)
        _store = State(initialValue: store)
        _viewModel = State(initialValue: BookmarkViewModel(store: store))
    }

    // MARK: - Body

    public var body: some Scene {
        WindowGroup {
            BookmarkListView(viewModel: viewModel)
                .environment(\.router, router)
        }
    }
}

// MARK: - Router

/// Navigation router following navigation-patterns reference
/// "Router owns the path and any sheet state"
@Observable
public final class Router {
    public var path = NavigationPath()
    public var presentedSheet: BookmarkSheet?

    public init() {}

    public func navigate(to route: BookmarkRoute) {
        path.append(route)
    }

    public func popToRoot() {
        path = NavigationPath()
    }

    public func present(_ sheet: BookmarkSheet) {
        presentedSheet = sheet
    }

    public func dismissSheet() {
        presentedSheet = nil
    }
}

// MARK: - Routes

/// Route enum for navigation destinations
public enum BookmarkRoute: Hashable {
    case detail(Bookmark)
    case tag(String)
}

/// Sheet enum for modal presentations
public enum BookmarkSheet: Identifiable {
    case add
    case edit(Bookmark)

    public var id: String {
        switch self {
        case .add: return "add"
        case .edit(let bookmark): return "edit-\(bookmark.id)"
        }
    }
}

// MARK: - Environment Key

private struct RouterKey: EnvironmentKey {
    static let defaultValue = Router()
}

public extension EnvironmentValues {
    var router: Router {
        get { self[RouterKey.self] }
        set { self[RouterKey.self] = newValue }
    }
}
