import SwiftUI

/// Main entry point for the Bookmark App
/// Following SwiftUI UI Patterns: TabView + NavigationStack app scaffolding
@main
public struct BookmarkApp: App {
    // MARK: - State

    @State private var store = BookmarkStore(persistence: .live)
    @State private var viewModel: BookmarkViewModel?

    // MARK: - Body

    public var body: some Scene {
        WindowGroup {
            contentView
                .task { initializeViewModel() }
        }
    }

    // MARK: - Private

    @ViewBuilder
    private var contentView: some View {
        if let viewModel {
            BookmarkListView(viewModel: viewModel)
        } else {
            ProgressView("Loading...")
        }
    }

    private func initializeViewModel() {
        if viewModel == nil {
            viewModel = BookmarkViewModel(store: store)
        }
    }

    // MARK: - Initialization

    public init() {}
}
