import SwiftUI

/// Reusable flow layout for tag chips and similar elements
/// Following swiftui-ui-patterns: "Extract repeated UI elements into dedicated subviews"
public struct FlowLayout: Layout {
    public var spacing: CGFloat

    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = flowLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
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

// MARK: - Tag Chip

/// Reusable tag chip component
public struct TagChip: View {
    public let title: String
    public let isRemovable: Bool
    public let action: () -> Void

    public init(title: String, isRemovable: Bool = false, action: @escaping () -> Void = {}) {
        self.title = title
        self.isRemovable = isRemovable
        self.action = action
    }

    public var body: some View {
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
        .accessibilityLabel(isRemovable ? "Remove tag \(title)" : "Tag \(title)")
    }
}

// MARK: - Preview

#Preview("Flow Layout") {
    FlowLayout(spacing: 8) {
        ForEach(["swift", "ios", "swiftui", "tutorial", "programming", "apple"], id: \.self) { tag in
            TagChip(title: tag)
        }
    }
    .padding()
}
