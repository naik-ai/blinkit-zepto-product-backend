# SwiftUI UI Patterns

> Best practices for SwiftUI development, covering view creation, component patterns, and architecture guidance.

## Quick Start

### For Existing Projects
1. Identify the feature or view requiring changes
2. Locate similar examples in the existing codebase
3. Apply local conventions and patterns
4. Reference component guides in `references/` for specific patterns

### For New Projects
1. Start with app scaffolding (TabView + NavigationStack + sheets)
2. Wire up the navigation hierarchy first
3. Expand route and sheet enums incrementally
4. Follow the component guides for each UI pattern

## Core Principles

### State Management
- Use modern SwiftUI state: `@State`, `@Binding`, `@Observable`, `@Environment`
- **Avoid unnecessary view models** - prefer SwiftUI-native patterns
- Keep state local when feasible; inject shared dependencies via environment
- Use async/await with `.task` modifier for asynchronous operations

### View Architecture
- **Prefer composition** - keep views small and focused
- Extract repeated UI elements into dedicated subviews
- Define explicit loading and error states for async workflows
- One concern per view - avoid monolithic view files

### Navigation
- One `NavigationStack` per tab with its own path binding
- Use `Hashable` enums for routes
- Centralize route-to-view mappings with `navigationDestination(for:)`
- Keep router objects separate from other `@Observable` structures

## View Development Workflow

1. **Establish State Ownership** - Determine where each piece of state should live
2. **Identify Dependencies** - Plan environment injection points
3. **Sketch Hierarchy** - Map out the view structure before coding
4. **Handle Async Loading** - Use `.task` with state enums for loading/error/success flows
5. **Add Accessibility** - Include labels and identifiers for interactive elements
6. **Validate & Update** - Build and adjust callsites as needed

## Code Structure

### View File Organization (top to bottom)
```swift
struct MyView: View {
    // 1. Environment declarations
    @Environment(\.dismiss) private var dismiss

    // 2. Public/private let properties
    let title: String

    // 3. @State and stored properties
    @State private var isLoading = false

    // 4. Computed variables (non-view)
    private var formattedTitle: String { title.uppercased() }

    // 5. Initializers (if needed)
    init(title: String) {
        self.title = title
    }

    // 6. Body
    var body: some View {
        content
    }

    // 7. Computed view builders and view helpers
    @ViewBuilder
    private var content: some View {
        Text(formattedTitle)
    }

    // 8. Helper and async functions
    private func loadData() async {
        // ...
    }
}
```

## Common Patterns

### Loading States
```swift
enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)
}

@State private var state: LoadingState<[Item]> = .idle

var body: some View {
    Group {
        switch state {
        case .idle, .loading:
            ProgressView()
        case .loaded(let items):
            ItemListView(items: items)
        case .error(let error):
            ErrorView(error: error, retry: loadData)
        }
    }
    .task { await loadData() }
}
```

### Environment Injection
```swift
// Define the key
private struct DataServiceKey: EnvironmentKey {
    static let defaultValue: DataService = .live
}

extension EnvironmentValues {
    var dataService: DataService {
        get { self[DataServiceKey.self] }
        set { self[DataServiceKey.self] = newValue }
    }
}

// Use in views
@Environment(\.dataService) private var dataService
```

## General Rules

1. Prefer SwiftUI-native patterns over custom view models
2. Keep views small and focused (< 200 lines ideal)
3. Use modern async patterns (`.task`, `async/await`)
4. Maintain legacy patterns only when modifying legacy files
5. Follow project style guides and existing conventions
6. Add accessibility labels to all interactive elements
7. Use `@ViewBuilder` for conditional view composition
