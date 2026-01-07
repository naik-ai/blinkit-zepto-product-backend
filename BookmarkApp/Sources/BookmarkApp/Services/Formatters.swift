import Foundation

/// Cached formatters following swiftui-performance-audit skill
/// "Expensive formatters allocated per render - Cache formatters statically"
public enum Formatters {
    /// Date formatter for displaying bookmark dates
    /// Cached as static to avoid allocation on every render
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    /// Relative date formatter for "2 days ago" style
    public static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    /// URL host extractor - cached regex
    public static func host(from url: URL) -> String {
        url.host ?? url.absoluteString
    }

    /// Format date for display
    public static func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    /// Format relative date
    public static func formatRelativeDate(_ date: Date) -> String {
        relativeDateFormatter.localizedString(for: date, relativeTo: Date())
    }
}
