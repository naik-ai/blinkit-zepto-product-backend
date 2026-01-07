import SwiftUI

/// Add/Edit bookmark view following SwiftUI UI Patterns
/// - Clear state ownership
/// - Focused inputs
/// - Proper form validation
public struct BookmarkEditView: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    let mode: Mode
    let existingTags: [String]
    let onSave: (String, String, String, [String]) async -> Void

    // MARK: - State

    @State private var title: String
    @State private var urlString: String
    @State private var description: String
    @State private var tags: [String]
    @State private var newTag: String = ""
    @State private var isSaving = false
    @State private var urlValidationError: String?

    // MARK: - Initialization

    public init(
        mode: Mode,
        existingTags: [String],
        onSave: @escaping (String, String, String, [String]) async -> Void
    ) {
        self.mode = mode
        self.existingTags = existingTags
        self.onSave = onSave

        switch mode {
        case .add:
            _title = State(initialValue: "")
            _urlString = State(initialValue: "")
            _description = State(initialValue: "")
            _tags = State(initialValue: [])
        case .edit(let bookmark):
            _title = State(initialValue: bookmark.title)
            _urlString = State(initialValue: bookmark.url.absoluteString)
            _description = State(initialValue: bookmark.description)
            _tags = State(initialValue: bookmark.tags)
        }
    }

    // MARK: - Body

    public var body: some View {
        Form {
            urlSection
            detailsSection
            tagsSection
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .interactiveDismissDisabled(hasChanges)
        .onChange(of: urlString) { _, newValue in
            validateURL(newValue)
        }
    }

    // MARK: - Sections

    private var urlSection: some View {
        Section {
            TextField("URL", text: $urlString)
                .keyboardType(.URL)
                .textContentType(.URL)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .accessibilityLabel("Bookmark URL")

            if let error = urlValidationError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        } header: {
            Text("URL")
        } footer: {
            Text("Enter the full URL including https://")
        }
    }

    private var detailsSection: some View {
        Section("Details") {
            TextField("Title", text: $title)
                .accessibilityLabel("Bookmark title")

            TextField("Description (optional)", text: $description, axis: .vertical)
                .lineLimit(3...6)
                .accessibilityLabel("Bookmark description")
        }
    }

    private var tagsSection: some View {
        Section {
            // Current tags
            if !tags.isEmpty {
                currentTagsView
            }

            // Add new tag
            HStack {
                TextField("Add tag", text: $newTag)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .onSubmit { addTag() }

                Button(action: addTag) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.green)
                }
                .disabled(newTag.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            // Suggested tags
            if !suggestedTags.isEmpty {
                suggestedTagsView
            }
        } header: {
            Text("Tags")
        } footer: {
            Text("Tags help organize your bookmarks")
        }
    }

    private var currentTagsView: some View {
        FlowLayout(spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                TagChip(title: tag, isRemovable: true) {
                    removeTag(tag)
                }
            }
        }
    }

    private var suggestedTagsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Suggestions")
                .font(.caption)
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(suggestedTags, id: \.self) { tag in
                    TagChip(title: tag, isRemovable: false) {
                        addTag(tag)
                    }
                }
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                Task { await save() }
            }
            .disabled(!isValid || isSaving)
        }
    }

    // MARK: - Actions

    private func addTag(_ tag: String? = nil) {
        let tagToAdd = tag ?? newTag.trimmingCharacters(in: .whitespaces).lowercased()
        guard !tagToAdd.isEmpty, !tags.contains(tagToAdd) else { return }
        tags.append(tagToAdd)
        newTag = ""
    }

    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    private func validateURL(_ urlString: String) {
        if urlString.isEmpty {
            urlValidationError = nil
            return
        }

        guard let url = URL(string: urlString) else {
            urlValidationError = "Invalid URL format"
            return
        }

        if url.scheme == nil || url.host == nil {
            urlValidationError = "URL must include https:// or http://"
            return
        }

        urlValidationError = nil
    }

    private func save() async {
        isSaving = true
        await onSave(title, urlString, description, tags)
        isSaving = false
        dismiss()
    }

    // MARK: - Computed Properties

    private var isValid: Bool {
        !urlString.isEmpty &&
        urlValidationError == nil &&
        URL(string: urlString) != nil
    }

    private var hasChanges: Bool {
        switch mode {
        case .add:
            return !title.isEmpty || !urlString.isEmpty || !description.isEmpty || !tags.isEmpty
        case .edit(let bookmark):
            return title != bookmark.title ||
                   urlString != bookmark.url.absoluteString ||
                   description != bookmark.description ||
                   tags != bookmark.tags
        }
    }

    private var suggestedTags: [String] {
        existingTags.filter { !tags.contains($0) }
    }

    // MARK: - Mode

    public enum Mode {
        case add
        case edit(Bookmark)

        var title: String {
            switch self {
            case .add: return "Add Bookmark"
            case .edit: return "Edit Bookmark"
            }
        }
    }
}

// MARK: - Tag Chip

private struct TagChip: View {
    let title: String
    let isRemovable: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                if isRemovable {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                }
            }
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isRemovable ? Color.accentColor : Color.secondary.opacity(0.2))
            .foregroundStyle(isRemovable ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = flowLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = flowLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func flowLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
            totalHeight = currentY + lineHeight
        }

        return (CGSize(width: totalWidth, height: totalHeight), positions)
    }
}

// MARK: - Preview

#Preview("Add") {
    NavigationStack {
        BookmarkEditView(
            mode: .add,
            existingTags: ["swift", "ios", "tutorial"]
        ) { title, url, description, tags in
            print("Save: \(title), \(url)")
        }
    }
}

#Preview("Edit") {
    NavigationStack {
        BookmarkEditView(
            mode: .edit(Bookmark.samples[0]),
            existingTags: ["swift", "ios", "tutorial"]
        ) { title, url, description, tags in
            print("Update: \(title), \(url)")
        }
    }
}
