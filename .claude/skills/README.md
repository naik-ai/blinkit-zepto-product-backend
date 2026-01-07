# Claude Code Skills

This directory contains Swift and SwiftUI development skills adapted from [Dimillian/Skills](https://github.com/Dimillian/Skills).

## Available Skills

| Skill | Description | Use When |
|-------|-------------|----------|
| [swiftui-ui-patterns](./swiftui-ui-patterns.md) | Best practices for SwiftUI view creation and architecture | Building new views, designing app structure |
| [swift-concurrency-expert](./swift-concurrency-expert.md) | Swift 6.2+ concurrency patterns and fixes | Fixing concurrency errors, adding async code |
| [swiftui-view-refactor](./swiftui-view-refactor.md) | View structure and Observation patterns | Cleaning up views, handling view models |
| [swiftui-performance-audit](./swiftui-performance-audit.md) | Performance optimization guidance | Slow rendering, janky scrolling, CPU issues |
| [ios-debugger-agent](./ios-debugger-agent.md) | Build, run, and debug iOS apps | Testing on simulators, debugging UI |
| [swiftui-liquid-glass](./swiftui-liquid-glass.md) | iOS 26+ Liquid Glass API | Implementing glass effects |

## Reference Documents

Located in `references/`:

- [navigation-patterns.md](./references/navigation-patterns.md) - NavigationStack, sheets, deep links
- [swift-6-concurrency.md](./references/swift-6-concurrency.md) - Swift 6.2 concurrency updates

## Quick Reference

### View File Structure
```
1. Environment declarations
2. Public/private let properties
3. @State and stored properties
4. Computed variables (non-view)
5. Initializers
6. body
7. Computed view builders
8. Helper functions
```

### State Management Hierarchy
```
@State         → Local view state
@Binding       → Two-way connection to parent
@Observable    → Reference type observation
@Environment   → Dependency injection
```

### Concurrency Quick Guide
```
@MainActor     → UI-bound types
actor          → Shared mutable state
@concurrent    → Explicit background work
Sendable       → Thread-safe types
```

## Usage

Reference these skills when:
1. Starting a new SwiftUI feature
2. Fixing concurrency compiler errors
3. Optimizing slow views
4. Refactoring existing code
5. Implementing navigation

## Source

Skills adapted from https://github.com/Dimillian/Skills (MIT License)
