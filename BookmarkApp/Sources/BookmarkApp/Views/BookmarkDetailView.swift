import SwiftUI

/// Detailed view for a single bookmark
/// Following SwiftUI UI Patterns for focused, composable views
public struct BookmarkDetailView: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    // MARK: - Properties

    let bookmark: Bookmark
    let onToggleFavorite: () async -> Void
    let onDelete: () async -> Void
    let onEdit: () -> Void

    // MARK: - State

    @State private var showingDeleteConfirmation = false

    // MARK: - Body

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                metadataSection
                descriptionSection
                tagsSection
                actionsSection
            }
            .padding()
        }
        .navigationTitle("Bookmark")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .confirmationDialog(
            "Delete Bookmark",
            isPresented: $showingDeleteConfirmation
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    await onDelete()
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(bookmark.title)\"?")
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                faviconView
                VStack(alignment: .leading, spacing: 4) {
                    Text(bookmark.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(bookmark.url.host ?? bookmark.url.absoluteString)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                favoriteButton
            }
        }
    }

    private var faviconView: some View {
        AsyncImage(url: faviconURL) { phase in
            switch phase {
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fit)
            default:
                Image(systemName: "globe")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 48, height: 48)
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var favoriteButton: some View {
        Button {
            Task { await onToggleFavorite() }
        } label: {
            Image(systemName: bookmark.isFavorite ? "star.fill" : "star")
                .font(.title2)
                .foregroundStyle(bookmark.isFavorite ? .yellow : .secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(bookmark.isFavorite ? "Remove from favorites" : "Add to favorites")
    }

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(bookmark.url.absoluteString)
                    .font(.footnote)
                    .foregroundStyle(.blue)
            } icon: {
                Image(systemName: "link")
            }

            Label {
                Text("Added \(bookmark.createdAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "calendar")
            }

            if bookmark.updatedAt != bookmark.createdAt {
                Label {
                    Text("Updated \(bookmark.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } icon: {
                    Image(systemName: "clock.arrow.circlepath")
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var descriptionSection: some View {
        if !bookmark.description.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.headline)
                Text(bookmark.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var tagsSection: some View {
        if !bookmark.tags.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Tags")
                    .font(.headline)
                FlowLayout(spacing: 8) {
                    ForEach(bookmark.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.accentColor.opacity(0.15))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                openURL(bookmark.url)
            } label: {
                Label("Open in Browser", systemImage: "safari")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            HStack(spacing: 12) {
                Button {
                    UIPasteboard.general.url = bookmark.url
                } label: {
                    Label("Copy URL", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                ShareLink(item: bookmark.url) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.top)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }

                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }

    // MARK: - Computed

    private var faviconURL: URL? {
        guard let host = bookmark.url.host else { return nil }
        return URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=64")
    }
}

// MARK: - Preview
// Note: Uses shared FlowLayout from Components/FlowLayout.swift

#Preview {
    NavigationStack {
        BookmarkDetailView(
            bookmark: Bookmark.samples[0],
            onToggleFavorite: {},
            onDelete: {},
            onEdit: {}
        )
    }
}
