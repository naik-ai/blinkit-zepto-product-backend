# Navigation Patterns Reference

## NavigationStack

### Core Setup
One `NavigationStack` per tab with its own path binding.

```swift
// Route enum
enum Route: Hashable {
    case detail(Item)
    case settings
    case profile(User)
}

// Router class
@Observable
class Router {
    var path = NavigationPath()
    var presentedSheet: Sheet?

    func navigate(to route: Route) {
        path.append(route)
    }

    func popToRoot() {
        path = NavigationPath()
    }
}

// Environment key
private struct RouterKey: EnvironmentKey {
    static let defaultValue = Router()
}

extension EnvironmentValues {
    var router: Router {
        get { self[RouterKey.self] }
        set { self[RouterKey.self] = newValue }
    }
}
```

### Tab-Based Navigation

```swift
struct ContentView: View {
    @State private var selectedTab = Tab.home
    @State private var homeRouter = Router()
    @State private var searchRouter = Router()
    @State private var profileRouter = Router()

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homeRouter.path) {
                HomeView()
                    .navigationDestination(for: Route.self) { route in
                        destinationView(for: route)
                    }
            }
            .environment(\.router, homeRouter)
            .tag(Tab.home)

            NavigationStack(path: $searchRouter.path) {
                SearchView()
                    .navigationDestination(for: Route.self) { route in
                        destinationView(for: route)
                    }
            }
            .environment(\.router, searchRouter)
            .tag(Tab.search)

            // ... more tabs
        }
    }

    @ViewBuilder
    func destinationView(for route: Route) -> some View {
        switch route {
        case .detail(let item):
            ItemDetailView(item: item)
        case .settings:
            SettingsView()
        case .profile(let user):
            ProfileView(user: user)
        }
    }
}
```

### Child View Navigation

```swift
struct ItemRow: View {
    @Environment(\.router) private var router
    let item: Item

    var body: some View {
        Button {
            router.navigate(to: .detail(item))
        } label: {
            ItemRowContent(item: item)
        }
    }
}
```

## Sheets

### Sheet Enum Pattern

```swift
enum Sheet: Identifiable {
    case addItem
    case editItem(Item)
    case filter(FilterOptions)

    var id: String {
        switch self {
        case .addItem: return "addItem"
        case .editItem(let item): return "editItem-\(item.id)"
        case .filter: return "filter"
        }
    }
}

struct ContentView: View {
    @State private var presentedSheet: Sheet?

    var body: some View {
        content
            .sheet(item: $presentedSheet) { sheet in
                sheetContent(for: sheet)
            }
    }

    @ViewBuilder
    func sheetContent(for sheet: Sheet) -> some View {
        switch sheet {
        case .addItem:
            AddItemView()
        case .editItem(let item):
            EditItemView(item: item)
        case .filter(let options):
            FilterView(options: options)
        }
    }
}
```

## Deep Links

### URL Handling

```swift
struct ContentView: View {
    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    destinationView(for: route)
                }
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
    }

    func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else { return }

        switch host {
        case "item":
            if let id = components.queryItems?.first(where: { $0.name == "id" })?.value,
               let uuid = UUID(uuidString: id) {
                router.path.append(Route.detail(Item(id: uuid)))
            }
        case "settings":
            router.path.append(Route.settings)
        default:
            break
        }
    }
}
```

## Common Mistakes

1. **Sharing path across tabs** - Each tab needs its own NavigationStack and path
2. **Storing views in routes** - Routes should be lightweight data, not view instances
3. **Forgetting to reset on logout** - Clear navigation state during auth transitions
4. **Unstable route identities** - Routes must remain Hashable and stable

## Best Practices

1. **Centralize destination mapping** - Use single `navigationDestination(for:)` block
2. **Keep routers separate** - Don't mix router with other @Observable state
3. **Use environment injection** - Pass router through environment, not props
4. **Reset state appropriately** - Clear paths on significant app state changes
