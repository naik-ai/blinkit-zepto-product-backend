import SwiftUI

/// A single bookmark row following SwiftUI UI Patterns
/// - Small, focused view component
/// - Explicit inputs (data, callbacks)
/// - Proper accessibility
public struct BookmarkRowView: View {
    // MARK: - Properties

    let bookmark: Bookmark
    let onToggleFavorite: () async -> Void

    // MARK: - Private State

    @State private var isTogglingFavorite = false

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 12) {
            faviconView
            contentView
            Spacer()
            favoriteButton
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to open in browser")
    }

    // MARK: - Subviews

    private var faviconView: some View {
        AsyncImage(url: faviconURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                Image(systemName: "globe")
                    .foregroundStyle(.secondary)
            case .empty:
                ProgressView()
            @unknown default:
                Image(systemName: "globe")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 32, height: 32)
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(bookmark.title)
                .font(.headline)
                .lineLimit(1)

            Text(bookmark.url.host ?? bookmark.url.absoluteString)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            if !bookmark.tags.isEmpty {
                tagsView
            }
        }
    }

    private var tagsView: some View {
        HStack(spacing: 4) {
            ForEach(bookmark.tags.prefix(3), id: \.self) { tag in
                Text(tag)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.15))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(Capsule())
            }
            if bookmark.tags.count > 3 {
                Text("+\(bookmark.tags.count - 3)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var favoriteButton: some View {
        Button {
            Task {
                isTogglingFavorite = true
                await onToggleFavorite()
                isTogglingFavorite = false
            }
        } label: {
            Image(systemName: bookmark.isFavorite ? "star.fill" : "star")
                .foregroundStyle(bookmark.isFavorite ? .yellow : .secondary)
                .font(.title3)
        }
        .buttonStyle(.plain)
        .disabled(isTogglingFavorite)
        .accessibilityLabel(bookmark.isFavorite ? "Remove from favorites" : "Add to favorites")
    }

    // MARK: - Computed Properties

    private var faviconURL: URL? {
        guard let host = bookmark.url.host else { return nil }
        return URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=64")
    }

    private var accessibilityLabel: String {
        var label = bookmark.title
        if bookmark.isFavorite {
            label += ", favorite"
        }
        if !bookmark.tags.isEmpty {
            label += ", tags: \(bookmark.tags.joined(separator: ", "))"
        }
        return label
    }
}

// MARK: - Preview

#Preview {
    List {
        ForEach(Bookmark.samples) { bookmark in
            BookmarkRowView(bookmark: bookmark) {
                print("Toggle favorite for \(bookmark.title)")
            }
        }
    }
}
