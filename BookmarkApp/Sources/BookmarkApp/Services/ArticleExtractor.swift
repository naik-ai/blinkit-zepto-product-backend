import Foundation

/// Service for extracting article metadata from URLs
/// Fetches Open Graph, Twitter Cards, and basic HTML metadata
public actor ArticleExtractor {

    public init() {}

    // MARK: - Public API

    /// Extract metadata from a URL
    public func extractMetadata(from url: URL) async throws -> ArticleMetadata {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ArticleExtractorError.fetchFailed
        }

        guard let html = String(data: data, encoding: .utf8) else {
            throw ArticleExtractorError.invalidHTML
        }

        return parseMetadata(from: html, url: url)
    }

    /// Estimate reading time from article content
    public func estimateReadingTime(from content: String) -> Int {
        let words = content.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count
        // Average reading speed: 200-250 words per minute
        return max(1, words / 225)
    }

    // MARK: - HTML Parsing

    private func parseMetadata(from html: String, url: URL) -> ArticleMetadata {
        var metadata = ArticleMetadata()

        // Extract title (prefer og:title > twitter:title > <title>)
        metadata.title = extractMeta(html, property: "og:title")
            ?? extractMeta(html, name: "twitter:title")
            ?? extractTitle(html)

        // Extract description
        metadata.description = extractMeta(html, property: "og:description")
            ?? extractMeta(html, name: "twitter:description")
            ?? extractMeta(html, name: "description")

        // Extract author
        metadata.author = extractMeta(html, property: "article:author")
            ?? extractMeta(html, name: "author")
            ?? extractMeta(html, property: "og:article:author")

        // Extract site name
        metadata.siteName = extractMeta(html, property: "og:site_name")
            ?? url.host

        // Extract image URL
        if let imageString = extractMeta(html, property: "og:image")
            ?? extractMeta(html, name: "twitter:image") {
            metadata.imageURL = URL(string: imageString, relativeTo: url)?.absoluteURL
        }

        // Extract published date
        if let dateString = extractMeta(html, property: "article:published_time")
            ?? extractMeta(html, name: "date")
            ?? extractMeta(html, property: "og:article:published_time") {
            metadata.publishedDate = parseDate(dateString)
        }

        // Extract content (simplified - real implementation would use readability algorithms)
        metadata.excerpt = metadata.description

        // Calculate reading time if we have content
        if let description = metadata.description {
            metadata.readingTime = estimateReadingTime(from: description)
        }

        return metadata
    }

    private func extractMeta(_ html: String, property: String) -> String? {
        // Match <meta property="..." content="...">
        let pattern = #"<meta[^>]+property=["']\#(property)["'][^>]+content=["']([^"']+)["']"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let contentRange = Range(match.range(at: 1), in: html) else {
            // Try alternate order: content before property
            let altPattern = #"<meta[^>]+content=["']([^"']+)["'][^>]+property=["']\#(property)["']"#
            guard let altRegex = try? NSRegularExpression(pattern: altPattern, options: .caseInsensitive),
                  let altMatch = altRegex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
                  let altRange = Range(altMatch.range(at: 1), in: html) else {
                return nil
            }
            return String(html[altRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return String(html[contentRange]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func extractMeta(_ html: String, name: String) -> String? {
        // Match <meta name="..." content="...">
        let pattern = #"<meta[^>]+name=["']\#(name)["'][^>]+content=["']([^"']+)["']"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let contentRange = Range(match.range(at: 1), in: html) else {
            // Try alternate order
            let altPattern = #"<meta[^>]+content=["']([^"']+)["'][^>]+name=["']\#(name)["']"#
            guard let altRegex = try? NSRegularExpression(pattern: altPattern, options: .caseInsensitive),
                  let altMatch = altRegex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
                  let altRange = Range(altMatch.range(at: 1), in: html) else {
                return nil
            }
            return String(html[altRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return String(html[contentRange]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func extractTitle(_ html: String) -> String? {
        let pattern = #"<title[^>]*>([^<]+)</title>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let titleRange = Range(match.range(at: 1), in: html) else {
            return nil
        }
        return String(html[titleRange])
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
    }

    private func parseDate(_ dateString: String) -> Date? {
        let formatters: [ISO8601DateFormatter] = [
            {
                let f = ISO8601DateFormatter()
                f.formatOptions = [.withInternetDateTime]
                return f
            }(),
            {
                let f = ISO8601DateFormatter()
                f.formatOptions = [.withFullDate]
                return f
            }()
        ]

        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        // Try common date formats
        let dateFormatter = DateFormatter()
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd",
            "MMM dd, yyyy",
            "MMMM dd, yyyy"
        ]

        for format in formats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
        }

        return nil
    }
}

// MARK: - Article Metadata

/// Extracted metadata from an article URL
public struct ArticleMetadata: Sendable {
    public var title: String?
    public var description: String?
    public var author: String?
    public var siteName: String?
    public var imageURL: URL?
    public var publishedDate: Date?
    public var excerpt: String?
    public var readingTime: Int?
    public var articleContent: String?

    public init(
        title: String? = nil,
        description: String? = nil,
        author: String? = nil,
        siteName: String? = nil,
        imageURL: URL? = nil,
        publishedDate: Date? = nil,
        excerpt: String? = nil,
        readingTime: Int? = nil,
        articleContent: String? = nil
    ) {
        self.title = title
        self.description = description
        self.author = author
        self.siteName = siteName
        self.imageURL = imageURL
        self.publishedDate = publishedDate
        self.excerpt = excerpt
        self.readingTime = readingTime
        self.articleContent = articleContent
    }

    /// Convert to a bookmark with extracted metadata
    public func toBookmark(url: URL) -> Bookmark {
        Bookmark(
            title: title ?? url.host ?? url.absoluteString,
            url: url,
            description: description ?? "",
            author: author,
            publishedDate: publishedDate,
            siteName: siteName,
            excerpt: excerpt,
            readingTime: readingTime,
            imageURL: imageURL,
            articleContent: articleContent
        )
    }
}

// MARK: - Errors

public enum ArticleExtractorError: LocalizedError {
    case fetchFailed
    case invalidHTML
    case parsingFailed

    public var errorDescription: String? {
        switch self {
        case .fetchFailed:
            return "Failed to fetch article content"
        case .invalidHTML:
            return "Could not parse HTML content"
        case .parsingFailed:
            return "Failed to extract article metadata"
        }
    }
}
