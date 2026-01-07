# iOS Debugger Agent

> Build, run, and debug iOS apps on simulators using XcodeBuildMCP tools.

## When to Use

- Building and running iOS apps on simulators
- Debugging UI issues
- Capturing and analyzing logs
- Automated UI testing and verification

## Workflow

### 1. Discovery & Setup

```bash
# List available simulators
list_sims

# Identify booted simulator or boot one
# Establish session with project/workspace path, scheme, and simulator ID
```

### 2. Build & Launch

```bash
# Build and run the app
build_run_sim --project MyApp.xcodeproj --scheme MyApp --simulator "iPhone 15"

# Or launch already-built app
launch_app_sim --bundle-id com.example.myapp --simulator "iPhone 15"
```

### 3. Interaction & Inspection

**UI Description:**
- Query current UI layout and element hierarchy
- Identify elements by accessibility ID, label, or coordinates

**User Interactions:**
- Tap elements (prefer IDs/labels over coordinates)
- Type text into fields
- Perform gestures (swipe, scroll, pinch)
- Capture screenshots for visual verification

### 4. Monitoring

```bash
# Start log capture
start_sim_log_cap --bundle-id com.example.myapp

# ... perform interactions ...

# Stop and summarize logs
stop_sim_log_cap
```

## Troubleshooting

### Build Failures
- Retry with specific flags (`-allowProvisioningUpdates`)
- Verify correct scheme name
- Check for code signing issues

### Bundle ID Issues
- Use `get_bundle_id` tool to retrieve correct ID
- Verify scheme/bundle ID pairing matches

### UI Not Updating
- Refresh UI description after layout changes
- Wait for animations to complete
- Check for loading states

## Best Practices

1. **Always verify simulator is booted** before attempting operations
2. **Prefer accessibility IDs** over coordinate-based taps
3. **Capture screenshots** at key verification points
4. **Use structured logging** to trace issues
5. **Clean build folder** when experiencing mysterious failures

## Common Commands

```bash
# List schemes in project
xcodebuild -list -project MyApp.xcodeproj

# Build for simulator
xcodebuild build \
    -project MyApp.xcodeproj \
    -scheme MyApp \
    -destination 'platform=iOS Simulator,name=iPhone 15'

# Run tests
xcodebuild test \
    -project MyApp.xcodeproj \
    -scheme MyAppTests \
    -destination 'platform=iOS Simulator,name=iPhone 15'

# List simulators
xcrun simctl list devices

# Boot simulator
xcrun simctl boot "iPhone 15"

# Install app
xcrun simctl install booted /path/to/MyApp.app

# Launch app
xcrun simctl launch booted com.example.myapp

# Capture screenshot
xcrun simctl io booted screenshot screenshot.png

# Stream logs
xcrun simctl spawn booted log stream --predicate 'subsystem == "com.example.myapp"'
```
