import SwiftUI

/// Main bookmark list view following SwiftUI UI Patterns
/// - Composition with small, focused subviews
/// - Modern state management with @Observable
/// - .task for async loading
/// - Proper accessibility support
public struct BookmarkListView: View {
    // MARK: - Environment

    @Environment(\.openURL) private var openURL

    // MARK: - State

    @State private var viewModel: BookmarkViewModel
    @State private var selectedBookmark: Bookmark?
    @State private var isAddingBookmark = false
    @State private var bookmarkToEdit: Bookmark?
    @State private var showingDeleteConfirmation = false
    @State private var bookmarkToDelete: Bookmark?

    // MARK: - Initialization

    public init(viewModel: BookmarkViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Bookmarks")
                .toolbar { toolbarContent }
                .searchable(
                    text: $viewModel.filter.searchText,
                    prompt: "Search bookmarks"
                )
                .refreshable { await viewModel.loadBookmarks() }
        }
        .task { await viewModel.loadBookmarks() }
        .sheet(isPresented: $isAddingBookmark) { addBookmarkSheet }
        .sheet(item: $bookmarkToEdit) { bookmark in
            editBookmarkSheet(for: bookmark)
        }
        .confirmationDialog(
            "Delete Bookmark",
            isPresented: $showingDeleteConfirmation,
            presenting: bookmarkToDelete
        ) { bookmark in
            deleteConfirmationActions(for: bookmark)
        } message: { bookmark in
            Text("Are you sure you want to delete \"\(bookmark.title)\"?")
        }
        .alert(
            "Error",
            isPresented: .constant(viewModel.error != nil),
            presenting: viewModel.error
        ) { _ in
            Button("OK") { viewModel.clearError() }
        } message: { error in
            Text(error.localizedDescription)
        }
    }

    // MARK: - Content Views

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.bookmarks.isEmpty {
            loadingView
        } else if viewModel.filteredBookmarks.isEmpty {
            emptyStateView
        } else {
            bookmarkList
        }
    }

    private var loadingView: some View {
        ProgressView("Loading bookmarks...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label(
                viewModel.bookmarks.isEmpty ? "No Bookmarks" : "No Results",
                systemImage: viewModel.bookmarks.isEmpty ? "bookmark" : "magnifyingglass"
            )
        } description: {
            Text(
                viewModel.bookmarks.isEmpty
                    ? "Add your first bookmark to get started"
                    : "Try adjusting your search or filters"
            )
        } actions: {
            if viewModel.bookmarks.isEmpty {
                Button("Add Bookmark") { isAddingBookmark = true }
                    .buttonStyle(.borderedProminent)
            } else {
                Button("Clear Filters") { viewModel.filter = BookmarkFilter() }
            }
        }
    }

    private var bookmarkList: some View {
        List {
            filterSection
            bookmarksSection
        }
        .listStyle(.insetGrouped)
    }

    private var filterSection: some View {
        Section {
            filterControls
        }
    }

    private var filterControls: some View {
        VStack(spacing: 12) {
            // Sort picker
            HStack {
                Label("Sort", systemImage: "arrow.up.arrow.down")
                    .foregroundStyle(.secondary)
                Spacer()
                Picker("Sort", selection: $viewModel.filter.sortOrder) {
                    ForEach(BookmarkFilter.SortOrder.allCases, id: \.self) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
                .labelsHidden()
            }

            // Favorites toggle
            Toggle(isOn: $viewModel.filter.showFavoritesOnly) {
                Label("Favorites Only", systemImage: "star.fill")
            }
            .tint(.yellow)

            // Tag filter
            if !viewModel.allTags.isEmpty {
                tagFilterView
            }
        }
    }

    private var tagFilterView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Filter by Tag")
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    TagButton(
                        title: "All",
                        isSelected: viewModel.filter.selectedTag == nil
                    ) {
                        viewModel.filter.selectedTag = nil
                    }

                    ForEach(viewModel.allTags, id: \.self) { tag in
                        TagButton(
                            title: tag,
                            isSelected: viewModel.filter.selectedTag == tag
                        ) {
                            viewModel.filter.selectedTag = tag
                        }
                    }
                }
            }
        }
    }

    private var bookmarksSection: some View {
        Section("Bookmarks (\(viewModel.filteredBookmarks.count))") {
            ForEach(viewModel.filteredBookmarks) { bookmark in
                BookmarkRowView(
                    bookmark: bookmark,
                    onToggleFavorite: { await viewModel.toggleFavorite(bookmark) }
                )
                .contentShape(Rectangle())
                .onTapGesture { openURL(bookmark.url) }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        bookmarkToDelete = bookmark
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button { bookmarkToEdit = bookmark } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
                .contextMenu { contextMenu(for: bookmark) }
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                isAddingBookmark = true
            } label: {
                Label("Add Bookmark", systemImage: "plus")
            }
            .accessibilityLabel("Add new bookmark")
        }
    }

    // MARK: - Sheets

    private var addBookmarkSheet: some View {
        NavigationStack {
            BookmarkEditView(
                mode: .add,
                existingTags: viewModel.allTags
            ) { title, url, description, tags in
                await viewModel.addBookmark(
                    title: title,
                    urlString: url,
                    description: description,
                    tags: tags
                )
            }
        }
    }

    private func editBookmarkSheet(for bookmark: Bookmark) -> some View {
        NavigationStack {
            BookmarkEditView(
                mode: .edit(bookmark),
                existingTags: viewModel.allTags
            ) { title, url, description, tags in
                let updated = bookmark.updated(
                    title: title,
                    url: URL(string: url),
                    description: description,
                    tags: tags
                )
                await viewModel.updateBookmark(updated)
            }
        }
    }

    // MARK: - Context Menu

    @ViewBuilder
    private func contextMenu(for bookmark: Bookmark) -> some View {
        Button {
            openURL(bookmark.url)
        } label: {
            Label("Open", systemImage: "safari")
        }

        Button {
            UIPasteboard.general.url = bookmark.url
        } label: {
            Label("Copy URL", systemImage: "doc.on.doc")
        }

        Button {
            Task { await viewModel.toggleFavorite(bookmark) }
        } label: {
            Label(
                bookmark.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                systemImage: bookmark.isFavorite ? "star.slash" : "star"
            )
        }

        Divider()

        Button {
            bookmarkToEdit = bookmark
        } label: {
            Label("Edit", systemImage: "pencil")
        }

        Button(role: .destructive) {
            bookmarkToDelete = bookmark
            showingDeleteConfirmation = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    // MARK: - Delete Confirmation

    @ViewBuilder
    private func deleteConfirmationActions(for bookmark: Bookmark) -> some View {
        Button("Delete", role: .destructive) {
            Task { await viewModel.deleteBookmark(bookmark) }
        }
        Button("Cancel", role: .cancel) {}
    }
}

// MARK: - Tag Button

private struct TagButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Filter by \(title)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview

#Preview {
    BookmarkListView(viewModel: .preview)
}
