# SwiftUI View Refactor

> Refactor SwiftUI views for consistent structure, dependency injection, and proper Observation patterns.

## When to Use

- Cleaning up view layouts
- Handling view models safely
- Standardizing dependency and `@Observable` state initialization
- Splitting large view files

## Core Principles

### Model-View Pattern
> "Views are lightweight state expressions; models/services own business logic."

- Favor `@State`, `@Environment`, `@Query`, and async task/onChange orchestration
- Inject services via `@Environment`
- Keep views composable and small
- Business logic belongs in models/services, not views

## View Ordering (Top to Bottom)

```swift
struct MyView: View {
    // 1. Environment declarations
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dataService) private var dataService

    // 2. Private/public let properties
    private let configuration: Configuration
    public let onComplete: () -> Void

    // 3. @State and stored properties
    @State private var items: [Item] = []
    @State private var isLoading = false

    // 4. Computed variables (non-view)
    private var sortedItems: [Item] {
        items.sorted { $0.date > $1.date }
    }

    // 5. Initializers
    init(configuration: Configuration, onComplete: @escaping () -> Void) {
        self.configuration = configuration
        self.onComplete = onComplete
    }

    // 6. Body
    var body: some View {
        content
            .task { await loadItems() }
    }

    // 7. Computed view builders and view helpers
    @ViewBuilder
    private var content: some View {
        if isLoading {
            loadingView
        } else {
            itemsList
        }
    }

    private var loadingView: some View {
        ProgressView()
    }

    private var itemsList: some View {
        List(sortedItems) { item in
            ItemRow(item: item)
        }
    }

    // 8. Helper and async functions
    private func loadItems() async {
        isLoading = true
        items = await dataService.fetchItems()
        isLoading = false
    }
}
```

## View Model Handling

### Only Introduce View Models When Required
View models should only be added when explicitly needed (complex state coordination, testing requirements).

### Non-Optional @State Initialization
```swift
// ❌ Bad - Optional view model
struct MyView: View {
    @State private var viewModel: ViewModel?

    var body: some View {
        content.onAppear {
            viewModel = ViewModel(service: service)
        }
    }
}

// ✅ Good - Non-optional with init injection
struct MyView: View {
    @State private var viewModel: ViewModel

    init(service: DataService) {
        _viewModel = State(initialValue: ViewModel(service: service))
    }

    var body: some View {
        content
    }
}
```

## Observation Framework

### Store @Observable as @State in Root Views
```swift
@Observable
class ItemStore {
    var items: [Item] = []
    var isLoading = false
}

struct RootView: View {
    @State private var store = ItemStore()

    var body: some View {
        ItemListView(store: store)
    }
}

// Pass explicitly down the hierarchy
struct ItemListView: View {
    let store: ItemStore  // Not @State - passed from parent

    var body: some View {
        List(store.items) { item in
            ItemRow(item: item)
        }
    }
}
```

### Eliminate Redundant Wrappers
```swift
// ❌ Bad - Redundant wrapper
@State private var storeWrapper: ItemStoreWrapper?

// ✅ Good - Direct usage
@State private var store = ItemStore()
```

## Splitting Large Views

### When Body Exceeds One Screen
1. Extract logical sections into computed view properties
2. Keep these in the same file initially

```swift
var body: some View {
    ScrollView {
        headerSection
        contentSection
        footerSection
    }
}

private var headerSection: some View {
    VStack { /* ... */ }
}

private var contentSection: some View {
    LazyVStack { /* ... */ }
}

private var footerSection: some View {
    HStack { /* ... */ }
}
```

### When Sections Become Complex
Move to dedicated nested View structs:

```swift
// Same file or separate file
private struct HeaderSection: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.title)
            Text(subtitle).font(.subheadline)
        }
    }
}
```

### Pass Focused Inputs
```swift
// ❌ Bad - Passing entire parent state
HeaderSection(viewModel: viewModel)

// ✅ Good - Passing only what's needed
HeaderSection(
    title: viewModel.title,
    subtitle: viewModel.subtitle,
    onTap: { viewModel.handleHeaderTap() }
)
```

## Large File Organization (300+ lines)

Use extensions with `// MARK: -` comments:

```swift
struct ComplexView: View {
    // Core properties and body here
}

// MARK: - Subviews
extension ComplexView {
    private var headerView: some View { /* ... */ }
    private var contentView: some View { /* ... */ }
}

// MARK: - Actions
extension ComplexView {
    private func handleSubmit() { /* ... */ }
    private func handleCancel() { /* ... */ }
}

// MARK: - Helpers
extension ComplexView {
    private var formattedDate: String { /* ... */ }
    private var isValid: Bool { /* ... */ }
}
```

## Refactoring Checklist

1. ☐ Reorder properties and methods according to guidelines
2. ☐ Favor MV pattern with lightweight orchestration
3. ☐ Replace optional view models with non-optional `@State` initialized in `init`
4. ☐ Confirm proper Observation usage (`@Observable` as `@State` in root)
5. ☐ Pass observables explicitly down hierarchy
6. ☐ Extract large body into computed view properties
7. ☐ Split complex sections into nested View structs
8. ☐ Pass focused inputs (data, bindings, callbacks) not entire state
9. ☐ Preserve existing behavior and business logic
