# Swift Concurrency Expert

> Review and fix Swift Concurrency issues in Swift 6.2+ codebases by applying actor isolation, Sendable safety, and modern concurrency patterns with minimal behavior changes.

## When to Use

- Reviewing Swift Concurrency usage
- Improving concurrency compliance
- Fixing Swift concurrency compiler errors
- Migrating to Swift 6 strict concurrency

## Workflow

### Step 1: Triage the Issue

1. **Record exact compiler diagnostics** and problematic symbols
2. **Examine project settings:**
   - Swift version (6.2+)
   - Strict concurrency level
   - Approachable concurrency status
3. **Determine current actor context** and isolation modes
4. **Establish execution target:** UI (main thread) or background

### Step 2: Apply the Smallest Safe Fix

Prioritize edits that preserve existing behavior while satisfying data-race safety.

## Common Fixes

### UI Types - Add @MainActor
```swift
// Before
class ProfileViewModel: ObservableObject {
    @Published var user: User?
}

// After
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
}
```

### Protocol Conformance - Isolated Extension
```swift
// Before
extension MyClass: SomeDelegate {
    func delegateMethod() { /* UI updates */ }
}

// After
extension MyClass: @MainActor SomeDelegate {
    func delegateMethod() { /* UI updates */ }
}
```

### Global/Static State - Actor Protection
```swift
// Before
class Cache {
    static var shared = Cache()
    var items: [String: Data] = [:]
}

// After - Option 1: MainActor
@MainActor
class Cache {
    static let shared = Cache()
    var items: [String: Data] = [:]
}

// After - Option 2: Actor
actor Cache {
    static let shared = Cache()
    var items: [String: Data] = [:]
}
```

### Background Operations - @concurrent
```swift
// Explicitly run on background thread
@concurrent
func processLargeDataset(_ data: Data) async -> ProcessedResult {
    // CPU-intensive work runs off main thread
}
```

### Sendable Safety
```swift
// Prefer immutable value types
struct UserInfo: Sendable {
    let id: UUID
    let name: String
}

// Add Sendable only when thread safety is verified
final class ThreadSafeCache: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String: Data] = [:]

    func get(_ key: String) -> Data? {
        lock.lock()
        defer { lock.unlock() }
        return storage[key]
    }
}
```

## Swift 6.2 Key Changes

### Async Functions Stay Isolated
```swift
// In Swift 6.2, this is safe - async functions continue on their calling actor
@MainActor
class ViewModel {
    var data: [Item] = []

    func loadData() async {
        let items = await fetchItems()  // Returns to MainActor
        data = items  // Safe - still on MainActor
    }
}
```

### Inferred Main Actor Mode
Enable for single-threaded projects to reduce boilerplate:
```swift
// All types in module default to @MainActor
// Use @concurrent for explicit background work
```

## Actor Pattern

```swift
actor DataStore {
    private var items: [UUID: Item] = [:]

    func add(_ item: Item) {
        items[item.id] = item
    }

    func get(_ id: UUID) -> Item? {
        items[id]
    }

    // nonisolated for Sendable-safe computed properties
    nonisolated var isEmpty: Bool {
        false  // Would need async for actual check
    }
}

// Usage
let store = DataStore()
await store.add(item)
let retrieved = await store.get(item.id)
```

## Best Practices

1. **Start on MainActor** - Default to main thread, opt into concurrency
2. **Use actors for shared mutable state** - They provide automatic synchronization
3. **Prefer value types** - Structs are inherently Sendable when their properties are
4. **Avoid @unchecked Sendable** - Only use when you can prove thread safety
5. **Keep async functions isolated** - They return to their calling actor in Swift 6.2
6. **Use @concurrent explicitly** - For CPU-intensive background work
7. **Minimal changes** - Fix concurrency errors without restructuring working code

## Red Flags to Watch

- `@unchecked Sendable` on reference types without synchronization
- Mutable global/static state without actor protection
- Assuming async functions run on background threads
- Mixing isolation contexts without explicit annotations
