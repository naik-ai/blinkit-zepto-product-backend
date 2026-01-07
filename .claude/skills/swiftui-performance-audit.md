# SwiftUI Performance Audit

> Audit and improve SwiftUI runtime performance through code review and architecture guidance.

## When to Use

- Slow rendering or janky scrolling
- CPU/memory issues
- Excessive view updates
- Layout problems
- App hangs or freezes

## Audit Workflow

1. **Code-First Review** - If code is provided
2. **Symptom-Based Inquiry** - If only symptoms described
3. **Profiling Guidance** - If code review is inconclusive
4. **Analysis & Diagnosis** - Using Instruments data
5. **Remediation** - Apply targeted fixes
6. **Verification** - Compare before/after metrics

## Primary Performance Culprits

1. View invalidation cascades from expansive state changes
2. Unstable list identities (ID churn, per-render UUID generation)
3. Computationally heavy `body` operations
4. Layout inefficiencies and preference chains
5. Unoptimized image handling
6. Over-reliance on implicit animations
7. Deep view hierarchies
8. Formatters created per-render

## Common Code Smells & Fixes

### Expensive Formatters in Body

```swift
// ❌ Bad - Allocates formatter every render
var body: some View {
    Text(NumberFormatter().string(from: value as NSNumber) ?? "")
}

// ✅ Good - Static cached formatter
private static let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
}()

var body: some View {
    Text(Self.numberFormatter.string(from: value as NSNumber) ?? "")
}
```

### Heavy Computed Properties

```swift
// ❌ Bad - Filters on every body evaluation
var filteredItems: [Item] {
    items.filter { $0.isActive }.sorted { $0.date > $1.date }
}

var body: some View {
    List(filteredItems) { item in
        ItemRow(item: item)
    }
}

// ✅ Good - Precompute and store in @State
@State private var filteredItems: [Item] = []

var body: some View {
    List(filteredItems) { item in
        ItemRow(item: item)
    }
    .onChange(of: items) { _, newItems in
        filteredItems = newItems.filter { $0.isActive }.sorted { $0.date > $1.date }
    }
}
```

### Sorting in ForEach

```swift
// ❌ Bad - Sorts on every render
ForEach(items.sorted { $0.name < $1.name }) { item in
    ItemRow(item: item)
}

// ✅ Good - Sort before view construction
let sortedItems = items.sorted { $0.name < $1.name }
ForEach(sortedItems) { item in
    ItemRow(item: item)
}
```

### Unstable IDs

```swift
// ❌ Bad - New UUID every render = complete list rebuild
ForEach(items, id: \.self) { item in  // If Item generates new ID
    ItemRow(item: item)
}

// ❌ Very Bad - UUID() in ID
ForEach(items) { item in
    ItemRow(item: item)
        .id(UUID())  // Forces recreation every render
}

// ✅ Good - Stable, persistent identifiers
struct Item: Identifiable {
    let id: UUID  // Set once at creation
    var name: String
}

ForEach(items) { item in
    ItemRow(item: item)
}
```

### Main-Thread Image Decoding

```swift
// ❌ Bad - Blocks main thread
Image(uiImage: UIImage(data: imageData)!)

// ✅ Good - Async image loading
AsyncImage(url: imageURL) { phase in
    switch phase {
    case .success(let image):
        image.resizable().aspectRatio(contentMode: .fit)
    case .failure:
        Image(systemName: "photo")
    case .empty:
        ProgressView()
    @unknown default:
        EmptyView()
    }
}

// ✅ Better - Custom async decoding for large images
@State private var decodedImage: UIImage?

var body: some View {
    Group {
        if let image = decodedImage {
            Image(uiImage: image)
        } else {
            ProgressView()
        }
    }
    .task {
        decodedImage = await decodeImageOffMain(data: imageData)
    }
}

@concurrent
func decodeImageOffMain(data: Data) async -> UIImage? {
    UIImage(data: data)?.preparingForDisplay()
}
```

### Overly Broad Observable Models

```swift
// ❌ Bad - Single model touches everything
@Observable
class AppState {
    var user: User?
    var items: [Item] = []
    var settings: Settings = .default
    var notifications: [Notification] = []
}

// Any change invalidates all observing views

// ✅ Good - Granular state distribution
@Observable class UserState { var user: User? }
@Observable class ItemsState { var items: [Item] = [] }
@Observable class SettingsState { var settings: Settings = .default }

// Views only observe what they need
```

## State Scope Optimization

```swift
// ❌ Bad - State too high in hierarchy
struct ParentView: View {
    @State private var selectedItem: Item?  // Every child re-renders on change

    var body: some View {
        List(items) { item in
            ChildRow(item: item, isSelected: item == selectedItem)
        }
    }
}

// ✅ Good - State closer to leaf views
struct ChildRow: View {
    let item: Item
    @State private var isSelected = false  // Local state

    var body: some View {
        // Only this row updates
    }
}
```

## Layout Optimization

```swift
// ❌ Bad - Deep nesting and excessive GeometryReaders
GeometryReader { geo in
    VStack {
        HStack {
            GeometryReader { innerGeo in
                // ...
            }
        }
    }
}

// ✅ Good - Flatter hierarchy, minimal geometry readers
VStack {
    content
}
.frame(maxWidth: .infinity)  // Use frame instead of GeometryReader when possible
```

## Animation Scoping

```swift
// ❌ Bad - Implicit animation on large tree
VStack {
    // Many child views
}
.animation(.default, value: someValue)

// ✅ Good - Scoped animation
VStack {
    animatedContent
        .animation(.default, value: someValue)
    staticContent  // Not affected
}
```

## Equatable for Expensive Views

```swift
struct ExpensiveView: View, Equatable {
    let data: ComplexData

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.data.id == rhs.data.id  // Custom equality check
    }

    var body: some View {
        // Complex rendering
    }
}

// Usage
ExpensiveView(data: data)
    .equatable()  // Prevents re-render if equal
```

## Profiling with Instruments

1. **Build for Release** - Debug builds are not representative
2. **Use SwiftUI template** - Capture SwiftUI timeline + Time Profiler
3. **Reproduce exact conditions** - Same data, same interactions
4. **Look for:**
   - View invalidation storms (rapid successive updates)
   - Long frame times (> 16ms for 60fps)
   - Main thread blocks
   - Memory spikes

## Audit Deliverables

| Metric | Baseline | Optimized | Change |
|--------|----------|-----------|--------|
| Frame time | 45ms | 12ms | -73% |
| View updates/scroll | 150 | 12 | -92% |
| Memory peak | 280MB | 95MB | -66% |

Prioritized issues with impact and effort estimates guide remediation.
