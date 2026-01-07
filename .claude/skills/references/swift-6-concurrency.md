# Swift 6.2 Concurrency Reference

## Philosophy Change

Swift 6.2 shifts from implicit background offloading to explicit concurrency:
> "Stay single-threaded by default until you choose to introduce concurrency"

Data-race-free code is now the natural default.

## Key Improvements

### 1. Async Functions Stay Isolated

Previously, calling async methods on main-actor objects triggered data-race errors. Now:

```swift
@MainActor
class ViewModel {
    var items: [Item] = []

    func loadItems() async {
        // In Swift 6.2, this async call returns to MainActor
        let fetchedItems = await api.fetchItems()
        items = fetchedItems  // Safe - still on MainActor
    }
}
```

Async functions "continue to run on the actor it was called from."

### 2. Isolated Conformances

Protocol implementations can use `@MainActor` annotation:

```swift
// Compiler enforces isolated conformances only operate within actor context
extension MyClass: @MainActor SomeDelegate {
    func delegateCallback() {
        // Guaranteed to be on MainActor
        updateUI()
    }
}
```

### 3. Inferred Main Actor Mode

Opt-in mode automatically applies `@MainActor` to all types:

```swift
// In project settings or package manifest:
// swift-settings: [.enableExperimentalFeature("InferredActorIsolation")]

// All types default to @MainActor
class MyViewModel {  // Implicitly @MainActor
    var data: [String] = []
}
```

This reduces boilerplate while maintaining data-race safety.

### 4. Explicit Background Work

Use `@concurrent` for CPU-intensive operations:

```swift
@concurrent
func processLargeDataset(_ data: Data) async -> ProcessedResult {
    // Explicitly runs on background thread
    // Essential for keeping apps responsive
    let decoded = JSONDecoder().decode(LargeModel.self, from: data)
    return process(decoded)
}
```

## Implementation Path

1. **Start with MainActor code** - Default to main thread
2. **Adopt async functions** - They remain isolated by default
3. **Use @concurrent selectively** - For performance-critical background work

## Common Patterns

### MainActor ViewModel

```swift
@MainActor
@Observable
class ItemViewModel {
    var items: [Item] = []
    var isLoading = false
    var error: Error?

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            items = try await fetchItems()
        } catch {
            self.error = error
        }
    }

    // Async but stays on MainActor
    private func fetchItems() async throws -> [Item] {
        try await api.getItems()
    }
}
```

### Background Processing

```swift
@MainActor
class ImageProcessor {
    var processedImage: UIImage?

    func processImage(_ data: Data) async {
        // Offload heavy work
        let processed = await processInBackground(data)
        processedImage = processed  // Back on MainActor
    }

    @concurrent
    private func processInBackground(_ data: Data) async -> UIImage? {
        guard let image = UIImage(data: data) else { return nil }
        return await image.byApplyingFilters()
    }
}
```

### Actor for Shared State

```swift
actor DataCache {
    private var storage: [String: Data] = [:]

    func store(_ data: Data, for key: String) {
        storage[key] = data
    }

    func retrieve(_ key: String) -> Data? {
        storage[key]
    }

    func clear() {
        storage.removeAll()
    }
}

// Usage (requires await)
let cache = DataCache()
await cache.store(data, for: "key")
let retrieved = await cache.retrieve("key")
```

## Migration Tips

1. **Add @MainActor to UI types first** - ViewModels, delegates, etc.
2. **Identify background work** - Mark with @concurrent
3. **Use actors for shared mutable state** - Replace locks/queues
4. **Test thoroughly** - Concurrency bugs can be subtle
5. **Enable strict concurrency checking** - Catch issues at compile time

## Compiler Flags

```swift
// Package.swift
.target(
    name: "MyTarget",
    swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
        .enableExperimentalFeature("InferredActorIsolation")
    ]
)
```
