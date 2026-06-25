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
    #expect(help.contains("aicockpit task propose"))
    #expect(help.contains("aicockpit work ready"))
    #expect(help.contains("aicockpit github comment"))
    #expect(help.contains("--backend canonical|local-fixture|github-fixture|github-issues"))
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
