# CSCI Project Form Trade Study

**System:** Agile Airframe  
**Decision Date:** 2026-06-01  
**Target Toolchain:** Xcode 26, Swift, SwiftUI  
**Target Platform:** macOS 26  
**Status:** Recommended baseline

## 1. Decision Summary

Use an Xcode workspace as the top-level developer entry point, with each CSCI kept as a separate source unit:

```text
Airframe.xcworkspace
├── AirframeCore/        Swift package, library product
├── AICockpit/           Swift package, executable product plus reusable command library target
└── AgileCockpit/        Xcode macOS SwiftUI app project
```

Recommended forms:

| CSCI | Recommended Form | Primary Product | Rationale |
| ---- | ---------------- | --------------- | --------- |
| AirframeCore | Standalone Swift package | Library product | Best fit for reusable domain APIs consumed by both CLI and app clients. |
| AICockpit | Standalone Swift package | Executable product | Best fit for a command interface usable by Codex, Claude Code, shell scripts, and CI without app packaging. |
| AgileCockpit | Xcode macOS app project | SwiftUI `.app` | Best fit for a full native macOS 26 user interface, signing, app lifecycle, assets, previews, and UI testing. |

## 2. Context

Agile Airframe is composed of three CSCIs:

- **AirframeCore**: Shared domain, workflow, authority, metrics, audit, configuration, and backend adapter layer.
- **AICockpit**: Agent-facing command interface for scoped project-management operations.
- **AgileCockpit**: Human-facing macOS application with full SwiftUI interface.

AirframeCore must be used by both other CSCIs. AICockpit must be easy for coding agents and automation to run directly. AgileCockpit must be a native macOS app targeting macOS 26.

## 3. AirframeCore Options

### Option A: Swift Package Library

AirframeCore is a standalone Swift package with one or more library products and test targets.

Pros:

- Native fit for reusable Swift modules.
- Clean source-of-truth in `Package.swift`.
- Easy consumption from both the CLI package and the macOS app project as a local package.
- Strong unit-test workflow with `swift test` and Xcode.
- Portable outside Xcode for command-line builds and CI.
- Supports modular target decomposition, such as `AirframeDomain`, `AirframeWorkflow`, `AirframeBackends`, and `AirframeTesting`.

Cons:

- App-specific capabilities, signing, entitlements, and asset catalogs belong elsewhere.
- Xcode project settings are intentionally minimal compared with app/framework projects.

Assessment: Best match.

### Option B: Xcode Framework Project

AirframeCore is an Xcode project that builds a macOS framework.

Pros:

- Familiar Xcode build settings and framework artifact.
- Can model Apple-platform-specific framework packaging directly.

Cons:

- Heavier than needed for shared project-management domain logic.
- Less ergonomic for command-line and CI usage than SwiftPM.
- More Xcode project file churn.
- Encourages platform coupling that AirframeCore should avoid.

Assessment: Not recommended for the initial implementation.

### Option C: Source Folder Inside App Project

AirframeCore code lives directly inside the AgileCockpit app project and is imported by AICockpit through project references or duplicated settings.

Pros:

- Fastest one-project startup.

Cons:

- Violates the intended CSCI boundary.
- Makes AICockpit a secondary client of an app-owned codebase.
- Harder to test and reuse independently.

Assessment: Reject.

## 4. AICockpit Options

### Option A: Swift Package Executable

AICockpit is a standalone Swift package with:

- an executable product named `aicockpit`;
- a library target, such as `AICockpitKit`, containing command parsing, command handlers, and output formatting;
- a test target for parser, command, and output behavior;
- a dependency on local `AirframeCore`.

Pros:

- Produces a normal command-line executable.
- Usable by Codex, Claude Code, shell scripts, and CI.
- Buildable with `swift build` and testable with `swift test`.
- Keeps command implementation testable without launching a process for every test.
- Can still be opened in Xcode and included in the workspace.

Cons:

- Installer/distribution work is separate if a global `aicockpit` command is desired.
- No app bundle, which is correct for this CSCI.

Assessment: Best match.

### Option B: Xcode Command Line Tool Project

AICockpit is an Xcode command-line tool project.

Pros:

- Xcode can create and run it directly.
- Straightforward for a single binary.

Cons:

- Less convenient for package reuse and command-line-first workflows.
- More fragile for agent and CI usage than a Swift package executable.
- Dependency wiring to AirframeCore is less clean than package-to-package dependency.

Assessment: Acceptable but weaker than a Swift package executable.

### Option C: Library Only

AICockpit provides command APIs but no executable.

Pros:

- Easy to embed in another process.

Cons:

- Fails the direct agent/CLI usability requirement.
- Requires another wrapper before Codex or Claude Code can use it.

Assessment: Reject.

## 5. AgileCockpit Options

### Option A: Xcode macOS SwiftUI App Project

AgileCockpit is a native macOS app project depending on local AirframeCore.

Pros:

- Correct form for a full SwiftUI macOS app.
- Supports asset catalogs, app lifecycle, signing, entitlements, previews, UI tests, and app-specific build settings.
- Keeps UI concerns out of AirframeCore.
- Can coexist with local Swift packages in the workspace.

Cons:

- Requires Xcode project maintenance.
- Automated project generation may be useful later if project-file churn becomes painful.

Assessment: Best match.

### Option B: Swift Package App Target

AgileCockpit is attempted as a Swift package-only app.

Pros:

- One package manifest style.

Cons:

- Poor fit for a full macOS application with signing, assets, previews, and UI test lifecycle.
- Not the normal Xcode path for app distribution.

Assessment: Reject for the main app.

## 6. Workspace Recommendation

Create a top-level `Airframe.xcworkspace` and add:

1. `AirframeCore/Package.swift`
2. `AICockpit/Package.swift`
3. `AgileCockpit/AgileCockpit.xcodeproj`

The app project should add `AirframeCore` as a local package dependency. The AICockpit package should depend on AirframeCore by local path.

The workspace is the daily Xcode entry point, while SwiftPM remains the source of truth for the two package CSCIs.

## 7. Proposed Repository Layout

```text
Airframe/
├── Airframe.xcworkspace/
├── AirframeCore/
│   ├── Package.swift
│   ├── Sources/
│   │   └── AirframeCore/
│   └── Tests/
│       └── AirframeCoreTests/
├── AICockpit/
│   ├── Package.swift
│   ├── Sources/
│   │   ├── AICockpit/
│   │   └── AICockpitKit/
│   └── Tests/
│       └── AICockpitKitTests/
├── AgileCockpit/
│   ├── AgileCockpit.xcodeproj/
│   ├── AgileCockpit/
│   ├── AgileCockpitTests/
│   └── AgileCockpitUITests/
└── docs/
```

## 8. Build and Test Implications

Expected local commands:

```sh
swift test --package-path AirframeCore
swift test --package-path AICockpit
swift run --package-path AICockpit aicockpit --help
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

Expected Xcode schemes:

- `AirframeCore`
- `AICockpit`
- `AgileCockpit`

## 9. Risks and Mitigations

| Risk | Mitigation |
| ---- | ---------- |
| SwiftPM platform enum for macOS 26 depends on installed Xcode 26 toolchain support. | Verify generated `Package.swift` manifests with the installed `swift package describe`; adjust syntax only if the local toolchain requires it. |
| Workspace may contain both packages and an app project, which can confuse dependency ownership. | Treat `Package.swift` as source of truth for package CSCIs and `AgileCockpit.xcodeproj` as source of truth for app-only concerns. |
| AICockpit command logic can become hard to test if placed entirely in `main.swift`. | Put command parsing and execution in `AICockpitKit`; keep the executable target thin. |
| AirframeCore can accidentally gain UI dependencies. | Keep AirframeCore free of SwiftUI/AppKit except in adapter targets explicitly justified later. |

## 10. Decision

Proceed with:

- **AirframeCore** as a standalone Swift package with a library product.
- **AICockpit** as a standalone Swift package with an executable product and reusable command library target.
- **AgileCockpit** as an Xcode macOS SwiftUI app project.
- **Airframe.xcworkspace** as the top-level workspace containing all three CSCIs.

This preserves independent CSCI boundaries while supporting the requested Xcode 26/macOS 26 Swift/SwiftUI implementation path.

## 11. References

- Apple Developer Documentation, Swift packages: reusable components that Xcode can create, publish, add, remove, and manage.
- Apple Developer Documentation, Creating a standalone Swift package with Xcode: packages can bundle executable code as executable products or shareable code as library products.
- Apple Developer Documentation, PackageDescription Product: package products can expose library, executable, and plugin products.
- Apple Developer Documentation, Xcode Workspace: a workspace can contain multiple Xcode projects and other files.
