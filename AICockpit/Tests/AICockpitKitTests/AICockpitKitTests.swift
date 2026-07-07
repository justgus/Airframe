import Testing
import AirframeCore
@testable import AICockpitKit
import Foundation

@Test func helpTextIncludesCommandNameAndCoreIdentity() {
    let help = AICockpitCommand.helpText()

    #expect(help.contains("aicockpit"))
    #expect(help.contains("AirframeCore 0.1.0"))
    #expect(help.contains("aicockpit context"))
    #expect(help.contains("aicockpit config diagnose"))
    #expect(help.contains("aicockpit state diagnostics"))
    #expect(help.contains("aicockpit requirements import --format csv|json --file path --dry-run"))
    #expect(help.contains("aicockpit requirements export --format csv|json"))
    #expect(help.contains("aicockpit tests list"))
    #expect(help.contains("aicockpit plans submit"))
    #expect(help.contains("aicockpit tests inspect TEST-ID"))
    #expect(help.contains("aicockpit tests validate"))
    #expect(help.contains("aicockpit task propose"))
    #expect(help.contains("aicockpit work ready"))
    #expect(help.contains("aicockpit github comment"))
    #expect(help.contains("--backend canonical|local-fixture|github-fixture|github-issues"))
}

@Test func plansSubmitListInspectAndDenyHumanDecisions() throws {
    let configPath = try temporaryCanonicalTestConfigurationPath()
    let submit = AICockpitCommand.response(arguments: [
        "plans", "submit",
        "--config", configPath,
        "--id", "PLAN-023-001",
        "--title", "Implement plan review",
        "--summary", "Add plan records, commands, and UI.",
        "--task", "T-0154",
        "--scope", "AirframeCore model",
        "--file-change", "AirframeCore/Sources/AirframeCore/PlanReview.swift",
        "--command", "swift test --package-path AirframeCore",
        "--external-effect", "None",
        "--verification", "Plan approval is human-only.",
        "--output", "json"
    ])
    let list = AICockpitCommand.response(arguments: [
        "plans", "list",
        "--config", configPath,
        "--output", "json"
    ])
    let inspect = AICockpitCommand.response(arguments: [
        "plans", "inspect", "PLAN-023-001",
        "--config", configPath,
        "--output", "json"
    ])
    let approve = AICockpitCommand.response(arguments: [
        "plans", "approve", "PLAN-023-001",
        "--config", configPath,
        "--output", "json"
    ])

    #expect(submit.exitCode == 0)
    #expect(submit.standardOutput.contains("\"kind\" : \"canonicalPlanSubmission\""))
    #expect(submit.standardOutput.contains("\"decisionState\" : \"pending\""))
    #expect(submit.standardOutput.contains("\"targetEpicID\""))
    #expect(submit.standardOutput.contains("EP-9700"))
    #expect(list.exitCode == 0)
    #expect(list.standardOutput.contains("\"kind\" : \"canonicalPlanList\""))
    #expect(list.standardOutput.contains("PLAN-023-001"))
    #expect(inspect.exitCode == 0)
    #expect(inspect.standardOutput.contains("\"kind\" : \"canonicalPlanInspection\""))
    #expect(inspect.standardOutput.contains("PlanReview.swift"))
    #expect(approve.exitCode == 77)
    #expect(approve.standardOutput.contains("category: planDecision"))
    #expect(approve.standardOutput.contains("reason: authorityClassNotPermitted"))
}

@Test func configDiagnoseReturnsStableMarkdownContract() {
    let result = AICockpitCommand.response(arguments: ["config", "diagnose"])

    #expect(result.exitCode == 0)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("kind: configurationDiagnostics"))
    #expect(result.standardOutput.contains("## Configuration Diagnostics"))
    #expect(result.standardOutput.contains("status: ok"))
    #expect(result.standardOutput.contains("backend: github-fixture at justgus/Airframe"))
    #expect(result.standardOutput.contains("issues: None"))
}

@Test func configDiagnoseReturnsStableJSONContract() {
    let result = AICockpitCommand.response(arguments: ["config", "diagnose", "--output", "json"])

    #expect(result.exitCode == 0)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("\"kind\" : \"configurationDiagnostics\""))
    #expect(result.standardOutput.contains("\"configurationDiagnostics\""))
    #expect(result.standardOutput.contains("\"backendKind\" : \"github-fixture\""))
    #expect(result.standardOutput.contains("\"status\" : \"ok\""))
}

@Test func configDiagnoseExplainsCanonicalLocalFirstOperationForGitHubWorkspace() throws {
    let config = try temporaryGitHubConfigurationWithCanonicalStatePath()
    let result = AICockpitCommand.response(arguments: [
        "config", "diagnose",
        "--config", config,
        "--output", "json"
    ])

    #expect(result.exitCode == 0)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("\"status\" : \"warning\""))
    #expect(result.standardOutput.contains("\"code\" : \"canonicalStoreUsesLocalBackend\""))
    #expect(result.standardOutput.contains("GitHub-backed paths are optional"))
}

@Test func stateDiagnosticsReturnsCanonicalDiagnosticsJSON() {
    let store = temporaryStorePath()
    let created = AICockpitCommand.response(arguments: [
        "task", "create",
        "--store", store,
        "--id", "T-9126",
        "--title", "Add canonical diagnostics",
        "--status", "active",
        "--epic", "EP-999",
        "--sprint", "SP-999",
        "--output", "json"
    ])
    let diagnostics = AICockpitCommand.response(arguments: [
        "state", "diagnostics",
        "--store", store,
        "--output", "json"
    ])

    #expect(created.exitCode == 0)
    #expect(diagnostics.exitCode == 0)
    #expect(diagnostics.standardOutput.contains("\"kind\" : \"canonicalStateDiagnostics\""))
    #expect(diagnostics.standardOutput.contains("\"canonicalDiagnostics\""))
    #expect(diagnostics.standardOutput.contains("\"reasonCode\" : \"taskEpicMissing\""))
    #expect(diagnostics.standardOutput.contains("\"severity\" : \"warning\""))
}

@Test func stateDiagnosticsDoesNotBypassHumanOnlyStatusGuards() {
    let store = temporaryStorePath()
    _ = AICockpitCommand.response(arguments: [
        "task", "create",
        "--store", store,
        "--id", "T-9127",
        "--title", "Verify canonical authority boundaries",
        "--status", "active",
        "--output", "json"
    ])

    let diagnostics = AICockpitCommand.response(arguments: [
        "state", "diagnostics",
        "--store", store,
        "--output", "json"
    ])
    let verified = AICockpitCommand.response(arguments: [
        "task", "status", "T-9127",
        "--store", store,
        "--to", "verified",
        "--output", "json"
    ])
    let packet = AICockpitCommand.response(arguments: [
        "task", "packet", "T-9127",
        "--store", store,
        "--output", "json"
    ])

    #expect(diagnostics.exitCode == 0)
    #expect(diagnostics.standardOutput.contains("\"kind\" : \"canonicalStateDiagnostics\""))
    #expect(verified.exitCode == 64)
    #expect(verified.standardOutput.contains("verification is human-only"))
    #expect(packet.standardOutput.contains("\"status\" : \"active\""))
}

@Test func helpCommandReturnsSuccess() {
    #expect(AICockpitCommand.main(arguments: ["--help"]) == 0)
}

@Test func requirementsImportDryRunReturnsPreviewFromCSVInterchange() throws {
    let configPath = try temporaryCanonicalRequirementsConfigurationPath()
    let rootURL = URL(filePath: configPath).deletingLastPathComponent()
    let store = AirframeCanonicalJSONStore(rootURL: rootURL)
    try store.save(
        AirframeCanonicalRequirementRecord(
            id: AirframeID("REQ-0001"),
            title: "Existing requirement",
            statement: "Original statement",
            status: .draft
        )
    )
    try store.save(
        AirframeCanonicalRequirementRecord(
            id: AirframeID("REQ-0003"),
            title: "Removed requirement",
            statement: "Removed statement",
            status: .draft
        )
    )
    let importURL = rootURL.appending(path: "requirements.csv")
    try Data(
        """
        record_kind,id,requirement_id,revision_number,external_id,title,statement,status,rationale,source_kind,source_uri,priority,verification_method,validation_required,release_scope,parent_ids,derived_from_ids,supersedes_ids,trace_links,deviation_ids,current_revision_id,change_rationale
        requirement,REQ-0001,,,EXT-1,Existing requirement,Changed statement,active,,airframe,,high,test,true,v1,,,,,,,
        requirement,REQ-0002,,,EXT-2,New requirement,New statement,draft,,airframe,,medium,test,true,v1,,,,,,,
        """.utf8
    ).write(to: importURL)

    let result = AICockpitCommand.response(arguments: [
        "requirements", "import",
        "--config", configPath,
        "--format", "csv",
        "--file", importURL.path,
        "--dry-run",
        "--output", "json"
    ])

    #expect(result.exitCode == 0)
    #expect(result.standardOutput.contains("\"kind\" : \"requirementsImportPreview\""))
    #expect(result.standardOutput.contains("\"format\" : \"csv\""))
    #expect(result.standardOutput.contains("\"createdCount\" : 1"))
    #expect(result.standardOutput.contains("\"updatedCount\" : 1"))
    #expect(result.standardOutput.contains("\"removedCount\" : 1"))
    #expect(result.standardOutput.contains("\"rawValue\" : \"REQ-0002\""))
}

@Test func requirementsExportRoutesJSONThroughInterchange() throws {
    let configPath = try temporaryCanonicalRequirementsConfigurationPath()
    let rootURL = URL(filePath: configPath).deletingLastPathComponent()
    try AirframeCanonicalJSONStore(rootURL: rootURL).save(
        AirframeCanonicalRequirementRecord(
            id: AirframeID("REQ-0100"),
            title: "Exported requirement",
            statement: "Exported statement",
            status: .active,
            releaseScope: ["v1"]
        )
    )

    let result = AICockpitCommand.response(arguments: [
        "requirements", "export",
        "--config", configPath,
        "--format", "json"
    ])

    #expect(result.exitCode == 0)
    #expect(result.standardOutput.contains("\"requirements\""))
    #expect(result.standardOutput.contains("\"rawValue\" : \"REQ-0100\""))
    #expect(result.standardOutput.contains("\"title\" : \"Exported requirement\""))
    #expect(result.standardOutput.contains("\"releaseScope\" : ["))
}

@Test func stateImportMarkdownIncludesClosedSprintArtifactsFromClosedDirectory() throws {
    let configPath = try temporaryLiveConfigurationPath()
    let rootURL = URL(filePath: configPath).deletingLastPathComponent()
    let closedSprintsDirectory = rootURL.appending(path: "docs/Sprints/Closed")
    try FileManager.default.createDirectory(at: closedSprintsDirectory, withIntermediateDirectories: true)
    try Data(
        """
        # SP-002: Expanded Schema & Mock Telemetry

        **Status:** Closed
        **Epic:** EP-002
        **Goal:** Expand the canonical schema and mock telemetry support.
        **Start Date:** 2026-06-01
        **End Date:** 2026-06-02
        """.utf8
    ).write(to: closedSprintsDirectory.appending(path: "Sprint-SP-002.md"))
    try Data(
        """
        # SP-003: Workflow, Authority, and Audit Foundation

        **Status:** Closed
        **Epic:** EP-003
        **Goal:** Implement the deny-by-default workflow and audit foundation.
        **Start Date:** 2026-06-02
        **End Date:** 2026-06-03
        """.utf8
    ).write(to: closedSprintsDirectory.appending(path: "Sprint-SP-003.md"))

    let result = AICockpitCommand.response(arguments: [
        "state", "import-markdown",
        "--config", configPath
    ])
    let store = AirframeCanonicalJSONStore(rootURL: rootURL)
    let sprint002 = try store.load(AirframeCanonicalSprintRecord.self, id: AirframeID("SP-002"))
    let sprint003 = try store.load(AirframeCanonicalSprintRecord.self, id: AirframeID("SP-003"))

    #expect(result.exitCode == 0)
    #expect(result.standardOutput.contains("sprints: 2"))
    #expect(sprint002?.workItem.status == .closed)
    #expect(sprint003?.workItem.status == .closed)
    #expect(sprint002?.epicID == AirframeID("EP-002"))
    #expect(sprint003?.epicID == AirframeID("EP-003"))
}

@Test func stateImportMarkdownPreservesActiveEpicAndSprintStatuses() throws {
    let configPath = try temporaryLiveConfigurationPath()
    let rootURL = URL(filePath: configPath).deletingLastPathComponent()
    try FileManager.default.createDirectory(at: rootURL.appending(path: "docs/Epics"), withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: rootURL.appending(path: "docs/Sprints"), withIntermediateDirectories: true)
    try Data(
        """
        # EP-010: Active Epic

        **Status:** Active
        **Owner:** Human

        **Goal:**
        Preserve the active Epic status during markdown import.

        **Rationale:**
        Status mapping must not downgrade active work.
        """.utf8
    ).write(to: rootURL.appending(path: "docs/Epics/Epic-active.md"))
    try Data(
        """
        # SP-010: Active Sprint

        **Status:** Active
        **Epic:** EP-010
        **Goal:** Preserve the active Sprint status during markdown import.
        **Start Date:** 2026-06-01
        """.utf8
    ).write(to: rootURL.appending(path: "docs/Sprints/Sprint-active.md"))

    let result = AICockpitCommand.response(arguments: [
        "state", "import-markdown",
        "--config", configPath
    ])
    let store = AirframeCanonicalJSONStore(rootURL: rootURL)
    let epic = try store.load(AirframeCanonicalEpicRecord.self, id: AirframeID("EP-010"))
    let sprint = try store.load(AirframeCanonicalSprintRecord.self, id: AirframeID("SP-010"))

    #expect(result.exitCode == 0)
    #expect(epic?.workItem.status == .active)
    #expect(sprint?.workItem.status == .active)
}

@Test func stateImportMarkdownPreservesBatchTaskBackLinksFromVerifiedDocuments() throws {
    let configPath = try temporaryLiveConfigurationPath()
    let rootURL = URL(filePath: configPath).deletingLastPathComponent()
    let verifiedTasksDirectory = rootURL.appending(path: "docs/Tasks/Verified")
    try FileManager.default.createDirectory(at: verifiedTasksDirectory, withIntermediateDirectories: true)
    try Data(
        """
        # Verified Tasks T-0001 through T-0002

        **Date Verified:** 2026-06-01
        **Verified By:** HumanOwner
        **Sprint:** SP-001
        **Epic:** EP-001

        The user verified SP-001 on 2026-06-01. The following Tasks are human-verified:

        | Task | GitHub Issue | Title | Status |
        | ---- | ------------ | ----- | ------ |
        | T-0001 | #1 | Scaffold AirframeCore Swift package | Implemented - Verified |
        | T-0002 | #2 | Scaffold AICockpit Swift package executable | Implemented - Verified |
        """.utf8
    ).write(to: verifiedTasksDirectory.appending(path: "Task-verified-0001-0002.md"))

    let result = AICockpitCommand.response(arguments: [
        "state", "import-markdown",
        "--config", configPath
    ])
    let store = AirframeCanonicalJSONStore(rootURL: rootURL)
    let task1 = try store.load(AirframeCanonicalTaskRecord.self, id: AirframeID("T-0001"))
    let task2 = try store.load(AirframeCanonicalTaskRecord.self, id: AirframeID("T-0002"))

    #expect(result.exitCode == 0)
    #expect(task1?.epicID == AirframeID("EP-001"))
    #expect(task1?.sprintID == AirframeID("SP-001"))
    #expect(task2?.epicID == AirframeID("EP-001"))
    #expect(task2?.sprintID == AirframeID("SP-001"))
}

@Test func mutationCommandsDefaultToCanonicalPerRecordStoreWhenConfigured() throws {
    let configPath = try temporaryLiveConfigurationPath()
    let rootURL = URL(filePath: configPath).deletingLastPathComponent()
    let repository = AirframeCanonicalStoreRepository(rootURL: rootURL)
    try repository.store.save(
        AirframeCanonicalProjectRecord(
            id: AirframeID("PRJ-AIRFRAME"),
            name: "Agile Airframe",
            repository: "justgus/Airframe",
            epicIDs: [AirframeID("EP-9100")]
        )
    )
    try repository.store.save(
        AirframeCanonicalEpicRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("EP-9100"),
                kind: .epic,
                title: "Canonical mutation routing",
                status: .backlog
            ),
            owner: "Airframe",
            goal: "Route mutations to canonical state.",
            rationale: "Imported per-record state must be repairable."
        )
    )

    let result = AICockpitCommand.response(arguments: [
        "epic", "status", "EP-9100",
        "--config", configPath,
        "--to", "active",
        "--output", "json"
    ])
    let savedEpic = try repository.store.load(AirframeCanonicalEpicRecord.self, id: AirframeID("EP-9100"))

    #expect(result.exitCode == 0)
    #expect(result.standardOutput.contains("\"backendKind\" : \"canonical\""))
    #expect(savedEpic?.workItem.status == .active)
}

@Test func createCommandsDefaultOwnershipToCanonicalActivePointersWhenAvailable() throws {
    let configPath = try temporaryLiveConfigurationPath()
    let rootURL = URL(filePath: configPath).deletingLastPathComponent()
    let repository = AirframeCanonicalStoreRepository(rootURL: rootURL)
    try repository.store.save(
        AirframeCanonicalProjectRecord(
            id: AirframeID("PRJ-AIRFRAME"),
            name: "Agile Airframe",
            repository: "justgus/Airframe",
            activeEpicID: AirframeID("EP-9500"),
            activeSprintID: AirframeID("SP-9500"),
            epicIDs: [AirframeID("EP-9500")],
            sprintIDs: [AirframeID("SP-9500")]
        )
    )
    try repository.store.save(
        AirframeCanonicalEpicRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("EP-9500"),
                kind: .epic,
                title: "Canonical active Epic",
                status: .active
            ),
            owner: "Airframe",
            goal: "Own new work.",
            rationale: "Canonical state is the source of truth."
        )
    )
    try repository.store.save(
        AirframeCanonicalSprintRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("SP-9500"),
                kind: .sprint,
                title: "Canonical active Sprint",
                status: .active
            ),
            epicID: AirframeID("EP-9500"),
            goal: "Own new work."
        )
    )

    let result = AICockpitCommand.response(arguments: [
        "issue", "create",
        "--config", configPath,
        "--id", "I-9500",
        "--title", "Use canonical active owners",
        "--status", "active",
        "--output", "json"
    ])
    let savedIssue = try repository.store.load(AirframeCanonicalIssueRecord.self, id: AirframeID("I-9500"))

    #expect(result.exitCode == 0)
    #expect(result.standardOutput.contains("\"backendKind\" : \"canonical\""))
    #expect(savedIssue?.epicID == AirframeID("EP-9500"))
    #expect(savedIssue?.sprintID == AirframeID("SP-9500"))
}

@Test func githubConfiguredWorkspaceRunsCanonicalWorkItemCommandsOffline() throws {
    let configPath = try temporaryGitHubConfigurationWithCanonicalStatePath()
    let rootURL = URL(filePath: configPath).deletingLastPathComponent()
    let repository = AirframeCanonicalStoreRepository(rootURL: rootURL)
    try seedCanonicalActiveOwners(repository: repository, epicID: "EP-9600", sprintID: "SP-9600")

    let task = AICockpitCommand.response(arguments: [
        "task", "create",
        "--config", configPath,
        "--id", "T-9600",
        "--title", "Offline task flow",
        "--status", "active",
        "--output", "json"
    ])
    let issue = AICockpitCommand.response(arguments: [
        "issue", "create",
        "--config", configPath,
        "--id", "I-9600",
        "--title", "Offline issue flow",
        "--status", "active",
        "--output", "json"
    ])
    let sprint = AICockpitCommand.response(arguments: [
        "sprint", "create",
        "--config", configPath,
        "--id", "SP-9601",
        "--title", "Offline sprint flow",
        "--status", "planning",
        "--epic", "EP-9600",
        "--output", "json"
    ])
    let epic = AICockpitCommand.response(arguments: [
        "epic", "create",
        "--config", configPath,
        "--id", "EP-9601",
        "--title", "Offline epic flow",
        "--status", "draft",
        "--output", "json"
    ])
    let updated = AICockpitCommand.response(arguments: [
        "task", "update", "T-9600",
        "--config", configPath,
        "--title", "Offline task flow updated",
        "--output", "json"
    ])
    let implemented = AICockpitCommand.response(arguments: [
        "task", "status", "T-9600",
        "--config", configPath,
        "--to", "implemented",
        "--output", "json"
    ])
    let packet = AICockpitCommand.response(arguments: [
        "task", "packet", "T-9600",
        "--config", configPath,
        "--output", "json"
    ])
    let summary = AICockpitCommand.response(arguments: [
        "project", "summary",
        "--config", configPath,
        "--output", "json"
    ])

    for result in [task, issue, sprint, epic, updated, implemented, packet, summary] {
        #expect(result.exitCode == 0)
        #expect(result.standardError.isEmpty)
        #expect(result.standardOutput.contains("\"backendKind\" : \"canonical\""))
    }
    #expect(implemented.standardOutput.contains("\"status\" : \"implementedNotVerified\""))
    #expect(packet.standardOutput.contains("\"kind\" : \"taskPacket\""))
    #expect(summary.standardOutput.contains("\"kind\" : \"projectSummary\""))
}

@Test func canonicalStoreBackendCreatesAndLinksTaskRecords() throws {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AICockpitCanonicalCreateTests")
        .appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)

    let repository = AirframeCanonicalStoreRepository(rootURL: rootURL)
    try repository.store.save(
        AirframeCanonicalProjectRecord(
            id: AirframeID("PRJ-AIRFRAME"),
            name: "Agile Airframe",
            repository: "justgus/Airframe",
            epicIDs: [AirframeID("EP-9400")],
            sprintIDs: [AirframeID("SP-9400")],
            taskIDs: []
        )
    )
    try repository.store.save(
        AirframeCanonicalEpicRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("EP-9400"),
                kind: .epic,
                title: "Canonical create path",
                status: .backlog
            ),
            owner: "Airframe",
            goal: "Allow canonical record creation.",
            rationale: "The CLI create path needs a writable canonical backend."
        )
    )
    try repository.store.save(
        AirframeCanonicalSprintRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("SP-9400"),
                kind: .sprint,
                title: "Canonical create sprint",
                status: .backlog
            ),
            epicID: AirframeID("EP-9400"),
            goal: "Create canonical tasks into linked sprint."
        )
    )

    let backend = AirframeCanonicalStoreBackend(repository: repository)
    let taskID = AirframeID("T-9400")
    try backend.createWorkRecord(
        AirframeLocalWorkRecord(
            workItem: AirframeWorkItem(
                id: taskID,
                kind: .task,
                title: "Create canonical task records",
                status: .backlog
            ),
            epicID: AirframeID("EP-9400"),
            sprintID: AirframeID("SP-9400"),
            priority: .high,
            acceptanceCriteria: ["Task can be created in the canonical store."],
            scope: ["AirframeCore"],
            constraints: ["No duplicate IDs"],
            evidenceRequirements: ["Verify epic and sprint links"]
        )
    )

    let savedTask = try repository.store.load(AirframeCanonicalTaskRecord.self, id: taskID)
    let savedEpic = try repository.store.load(AirframeCanonicalEpicRecord.self, id: AirframeID("EP-9400"))
    let savedSprint = try repository.store.load(AirframeCanonicalSprintRecord.self, id: AirframeID("SP-9400"))
    let savedProject = try repository.store.load(AirframeCanonicalProjectRecord.self, id: AirframeID("PRJ-AIRFRAME"))

    #expect(backend.capabilities.supportsCreateWorkItem)
    #expect(savedTask?.workItem.title == "Create canonical task records")
    #expect(savedTask?.epicID == AirframeID("EP-9400"))
    #expect(savedTask?.sprintID == AirframeID("SP-9400"))
    #expect(savedEpic?.taskIDs == [taskID])
    #expect(savedSprint?.taskIDs == [taskID])
    #expect(savedProject?.taskIDs.contains(taskID) == true)
}

@Test func stateRepairRestoresCanonicalActiveEpicFromDiagnostics() throws {
    let configPath = try temporaryLiveConfigurationPath()
    let rootURL = URL(filePath: configPath).deletingLastPathComponent()
    let repository = AirframeCanonicalStoreRepository(rootURL: rootURL)
    try repository.store.save(
        AirframeCanonicalProjectRecord(
            id: AirframeID("PRJ-AIRFRAME"),
            name: "Agile Airframe",
            repository: "justgus/Airframe",
            activeEpicID: AirframeID("EP-9200"),
            epicIDs: [AirframeID("EP-9200")],
            taskIDs: [AirframeID("T-9200")]
        )
    )
    try repository.store.save(
        AirframeCanonicalEpicRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("EP-9200"),
                kind: .epic,
                title: "Restore active Epic",
                status: .closed
            ),
            owner: "Airframe",
            goal: "Restore an incorrectly closed active Epic.",
            rationale: "Diagnostics must offer executable canonical repairs.",
            taskIDs: [AirframeID("T-9200")]
        )
    )
    try repository.store.save(
        AirframeCanonicalTaskRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("T-9200"),
                kind: .task,
                title: "Open child work",
                status: .active
            ),
            component: "AirframeCore",
            priority: .high,
            rationale: "Closed Epic owns open work.",
            epicID: AirframeID("EP-9200")
        )
    )

    let result = AICockpitCommand.response(arguments: [
        "state", "repair",
        "--config", configPath,
        "--action", "restoreEpicToActive",
        "--id", "EP-9200",
        "--approve",
        "--approved-by", "Human",
        "--output", "json"
    ])
    let savedEpic = try repository.store.load(AirframeCanonicalEpicRecord.self, id: AirframeID("EP-9200"))

    #expect(result.exitCode == 0)
    #expect(result.standardOutput.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("{"))
    #expect(result.standardOutput.contains("\"action\" : \"restoreEpicToActive\""))
    #expect(savedEpic?.workItem.status == .active)
}

@Test func stateRepairReconcilesCanonicalEpicTaskLinksFromDiagnostics() throws {
    let configPath = try temporaryLiveConfigurationPath()
    let rootURL = URL(filePath: configPath).deletingLastPathComponent()
    let repository = AirframeCanonicalStoreRepository(rootURL: rootURL)
    try repository.store.save(
        AirframeCanonicalProjectRecord(
            id: AirframeID("PRJ-AIRFRAME"),
            name: "Agile Airframe",
            repository: "justgus/Airframe",
            epicIDs: [AirframeID("EP-9300")],
            taskIDs: [AirframeID("T-9300")]
        )
    )
    try repository.store.save(
        AirframeCanonicalEpicRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("EP-9300"),
                kind: .epic,
                title: "Reconcile Epic task links",
                status: .active
            ),
            owner: "Airframe",
            goal: "Repair relationship drift.",
            rationale: "Canonical relationship repairs must be executable.",
            taskIDs: [AirframeID("T-9300")]
        )
    )
    try repository.store.save(
        AirframeCanonicalTaskRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("T-9300"),
                kind: .task,
                title: "Relationship drift",
                status: .active
            ),
            component: "AirframeCore",
            priority: .high,
            rationale: "Task points at the wrong Epic.",
            epicID: AirframeID("EP-OTHER")
        )
    )

    let result = AICockpitCommand.response(arguments: [
        "state", "repair",
        "--config", configPath,
        "--action", "reconcileEpicTaskLinks",
        "--id", "T-9300",
        "--approve",
        "--approved-by", "Human",
        "--output", "json"
    ])
    let savedTask = try repository.store.load(AirframeCanonicalTaskRecord.self, id: AirframeID("T-9300"))

    #expect(result.exitCode == 0)
    #expect(result.standardOutput.contains("\"action\" : \"reconcileEpicTaskLinks\""))
    #expect(savedTask?.epicID == AirframeID("EP-9300"))
}

@Test func requirementsImportApplyWritesCanonicalRequirementRecords() throws {
    let configPath = try temporaryCanonicalRequirementsConfigurationPath()
    let rootURL = URL(filePath: configPath).deletingLastPathComponent()
    let store = AirframeCanonicalJSONStore(rootURL: rootURL)
    try store.save(
        AirframeCanonicalRequirementRecord(
            id: AirframeID("REQ-0199"),
            title: "Removed requirement",
            statement: "Removed statement",
            status: .draft
        )
    )
    let importURL = rootURL.appending(path: "requirements.csv")
    try Data(
        """
        record_kind,id,requirement_id,revision_number,external_id,title,statement,status,rationale,source_kind,source_uri,priority,verification_method,validation_required,release_scope,parent_ids,derived_from_ids,supersedes_ids,trace_links,deviation_ids,current_revision_id,change_rationale
        requirement,REQ-0200,,,EXT-200,Apply requirement,Apply statement,draft,,airframe,,medium,test,true,,,,,,,,
        """.utf8
    ).write(to: importURL)

    let result = AICockpitCommand.response(arguments: [
        "requirements", "import",
        "--config", configPath,
        "--format", "csv",
        "--file", importURL.path,
        "--apply",
        "--output", "json"
    ])
    let savedRequirement = try store.load(AirframeCanonicalRequirementRecord.self, id: AirframeID("REQ-0200"))
    let removedRequirement = try store.load(AirframeCanonicalRequirementRecord.self, id: AirframeID("REQ-0199"))

    #expect(result.exitCode == 0)
    #expect(result.standardOutput.contains("\"kind\" : \"requirementsImportApply\""))
    #expect(result.standardOutput.contains("\"applied\" : true"))
    #expect(result.standardOutput.contains("\"createdCount\" : 1"))
    #expect(result.standardOutput.contains("\"removedCount\" : 1"))
    #expect(savedRequirement?.title == "Apply requirement")
    #expect(removedRequirement == nil)
}

@Test func testsListInspectAndValidateCanonicalTestDefinitions() throws {
    let configPath = try temporaryCanonicalTestConfigurationPath()
    let rootURL = URL(filePath: configPath).deletingLastPathComponent()
    let repository = AirframeCanonicalStoreRepository(rootURL: rootURL)
    try repository.store.save(
        AirframeCanonicalRequirementRecord(
            id: AirframeID("REQ-9700"),
            title: "Traceability requirement",
            statement: "The canonical test should trace back to a requirement.",
            status: .active
        )
    )
    try repository.store.save(
        AirframeCanonicalAcceptanceCriterionRecord(
            id: AirframeID("EP-9700-AC-01"),
            ownerID: AirframeID("EP-9700"),
            text: "The requirement has a matching acceptance criterion."
        )
    )
    try repository.store.save(
        AirframeCanonicalEpicRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("EP-9700"),
                kind: .epic,
                title: "Canonical traceability epic",
                status: .active
            ),
            owner: "Airframe",
            goal: "Keep canonical tests linked to requirements.",
            rationale: "The validation command should see a real work item owner."
        )
    )
    try repository.store.save(
        AirframeCanonicalTestRecord(
            id: AirframeID("TEST-9700-001"),
            title: "Canonical traceability",
            objective: "Keep requirements linked to tests.",
            kind: .acceptance,
            status: .ready,
            requirementIDs: [AirframeID("REQ-9700")],
            acceptanceCriterionIDs: [AirframeID("EP-9700-AC-01")],
            workItemIDs: [AirframeID("EP-9700")],
            steps: ["Load canonical state.", "Inspect the test definition.", "Validate the traceability graph."],
            expectedResults: ["The test is listed.", "The test can be inspected.", "Validation returns ok."],
            automationCommand: "swift test --package-path AICockpit",
            artifactReferences: ["docs/generated/Requirements/Requirements-Traceability-Matrix.md"],
            notes: ["Seeded via CLI regression test."]
        )
    )

    let list = AICockpitCommand.response(arguments: [
        "tests", "list",
        "--config", configPath,
        "--output", "json"
    ])
    let inspect = AICockpitCommand.response(arguments: [
        "tests", "inspect", "TEST-9700-001",
        "--config", configPath,
        "--output", "json"
    ])
    let validate = AICockpitCommand.response(arguments: [
        "tests", "validate",
        "--config", configPath,
        "--output", "json"
    ])

    #expect(list.exitCode == 0)
    #expect(list.standardOutput.contains("\"kind\" : \"canonicalTestList\""))
    #expect(list.standardOutput.contains("\"rawValue\" : \"TEST-9700-001\""))
    #expect(inspect.exitCode == 0)
    #expect(inspect.standardOutput.contains("\"kind\" : \"canonicalTestInspection\""))
    #expect(inspect.standardOutput.contains("\"objective\" : \"Keep requirements linked to tests.\""))
    #expect(validate.exitCode == 0)
    #expect(validate.standardOutput.contains("\"kind\" : \"canonicalTestValidation\""))
    #expect(validate.standardOutput.contains("\"status\" : \"ok\""))
}

@Test func testsCreateAndUpdateCanonicalTestDefinitions() throws {
    let configPath = try temporaryCanonicalTestConfigurationPath()
    let rootURL = URL(filePath: configPath).deletingLastPathComponent()
    let repository = AirframeCanonicalStoreRepository(rootURL: rootURL)
    try repository.store.save(
        AirframeCanonicalRequirementRecord(
            id: AirframeID("REQ-9701"),
            title: "Creation requirement",
            statement: "The test create command persists canonical test records.",
            status: .active
        )
    )

    let created = AICockpitCommand.response(arguments: [
        "tests", "create",
        "--config", configPath,
        "--id", "TEST-9701-001",
        "--title", "Canonical test create",
        "--objective", "Persist a canonical test record.",
        "--kind", "unit",
        "--status", "ready",
        "--requirement", "REQ-9701",
        "--step", "Run the create command.",
        "--expected", "The record is saved.",
        "--automation-command", "swift test --package-path AICockpit",
        "--artifact", "docs/generated/Requirements/Requirements-Traceability-Matrix.md",
        "--note", "Initial seeded definition.",
        "--output", "json"
    ])
    let updated = AICockpitCommand.response(arguments: [
        "tests", "update", "TEST-9701-001",
        "--config", configPath,
        "--title", "Canonical test create updated",
        "--objective", "Persist updated canonical test metadata.",
        "--status", "active",
        "--note", "Updated via CLI regression test.",
        "--output", "json"
    ])
    let saved = try repository.store.load(AirframeCanonicalTestRecord.self, id: AirframeID("TEST-9701-001"))

    #expect(created.exitCode == 0)
    #expect(created.standardOutput.contains("\"kind\" : \"canonicalTestCreation\""))
    #expect(created.standardOutput.contains("\"status\" : \"ready\""))
    #expect(updated.exitCode == 0)
    #expect(updated.standardOutput.contains("\"kind\" : \"canonicalTestUpdate\""))
    #expect(updated.standardOutput.contains("Canonical test create updated"))
    #expect(saved?.title == "Canonical test create updated")
    #expect(saved?.objective == "Persist updated canonical test metadata.")
    #expect(saved?.status == .active)
    #expect(saved?.requirementIDs == [AirframeID("REQ-9701")])
}

@Test func acceptanceCriteriaSuitesEpicReadinessAndIssueDetailsUseAICockpitCommands() throws {
    let configPath = try temporaryCanonicalTestConfigurationPath()
    let rootURL = URL(filePath: configPath).deletingLastPathComponent()
    let repository = AirframeCanonicalStoreRepository(rootURL: rootURL)
    try repository.store.save(
        AirframeCanonicalProjectRecord(
            id: AirframeID("PRJ-AIRFRAME"),
            name: "Agile Airframe",
            repository: "justgus/Airframe",
            activeEpicID: AirframeID("EP-9702")
        )
    )
    try repository.store.save(
        AirframeCanonicalEpicRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("EP-9702"),
                kind: .epic,
                title: "AICockpit coverage commands",
                status: .active
            ),
            owner: "Airframe",
            goal: "Manage coverage through AICockpit.",
            rationale: "Agents should not edit canonical JSON directly."
        )
    )
    try repository.store.save(
        AirframeCanonicalRequirementRecord(
            id: AirframeID("REQ-9702"),
            title: "Coverage command requirement",
            statement: "AICockpit shall manage Epic acceptance coverage.",
            status: .active
        )
    )

    let criterion = AICockpitCommand.response(arguments: [
        "acceptance-criteria", "create",
        "--config", configPath,
        "--id", "EP-9702-AC-01",
        "--owner", "EP-9702",
        "--text", "Epic coverage is managed through AICockpit.",
        "--output", "json"
    ])
    let test = AICockpitCommand.response(arguments: [
        "tests", "create",
        "--config", configPath,
        "--id", "TEST-9702-001",
        "--title", "Coverage command test",
        "--objective", "Verify coverage links.",
        "--kind", "acceptance",
        "--status", "ready",
        "--requirement", "REQ-9702",
        "--acceptance-criterion", "EP-9702-AC-01",
        "--work-item", "EP-9702",
        "--output", "json"
    ])
    let suite = AICockpitCommand.response(arguments: [
        "test-suites", "create",
        "--config", configPath,
        "--id", "TS-9702-001",
        "--title", "Coverage command suite",
        "--objective", "Group coverage command tests.",
        "--status", "ready",
        "--test", "TEST-9702-001",
        "--requirement", "REQ-9702",
        "--acceptance-criterion", "EP-9702-AC-01",
        "--output", "json"
    ])
    let coverage = AICockpitCommand.response(arguments: [
        "epic", "coverage", "EP-9702",
        "--config", configPath,
        "--output", "json"
    ])
    let readiness = AICockpitCommand.response(arguments: [
        "epic", "ready", "EP-9702",
        "--config", configPath,
        "--output", "json"
    ])
    let issue = AICockpitCommand.response(arguments: [
        "issue", "create",
        "--config", configPath,
        "--backend", "canonical",
        "--id", "I-9702",
        "--title", "Issue details through AICockpit",
        "--status", "active",
        "--epic", "EP-9702",
        "--observed", "Issue details previously required direct JSON edits.",
        "--expected", "AICockpit persists issue detail fields.",
        "--repro", "Create a detailed issue through AICockpit.",
        "--component", "AICockpit",
        "--note", "Regression coverage for I-0027.",
        "--output", "json"
    ])
    let export = AICockpitCommand.response(arguments: [
        "state", "export-markdown",
        "--config", configPath
    ])

    let savedEpic = try repository.store.load(AirframeCanonicalEpicRecord.self, id: AirframeID("EP-9702"))
    let savedSuite = try repository.store.load(AirframeCanonicalTestSuiteRecord.self, id: AirframeID("TS-9702-001"))
    let savedIssue = try repository.store.load(AirframeCanonicalIssueRecord.self, id: AirframeID("I-9702"))
    let epicProjection = try String(
        contentsOf: rootURL.appending(path: "docs/generated/Epics/EP-9702.md"),
        encoding: .utf8
    )

    #expect(criterion.exitCode == 0)
    #expect(criterion.standardOutput.contains("\"kind\" : \"canonicalAcceptanceCriterionCreation\""))
    #expect(test.exitCode == 0)
    #expect(suite.exitCode == 0)
    #expect(suite.standardOutput.contains("\"kind\" : \"canonicalTestSuiteCreation\""))
    #expect(coverage.exitCode == 0)
    #expect(coverage.standardOutput.contains("\"kind\" : \"canonicalEpicCoverage\""))
    #expect(coverage.standardOutput.contains("\"isReady\" : true"))
    #expect(readiness.exitCode == 0)
    #expect(readiness.standardOutput.contains("\"kind\" : \"canonicalEpicReadiness\""))
    #expect(issue.exitCode == 0)
    #expect(savedEpic?.acceptanceCriterionIDs == [AirframeID("EP-9702-AC-01")])
    #expect(savedSuite?.testIDs == [AirframeID("TEST-9702-001")])
    #expect(savedIssue?.observedBehavior == "Issue details previously required direct JSON edits.")
    #expect(savedIssue?.expectedBehavior == "AICockpit persists issue detail fields.")
    #expect(savedIssue?.reproductionSteps == ["Create a detailed issue through AICockpit."])
    #expect(savedIssue?.affectedComponents == ["AICockpit"])
    #expect(savedIssue?.notes == ["Regression coverage for I-0027."])
    #expect(export.exitCode == 0)
    #expect(epicProjection.contains("**Acceptance Criteria:**"))
    #expect(epicProjection.contains("EP-9702-AC-01: Epic coverage is managed through AICockpit."))
}

@Test func stateExportMarkdownProjectsRequirementReportsAndReturns() throws {
    let configPath = try temporaryCanonicalRequirementsConfigurationPath()
    let rootURL = URL(filePath: configPath).deletingLastPathComponent()
    let store = AirframeCanonicalJSONStore(rootURL: rootURL)
    try store.save(
        AirframeCanonicalTaskRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("T-9700"),
                kind: .task,
                title: "Export Markdown regression",
                status: .active
            ),
            component: "AICockpit",
            priority: .high,
            rationale: "Export should finish after projecting requirement reports.",
            requirementIDs: [AirframeID("REQ-9700")]
        )
    )
    try store.save(
        AirframeCanonicalRequirementRecord(
            id: AirframeID("REQ-9700"),
            title: "Markdown export completes",
            statement: "AICockpit shall export generated Markdown projections and exit.",
            status: .implemented,
            traceLinks: [
                AirframeRequirementLink(
                    id: AirframeID("LINK-REQ-9700-T-9700"),
                    targetKind: AirframeRequirementTraceTargetKind.task.rawValue,
                    targetID: "T-9700"
                )
            ]
        )
    )

    let result = AICockpitCommand.response(arguments: [
        "state", "export-markdown",
        "--config", configPath
    ])
    let taskProjection = try String(
        contentsOf: rootURL.appending(path: "docs/generated/Tasks/T-9700.md"),
        encoding: .utf8
    )
    let requirementProjection = try String(
        contentsOf: rootURL.appending(path: "docs/generated/Requirements/Requirements-Traceability-Matrix.md"),
        encoding: .utf8
    )

    #expect(result.exitCode == 0)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("canonicalMarkdownExport"))
    #expect(taskProjection.contains("T-9700"))
    #expect(requirementProjection.contains("REQ-9700"))
}

@Test func artifactManagementCommandsListInspectLinkAndReportGaps() throws {
    let configPath = try temporaryCanonicalTestConfigurationPath()
    let rootURL = URL(filePath: configPath).deletingLastPathComponent()
    let repository = AirframeCanonicalStoreRepository(rootURL: rootURL)
    try repository.store.save(
        AirframeCanonicalProjectRecord(
            id: AirframeID("PRJ-AIRFRAME"),
            name: "Agile Airframe",
            repository: "justgus/Airframe",
            epicIDs: [AirframeID("EP-9728")],
            sprintIDs: [AirframeID("SP-9728")],
            taskIDs: [AirframeID("T-9728")]
        )
    )
    try repository.store.save(
        AirframeCanonicalEpicRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("EP-9728"),
                kind: .epic,
                title: "Artifact management",
                status: .active
            ),
            owner: "Airframe",
            goal: "Manage artifact links from AICockpit.",
            rationale: "Agents should not edit canonical JSON directly."
        )
    )
    try repository.store.save(
        AirframeCanonicalSprintRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("SP-9728"),
                kind: .sprint,
                title: "Artifact management sprint",
                status: .active
            ),
            epicID: AirframeID("EP-9728"),
            goal: "Exercise management commands."
        )
    )
    try repository.store.save(
        AirframeCanonicalTaskRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("T-9728"),
                kind: .task,
                title: "Linkable artifact task",
                status: .active
            ),
            component: "AICockpit",
            priority: .medium,
            rationale: "AICockpit should link tasks to traceability records."
        )
    )
    try repository.store.save(
        AirframeCanonicalRequirementRecord(
            id: AirframeID("REQ-9728"),
            title: "Artifact links",
            statement: "AICockpit shall manage work-product traceability links.",
            status: .active
        )
    )
    try repository.store.save(
        AirframeCanonicalTestRecord(
            id: AirframeID("TEST-9728"),
            title: "Artifact command test",
            objective: "Verify artifact link commands.",
            kind: .regression,
            status: .ready
        )
    )

    let gapsBefore = AICockpitCommand.response(arguments: [
        "task", "gaps",
        "--config", configPath,
        "--output", "json"
    ])
    let link = AICockpitCommand.response(arguments: [
        "task", "link", "T-9728",
        "--config", configPath,
        "--epic", "EP-9728",
        "--sprint", "SP-9728",
        "--requirement", "REQ-9728",
        "--test", "TEST-9728",
        "--output", "json"
    ])
    let inspect = AICockpitCommand.response(arguments: [
        "task", "inspect", "T-9728",
        "--config", configPath,
        "--output", "json"
    ])
    let list = AICockpitCommand.response(arguments: [
        "task", "list",
        "--config", configPath,
        "--output", "json"
    ])
    let savedTask = try repository.store.load(AirframeCanonicalTaskRecord.self, id: AirframeID("T-9728"))
    let savedTest = try repository.store.load(AirframeCanonicalTestRecord.self, id: AirframeID("TEST-9728"))

    #expect(gapsBefore.exitCode == 0)
    #expect(gapsBefore.standardOutput.contains("T-9728 has no requirement links."))
    #expect(gapsBefore.standardOutput.contains("T-9728 has no linked tests."))
    #expect(link.exitCode == 0)
    #expect(link.standardOutput.contains("\"kind\" : \"taskLinks\""))
    #expect(inspect.exitCode == 0)
    #expect(inspect.standardOutput.contains("\"requirementIDs\" : ["))
    #expect(inspect.standardOutput.contains("\"REQ-9728\""))
    #expect(inspect.standardOutput.contains("\"TEST-9728\""))
    #expect(list.exitCode == 0)
    #expect(list.standardOutput.contains("\"kind\" : \"taskList\""))
    #expect(list.standardOutput.contains("\"T-9728\""))
    #expect(savedTask?.epicID == AirframeID("EP-9728"))
    #expect(savedTask?.sprintID == AirframeID("SP-9728"))
    #expect(savedTask?.requirementIDs == [AirframeID("REQ-9728")])
    #expect(savedTest?.workItemIDs == [AirframeID("T-9728")])
}

@Test func githubConfiguredCanonicalSprintAndEpicWorkflowCommandsStayLocalOffline() throws {
    let configPath = try temporaryGitHubConfigurationWithCanonicalStatePath()
    let rootURL = URL(filePath: configPath).deletingLastPathComponent()
    let repository = AirframeCanonicalStoreRepository(rootURL: rootURL)
    try repository.store.save(
        AirframeCanonicalProjectRecord(
            id: AirframeID("PRJ-AIRFRAME"),
            name: "Agile Airframe",
            repository: "justgus/Airframe"
        )
    )

    let epicCreate = AICockpitCommand.response(arguments: [
        "epic", "create",
        "--config", configPath,
        "--id", "EP-9600",
        "--title", "Offline Epic workflow",
        "--status", "proposed",
        "--scope", "Exercise local Epic workflow transitions.",
        "--output", "json"
    ])
    let sprintCreate = AICockpitCommand.response(arguments: [
        "sprint", "create",
        "--config", configPath,
        "--id", "SP-9600",
        "--title", "Offline Sprint workflow",
        "--status", "backlog",
        "--epic", "EP-9600",
        "--scope", "Exercise local Sprint workflow transitions.",
        "--output", "json"
    ])
    let sprintPlanning = AICockpitCommand.response(arguments: [
        "sprint", "status", "SP-9600",
        "--config", configPath,
        "--to", "planning",
        "--output", "json"
    ])
    let sprintActive = AICockpitCommand.response(arguments: [
        "sprint", "status", "SP-9600",
        "--config", configPath,
        "--to", "active",
        "--output", "json"
    ])
    let sprintReview = AICockpitCommand.response(arguments: [
        "sprint", "status", "SP-9600",
        "--config", configPath,
        "--to", "review",
        "--output", "json"
    ])
    let epicDraft = AICockpitCommand.response(arguments: [
        "epic", "status", "EP-9600",
        "--config", configPath,
        "--to", "draft",
        "--output", "json"
    ])
    let epicBacklog = AICockpitCommand.response(arguments: [
        "epic", "status", "EP-9600",
        "--config", configPath,
        "--to", "backlog",
        "--output", "json"
    ])
    let epicActive = AICockpitCommand.response(arguments: [
        "epic", "status", "EP-9600",
        "--config", configPath,
        "--to", "active",
        "--output", "json"
    ])
    let epicComplete = AICockpitCommand.response(arguments: [
        "epic", "status", "EP-9600",
        "--config", configPath,
        "--to", "complete",
        "--output", "json"
    ])
    let deniedSprintClose = AICockpitCommand.response(arguments: [
        "sprint", "status", "SP-9600",
        "--config", configPath,
        "--to", "closed",
        "--output", "json"
    ])
    let deniedEpicClose = AICockpitCommand.response(arguments: [
        "epic", "status", "EP-9600",
        "--config", configPath,
        "--to", "closed",
        "--output", "json"
    ])
    let export = AICockpitCommand.response(arguments: [
        "state", "export-markdown",
        "--config", configPath
    ])

    let sprint = try repository.store.load(AirframeCanonicalSprintRecord.self, id: AirframeID("SP-9600"))
    let epic = try repository.store.load(AirframeCanonicalEpicRecord.self, id: AirframeID("EP-9600"))
    let project = try repository.store.load(AirframeCanonicalProjectRecord.self, id: AirframeID("PRJ-AIRFRAME"))
    let sprintProjection = try String(
        contentsOf: rootURL.appending(path: "docs/generated/Sprints/SP-9600.md"),
        encoding: .utf8
    )
    let epicProjection = try String(
        contentsOf: rootURL.appending(path: "docs/generated/Epics/EP-9600.md"),
        encoding: .utf8
    )

    #expect(epicCreate.exitCode == 0)
    #expect(epicCreate.standardOutput.contains("\"backendKind\" : \"canonical\""))
    #expect(epicCreate.standardOutput.contains("\"supportsGitHubIssues\" : false"))
    #expect(sprintCreate.exitCode == 0)
    #expect(sprintPlanning.exitCode == 0)
    #expect(sprintActive.exitCode == 0)
    #expect(sprintReview.exitCode == 0)
    #expect(epicDraft.exitCode == 0)
    #expect(epicBacklog.exitCode == 0)
    #expect(epicActive.exitCode == 0)
    #expect(epicComplete.exitCode == 0)
    #expect(deniedSprintClose.exitCode == 64)
    #expect(deniedSprintClose.standardOutput.contains("sprint closure is human-only"))
    #expect(deniedEpicClose.exitCode == 64)
    #expect(deniedEpicClose.standardOutput.contains("epic closure is human-only"))
    #expect(export.exitCode == 0)
    #expect(export.standardOutput.contains("canonicalMarkdownExport"))
    #expect(sprint?.workItem.status == .review)
    #expect(epic?.workItem.status == .complete)
    #expect(project?.activeSprintID == AirframeID("SP-9600"))
    #expect(project?.activeEpicID == nil)
    #expect(project?.epicIDs.contains(AirframeID("EP-9600")) == true)
    #expect(sprintProjection.contains("**Status:** Review"))
    #expect(epicProjection.contains("**Status:** Complete"))
}

@Test func stateImportMarkdownSeedsCanonicalRequirementsFromRequirementDocs() throws {
    let configPath = try temporaryCanonicalRequirementsConfigurationPath()
    let rootURL = URL(filePath: configPath).deletingLastPathComponent()
    let requirementsDirectory = rootURL.appending(path: "docs/requirements")
    try FileManager.default.createDirectory(at: requirementsDirectory, withIntermediateDirectories: true)
    try Data(
        """
        # Requirements Traceability Requirements

        ## 3. Functional Requirements

        ### RT-FR-001 Requirement Records

        Airframe shall maintain canonical requirement records with stable IDs.

        ### RT-FR-002 Requirement Revision State

        Airframe shall support requirement revision metadata, including status, source, version, rationale, and change history.
        """.utf8
    ).write(to: requirementsDirectory.appending(path: "RequirementsTraceability_Requirements.md"))

    let result = AICockpitCommand.response(arguments: [
        "state", "import-markdown",
        "--config", configPath
    ])

    let store = AirframeCanonicalJSONStore(rootURL: rootURL)
    let requirement1 = try store.load(AirframeCanonicalRequirementRecord.self, id: AirframeID("RT-FR-001"))
    let requirement2 = try store.load(AirframeCanonicalRequirementRecord.self, id: AirframeID("RT-FR-002"))

    #expect(result.exitCode == 0)
    #expect(result.standardOutput.contains("requirements: 2"))
    #expect(requirement1?.title == "Requirement Records")
    #expect(requirement2?.title == "Requirement Revision State")
    #expect(requirement1?.sourceURI?.contains("RequirementsTraceability_Requirements.md") == true)
    #expect(requirement2?.sourceURI?.contains("RequirementsTraceability_Requirements.md") == true)
}

@Test func unknownCommandReturnsUsageError() {
    #expect(AICockpitCommand.main(arguments: ["unknown"]) == 64)
}

@Test func unknownCommandReturnsJSONErrorEnvelope() {
    let result = AICockpitCommand.response(arguments: ["unknown", "--output", "json"])

    #expect(result.exitCode == 64)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("\"status\" : \"error\""))
    #expect(result.standardOutput.contains("\"code\" : \"unknownCommand\""))
    #expect(result.standardOutput.contains("\"message\" : \"unknown command\""))
}

@Test func contextCommandReturnsCurrentProjectContext() {
    let result = AICockpitCommand.response(arguments: ["context"])

    #expect(result.exitCode == 0)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("Airframe Context"))
    #expect(result.standardOutput.contains("Workspace: Airframe (WS-AIRFRAME)"))
    #expect(result.standardOutput.contains("Project: Agile Airframe (PRJ-AIRFRAME)"))
    #expect(result.standardOutput.contains("Active Sprint: None"))
}

@Test func contextCommandSupportsExplicitRuntimeConfiguration() throws {
    let config = try temporaryLiveConfigurationPath()

    let result = AICockpitCommand.response(arguments: [
        "context",
        "--config", config
    ])

    #expect(result.exitCode == 0)
    #expect(result.standardOutput.contains("Workspace: Airframe Live Demo (WS-AIRFRAME-LIVE)"))
    #expect(result.standardOutput.contains("Project: Agile Airframe (PRJ-AIRFRAME)"))
    #expect(result.standardOutput.contains("Repository: justgus/Airframe"))
    #expect(result.standardOutput.contains("Active Epic: EP-009"))
    #expect(result.standardOutput.contains("Active Sprint: SP-009"))
}

@Test func contextCommandPrefersCanonicalProjectActiveSprintWhenStateExists() throws {
    let config = try temporaryLiveConfigurationPath()
    let rootURL = URL(filePath: config).deletingLastPathComponent()
    let store = AirframeCanonicalJSONStore(rootURL: rootURL)
    try store.save(
        AirframeCanonicalProjectRecord(
            id: AirframeID("PRJ-AIRFRAME"),
            name: "Agile Airframe",
            repository: "justgus/Airframe",
            activeEpicID: AirframeID("EP-021"),
            activeSprintID: AirframeID("SP-032"),
            sprintIDs: [AirframeID("SP-032")]
        )
    )

    let result = AICockpitCommand.response(arguments: [
        "context",
        "--config", config
    ])

    #expect(result.exitCode == 0)
    #expect(result.standardOutput.contains("Active Epic: EP-021"))
    #expect(result.standardOutput.contains("Active Sprint: SP-032"))
    #expect(!result.standardOutput.contains("Active Sprint: SP-009"))
}

@Test func configDiagnoseSupportsExplicitRuntimeConfiguration() throws {
    let config = try temporaryLiveConfigurationPath()

    let result = AICockpitCommand.response(arguments: [
        "config", "diagnose",
        "--config", config,
        "--output", "json"
    ])

    #expect(result.exitCode == 0)
    #expect(result.standardOutput.contains("\"workspaceID\" : {"))
    #expect(result.standardOutput.contains("\"rawValue\" : \"WS-AIRFRAME-LIVE\""))
    #expect(result.standardOutput.contains("\"backendKind\" : \"github-fixture\""))
    #expect(result.standardOutput.contains("\"backendLocation\" : \"justgus\\/Airframe\""))
}

@Test func deniedAuthorityCommandReturnsReasonCode() {
    let result = AICockpitCommand.response(arguments: ["authority", "demo-denied"])

    #expect(result.exitCode == 77)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("status: denied"))
    #expect(result.standardOutput.contains("reason: authorityClassNotPermitted"))
    #expect(result.standardOutput.contains("operation: OP-ACCEPT-WORK"))
}

@Test func taskProposeCreatesLocalTaskAndMarkdownOutput() {
    let store = temporaryStorePath()

    let result = AICockpitCommand.response(arguments: [
        "task", "propose",
        "--store", store,
        "--id", "T-9001",
        "--title", "Implement command parser",
        "--acceptance", "Parser tests pass",
        "--scope", "AICockpitKit",
        "--constraint", "Keep executable target thin",
        "--evidence-required", "swift test --package-path AICockpit",
        "--protected-path", "docs/Tasks/Verified"
    ])

    #expect(result.exitCode == 0)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("kind: taskProposal"))
    #expect(result.standardOutput.contains("id: T-9001"))
    #expect(result.standardOutput.contains("status: Active"))
}

@Test func issueProposeSupportsJSONOutput() {
    let store = temporaryStorePath()
    let refreshNotifier = SpyRefreshNotifier()

    let result = AICockpitCommand.response(arguments: [
        "issue", "propose",
        "--store", store,
        "--id", "I-9001",
        "--title", "Unexpected local backend failure",
        "--output", "json"
    ], refreshNotifier: refreshNotifier)

    #expect(result.exitCode == 0)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("\"kind\" : \"issueProposal\""))
    #expect(result.standardOutput.contains("\"rawValue\" : \"I-9001\""))
    #expect(refreshNotifier.postCount == 1)
}

@Test func readOnlyCommandDoesNotPostRefreshNotification() {
    let refreshNotifier = SpyRefreshNotifier()

    let result = AICockpitCommand.response(arguments: [
        "project", "summary",
        "--store", temporaryStorePath()
    ], refreshNotifier: refreshNotifier)

    #expect(result.exitCode == 0)
    #expect(refreshNotifier.postCount == 0)
}

@Test func failedMutationDoesNotPostRefreshNotification() {
    let refreshNotifier = SpyRefreshNotifier()

    let result = AICockpitCommand.response(arguments: [
        "task", "propose",
        "--store", temporaryStorePath(),
        "--id", "T-9005"
    ], refreshNotifier: refreshNotifier)

    #expect(result.exitCode == 64)
    #expect(refreshNotifier.postCount == 0)
}

@Test func taskNextReturnsFirstActiveTask() {
    let store = temporaryStorePath()
    _ = AICockpitCommand.response(arguments: [
        "task", "propose",
        "--store", store,
        "--id", "T-9002",
        "--title", "Implement next task command"
    ])

    let result = AICockpitCommand.response(arguments: [
        "task", "next",
        "--store", store
    ])

    #expect(result.exitCode == 0)
    #expect(result.standardOutput.contains("kind: nextTask"))
    #expect(result.standardOutput.contains("id: T-9002"))
}

@Test func taskPacketIncludesRequiredSections() {
    let store = temporaryStorePath()
    _ = AICockpitCommand.response(arguments: [
        "task", "propose",
        "--store", store,
        "--id", "T-9003",
        "--title", "Implement task packet command",
        "--acceptance", "Task packet includes acceptance criteria",
        "--scope", "AICockpitKit",
        "--constraint", "Use AirframeCore packet data",
        "--evidence-required", "AICockpit tests pass"
    ])

    let result = AICockpitCommand.response(arguments: [
        "task", "packet", "T-9003",
        "--store", store
    ])

    #expect(result.exitCode == 0)
    #expect(result.standardOutput.contains("## Task Packet"))
    #expect(result.standardOutput.contains("### Acceptance Criteria"))
    #expect(result.standardOutput.contains("Task packet includes acceptance criteria"))
    #expect(result.standardOutput.contains("Use AirframeCore packet data"))
}

@Test func evidenceAttachAndWorkReadyUpdateLocalTask() {
    let store = temporaryStorePath()
    _ = AICockpitCommand.response(arguments: [
        "task", "propose",
        "--store", store,
        "--id", "T-9004",
        "--title", "Implement evidence command"
    ])

    let evidence = AICockpitCommand.response(arguments: [
        "evidence", "attach", "T-9004",
        "--store", store,
        "--id", "EV-9004-001",
        "--summary", "AICockpit tests passed",
        "--artifact", "swift test --package-path AICockpit"
    ])
    let ready = AICockpitCommand.response(arguments: [
        "work", "ready", "T-9004",
        "--store", store,
        "--output", "json"
    ])

    #expect(evidence.exitCode == 0)
    #expect(evidence.standardOutput.contains("Evidence attached"))
    #expect(ready.exitCode == 0)
    #expect(ready.standardOutput.contains("\"kind\" : \"readyForVerification\""))
    #expect(ready.standardOutput.contains("\"status\" : \"implementedNotVerified\""))
    #expect(ready.standardOutput.contains("EV-9004-001"))
}

@Test func githubFixtureBackendWorksThroughCanonicalCommands() {
    let store = temporaryStorePath()
    let proposed = AICockpitCommand.response(arguments: [
        "task", "propose",
        "--backend", "github-fixture",
        "--store", store,
        "--id", "T-9039",
        "--title", "Integrate GitHub backend with AICockpit",
        "--github", "39"
    ])
    let summary = AICockpitCommand.response(arguments: [
        "project", "summary",
        "--backend", "github-fixture",
        "--store", store,
        "--output", "json"
    ])

    #expect(proposed.exitCode == 0)
    #expect(proposed.standardOutput.contains("backend: github-fixture"))
    #expect(proposed.standardOutput.contains("githubIssues: supported"))
    #expect(summary.exitCode == 0)
    #expect(summary.standardOutput.contains("\"backendKind\" : \"github-fixture\""))
    #expect(summary.standardOutput.contains("\"supportsGitHubIssues\" : true"))
    #expect(summary.standardOutput.contains("\"activeTaskCount\" : 1"))
    #expect(summary.standardOutput.contains("\"rawValue\" : \"T-9039\""))
}

@Test func localTaskCreateUpdateAndStatusCommandsMutateRecord() {
    let store = temporaryStorePath()
    let created = AICockpitCommand.response(arguments: [
        "task", "create",
        "--store", store,
        "--id", "T-9101",
        "--title", "Create local task",
        "--status", "backlog",
        "--epic", "EP-017",
        "--sprint", "SP-018",
        "--priority", "high",
        "--output", "json"
    ])
    let activated = AICockpitCommand.response(arguments: [
        "task", "status", "T-9101",
        "--store", store,
        "--to", "active",
        "--output", "json"
    ])
    let updated = AICockpitCommand.response(arguments: [
        "task", "update", "T-9101",
        "--store", store,
        "--title", "Updated local task",
        "--priority", "low",
        "--acceptance", "Updated acceptance",
        "--output", "json"
    ])
    let packet = AICockpitCommand.response(arguments: [
        "task", "packet", "T-9101",
        "--store", store,
        "--output", "json"
    ])

    #expect(created.exitCode == 0)
    #expect(created.standardOutput.contains("\"kind\" : \"taskCreation\""))
    #expect(created.standardOutput.contains("\"status\" : \"backlog\""))
    #expect(activated.exitCode == 0)
    #expect(activated.standardOutput.contains("\"status\" : \"active\""))
    #expect(updated.exitCode == 0)
    #expect(updated.standardOutput.contains("Updated local task"))
    #expect(packet.standardOutput.contains("Updated acceptance"))
}

@Test func localIssueCreateUpdateAndStatusCommandsMutateRecord() {
    let store = temporaryStorePath()
    let created = AICockpitCommand.response(arguments: [
        "issue", "create",
        "--store", store,
        "--id", "I-9101",
        "--title", "Create local issue",
        "--severity", "high"
    ])
    let activated = AICockpitCommand.response(arguments: [
        "issue", "status", "I-9101",
        "--store", store,
        "--to", "active"
    ])
    let resolved = AICockpitCommand.response(arguments: [
        "issue", "status", "I-9101",
        "--store", store,
        "--to", "resolved",
        "--output", "json"
    ])

    #expect(created.exitCode == 0)
    #expect(created.standardOutput.contains("kind: issueCreation"))
    #expect(activated.exitCode == 0)
    #expect(resolved.exitCode == 0)
    #expect(resolved.standardOutput.contains("\"status\" : \"implementedNotVerified\""))
}

@Test func localSprintAndEpicPlanningCreateCommandsAreSupported() {
    let store = temporaryStorePath()
    let sprint = AICockpitCommand.response(arguments: [
        "sprint", "create",
        "--store", store,
        "--id", "SP-9101",
        "--title", "Planning sprint",
        "--status", "planning",
        "--epic", "EP-017",
        "--output", "json"
    ])
    let epic = AICockpitCommand.response(arguments: [
        "epic", "create",
        "--store", store,
        "--id", "EP-9101",
        "--title", "Planning epic",
        "--status", "draft",
        "--output", "json"
    ])

    #expect(sprint.exitCode == 0)
    #expect(sprint.standardOutput.contains("\"kind\" : \"sprintCreation\""))
    #expect(sprint.standardOutput.contains("\"status\" : \"planning\""))
    #expect(epic.exitCode == 0)
    #expect(epic.standardOutput.contains("\"kind\" : \"epicCreation\""))
    #expect(epic.standardOutput.contains("\"status\" : \"draft\""))
}

@Test func aicockpitRejectsHumanOnlyStatusCommands() {
    let store = temporaryStorePath()
    _ = AICockpitCommand.response(arguments: [
        "task", "create",
        "--store", store,
        "--id", "T-9102",
        "--title", "Human only task",
        "--status", "active"
    ])

    let verified = AICockpitCommand.response(arguments: [
        "task", "status", "T-9102",
        "--store", store,
        "--to", "verified",
        "--output", "json"
    ])
    let closed = AICockpitCommand.response(arguments: [
        "sprint", "create",
        "--store", store,
        "--id", "SP-9102",
        "--title", "Human only sprint",
        "--status", "closed",
        "--output", "json"
    ])

    #expect(verified.exitCode == 64)
    #expect(verified.standardOutput.contains("verification is human-only"))
    #expect(closed.exitCode == 64)
    #expect(closed.standardOutput.contains("closure is human-only"))
}

@Test func updateStatusRejectsInvalidWorkflowTransitionWithoutMutation() {
    let store = temporaryStorePath()
    _ = AICockpitCommand.response(arguments: [
        "task", "create",
        "--store", store,
        "--id", "T-9103",
        "--title", "Invalid transition task",
        "--status", "backlog"
    ])

    let result = AICockpitCommand.response(arguments: [
        "task", "update", "T-9103",
        "--store", store,
        "--status", "implemented",
        "--output", "json"
    ])
    let packet = AICockpitCommand.response(arguments: [
        "task", "packet", "T-9103",
        "--store", store,
        "--output", "json"
    ])

    #expect(result.exitCode == 78)
    #expect(result.standardOutput.contains("Invalid workflow transition"))
    #expect(packet.standardOutput.contains("\"status\" : \"backlog\""))
}

@Test func issueStatusAllowsResolvedRollbackTransitions() {
    let store = temporaryStorePath()
    _ = AICockpitCommand.response(arguments: [
        "issue", "create",
        "--store", store,
        "--id", "I-9029",
        "--title", "Rollback issue",
        "--status", "active"
    ])
    let resolved = AICockpitCommand.response(arguments: [
        "issue", "status", "I-9029",
        "--store", store,
        "--to", "resolved",
        "--output", "json"
    ])
    let active = AICockpitCommand.response(arguments: [
        "issue", "status", "I-9029",
        "--store", store,
        "--to", "active",
        "--output", "json"
    ])
    _ = AICockpitCommand.response(arguments: [
        "issue", "status", "I-9029",
        "--store", store,
        "--to", "resolved"
    ])
    let backlog = AICockpitCommand.response(arguments: [
        "issue", "status", "I-9029",
        "--store", store,
        "--to", "backlog",
        "--output", "json"
    ])

    #expect(resolved.exitCode == 0)
    #expect(resolved.standardOutput.contains("\"status\" : \"implementedNotVerified\""))
    #expect(active.exitCode == 0)
    #expect(active.standardOutput.contains("\"status\" : \"active\""))
    #expect(backlog.exitCode == 0)
    #expect(backlog.standardOutput.contains("\"status\" : \"backlog\""))
}

@Test func githubIssuesBackendRequiresApprovalForLegacyProposeMutation() {
    let result = AICockpitCommand.response(arguments: [
        "task", "propose",
        "--backend", "github-issues",
        "--id", "T-9054",
        "--title", "Attempt read-only mutation",
        "--output", "json"
    ])

    #expect(result.exitCode == 78)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("\"code\" : \"backendCommandFailed\""))
    #expect(result.standardOutput.contains("requires confirmation"))
}

@Test func githubIssueCommentRequiresExplicitApprovalBeforeLiveLookup() {
    let result = AICockpitCommand.response(arguments: [
        "github", "comment", "T-0067",
        "--backend", "github-issues",
        "--body", "Evidence is ready.",
        "--output", "json"
    ])

    #expect(result.exitCode == 78)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("\"code\" : \"backendCommandFailed\""))
    #expect(result.standardOutput.contains("requires confirmation"))
}

@Test func githubIssueCreateRequiresExplicitApprovalBeforeLiveMutation() {
    let result = AICockpitCommand.response(arguments: [
        "task", "create",
        "--backend", "github-issues",
        "--id", "T-9104",
        "--title", "Attempt unapproved live create",
        "--output", "json"
    ])

    #expect(result.exitCode == 78)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("\"code\" : \"backendCommandFailed\""))
    #expect(result.standardOutput.contains("requires confirmation"))
}

@Test func taskProposalUsesRuntimeConfigSprintEpicDefaultsAndStore() throws {
    let config = try temporaryLiveConfigurationPath()
    let store = temporaryStorePath()
    let proposed = AICockpitCommand.response(arguments: [
        "task", "propose",
        "--config", config,
        "--store", store,
        "--id", "T-9047",
        "--title", "Use runtime config defaults"
    ])
    let packet = AICockpitCommand.response(arguments: [
        "task", "packet", "T-9047",
        "--config", config,
        "--store", store
    ])

    #expect(proposed.exitCode == 0)
    #expect(packet.exitCode == 0)
    #expect(packet.standardOutput.contains("Use runtime config defaults"))
}

@Test func missingRequiredOptionReturnsUsageError() {
    let result = AICockpitCommand.response(arguments: [
        "task", "propose",
        "--store", temporaryStorePath(),
        "--id", "T-9005"
    ])

    #expect(result.exitCode == 64)
    #expect(result.standardError.contains("missing required option --title"))
}

@Test func invalidBackendReturnsJSONErrorEnvelope() {
    let result = AICockpitCommand.response(arguments: [
        "project", "summary",
        "--backend", "unknown-backend",
        "--output", "json"
    ])

    #expect(result.exitCode == 64)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("\"status\" : \"error\""))
    #expect(result.standardOutput.contains("\"code\" : \"invalidArguments\""))
    #expect(result.standardOutput.contains("unsupported backend unknown-backend"))
}

private func temporaryStorePath() -> String {
    FileManager.default.temporaryDirectory
        .appending(path: "AICockpitKitTests")
        .appending(path: UUID().uuidString)
        .appending(path: "airframe-local-backend.json")
        .path
}

private func temporaryLiveConfigurationPath() throws -> String {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AICockpitLiveConfig")
        .appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
    let configURL = rootURL.appending(path: "airframe-workspace.json")
    try Data(
        """
        {
          "schemaVersion": 1,
          "workspace": {
            "id": { "rawValue": "WS-AIRFRAME-LIVE" },
            "name": "Airframe Live Demo",
            "rootPath": "."
          },
          "projects": [
            {
              "id": { "rawValue": "PRJ-AIRFRAME" },
              "name": "Agile Airframe",
              "repository": "justgus/Airframe",
              "activeSprintID": { "rawValue": "SP-009" },
              "activeEpicID": { "rawValue": "EP-009" }
            }
          ],
          "defaultProjectID": { "rawValue": "PRJ-AIRFRAME" },
          "backend": {
            "kind": "github-fixture",
            "location": "justgus/Airframe"
          }
        }
        """.utf8
    ).write(to: configURL)
    return configURL.path
}

private func temporaryCanonicalTestConfigurationPath() throws -> String {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AICockpitCanonicalTestConfig")
        .appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(
        at: rootURL.appending(path: ".airframe/state"),
        withIntermediateDirectories: true
    )
    let configURL = rootURL.appending(path: "airframe-workspace.json")
    try Data(
        """
        {
          "schemaVersion": 1,
          "workspace": {
            "id": { "rawValue": "WS-AIRFRAME-LIVE" },
            "name": "Airframe Live Demo",
            "rootPath": "."
          },
          "projects": [
            {
              "id": { "rawValue": "PRJ-AIRFRAME" },
              "name": "Agile Airframe",
              "repository": "justgus/Airframe",
              "activeSprintID": null,
              "activeEpicID": { "rawValue": "EP-9700" }
            }
          ],
          "defaultProjectID": { "rawValue": "PRJ-AIRFRAME" },
          "backend": {
            "kind": "github-fixture",
            "location": "justgus/Airframe"
          }
        }
        """.utf8
    ).write(to: configURL)
    return configURL.path
}

private func temporaryGitHubConfigurationWithCanonicalStatePath() throws -> String {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AICockpitGitHubConfigWithCanonicalState")
        .appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(
        at: rootURL.appending(path: ".airframe/state"),
        withIntermediateDirectories: true
    )
    let configURL = rootURL.appending(path: "airframe-workspace.json")
    try Data(
        """
        {
          "schemaVersion": 1,
          "workspace": {
            "id": { "rawValue": "WS-AIRFRAME-LIVE" },
            "name": "Airframe Live Demo",
            "rootPath": "."
          },
          "projects": [
            {
              "id": { "rawValue": "PRJ-AIRFRAME" },
              "name": "Agile Airframe",
              "repository": "justgus/Airframe",
              "activeSprintID": { "rawValue": "SP-035" },
              "activeEpicID": { "rawValue": "EP-019" }
            }
          ],
          "defaultProjectID": { "rawValue": "PRJ-AIRFRAME" },
          "backend": {
            "kind": "github-issues",
            "location": "justgus/Airframe"
          }
        }
        """.utf8
    ).write(to: configURL)
    return configURL.path
}

private func seedCanonicalActiveOwners(
    repository: AirframeCanonicalStoreRepository,
    epicID: String,
    sprintID: String
) throws {
    try repository.store.save(
        AirframeCanonicalProjectRecord(
            id: AirframeID("PRJ-AIRFRAME"),
            name: "Agile Airframe",
            repository: "justgus/Airframe",
            activeEpicID: AirframeID(epicID),
            activeSprintID: AirframeID(sprintID),
            epicIDs: [AirframeID(epicID)],
            sprintIDs: [AirframeID(sprintID)]
        )
    )
    try repository.store.save(
        AirframeCanonicalEpicRecord(
            workItem: AirframeWorkItem(
                id: AirframeID(epicID),
                kind: .epic,
                title: "Canonical active Epic",
                status: .active
            ),
            owner: "Airframe",
            goal: "Own local-only work.",
            rationale: "Canonical state is the source of truth."
        )
    )
    try repository.store.save(
        AirframeCanonicalSprintRecord(
            workItem: AirframeWorkItem(
                id: AirframeID(sprintID),
                kind: .sprint,
                title: "Canonical active Sprint",
                status: .active
            ),
            epicID: AirframeID(epicID),
            goal: "Own local-only work."
        )
    )
}

private func temporaryCanonicalRequirementsConfigurationPath() throws -> String {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AICockpitRequirementsConfig")
        .appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
    let configURL = rootURL.appending(path: "airframe-workspace.json")
    try Data(
        """
        {
          "schemaVersion": 1,
          "workspace": {
            "id": { "rawValue": "WS-AIRFRAME-REQ" },
            "name": "Airframe Requirements Test",
            "rootPath": "."
          },
          "projects": [
            {
              "id": { "rawValue": "PRJ-AIRFRAME" },
              "name": "Agile Airframe",
              "repository": "justgus/Airframe",
              "activeSprintID": null,
              "activeEpicID": { "rawValue": "EP-021" }
            }
          ],
          "defaultProjectID": { "rawValue": "PRJ-AIRFRAME" },
          "backend": {
            "kind": "local-fixture",
            "location": "airframe-local-backend.json"
          }
        }
        """.utf8
    ).write(to: configURL)
    return configURL.path
}

private final class SpyRefreshNotifier: AICockpitRefreshNotifying {
    private(set) var postCount = 0

    func postRefresh() {
        postCount += 1
    }
}
