// Public API exports for BookmarkApp module
// Re-export key types for external usage

// Models
@_exported import struct Foundation.URL
@_exported import struct Foundation.UUID
@_exported import struct Foundation.Date

// The module exposes:
// - Bookmark: The main data model
// - BookmarkFilter: Filter and sort configuration
// - BookmarkStore: Actor-based persistence layer
// - BookmarkViewModel: Observable view model
// - BookmarkListView: Main UI component
// - BookmarkRowView: List row component
// - BookmarkEditView: Add/Edit form component
