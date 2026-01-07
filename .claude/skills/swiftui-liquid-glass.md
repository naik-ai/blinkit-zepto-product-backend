# SwiftUI Liquid Glass

> Implement iOS 26+ Liquid Glass API in SwiftUI with native implementations aligned with Apple design guidance.

## When to Use

- Building features using iOS 26+ Liquid Glass effects
- Reviewing existing Liquid Glass implementations
- Refactoring components to adopt glass effects
- Designing glass surfaces and interactions

## Core Principles

1. **Use native Liquid Glass APIs** - Not custom blur solutions
2. **Use `GlassEffectContainer`** when multiple glass elements coexist
3. **Apply `.glassEffect()` after layout and appearance modifiers**
4. **Gate with `#available(iOS 26, *)`** and provide fallbacks
5. **Reserve `.interactive()` for user-interactive elements only**
6. **Keep shapes consistent** across related elements

## Basic Glass Effect

```swift
Text("Hello World")
    .padding()
    .glassEffect()
```

## Glass Effect with Shape

```swift
if #available(iOS 26, *) {
    VStack {
        Image(systemName: "star.fill")
        Text("Featured")
    }
    .padding()
    .glassEffect(.regular.shape(.capsule))
} else {
    // Fallback for older iOS
    VStack {
        Image(systemName: "star.fill")
        Text("Featured")
    }
    .padding()
    .background(.ultraThinMaterial)
    .clipShape(Capsule())
}
```

## Glass Effect Container

When multiple glass elements need to coexist:

```swift
if #available(iOS 26, *) {
    GlassEffectContainer {
        VStack(spacing: 16) {
            headerGlass
            contentGlass
            footerGlass
        }
    }
}

@ViewBuilder
private var headerGlass: some View {
    Text("Header")
        .padding()
        .glassEffect(.regular.shape(.rect(cornerRadius: 12)))
}

@ViewBuilder
private var contentGlass: some View {
    Text("Content")
        .padding()
        .glassEffect(.regular.shape(.rect(cornerRadius: 12)))
}
```

## Button Styles

```swift
if #available(iOS 26, *) {
    // Standard glass button
    Button("Action") { }
        .buttonStyle(.glass)

    // Prominent glass button
    Button("Primary Action") { }
        .buttonStyle(.glassProminent)
}
```

## Interactive Glass Elements

Only use `.interactive()` for elements that respond to user input:

```swift
if #available(iOS 26, *) {
    Button {
        // action
    } label: {
        Label("Settings", systemImage: "gear")
            .padding()
            .glassEffect(.regular.interactive())
    }
}
```

## Modifier Ordering

Apply glass effect **after** layout and appearance modifiers:

```swift
// ✅ Correct order
Text("Label")
    .font(.headline)           // 1. Typography
    .foregroundStyle(.primary) // 2. Colors
    .padding()                 // 3. Layout
    .frame(minWidth: 100)      // 4. Sizing
    .glassEffect()             // 5. Glass effect LAST

// ❌ Wrong order
Text("Label")
    .glassEffect()             // Too early!
    .padding()
    .font(.headline)
```

## Consistent Shapes

Keep shapes consistent across related elements:

```swift
private let cardShape = RoundedRectangle(cornerRadius: 16)

if #available(iOS 26, *) {
    VStack {
        headerCard
        contentCard
    }
}

@ViewBuilder
private var headerCard: some View {
    Text("Header")
        .padding()
        .glassEffect(.regular.shape(cardShape))
}

@ViewBuilder
private var contentCard: some View {
    Text("Content")
        .padding()
        .glassEffect(.regular.shape(cardShape))
}
```

## Availability Handling

Always provide fallbacks for older iOS versions:

```swift
struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        if #available(iOS 26, *) {
            content
                .padding()
                .glassEffect(.regular.shape(.rect(cornerRadius: 12)))
        } else {
            content
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
```

## Common Patterns

### Navigation Bar Glass
```swift
if #available(iOS 26, *) {
    NavigationStack {
        content
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Title")
                        .glassEffect()
                }
            }
    }
}
```

### Floating Action Button
```swift
if #available(iOS 26, *) {
    Button {
        // action
    } label: {
        Image(systemName: "plus")
            .font(.title2)
            .padding()
            .glassEffect(.regular.shape(.circle).interactive())
    }
}
```

### Tab Bar Glass
```swift
if #available(iOS 26, *) {
    TabView {
        // tabs
    }
    .tabViewStyle(.glass)
}
```

## Best Practices

1. **Don't overuse** - Glass effects should enhance, not overwhelm
2. **Test on device** - Glass effects look different on actual hardware
3. **Consider accessibility** - Ensure sufficient contrast
4. **Performance** - Glass effects have GPU cost; use judiciously in lists
5. **Consistency** - Use the same shape family throughout your app
