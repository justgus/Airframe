# AgileCockpit Implementation Plan

**CSCI:** AgileCockpit  
**Product Form:** Xcode macOS SwiftUI application  
**Target Toolchain:** Xcode 26 / SwiftUI  
**Target Platform:** macOS 26  
**Status:** Planning baseline  

## 1. Objective

AgileCockpit is the human-facing macOS application for project oversight, verification, sprint and epic control, metrics, and audit visibility. It must provide a full SwiftUI interface while delegating domain, workflow, authority, backend, metrics, and audit behavior to AirframeCore.

## 2. Project Shape

Initial project layout:

```text
AgileCockpit/
├── AgileCockpit.xcodeproj/
├── AgileCockpit/
│   ├── App/
│   ├── Views/
│   ├── ViewModels/
│   ├── Commands/
│   ├── Assets.xcassets/
│   └── Resources/
├── AgileCockpitTests/
└── AgileCockpitUITests/
```

SwiftUI view models may adapt AirframeCore entities for presentation, but they must not become an alternate source of canonical workflow state.

## 3. Epic Roadmap

| Epic | Milestone | Executable Result |
| ---- | --------- | ----------------- |
| EP-001 | Workspace and Toolchain Baseline | AgileCockpit app launches in the workspace. |
| EP-002 | Core Domain and Configuration Foundation | App can load and show local workspace/project context. |
| EP-003 | Workflow, Authority, and Audit Foundation | App shows allowed/denied human actions and audit results. |
| EP-006 | AgileCockpit Dashboard MVP Integration | Dashboard, verification queue, and basic human actions work. |
| EP-007 | GitHub Backend MVP | App can show GitHub-backed project data through AirframeCore. |
| EP-008 | Verification, Hardening, and Release Candidate | App is accessible, testable, and ready for MVP verification. |

## 4. UI Surface

Initial primary views:

- Workspace/project selector.
- Dashboard summary.
- Active work list.
- Upcoming work list.
- Blocked work list.
- Ready for human verification queue.
- Work item detail and evidence review.
- Sprint detail and control view.
- Epic detail and control view.
- Metrics view.
- Audit view.
- Settings/configuration status view.

The first executable UI should emphasize project visibility and verification flow before advanced management screens.

## 5. Milestone Tasks

### EP-001: Workspace and Toolchain Baseline

- Create `AgileCockpit.xcodeproj` as a macOS SwiftUI app.
- Set macOS 26 as the deployment target.
- Add local `AirframeCore` package dependency.
- Add shared app scheme.
- Add basic smoke tests.
- Add app project to `Airframe.xcworkspace`.

Verification:

```sh
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' build
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

Independent executable result:

- AgileCockpit launches and displays a minimal shell that confirms AirframeCore is linked.

### EP-002: Core Domain and Configuration Foundation

- Implement workspace/project selection view.
- Display current project context from AirframeCore configuration.
- Add empty-state dashboard UI.
- Add UI state for selected project and filters.
- Add view model tests using local fixtures.

Verification:

```sh
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

Independent executable result:

- User can launch the app, select or view a configured project, and see baseline project metadata.

### EP-003: Workflow, Authority, and Audit Foundation

- Display actor/session context from AirframeCore.
- Show enabled, disabled, or hidden human-only actions based on operation evaluation.
- Present denied operation reason codes and explanations.
- Add audit event list and detail view.
- Add tests for disabled controls and error presentation.

Verification:

```sh
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

Independent executable result:

- User can see why actions are allowed or denied, and audit records are visible for attempted operations.

### EP-006: AgileCockpit Dashboard MVP Integration

- Implement dashboard summary sections: recently done, active now, ready for verification, blocked, next up, upcoming, sprint health, epic progress, and backend status.
- Implement verification review flow.
- Implement accept/reject/request-evidence UI actions through AirframeCore.
- Implement sprint and epic detail read views.
- Implement metrics cards or charts for initial AirframeCore metrics.
- Add accessibility labels and keyboard navigation for primary flows.

Verification:

```sh
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

Independent executable result:

- User can run the app against local fixture data, review a ready item, perform a human verification action, and see dashboard updates.

### EP-007: GitHub Backend MVP

- Display backend capability and synchronization status.
- Show GitHub-backed issues/tasks/sprints/epics through canonical AirframeCore models.
- Present backend failure and stale data states.
- Add UI tests or fixture tests for backend status and error states.

Verification:

```sh
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

Independent executable result:

- App can show project status from a GitHub-backed project through AirframeCore without GitHub-specific UI assumptions.

### EP-008: Verification, Hardening, and Release Candidate

- Complete accessibility checks for primary workflows.
- Add visual and interaction tests for major views.
- Add settings/configuration diagnostics.
- Improve loading, stale data, and error states.
- Document manual verification workflow for human reviewers.

Verification:

```sh
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

Independent executable result:

- AgileCockpit is ready for MVP human workflow verification with stable dashboard, review, metrics, and audit behavior.

## 6. Definition of Done

AgileCockpit work is complete for a milestone when:

- The app builds and launches from the workspace.
- UI operations call AirframeCore APIs rather than duplicating workflow or authority rules.
- Empty, loading, stale, denied, and backend failure states are handled.
- Tests cover the primary view models or flows added in the milestone.
- Manual verification steps are documented for user review.

