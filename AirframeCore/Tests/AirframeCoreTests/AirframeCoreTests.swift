import Testing
import AirframeCore
import Foundation

@Test func coreInfoProvidesBaselineIdentity() {
    let info = AirframeCoreInfo.current

    #expect(info.name == "AirframeCore")
    #expect(info.version == "0.1.0")
    #expect(info.summary == "AirframeCore 0.1.0")
}

@Test func refreshNotificationDefinesStableMessageContract() {
    #expect(AirframeRefreshNotification.message == "refresh")
    #expect(AirframeRefreshNotification.name.rawValue == "com.airframe.agilecockpit.refresh")
}

@Test func domainModelsProvideSharedWorkVocabulary() {
    let task = AirframeWorkItem(
        id: AirframeID("T-0007"),
        kind: .task,
        title: "Define canonical domain model",
        status: .active,
        githubIssue: 7
    )
    let evidence = AirframeEvidence(
        id: AirframeID("EV-0001"),
        summary: "Core tests passed",
        artifact: "swift test --package-path AirframeCore"
    )
    let gate = AirframeVerificationGate(
        id: AirframeID("VG-HUMAN"),
        name: "Human verification",
        requiredAuthorityClass: .humanOwner
    )

    #expect(task.id.rawValue == "T-0007")
    #expect(task.kind == .task)
    #expect(evidence.artifact.contains("AirframeCore"))
    #expect(gate.requiredAuthorityClass == .humanOwner)
}

@Test func canonicalRecordsPreserveRepoCoupledRelationships() throws {
    let epic = AirframeCanonicalEpicRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("EP-020"),
            kind: .epic,
            title: "Canonical Airframe Workflow State",
            status: .active
        ),
        owner: "Human / Airframe Planning",
        goal: "Move workflow state into canonical records.",
        rationale: "Markdown-authored state can drift.",
        startDate: "2026-06-17",
        acceptanceCriterionIDs: [AirframeID("EP-020-AC-01")],
        sprintIDs: [AirframeID("SP-025")],
        taskIDs: [AirframeID("T-0116"), AirframeID("T-0117")],
        planningDocumentPaths: ["docs/Architecture-Modification-Plan.md"]
    )
    let sprint = AirframeCanonicalSprintRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("SP-025"),
            kind: .sprint,
            title: "Canonical Store Schema and Validation",
            status: .active
        ),
        epicID: AirframeID("EP-020"),
        goal: "Define canonical store schema.",
        taskIDs: [AirframeID("T-0116"), AirframeID("T-0117")]
    )
    let task = AirframeCanonicalTaskRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("T-0116"),
            kind: .task,
            title: "Define canonical workflow record schemas",
            status: .active,
            githubIssue: 116
        ),
        component: "AirframeCore",
        priority: .high,
        rationale: "Airframe needs typed canonical records.",
        epicID: AirframeID("EP-020"),
        sprintID: AirframeID("SP-025"),
        acceptanceCriteria: [
            "Records preserve stable Airframe IDs and relationship IDs."
        ]
    )
    let project = AirframeCanonicalProjectRecord(
        id: AirframeID("PRJ-AIRFRAME"),
        name: "Agile Airframe",
        repository: "justgus/Airframe",
        activeEpicID: epic.workItem.id,
        activeSprintID: sprint.workItem.id,
        epicIDs: [epic.workItem.id],
        sprintIDs: [sprint.workItem.id],
        taskIDs: [task.workItem.id]
    )

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    let decodedProject = try decoder.decode(
        AirframeCanonicalProjectRecord.self,
        from: encoder.encode(project)
    )
    let decodedEpic = try decoder.decode(
        AirframeCanonicalEpicRecord.self,
        from: encoder.encode(epic)
    )
    let decodedSprint = try decoder.decode(
        AirframeCanonicalSprintRecord.self,
        from: encoder.encode(sprint)
    )
    let decodedTask = try decoder.decode(
        AirframeCanonicalTaskRecord.self,
        from: encoder.encode(task)
    )

    #expect(decodedProject.activeEpicID == AirframeID("EP-020"))
    #expect(decodedProject.activeSprintID == AirframeID("SP-025"))
    #expect(decodedEpic.taskIDs == [AirframeID("T-0116"), AirframeID("T-0117")])
    #expect(decodedSprint.epicID == AirframeID("EP-020"))
    #expect(decodedSprint.taskIDs.contains(decodedTask.workItem.id))
    #expect(decodedTask.epicID == decodedEpic.workItem.id)
    #expect(decodedTask.sprintID == decodedSprint.workItem.id)
    #expect(decodedTask.metadata.schemaVersion == .current)
}

@Test func canonicalRecordsRepresentEvidenceBackendMappingsAndWorkflowDefinitions() throws {
    let criterion = AirframeCanonicalAcceptanceCriterionRecord(
        id: AirframeID("EP-020-AC-01"),
        ownerID: AirframeID("EP-020"),
        text: "AirframeCore defines canonical Codable records.",
        isVerified: false,
        evidenceIDs: [AirframeID("EV-0116-001")]
    )
    let evidence = AirframeCanonicalEvidenceSummaryRecord(
        id: AirframeID("EV-0116-001"),
        workItemIDs: [AirframeID("T-0116")],
        summary: "AirframeCore tests pass.",
        result: .passed,
        requirementIDs: [AirframeID("REQ-CWS-FR-002")],
        command: "swift test --package-path AirframeCore",
        artifactReferences: ["AirframeCore test output"]
    )
    let test = AirframeCanonicalTestRecord(
        id: AirframeID("TEST-0116-001"),
        title: "Canonical records round-trip test",
        objective: "Verify canonical records encode and decode deterministically.",
        kind: .unit,
        status: .ready,
        requirementIDs: [AirframeID("REQ-CWS-FR-002")],
        acceptanceCriterionIDs: [criterion.id],
        workItemIDs: [AirframeID("T-0116")],
        evidenceIDs: [evidence.id],
        steps: ["Encode the record.", "Decode the record."],
        expectedResults: ["Decoded record matches the original."],
        automationCommand: "swift test --package-path AirframeCore",
        artifactReferences: ["AirframeCore/Tests/AirframeCoreTests"],
        notes: ["Canonical test definitions are not execution evidence."]
    )
    let testSuite = AirframeCanonicalTestSuiteRecord(
        id: AirframeID("TS-0116-001"),
        title: "Canonical record suite",
        objective: "Group canonical record tests by acceptance criterion.",
        status: .ready,
        testIDs: [test.id],
        requirementIDs: [AirframeID("REQ-CWS-FR-002")],
        acceptanceCriterionIDs: [criterion.id],
        notes: ["Suites group test definitions without replacing trace links."]
    )
    let testRun = AirframeCanonicalTestRunRecord(
        id: AirframeID("TR-0116-001"),
        testID: test.id,
        suiteID: testSuite.id,
        result: .passed,
        evidenceIDs: [evidence.id],
        command: "swift test --package-path AirframeCore",
        artifactReferences: ["AirframeCore test output"],
        environment: "local",
        notes: ["Runs capture execution results for a test definition."]
    )
    let mapping = AirframeCanonicalBackendMappingRecord(
        id: AirframeID("MAP-T-0116-GH"),
        localRecordID: AirframeID("T-0116"),
        backendKind: "github-issues",
        externalID: "#116",
        externalURL: "https://github.com/justgus/Airframe/issues/116"
    )
    let transition = AirframeCanonicalWorkflowTransitionRecord(
        id: AirframeID("WF-TASK-BACKLOG-ACTIVE"),
        workItemKind: .task,
        fromStatus: .backlog,
        toStatus: .active,
        operation: AirframeOperation(
            id: AirframeID("OP-ACTIVATE-TASK"),
            category: .workflowTransition
        ),
        requiredAuthorityClasses: [.humanOwner, .humanMaintainer, .llmAgent],
        preconditions: ["Task is assigned to the active Sprint."],
        sideEffects: ["Update generated task projection."]
    )
    let workflow = AirframeCanonicalWorkflowDefinitionRecord(
        id: AirframeID("WF-TASK"),
        workItemKind: .task,
        allowedStatuses: [.backlog, .active, .implementedNotVerified, .implementedVerified, .closed],
        transitionIDs: [transition.id]
    )

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    #expect(
        try decoder.decode(
            AirframeCanonicalAcceptanceCriterionRecord.self,
            from: encoder.encode(criterion)
        ) == criterion
    )
    #expect(
        try decoder.decode(
            AirframeCanonicalEvidenceSummaryRecord.self,
            from: encoder.encode(evidence)
        ).requirementIDs == [AirframeID("REQ-CWS-FR-002")]
    )
    #expect(
        try decoder.decode(
            AirframeCanonicalTestRecord.self,
            from: encoder.encode(test)
        ) == test
    )
    #expect(
        try decoder.decode(
            AirframeCanonicalTestSuiteRecord.self,
            from: encoder.encode(testSuite)
        ) == testSuite
    )
    #expect(
        try decoder.decode(
            AirframeCanonicalTestRunRecord.self,
            from: encoder.encode(testRun)
        ) == testRun
    )
    #expect(
        try decoder.decode(
            AirframeCanonicalBackendMappingRecord.self,
            from: encoder.encode(mapping)
        ).externalID == "#116"
    )
    #expect(
        try decoder.decode(
            AirframeCanonicalWorkflowTransitionRecord.self,
            from: encoder.encode(transition)
        ).requiredAuthorityClasses.contains(.llmAgent)
    )
    #expect(
        try decoder.decode(
            AirframeCanonicalWorkflowDefinitionRecord.self,
            from: encoder.encode(workflow)
        ).transitionIDs == [AirframeID("WF-TASK-BACKLOG-ACTIVE")]
    )
}

@Test func canonicalPlanRecordsPersistAndHumanDecisionAudits() throws {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AirframeCorePlanReview-\(UUID().uuidString)")
    let repository = AirframeCanonicalStoreRepository(rootURL: rootURL)
    let plan = AirframeCanonicalImplementationPlanRecord(
        id: AirframeID("PLAN-023-001"),
        title: "Plan review workflow",
        summary: "Add canonical plan review and approval.",
        proposedByActorID: AirframeID("ACTOR-LLM"),
        targetEpicID: AirframeID("EP-023"),
        targetSprintID: AirframeID("SP-036"),
        targetTaskIDs: [AirframeID("T-0154")],
        scope: ["Core model"],
        fileChanges: ["AirframeCore/Sources/AirframeCore/PlanReview.swift"],
        commands: ["swift test --package-path AirframeCore"],
        externalEffects: ["None"],
        verificationCriteria: ["Plan decisions are audited."]
    )
    try repository.store.save(plan)

    let actor = AirframeActor(
        id: AirframeID("ACTOR-HUMAN"),
        displayName: "Human Reviewer",
        authorityClass: .humanReviewer,
        credentialSource: .localSession
    )
    let credential = AirframeCredentialContext(
        credentialID: AirframeID("CRED-HUMAN"),
        actorID: actor.id,
        credentialSource: .localSession,
        executionProjectID: AirframeID("PRJ-AIRFRAME"),
        allowedProjectIDs: [AirframeID("PRJ-AIRFRAME")]
    )
    let context = try AirframeCertifiedContext(
        actor: actor,
        credential: credential,
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )
    let result = try AirframePlanReviewService().decide(
        planID: plan.id,
        outcome: .approved,
        note: "Approved for implementation.",
        context: context,
        targetProjectID: AirframeID("PRJ-AIRFRAME"),
        repository: repository,
        decisionID: AirframeID("PD-023-001"),
        auditID: AirframeID("AUD-023-001"),
        decidedAt: Date(timeIntervalSince1970: 0)
    )

    let loadedPlan = try #require(try repository.store.load(AirframeCanonicalImplementationPlanRecord.self, id: plan.id))
    let loadedDecision = try #require(try repository.store.load(AirframeCanonicalPlanDecisionRecord.self, id: AirframeID("PD-023-001")))
    let loadedAudit = try #require(try repository.store.load(AirframeCanonicalAuditEventRecord.self, id: AirframeID("AUD-023-001")))

    #expect(result.plan.decisionState == .approved)
    #expect(loadedPlan.decisionState == .approved)
    #expect(loadedPlan.auditEventIDs == [AirframeID("AUD-023-001")])
    #expect(loadedDecision.outcome == .approved)
    #expect(loadedAudit.event.action == "OP-HUMAN-APPROVE-PLAN")
}

@Test func canonicalPlanDecisionDeniesLLMAgent() throws {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AirframeCorePlanReviewDenied-\(UUID().uuidString)")
    let repository = AirframeCanonicalStoreRepository(rootURL: rootURL)
    try repository.store.save(
        AirframeCanonicalImplementationPlanRecord(
            id: AirframeID("PLAN-023-002"),
            title: "Plan review workflow",
            summary: "Add canonical plan review and approval.",
            proposedByActorID: AirframeID("ACTOR-LLM")
        )
    )
    let actor = AirframeActor(
        id: AirframeID("ACTOR-LLM"),
        displayName: "AICockpit Agent",
        authorityClass: .llmAgent,
        credentialSource: .cliEnvironment
    )
    let credential = AirframeCredentialContext(
        credentialID: AirframeID("CRED-LLM"),
        actorID: actor.id,
        credentialSource: .cliEnvironment,
        executionProjectID: AirframeID("PRJ-AIRFRAME"),
        allowedProjectIDs: [AirframeID("PRJ-AIRFRAME")]
    )
    let context = try AirframeCertifiedContext(
        actor: actor,
        credential: credential,
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )

    #expect(throws: AirframeBackendError.authorityDenied(.authorityClassNotPermitted)) {
        try AirframePlanReviewService().decide(
            planID: AirframeID("PLAN-023-002"),
            outcome: .approved,
            context: context,
            targetProjectID: AirframeID("PRJ-AIRFRAME"),
            repository: repository
        )
    }
}

@Test func canonicalRequirementRecordsRoundTripWithRevisionLinkage() throws {
    let requirement = AirframeCanonicalRequirementRecord(
        id: AirframeID("REQ-0001"),
        title: "The system shall record canonical requirements.",
        statement: "AirframeCore shall persist requirements as repo-local canonical records.",
        status: .active,
        rationale: "Canonical requirement storage is the first step in the traceability model.",
        sourceKind: .airframe,
        sourceURI: "docs/Architecture-Modification-Plan.md#6-requirements-and-release-traceability",
        externalID: "REQ-LEGACY-001",
        priority: .high,
        verificationMethod: .review,
        validationRequired: true,
        releaseScope: ["EP-021"],
        parentIDs: [AirframeID("REQ-0000")],
        derivedFromIDs: [AirframeID("REQ-BASE")],
        supersedesIDs: [AirframeID("REQ-OLD-1")],
        traceLinks: [
            AirframeRequirementLink(
                id: AirframeID("RL-0001"),
                targetKind: "task",
                targetID: "T-0132",
                title: "Defines the requirement record model"
            )
        ],
        deviationIDs: [AirframeID("DEV-0001")],
        currentRevisionID: AirframeID("REQ-0001-R2"),
        changeRationale: "Initial canonical requirement schema."
    )
    let revision = AirframeCanonicalRequirementRevisionRecord(
        id: AirframeID("REQ-0001-R2"),
        requirementID: requirement.id,
        revisionNumber: 2,
        title: requirement.title,
        statement: requirement.statement,
        status: requirement.status,
        rationale: requirement.rationale,
        sourceKind: requirement.sourceKind,
        sourceURI: requirement.sourceURI,
        priority: requirement.priority,
        verificationMethod: requirement.verificationMethod,
        validationRequired: requirement.validationRequired,
        releaseScope: requirement.releaseScope,
        parentIDs: requirement.parentIDs,
        derivedFromIDs: requirement.derivedFromIDs,
        supersedesIDs: requirement.supersedesIDs,
        traceLinks: requirement.traceLinks,
        deviationIDs: requirement.deviationIDs,
        changeRationale: requirement.changeRationale
    )

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    #expect(
        try decoder.decode(
            AirframeCanonicalRequirementRecord.self,
            from: encoder.encode(requirement)
        ) == requirement
    )
    #expect(
        try decoder.decode(
            AirframeCanonicalRequirementRevisionRecord.self,
            from: encoder.encode(revision)
        ) == revision
    )
}

@Test func canonicalJSONStorePersistsOneFilePerRecordKind() throws {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AirframeCanonicalStore-\(UUID().uuidString)")
    defer {
        try? FileManager.default.removeItem(at: rootURL)
    }

    let store = AirframeCanonicalJSONStore(rootURL: rootURL)
    let task = AirframeCanonicalTaskRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("T-0117"),
            kind: .task,
            title: "Implement repo-local JSON canonical store",
            status: .active,
            githubIssue: 117
        ),
        component: "AirframeCore",
        priority: .high,
        rationale: "Canonical workflow state must live in the repository.",
        epicID: AirframeID("EP-020"),
        sprintID: AirframeID("SP-025"),
        acceptanceCriteria: [
            "AirframeCore can read and write repo-local canonical JSON records."
        ]
    )
    let sprint = AirframeCanonicalSprintRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("SP-025"),
            kind: .sprint,
            title: "Canonical Store Schema and Validation",
            status: .active
        ),
        epicID: AirframeID("EP-020"),
        goal: "Define the canonical store schema.",
        taskIDs: [task.workItem.id]
    )

    try store.save(task)
    try store.save(sprint)

    let taskURL = store.recordURL(for: AirframeID("T-0117"), as: AirframeCanonicalTaskRecord.self)
    let sprintURL = store.recordURL(for: AirframeID("SP-025"), as: AirframeCanonicalSprintRecord.self)
    let loadedTask = try #require(
        try store.load(AirframeCanonicalTaskRecord.self, id: AirframeID("T-0117"))
    )
    let loadedSprint = try #require(
        try store.load(AirframeCanonicalSprintRecord.self, id: AirframeID("SP-025"))
    )

    #expect(taskURL.path.hasSuffix(".airframe/state/tasks/T-0117.json"))
    #expect(sprintURL.path.hasSuffix(".airframe/state/sprints/SP-025.json"))
    #expect(loadedTask == task)
    #expect(loadedSprint.taskIDs == [AirframeID("T-0117")])
    #expect(store.exists(AirframeCanonicalTaskRecord.self, id: AirframeID("T-0117")))
    #expect(try store.list(AirframeCanonicalTaskRecord.self).map(\.workItem.id) == [AirframeID("T-0117")])

    try store.delete(AirframeCanonicalTaskRecord.self, id: AirframeID("T-0117"))

    #expect(!store.exists(AirframeCanonicalTaskRecord.self, id: AirframeID("T-0117")))
    #expect(try store.load(AirframeCanonicalTaskRecord.self, id: AirframeID("T-0117")) == nil)
}

@Test func canonicalJSONStorePersistsRequirementRecords() throws {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AirframeCanonicalRequirements-\(UUID().uuidString)")
    defer {
        try? FileManager.default.removeItem(at: rootURL)
    }

    let store = AirframeCanonicalJSONStore(rootURL: rootURL)
    let requirement = AirframeCanonicalRequirementRecord(
        id: AirframeID("REQ-0001"),
        title: "The system shall record canonical requirements.",
        statement: "AirframeCore shall persist requirements as repo-local canonical records.",
        status: .active,
        rationale: "Requirements are the foundation for traceability.",
        sourceKind: .airframe,
        sourceURI: "docs/Architecture-Modification-Plan.md#6-requirements-and-release-traceability",
        externalID: "LEGACY-REQ-001",
        priority: .high,
        verificationMethod: .review,
        validationRequired: true,
        releaseScope: ["EP-021"],
        currentRevisionID: AirframeID("REQ-0001-R1")
    )
    let revision = AirframeCanonicalRequirementRevisionRecord(
        id: AirframeID("REQ-0001-R1"),
        requirementID: requirement.id,
        revisionNumber: 1,
        title: requirement.title,
        statement: requirement.statement,
        status: requirement.status,
        rationale: requirement.rationale,
        sourceKind: requirement.sourceKind,
        sourceURI: requirement.sourceURI,
        priority: requirement.priority,
        verificationMethod: requirement.verificationMethod,
        validationRequired: requirement.validationRequired,
        releaseScope: requirement.releaseScope
    )

    try store.save(requirement)
    try store.save(revision)

    let requirementURL = store.recordURL(for: requirement.id, as: AirframeCanonicalRequirementRecord.self)
    let revisionURL = store.recordURL(for: revision.id, as: AirframeCanonicalRequirementRevisionRecord.self)
    let loadedRequirement = try #require(
        try store.load(AirframeCanonicalRequirementRecord.self, id: requirement.id)
    )
    let loadedRevision = try #require(
        try store.load(AirframeCanonicalRequirementRevisionRecord.self, id: revision.id)
    )

    #expect(requirementURL.path.hasSuffix(".airframe/state/requirements/REQ-0001.json"))
    #expect(revisionURL.path.hasSuffix(".airframe/state/requirement-revisions/REQ-0001-R1.json"))
    #expect(loadedRequirement == requirement)
    #expect(loadedRevision == revision)
    #expect(try store.list(AirframeCanonicalRequirementRecord.self).map(\.id) == [AirframeID("REQ-0001")])
    #expect(try store.list(AirframeCanonicalRequirementRevisionRecord.self).map(\.id) == [AirframeID("REQ-0001-R1")])
}

@Test func canonicalJSONStorePersistsTestRecords() throws {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AirframeCanonicalTestStore-\(UUID().uuidString)")
    defer {
        try? FileManager.default.removeItem(at: rootURL)
    }

    let store = AirframeCanonicalJSONStore(rootURL: rootURL)
    let testRecord = AirframeCanonicalTestRecord(
        id: AirframeID("TEST-9001"),
        title: "Requirement traceability model test",
        objective: "Verify tests can trace requirements through acceptance criteria.",
        kind: .acceptance,
        status: .active,
        requirementIDs: [AirframeID("REQ-9001")],
        acceptanceCriterionIDs: [AirframeID("AC-9001")],
        workItemIDs: [AirframeID("T-9001")],
        steps: ["Load canonical requirements.", "Resolve test traceability."],
        expectedResults: ["The requirement trace summary includes TEST-9001."]
    )
    let suiteRecord = AirframeCanonicalTestSuiteRecord(
        id: AirframeID("TS-9001"),
        title: "Requirement traceability suite",
        objective: "Group requirement traceability tests.",
        status: .active,
        testIDs: [testRecord.id],
        requirementIDs: [AirframeID("REQ-9001")],
        acceptanceCriterionIDs: [AirframeID("AC-9001")]
    )
    let runRecord = AirframeCanonicalTestRunRecord(
        id: AirframeID("TR-9001"),
        testID: testRecord.id,
        suiteID: suiteRecord.id,
        result: .passed,
        evidenceIDs: [AirframeID("EV-9001")],
        command: "swift test --package-path AirframeCore",
        environment: "local"
    )

    try store.save(testRecord)
    try store.save(suiteRecord)
    try store.save(runRecord)

    let loaded = try #require(
        try store.load(AirframeCanonicalTestRecord.self, id: AirframeID("TEST-9001"))
    )
    let loadedSuite = try #require(
        try store.load(AirframeCanonicalTestSuiteRecord.self, id: AirframeID("TS-9001"))
    )
    let loadedRun = try #require(
        try store.load(AirframeCanonicalTestRunRecord.self, id: AirframeID("TR-9001"))
    )
    let state = try AirframeCanonicalStoreRepository(store: store).loadState()

    #expect(loaded == testRecord)
    #expect(loadedSuite == suiteRecord)
    #expect(loadedRun == runRecord)
    #expect(state.tests == [testRecord])
    #expect(state.testSuites == [suiteRecord])
    #expect(state.testRuns == [runRecord])
}

@Test func canonicalRepositorySprintActivationSetsProjectActiveSprint() throws {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AirframeCanonicalSprintActivation-\(UUID().uuidString)")
    defer {
        try? FileManager.default.removeItem(at: rootURL)
    }

    let store = AirframeCanonicalJSONStore(rootURL: rootURL)
    let project = AirframeCanonicalProjectRecord(
        id: AirframeID("PRJ-AIRFRAME"),
        name: "Agile Airframe",
        repository: "justgus/Airframe",
        activeEpicID: AirframeID("EP-021"),
        activeSprintID: nil,
        sprintIDs: [AirframeID("SP-032")]
    )
    let sprint = AirframeCanonicalSprintRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("SP-032"),
            kind: .sprint,
            title: "Compliance Documents and Regression Coverage",
            status: .planning
        ),
        epicID: AirframeID("EP-021"),
        goal: "Generate compliance documents and regression coverage."
    )
    try store.save(project)
    try store.save(sprint)

    try AirframeCanonicalStoreRepository(store: store)
        .transitionWorkItem(id: AirframeID("SP-032"), to: .active)

    let loadedProject = try #require(
        try store.load(AirframeCanonicalProjectRecord.self, id: AirframeID("PRJ-AIRFRAME"))
    )
    let loadedSprint = try #require(
        try store.load(AirframeCanonicalSprintRecord.self, id: AirframeID("SP-032"))
    )
    #expect(loadedSprint.workItem.status == .active)
    #expect(loadedProject.activeSprintID == AirframeID("SP-032"))
}

@Test func canonicalRepositorySprintClosureClearsMatchingProjectActiveSprint() throws {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AirframeCanonicalSprintClosure-\(UUID().uuidString)")
    defer {
        try? FileManager.default.removeItem(at: rootURL)
    }

    let store = AirframeCanonicalJSONStore(rootURL: rootURL)
    let project = AirframeCanonicalProjectRecord(
        id: AirframeID("PRJ-AIRFRAME"),
        name: "Agile Airframe",
        repository: "justgus/Airframe",
        activeEpicID: AirframeID("EP-021"),
        activeSprintID: AirframeID("SP-032"),
        sprintIDs: [AirframeID("SP-032")]
    )
    let sprint = AirframeCanonicalSprintRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("SP-032"),
            kind: .sprint,
            title: "Compliance Documents and Regression Coverage",
            status: .review
        ),
        epicID: AirframeID("EP-021"),
        goal: "Generate compliance documents and regression coverage."
    )
    try store.save(project)
    try store.save(sprint)

    try AirframeCanonicalStoreRepository(store: store)
        .transitionWorkItem(id: AirframeID("SP-032"), to: .closed)

    let loadedProject = try #require(
        try store.load(AirframeCanonicalProjectRecord.self, id: AirframeID("PRJ-AIRFRAME"))
    )
    let loadedSprint = try #require(
        try store.load(AirframeCanonicalSprintRecord.self, id: AirframeID("SP-032"))
    )
    #expect(loadedSprint.workItem.status == .closed)
    #expect(loadedProject.activeSprintID == nil)
}

@Test func canonicalRepositorySprintReturnToBacklogClearsMatchingProjectActiveSprint() throws {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AirframeCanonicalSprintBacklogReturn-\(UUID().uuidString)")
    defer {
        try? FileManager.default.removeItem(at: rootURL)
    }

    let store = AirframeCanonicalJSONStore(rootURL: rootURL)
    let project = AirframeCanonicalProjectRecord(
        id: AirframeID("PRJ-AIRFRAME"),
        name: "Agile Airframe",
        repository: "justgus/Airframe",
        activeEpicID: AirframeID("EP-021"),
        activeSprintID: AirframeID("SP-032"),
        sprintIDs: [AirframeID("SP-032")]
    )
    let sprint = AirframeCanonicalSprintRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("SP-032"),
            kind: .sprint,
            title: "Compliance Documents and Regression Coverage",
            status: .active
        ),
        epicID: AirframeID("EP-021"),
        goal: "Generate compliance documents and regression coverage."
    )
    try store.save(project)
    try store.save(sprint)

    try AirframeCanonicalStoreRepository(store: store)
        .transitionWorkItem(id: AirframeID("SP-032"), to: .backlog)

    let loadedProject = try #require(
        try store.load(AirframeCanonicalProjectRecord.self, id: AirframeID("PRJ-AIRFRAME"))
    )
    let loadedSprint = try #require(
        try store.load(AirframeCanonicalSprintRecord.self, id: AirframeID("SP-032"))
    )
    #expect(loadedSprint.workItem.status == .backlog)
    #expect(loadedProject.activeSprintID == nil)
}

@Test func canonicalRepositoryMoveIssueClearsStaleOwnerLinks() throws {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AirframeCanonicalMoveIssue-\(UUID().uuidString)")
    defer {
        try? FileManager.default.removeItem(at: rootURL)
    }

    let store = AirframeCanonicalJSONStore(rootURL: rootURL)
    let issueID = AirframeID("I-0020")
    try store.save(canonicalEpic(id: "EP-018", status: .closed, issueIDs: [issueID]))
    try store.save(canonicalEpic(id: "EP-022", status: .active))
    try store.save(canonicalSprint(id: "SP-024", status: .closed, epicID: AirframeID("EP-018"), issueIDs: [issueID]))
    try store.save(canonicalSprint(id: "SP-034", status: .active, epicID: AirframeID("EP-022")))
    try store.save(canonicalIssue(id: issueID, epicID: AirframeID("EP-018"), sprintID: AirframeID("SP-024")))

    try AirframeCanonicalStoreRepository(store: store)
        .moveIssue(issueID: issueID, toEpicID: AirframeID("EP-022"), toSprintID: AirframeID("SP-034"))

    let oldEpic = try #require(try store.load(AirframeCanonicalEpicRecord.self, id: AirframeID("EP-018")))
    let newEpic = try #require(try store.load(AirframeCanonicalEpicRecord.self, id: AirframeID("EP-022")))
    let oldSprint = try #require(try store.load(AirframeCanonicalSprintRecord.self, id: AirframeID("SP-024")))
    let newSprint = try #require(try store.load(AirframeCanonicalSprintRecord.self, id: AirframeID("SP-034")))
    let issue = try #require(try store.load(AirframeCanonicalIssueRecord.self, id: issueID))

    #expect(!oldEpic.issueIDs.contains(issueID))
    #expect(newEpic.issueIDs == [issueID])
    #expect(!oldSprint.issueIDs.contains(issueID))
    #expect(newSprint.issueIDs == [issueID])
    #expect(issue.epicID == AirframeID("EP-022"))
    #expect(issue.sprintID == AirframeID("SP-034"))
}

@Test func canonicalRepositoryMoveTaskClearsStaleOwnerLinks() throws {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AirframeCanonicalMoveTask-\(UUID().uuidString)")
    defer {
        try? FileManager.default.removeItem(at: rootURL)
    }

    let store = AirframeCanonicalJSONStore(rootURL: rootURL)
    let taskID = AirframeID("T-0999")
    try store.save(canonicalEpic(id: "EP-018", status: .closed, taskIDs: [taskID]))
    try store.save(canonicalEpic(id: "EP-022", status: .active))
    try store.save(canonicalSprint(id: "SP-024", status: .closed, epicID: AirframeID("EP-018"), taskIDs: [taskID]))
    try store.save(canonicalSprint(id: "SP-034", status: .active, epicID: AirframeID("EP-022")))
    try store.save(canonicalTask(id: taskID, epicID: AirframeID("EP-018"), sprintID: AirframeID("SP-024")))

    try AirframeCanonicalStoreRepository(store: store)
        .moveTask(taskID: taskID, toEpicID: AirframeID("EP-022"), toSprintID: AirframeID("SP-034"))

    let oldEpic = try #require(try store.load(AirframeCanonicalEpicRecord.self, id: AirframeID("EP-018")))
    let newEpic = try #require(try store.load(AirframeCanonicalEpicRecord.self, id: AirframeID("EP-022")))
    let oldSprint = try #require(try store.load(AirframeCanonicalSprintRecord.self, id: AirframeID("SP-024")))
    let newSprint = try #require(try store.load(AirframeCanonicalSprintRecord.self, id: AirframeID("SP-034")))
    let task = try #require(try store.load(AirframeCanonicalTaskRecord.self, id: taskID))

    #expect(!oldEpic.taskIDs.contains(taskID))
    #expect(newEpic.taskIDs == [taskID])
    #expect(!oldSprint.taskIDs.contains(taskID))
    #expect(newSprint.taskIDs == [taskID])
    #expect(task.epicID == AirframeID("EP-022"))
    #expect(task.sprintID == AirframeID("SP-034"))
}

@Test func canonicalRepositoryUpdateIssueReconcilesOwnerLinks() throws {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AirframeCanonicalUpdateIssueMove-\(UUID().uuidString)")
    defer {
        try? FileManager.default.removeItem(at: rootURL)
    }

    let store = AirframeCanonicalJSONStore(rootURL: rootURL)
    let issueID = AirframeID("I-0020")
    try store.save(canonicalEpic(id: "EP-018", status: .closed, issueIDs: [issueID]))
    try store.save(canonicalEpic(id: "EP-022", status: .active))
    try store.save(canonicalSprint(id: "SP-024", status: .closed, epicID: AirframeID("EP-018"), issueIDs: [issueID]))
    try store.save(canonicalSprint(id: "SP-034", status: .active, epicID: AirframeID("EP-022")))
    try store.save(canonicalIssue(id: issueID, epicID: AirframeID("EP-018"), sprintID: AirframeID("SP-024")))

    try AirframeCanonicalStoreRepository(store: store).updateWorkRecord(
        AirframeLocalWorkRecord(
            workItem: AirframeWorkItem(
                id: issueID,
                kind: .issue,
                title: "Canonical moves can leave stale reverse links on closed work",
                status: .active
            ),
            epicID: AirframeID("EP-022"),
            sprintID: AirframeID("SP-034"),
            priority: .high
        )
    )

    let oldEpic = try #require(try store.load(AirframeCanonicalEpicRecord.self, id: AirframeID("EP-018")))
    let newEpic = try #require(try store.load(AirframeCanonicalEpicRecord.self, id: AirframeID("EP-022")))
    let oldSprint = try #require(try store.load(AirframeCanonicalSprintRecord.self, id: AirframeID("SP-024")))
    let newSprint = try #require(try store.load(AirframeCanonicalSprintRecord.self, id: AirframeID("SP-034")))
    let issue = try #require(try store.load(AirframeCanonicalIssueRecord.self, id: issueID))

    #expect(!oldEpic.issueIDs.contains(issueID))
    #expect(newEpic.issueIDs == [issueID])
    #expect(!oldSprint.issueIDs.contains(issueID))
    #expect(newSprint.issueIDs == [issueID])
    #expect(issue.epicID == AirframeID("EP-022"))
    #expect(issue.sprintID == AirframeID("SP-034"))
}

@Test func requirementInterchangeRoundTripsJSONAndCSV() throws {
    let requirement = AirframeCanonicalRequirementRecord(
        id: AirframeID("REQ-0002"),
        title: "Requirements import/export shall support diff review.",
        statement: "AirframeCore shall export requirements in deterministic CSV and JSON forms.",
        status: .draft,
        rationale: "The interchange layer supports future migration and review.",
        sourceKind: .manual,
        sourceURI: "docs/architecture/RequirementsTraceability_ImportExport_Plan.md",
        externalID: "EXT-42",
        priority: .medium,
        verificationMethod: .review,
        validationRequired: false,
        releaseScope: ["EP-021", "SP-029"],
        parentIDs: [AirframeID("REQ-0001")],
        derivedFromIDs: [AirframeID("REQ-BASE")],
        supersedesIDs: [AirframeID("REQ-OLD-2")],
        traceLinks: [
            AirframeRequirementLink(
                id: AirframeID("RL-0002"),
                targetKind: "task",
                targetID: "T-0133",
                title: "Requirement interchange"
            )
        ],
        deviationIDs: [AirframeID("DEV-0002")],
        currentRevisionID: AirframeID("REQ-0002-R1"),
        changeRationale: "Initial interchange implementation."
    )
    let revision = AirframeCanonicalRequirementRevisionRecord(
        id: AirframeID("REQ-0002-R1"),
        requirementID: requirement.id,
        revisionNumber: 1,
        title: requirement.title,
        statement: requirement.statement,
        status: requirement.status,
        rationale: requirement.rationale,
        sourceKind: requirement.sourceKind,
        sourceURI: requirement.sourceURI,
        priority: requirement.priority,
        verificationMethod: requirement.verificationMethod,
        validationRequired: requirement.validationRequired,
        releaseScope: requirement.releaseScope,
        parentIDs: requirement.parentIDs,
        derivedFromIDs: requirement.derivedFromIDs,
        supersedesIDs: requirement.supersedesIDs,
        traceLinks: requirement.traceLinks,
        deviationIDs: requirement.deviationIDs,
        changeRationale: requirement.changeRationale
    )

    let interchange = AirframeRequirementInterchange()
    let json = try interchange.exportJSON(requirements: [requirement], revisions: [revision])
    let document = try interchange.importJSON(json)
    let csv = try interchange.exportCSV(requirements: document.requirements, revisions: document.revisions)
    let importedCSV = try interchange.importCSV(csv)

    #expect(document.requirements == [requirement])
    #expect(document.revisions == [revision])
    #expect(importedCSV.requirements == [requirement])
    #expect(importedCSV.revisions == [revision])
    #expect(csv.contains("record_kind"))
    #expect(csv.contains("REQ-0002"))
    #expect(json.contains("\"requirements\""))
}

@Test func requirementInterchangePreviewReportsCreatedUpdatedUnchangedRemovedAndConflictedRecords() throws {
    let unchangedExistingRequirement = AirframeCanonicalRequirementRecord(
        id: AirframeID("REQ-1000"),
        title: "Unchanged requirement",
        statement: "Existing canonical requirement.",
        status: .active,
        rationale: "Baseline record.",
        sourceKind: .airframe,
        sourceURI: "docs/requirements/existing.md",
        currentRevisionID: AirframeID("REQ-1000-R1")
    )
    let updatedExistingRequirement = AirframeCanonicalRequirementRecord(
        id: AirframeID("REQ-1100"),
        title: "Updated requirement",
        statement: "Existing canonical requirement.",
        status: .active,
        rationale: "Baseline record.",
        sourceKind: .airframe,
        sourceURI: "docs/requirements/updated.md",
        currentRevisionID: AirframeID("REQ-1100-R1")
    )
    let removedRequirement = AirframeCanonicalRequirementRecord(
        id: AirframeID("REQ-2000"),
        title: "Removed requirement",
        statement: "This requirement will be removed from the import payload.",
        status: .draft,
        rationale: "Legacy record.",
        sourceKind: .manual,
        sourceURI: "docs/requirements/removed.md"
    )
    let unchangedExistingRevision = AirframeCanonicalRequirementRevisionRecord(
        id: AirframeID("REQ-1000-R1"),
        requirementID: unchangedExistingRequirement.id,
        revisionNumber: 1,
        title: unchangedExistingRequirement.title,
        statement: unchangedExistingRequirement.statement,
        status: unchangedExistingRequirement.status,
        rationale: unchangedExistingRequirement.rationale,
        sourceKind: unchangedExistingRequirement.sourceKind,
        sourceURI: unchangedExistingRequirement.sourceURI
    )
    let updatedExistingRevision = AirframeCanonicalRequirementRevisionRecord(
        id: AirframeID("REQ-1100-R1"),
        requirementID: updatedExistingRequirement.id,
        revisionNumber: 1,
        title: updatedExistingRequirement.title,
        statement: updatedExistingRequirement.statement,
        status: updatedExistingRequirement.status,
        rationale: updatedExistingRequirement.rationale,
        sourceKind: updatedExistingRequirement.sourceKind,
        sourceURI: updatedExistingRequirement.sourceURI
    )
    let removedRevision = AirframeCanonicalRequirementRevisionRecord(
        id: AirframeID("REQ-2000-R1"),
        requirementID: removedRequirement.id,
        revisionNumber: 1,
        title: removedRequirement.title,
        statement: removedRequirement.statement,
        status: removedRequirement.status,
        rationale: removedRequirement.rationale,
        sourceKind: removedRequirement.sourceKind,
        sourceURI: removedRequirement.sourceURI
    )

    let unchangedRequirement = unchangedExistingRequirement
    let updatedRequirement = AirframeCanonicalRequirementRecord(
        id: updatedExistingRequirement.id,
        title: "Updated requirement",
        statement: "Existing canonical requirement with updated text.",
        status: .verified,
        rationale: "Baseline record updated.",
        sourceKind: .airframe,
        sourceURI: "docs/requirements/updated.md",
        currentRevisionID: AirframeID("REQ-1100-R2")
    )
    let createdRequirement = AirframeCanonicalRequirementRecord(
        id: AirframeID("REQ-3000"),
        title: "Created requirement",
        statement: "A new requirement from import.",
        status: .draft,
        rationale: "New record.",
        sourceKind: .manual,
        sourceURI: "docs/requirements/created.md"
    )
    let incomingRequirementDuplicate = AirframeCanonicalRequirementRecord(
        id: AirframeID("REQ-3000"),
        title: "Created requirement duplicate",
        statement: "This duplicate should conflict.",
        status: .draft,
        rationale: "Duplicate record.",
        sourceKind: .manual,
        sourceURI: "docs/requirements/created-duplicate.md"
    )

    let unchangedRevision = unchangedExistingRevision
    let updatedRevision = AirframeCanonicalRequirementRevisionRecord(
        id: updatedExistingRevision.id,
        requirementID: updatedExistingRequirement.id,
        revisionNumber: 1,
        title: updatedExistingRequirement.title,
        statement: "Existing canonical requirement with updated revision text.",
        status: .verified,
        rationale: "Baseline record updated.",
        sourceKind: .airframe,
        sourceURI: updatedExistingRequirement.sourceURI
    )
    let createdRevision = AirframeCanonicalRequirementRevisionRecord(
        id: AirframeID("REQ-3000-R1"),
        requirementID: createdRequirement.id,
        revisionNumber: 1,
        title: createdRequirement.title,
        statement: createdRequirement.statement,
        status: createdRequirement.status,
        rationale: createdRequirement.rationale,
        sourceKind: createdRequirement.sourceKind,
        sourceURI: createdRequirement.sourceURI
    )
    let incomingRevisionDuplicate = AirframeCanonicalRequirementRevisionRecord(
        id: AirframeID("REQ-3000-R1"),
        requirementID: createdRequirement.id,
        revisionNumber: 1,
        title: "Created requirement duplicate",
        statement: "This duplicate should conflict.",
        status: .draft,
        rationale: "Duplicate record.",
        sourceKind: .manual,
        sourceURI: "docs/requirements/created-duplicate.md"
    )

    let previewJSONDocument = AirframeRequirementInterchangeDocument(
        requirements: [unchangedRequirement, updatedRequirement, createdRequirement, incomingRequirementDuplicate],
        revisions: [unchangedRevision, updatedRevision, createdRevision, incomingRevisionDuplicate]
    )
    let previewJSON = try JSONEncoder().encode(previewJSONDocument)
    let interchange = AirframeRequirementInterchange()
    let preview = try interchange.previewImportJSON(
        String(decoding: previewJSON, as: UTF8.self),
        existingRequirements: [unchangedExistingRequirement, updatedExistingRequirement, removedRequirement],
        existingRevisions: [unchangedExistingRevision, updatedExistingRevision, removedRevision]
    )

    #expect(preview.createdCount == 2)
    #expect(preview.updatedCount == 2)
    #expect(preview.unchangedCount == 2)
    #expect(preview.removedCount == 2)
    #expect(preview.conflictedCount == 2)
    #expect(preview.requirements.contains(where: { $0.changeKind == .conflicted && $0.id == AirframeID("REQ-3000") }))
    #expect(preview.revisions.contains(where: { $0.changeKind == .conflicted && $0.id == AirframeID("REQ-3000-R1") }))

    let csv = try interchange.exportCSV(
        requirements: [unchangedRequirement, updatedRequirement, createdRequirement, incomingRequirementDuplicate],
        revisions: [unchangedRevision, updatedRevision, createdRevision, incomingRevisionDuplicate]
    )
    let csvPreview = try interchange.previewImportCSV(
        csv,
        existingRequirements: [unchangedExistingRequirement, updatedExistingRequirement, removedRequirement],
        existingRevisions: [unchangedExistingRevision, updatedExistingRevision, removedRevision]
    )

    #expect(csvPreview == preview)
}

@Test func requirementTraceabilityIndexAndGateEvaluationCoverWorkItemsEvidenceAndReports() throws {
    let requirement = AirframeCanonicalRequirementRecord(
        id: AirframeID("REQ-9001"),
        title: "The system shall link requirements to work and evidence.",
        statement: "AirframeCore shall provide traceability coverage for requirement-linked work items and evidence.",
        status: .active,
        rationale: "Traceability is required for release gating.",
        sourceKind: .manual,
        sourceURI: "docs/requirements/traceability.md",
        releaseScope: ["SP-029"],
        traceLinks: [
            AirframeRequirementLink(
                id: AirframeID("RL-9001"),
                targetKind: "task",
                targetID: "T-9001",
                title: "Requirement implementation task"
            ),
            AirframeRequirementLink(
                id: AirframeID("RL-9002"),
                targetKind: "evidence",
                targetID: "EV-9001",
                title: "Requirement evidence"
            ),
            AirframeRequirementLink(
                id: AirframeID("RL-9003"),
                targetKind: "design",
                targetID: "DESIGN-42",
                title: "Design note"
            )
        ],
        currentRevisionID: AirframeID("REQ-9001-R1")
    )
    let verifiedRequirement = AirframeCanonicalRequirementRecord(
        id: AirframeID("REQ-9002"),
        title: "The system shall keep source metadata.",
        statement: "AirframeCore shall preserve source metadata with revision history.",
        status: .verified,
        rationale: "Source provenance is required for import/export auditing.",
        sourceKind: .external,
        sourceURI: "docs/source/requirements.csv",
        releaseScope: ["SP-029"],
        currentRevisionID: AirframeID("REQ-9002-R1")
    )
    let draftRequirement = AirframeCanonicalRequirementRecord(
        id: AirframeID("REQ-9003"),
        title: "The system shall expose release gate reporting.",
        statement: "AirframeCore shall explain why a release can or cannot close.",
        status: .draft,
        rationale: "Release gating needs a user-facing explanation.",
        sourceKind: .airframe,
        sourceURI: "docs/requirements/release-gates.md",
        releaseScope: ["SP-029"]
    )
    let requirementRevision = AirframeCanonicalRequirementRevisionRecord(
        id: AirframeID("REQ-9001-R1"),
        requirementID: requirement.id,
        revisionNumber: 1,
        title: requirement.title,
        statement: requirement.statement,
        status: requirement.status,
        rationale: requirement.rationale,
        sourceKind: requirement.sourceKind,
        sourceURI: requirement.sourceURI
    )
    let task = AirframeCanonicalTaskRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("T-9001"),
            kind: .task,
            title: "Implement traceability index",
            status: .implementedNotVerified
        ),
        component: "AirframeCore",
        priority: .high,
        rationale: "Traceability implementation is required for release gating.",
        epicID: AirframeID("EP-021"),
        sprintID: AirframeID("SP-029"),
        requirementIDs: [requirement.id],
        testSteps: ["Run traceability tests"]
    )
    let acceptanceCriterion = AirframeCanonicalAcceptanceCriterionRecord(
        id: AirframeID("AC-9001"),
        ownerID: AirframeID("EP-021"),
        text: "Show requirement traceability coverage for requirement-linked work items and evidence.",
        isVerified: true
    )
    let test = AirframeCanonicalTestRecord(
        id: AirframeID("TEST-9001"),
        title: "Traceability report acceptance test",
        objective: "Verify requirement traceability coverage for requirement-linked acceptance criteria.",
        kind: .acceptance,
        status: .active,
        acceptanceCriterionIDs: [acceptanceCriterion.id],
        workItemIDs: [task.workItem.id],
        steps: ["Generate the requirement traceability reports."],
        expectedResults: ["REQ-9001 links to AC-9001 and TEST-9001."]
    )
    let evidence = AirframeCanonicalEvidenceSummaryRecord(
        id: AirframeID("EV-9001"),
        workItemIDs: [task.workItem.id],
        summary: "Traceability tests passed.",
        result: .passed,
        requirementIDs: [requirement.id],
        command: "swift test --package-path AirframeCore",
        artifactReferences: ["docs/generated/Requirements/Requirements-Traceability-Matrix.md"],
        ciReferences: ["ci://runs/9001"],
        environment: "macOS"
    )

    let index = AirframeRequirementTraceabilityIndex(
        requirements: [requirement, verifiedRequirement, draftRequirement],
        revisions: [requirementRevision],
        evidence: [evidence],
        acceptanceCriteria: [acceptanceCriterion],
        tests: [test],
        tasks: [task]
    )
    let summary = index.traceSummary(for: requirement.id)
    let requirementsForTask = index.requirements(for: task.workItem.id)
    let requirementsForCriterion = index.requirements(for: acceptanceCriterion.id)
    let requirementsForTest = index.requirements(for: test.id)
    let requirementsForEvidence = index.requirements(for: evidence.id)
    let gaps = index.gapDiagnostics(releaseScope: "SP-029")
    let gate = index.releaseGateSummary(releaseScope: "SP-029")
    let coverage = index.coverageSummary(releaseScope: "SP-029")
    let documentation = AirframeRequirementDocumentationProjector().projectRequirementReport(index, releaseScope: "SP-029")

    #expect(summary.hasWorkItemTrace)
    #expect(summary.hasAcceptanceCriterionTrace)
    #expect(summary.hasTestTrace)
    #expect(summary.hasEvidenceTrace)
    #expect(summary.acceptanceCriterionIDs == [AirframeID("AC-9001")])
    #expect(summary.testIDs == [AirframeID("TEST-9001")])
    #expect(summary.revisionIDs == [AirframeID("REQ-9001-R1")])
    #expect(requirementsForTask.map { $0.id } == [requirement.id])
    #expect(requirementsForCriterion.map { $0.id } == [requirement.id])
    #expect(requirementsForTest.map { $0.id } == [requirement.id])
    #expect(requirementsForEvidence.map { $0.id } == [requirement.id])
    #expect(!gaps.contains { $0.requirementID == draftRequirement.id && $0.kind == AirframeRequirementGapKind.missingImplementationTrace })
    #expect(gaps.contains { $0.requirementID == draftRequirement.id && $0.kind == AirframeRequirementGapKind.missingVerificationEvidence })
    #expect(coverage.totalRequirementCount == 3)
    #expect(coverage.assignedRequirementCount >= 1)
    #expect(!gate.canClose)
    #expect(gate.blockedRequirementIDs.contains(draftRequirement.id))
    #expect(documentation["Requirements/Requirements-Specification.md"]?.contains("Verification Method") == true)
    #expect(documentation["Requirements/Requirements-Specification.md"]?.contains("TEST-9001") == true)
    #expect(documentation["Requirements/Requirements-Traceability-Matrix.md"]?.contains("REQ-9001") == true)
    #expect(documentation["Requirements/index.md"]?.contains("The system shall link requirements to work and evidence.") == true)
    #expect(documentation["Requirements/Requirements-Traceability-Matrix.md"]?.contains("The system shall link requirements to work and evidence.") == true)
    #expect(documentation["Requirements/Requirements-Traceability-Matrix.md"]?.contains("Epic Acceptance Criteria") == true)
    #expect(documentation["Requirements/Requirements-Traceability-Matrix.md"]?.contains("AC-9001") == true)
    #expect(documentation["Requirements/Requirements-Traceability-Matrix.md"]?.contains("TEST-9001") == false)
    #expect(documentation["Requirements/Requirements-Traceability-Matrix.md"]?.contains("T-9001") == false)
    #expect(documentation["Requirements/Requirements-Traceability-Matrix.md"]?.contains("EV-9001") == false)
    #expect(documentation["Requirements/Bidirectional-Requirements-Traceability-Matrix.md"]?.contains("TEST-9001") == true)
    #expect(documentation["Requirements/Bidirectional-Requirements-Traceability-Matrix.md"]?.contains("T-9001") == true)
    #expect(documentation["Requirements/Release-Gate.md"]?.contains("Can Close") == true)
    #expect(documentation["Requirements/Compliance-Verification-Matrix.md"]?.contains("Requirement") == true)
}

@Test func canonicalJSONStoreReportsMalformedRecordDiagnostics() throws {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AirframeCanonicalStoreMalformed-\(UUID().uuidString)")
    defer {
        try? FileManager.default.removeItem(at: rootURL)
    }

    let store = AirframeCanonicalJSONStore(rootURL: rootURL)
    let directoryURL = store.directoryURL(for: AirframeCanonicalTaskRecord.self)
    try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    try Data("{ malformed".utf8).write(
        to: store.recordURL(for: AirframeID("T-BAD"), as: AirframeCanonicalTaskRecord.self)
    )

    do {
        _ = try store.load(AirframeCanonicalTaskRecord.self, id: AirframeID("T-BAD"))
        Issue.record("Malformed canonical record should throw a decoding error.")
    } catch let error as AirframeBackendError {
        guard case .decodingFailed = error else {
            Issue.record("Expected decodingFailed, got \(error).")
            return
        }
    }
}

@Test func markdownArtifactImporterImportsTaskSprintAndEpicRecords() {
    let markdown = """
    # EP-020: Canonical Airframe Workflow State

    **Status:** Active
    **Owner:** Human / Airframe Planning
    **Start Date:** 2026-06-17

    **Goal:**
    Move Airframe workflow state from Markdown-authored artifacts to canonical records.

    **Rationale:**
    Markdown-authored state can drift.

    ### Related Sprints

    | Sprint | Goal | Status |
    | ------ | ---- | ------ |
    | SP-026 | Import Markdown artifacts. | Active |

    ### Related Tasks

    | Task | Title | Status |
    | ---- | ----- | ------ |
    | T-0120 | Build Markdown artifact importer for existing work products | Active |

    # SP-026: Markdown Import and Projection

    **Status:** Active
    **Epic:** EP-020: Canonical Airframe Workflow State
    **Goal:** Import current Markdown artifacts into canonical records.
    **Start Date:** 2026-06-18
    **End Date:** TBD
    **Capacity:** TBD

    ### Assigned Tasks

    | Task | Title | Priority | Status |
    | ---- | ----- | -------- | ------ |
    | T-0120 | Build Markdown artifact importer for existing work products | High | Active |

    ## T-0120: Build Markdown artifact importer for existing work products

    **Status:** Active
    **GitHub Issue:** #120
    **Component:** AirframeCore / Documentation
    **Priority:** High
    **Epic:** EP-020
    **Sprint Assigned:** SP-026
    **Date Requested:** 2026-06-17
    **Date Implemented:** TBD
    **Date Verified:** TBD

    **Rationale:**
    Existing Airframe work history must be preserved.

    **Acceptance Criteria:**
    1. Existing Epic, Sprint, Task, and Issue Markdown artifacts can be imported into canonical records.
    2. Stable IDs, statuses, relationships, evidence notes, and unstructured narrative are preserved where practical.
    3. Import produces diagnostics for ambiguous or inconsistent artifacts.
    """

    let result = AirframeMarkdownArtifactImporter().importDocument(
        markdown,
        sourcePath: "docs/Tasks/Task-active.md"
    )

    #expect(result.epics.map(\.workItem.id) == [AirframeID("EP-020")])
    #expect(result.sprints.map(\.workItem.id) == [AirframeID("SP-026")])
    #expect(result.tasks.map(\.workItem.id) == [AirframeID("T-0120")])
    #expect(result.epics[0].sprintIDs == [AirframeID("SP-026")])
    #expect(result.epics[0].taskIDs == [AirframeID("T-0120")])
    #expect(result.sprints[0].epicID == AirframeID("EP-020"))
    #expect(result.sprints[0].taskIDs == [AirframeID("T-0120")])
    #expect(result.tasks[0].workItem.githubIssue == 120)
    #expect(result.tasks[0].priority == .high)
    #expect(result.tasks[0].acceptanceCriteria.count == 3)
    #expect(result.tasks[0].metadata.source == "docs/Tasks/Task-active.md")
    #expect(result.diagnostics.map(\.code).contains(.ambiguousField))
}

@Test func markdownArtifactImporterPromotesEpicNoteAcceptanceCriteria() {
    let markdown = """
    ## EP-022: Telemetrix Importer and Canonical Repair Fixes

    **Status:** Active
    **Owner:** Human / Airframe Planning

    **Goal:**
    Fix canonical repair gaps.

    **Notes:**
    - Acceptance Criteria: 1. closed sprint artifacts import from docs/Sprints/Closed/. 2. active epic and sprint statuses import as active. 3. batch task back-links are preserved. 4. canonical create and JSON repair output gaps are covered.
    """

    let result = AirframeMarkdownArtifactImporter().importDocument(
        markdown,
        sourcePath: "docs/generated/Epics/EP-022.md"
    )

    #expect(result.epics.map(\.workItem.id) == [AirframeID("EP-022")])
    #expect(result.epics.first?.acceptanceCriterionIDs == [
        AirframeID("EP-022-AC-01"),
        AirframeID("EP-022-AC-02"),
        AirframeID("EP-022-AC-03"),
        AirframeID("EP-022-AC-04")
    ])
    #expect(result.acceptanceCriteria.map(\.text) == [
        "closed sprint artifacts import from docs/Sprints/Closed/.",
        "active epic and sprint statuses import as active.",
        "batch task back-links are preserved.",
        "canonical create and JSON repair output gaps are covered."
    ])
}

@Test func workStatusParsesEmojiDecoratedMarkdownLabels() {
    // Human-authored docs decorate status with leading emoji and, for issues,
    // a trailing parenthetical note. These must map to canonical statuses.
    #expect(AirframeWorkStatus.fromMarkdownLabel("🟡 Implemented - Not Verified") == .implementedNotVerified)
    #expect(AirframeWorkStatus.fromMarkdownLabel("✅ Implemented - Verified") == .implementedVerified)
    #expect(AirframeWorkStatus.fromMarkdownLabel("✅ Resolved - Verified") == .implementedVerified)
    #expect(AirframeWorkStatus.fromMarkdownLabel("✅ Closed") == .closed)
    #expect(AirframeWorkStatus.fromMarkdownLabel("🟡 Active") == .active)
    #expect(AirframeWorkStatus.fromMarkdownLabel("🔴 Open (backlog, not assigned)") == .backlog)
    #expect(AirframeWorkStatus.fromMarkdownLabel("⚠️ In Progress") == .active)
    // Plain (undecorated) labels still parse.
    #expect(AirframeWorkStatus.fromMarkdownLabel("Active") == .active)
    #expect(AirframeWorkStatus.fromMarkdownLabel("backlog") == .backlog)
    // Unknown labels yield nil so the importer can flag them.
    #expect(AirframeWorkStatus.fromMarkdownLabel("🟣 Frobnicated") == nil)
}

@Test func markdownArtifactImporterParsesEmojiStatusInWorkItemSection() {
    let markdown = """
    ## T-0018: Implement SQLiteTelemetryPersistence.append()

    **Status:** 🟡 Implemented - Not Verified
    **GitHub Issue:** #20
    **Epic:** EP-002
    **Sprint Assigned:** SP-004
    """

    let result = AirframeMarkdownArtifactImporter().importDocument(
        markdown,
        sourcePath: "docs/Tasks/Task-unverified.md"
    )

    #expect(result.tasks.map(\.workItem.id) == [AirframeID("T-0018")])
    #expect(result.tasks[0].workItem.status == .implementedNotVerified)
    // A parseable status must not emit a missing-Status diagnostic.
    #expect(!result.diagnostics.contains {
        $0.code == .missingRequiredField && $0.message.contains("Status")
    })
}

@Test func markdownArtifactImporterImportsRequirementRecordsFromRequirementDocs() {
    let markdown = """
    # Requirements Traceability Requirements

    ## 3. Functional Requirements

    ### RT-FR-001 Requirement Records

    Airframe shall maintain canonical requirement records with stable IDs.

    ### RT-FR-002 Requirement Revision State

    Airframe shall support requirement revision metadata, including status, source, version, rationale, and change history.
    """

    let result = AirframeMarkdownArtifactImporter().importDocument(
        markdown,
        sourcePath: "docs/requirements/RequirementsTraceability_Requirements.md"
    )

    #expect(result.requirements.map(\.id) == [AirframeID("RT-FR-001"), AirframeID("RT-FR-002")])
    #expect(result.requirements.allSatisfy { $0.status == .draft })
    #expect(result.requirements.allSatisfy { $0.sourceKind == .manual })
    #expect(result.requirements.allSatisfy { $0.sourceURI == "docs/requirements/RequirementsTraceability_Requirements.md" })
    #expect(result.requirements.allSatisfy { $0.currentRevisionID != nil })
    #expect(result.requirementRevisions.map(\.id) == [AirframeID("RT-FR-001-R1"), AirframeID("RT-FR-002-R1")])
    #expect(result.requirements[0].title == "Requirement Records")
    #expect(result.requirements[0].statement.contains("canonical requirement records"))
    #expect(result.requirements[1].statement.contains("requirement revision metadata"))
    #expect(result.diagnostics.isEmpty)
}

@Test func markdownArtifactImporterImportsIssueRecordsAndMergesDocuments() {
    let issueMarkdown = """
    ## I-0001: Dashboard status drill-down shows stray selection rectangle

    **Status:** Resolved - Not Verified
    **GitHub Issue:** #101
    **Severity:** Medium
    **Epic:** EP-017
    **Sprint Assigned:** SP-017
    **Date Reported:** 2026-06-12

    **Observed Behavior:**
    The dashboard shows a stray selection rectangle.

    **Expected Behavior:**
    The dashboard should not show unrelated focus chrome.

    **Reproduction Steps:**
    1. Open AgileCockpit.
    2. Select a status row.
    """
    let taskMarkdown = """
    ## T-0123: Document canonical migration and projection workflow

    **Status:** Active
    **GitHub Issue:** #123
    **Component:** Documentation
    **Priority:** Medium
    **Epic:** EP-020
    **Sprint Assigned:** SP-026

    **Rationale:**
    The project needs a documented migration path.
    """

    let result = AirframeMarkdownArtifactImporter().importDocuments([
        AirframeMarkdownDocument(sourcePath: "docs/Issues/Issue-active.md", markdown: issueMarkdown),
        AirframeMarkdownDocument(sourcePath: "docs/Tasks/Task-active.md", markdown: taskMarkdown)
    ])

    #expect(result.issues.map(\.workItem.id) == [AirframeID("I-0001")])
    #expect(result.tasks.map(\.workItem.id) == [AirframeID("T-0123")])
    #expect(result.issues[0].workItem.status == .implementedNotVerified)
    #expect(result.issues[0].reproductionSteps == ["Open AgileCockpit.", "Select a status row."])
    #expect(result.tasks[0].sprintID == AirframeID("SP-026"))
}

@Test func markdownArtifactImporterReportsUnsupportedAndMissingRequiredFields() {
    let unsupported = AirframeMarkdownArtifactImporter().importDocument(
        "# Not an Airframe artifact\n\nNo records here.",
        sourcePath: "docs/README.md"
    )
    let missingStatus = AirframeMarkdownArtifactImporter().importDocument(
        """
        ## T-9999: Missing status task

        **GitHub Issue:** #9999
        **Component:** AirframeCore
        **Priority:** High
        """,
        sourcePath: "docs/Tasks/Task-bad.md"
    )

    #expect(unsupported.diagnostics.map(\.code) == [.unsupportedArtifact])
    #expect(missingStatus.tasks.map(\.workItem.id) == [AirframeID("T-9999")])
    #expect(missingStatus.tasks[0].workItem.status == .backlog)
    #expect(missingStatus.diagnostics.contains {
        $0.code == .missingRequiredField && $0.recordID == AirframeID("T-9999")
    })
    #expect(!missingStatus.isClean)
}

@Test func markdownArtifactProjectorGeneratesDeterministicArtifactMarkdown() {
    let projector = AirframeMarkdownArtifactProjector()
    let task = AirframeCanonicalTaskRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("T-0121"),
            kind: .task,
            title: "Generate deterministic Markdown projections from canonical records",
            status: .active,
            githubIssue: 121
        ),
        component: "AirframeCore / Documentation",
        priority: .high,
        rationale: "Markdown should be generated from canonical state.",
        epicID: AirframeID("EP-020"),
        sprintID: AirframeID("SP-026"),
        dateRequested: "2026-06-17",
        acceptanceCriteria: [
            "AirframeCore can generate Epic, Sprint, Task, and Issue Markdown projections from canonical records.",
            "Generated output is deterministic.",
            "Index counts and tables are derived from canonical records."
        ],
        implementationDetails: "Projection uses canonical fields only."
    )
    let issue = AirframeCanonicalIssueRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("I-0001"),
            kind: .issue,
            title: "Dashboard status drill-down shows stray selection rectangle",
            status: .implementedNotVerified,
            githubIssue: 101
        ),
        severity: .medium,
        observedBehavior: "A stray selection rectangle appears.",
        expectedBehavior: "The UI should not show unrelated focus chrome.",
        epicID: AirframeID("EP-017"),
        sprintID: AirframeID("SP-017"),
        reproductionSteps: ["Open AgileCockpit.", "Select a status row."]
    )
    let sprint = AirframeCanonicalSprintRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("SP-026"),
            kind: .sprint,
            title: "Markdown Import and Projection",
            status: .active
        ),
        epicID: AirframeID("EP-020"),
        goal: "Import Markdown and project documentation.",
        startDate: "2026-06-18",
        taskIDs: [AirframeID("T-0121")]
    )
    let epic = AirframeCanonicalEpicRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("EP-020"),
            kind: .epic,
            title: "Canonical Airframe Workflow State",
            status: .active
        ),
        owner: "Human / Airframe Planning",
        goal: "Move Airframe workflow state into canonical records.",
        rationale: "Markdown state can drift.",
        sprintIDs: [AirframeID("SP-026")],
        taskIDs: [AirframeID("T-0121")]
    )

    #expect(projector.projectTask(task) == projector.projectTask(task))
    #expect(projector.projectTask(task).contains("## T-0121: Generate deterministic Markdown projections from canonical records"))
    #expect(projector.projectTask(task).contains("1. AirframeCore can generate Epic, Sprint, Task, and Issue Markdown projections from canonical records."))
    #expect(projector.projectIssue(issue).contains("**Observed Behavior:**\nA stray selection rectangle appears."))
    #expect(projector.projectIssue(issue).contains("2. Select a status row."))
    #expect(projector.projectSprint(sprint).contains("| T-0121 |  |"))
    #expect(projector.projectEpic(epic).contains("| SP-026 |  |"))
}

@Test func markdownArtifactProjectorOutputImportsBackToCanonicalTask() {
    let task = AirframeCanonicalTaskRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("T-0121"),
            kind: .task,
            title: "Generate deterministic Markdown projections from canonical records",
            status: .active,
            githubIssue: 121
        ),
        component: "AirframeCore / Documentation",
        priority: .high,
        rationale: "Markdown remains valuable for human review.",
        epicID: AirframeID("EP-020"),
        sprintID: AirframeID("SP-026"),
        dateRequested: "2026-06-17",
        acceptanceCriteria: ["Generated output is deterministic."]
    )

    let markdown = AirframeMarkdownArtifactProjector().projectTask(task)
    let imported = AirframeMarkdownArtifactImporter().importDocument(markdown)

    #expect(imported.tasks.count == 1)
    #expect(imported.tasks[0].workItem == task.workItem)
    #expect(imported.tasks[0].component == task.component)
    #expect(imported.tasks[0].epicID == task.epicID)
    #expect(imported.tasks[0].sprintID == task.sprintID)
    #expect(imported.tasks[0].acceptanceCriteria == task.acceptanceCriteria)
    #expect(imported.isClean)
}

@Test func markdownArtifactProjectorDerivesTaskIndexCountsAndOrdering() {
    let records = [
        AirframeCanonicalTaskRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("T-0123"),
                kind: .task,
                title: "Document canonical migration and projection workflow",
                status: .active,
                githubIssue: 123
            ),
            component: "Documentation",
            priority: .medium,
            rationale: "Document migration."
        ),
        AirframeCanonicalTaskRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("T-0120"),
                kind: .task,
                title: "Build Markdown artifact importer for existing work products",
                status: .implementedNotVerified,
                githubIssue: 120
            ),
            component: "AirframeCore",
            priority: .high,
            rationale: "Import existing work history."
        ),
        AirframeCanonicalTaskRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("T-0124"),
                kind: .task,
                title: "Move AICockpit project summary to canonical records",
                status: .backlog,
                githubIssue: 124
            ),
            component: "AICockpit",
            priority: .high,
            rationale: "Use canonical state."
        )
    ]

    let markdown = AirframeMarkdownArtifactProjector().projectTaskIndex(records)
    let firstTaskRange = markdown.range(of: "| T-0120 | #120 |")
    let secondTaskRange = markdown.range(of: "| T-0123 | #123 |")
    let thirdTaskRange = markdown.range(of: "| T-0124 | #124 |")

    #expect(markdown.contains("| Backlog | 1 |"))
    #expect(markdown.contains("| Active | 1 |"))
    #expect(markdown.contains("| Implemented - Not Verified | 1 |"))
    #expect(firstTaskRange?.lowerBound ?? markdown.endIndex < secondTaskRange?.lowerBound ?? markdown.endIndex)
    #expect(secondTaskRange?.lowerBound ?? markdown.endIndex < thirdTaskRange?.lowerBound ?? markdown.endIndex)
}

@Test func markdownImportProjectionRegressionCoversMigrationArtifactShapes() {
    let source = """
    # Active Sprint

    ## SP-026: Markdown Import and Projection

    **Status:** Active
    **Epic:** EP-020: Canonical Airframe Workflow State
    **Goal:** Import current Markdown artifacts into canonical records and generate deterministic documentation projections.
    **Start Date:** 2026-06-18
    **End Date:** TBD
    **Capacity:** TBD

    ### Assigned Tasks

    | Task | Title | Priority | Status |
    | ---- | ----- | -------- | ------ |
    | T-0121 | Generate deterministic Markdown projections from canonical records | High | Active |
    | T-0122 | Add import and projection regression coverage | High | Active |

    ## T-0121: Generate deterministic Markdown projections from canonical records

    **Status:** Active
    **GitHub Issue:** #121
    **Component:** AirframeCore / Documentation
    **Priority:** High
    **Epic:** EP-020
    **Sprint Assigned:** SP-026
    **Date Requested:** 2026-06-17
    **Date Implemented:** TBD
    **Date Verified:** TBD

    **Rationale:**
    Markdown remains valuable for human review and repository documentation, but it should be generated from canonical state.

    **Acceptance Criteria:**
    1. AirframeCore can generate Epic, Sprint, Task, and Issue Markdown projections from canonical records.
    2. Generated output is deterministic.
    3. Index counts and tables are derived from canonical records.

    ## I-0003: Status drill-down detail pane uses incomplete fallback text for Tasks and Issues

    **Status:** Resolved - Not Verified
    **GitHub Issue:** #103
    **Severity:** High
    **Epic:** EP-017
    **Sprint Assigned:** SP-017

    **Observed Behavior:**
    The detail pane renders fallback text.

    **Expected Behavior:**
    The detail pane should render full artifact text.
    """
    let invalid = """
    ## T-9998: Invalid imported Task

    **GitHub Issue:** #9998
    **Priority:** High
    """

    let importer = AirframeMarkdownArtifactImporter()
    let result = importer.importDocuments([
        AirframeMarkdownDocument(sourcePath: "docs/Sprints/Sprint-active.md", markdown: source),
        AirframeMarkdownDocument(sourcePath: "docs/Tasks/Task-invalid.md", markdown: invalid)
    ])
    let projector = AirframeMarkdownArtifactProjector()
    let taskProjection = projector.projectTask(result.tasks.first { $0.workItem.id == AirframeID("T-0121") }!)
    let indexProjection = projector.projectTaskIndex(result.tasks)

    #expect(result.sprints.map(\.workItem.id).contains(AirframeID("SP-026")))
    #expect(result.tasks.map(\.workItem.id).contains(AirframeID("T-0121")))
    #expect(result.issues.map(\.workItem.id).contains(AirframeID("I-0003")))
    #expect(result.diagnostics.contains { $0.code == .missingRequiredField && $0.recordID == AirframeID("T-9998") })
    #expect(taskProjection == projector.projectTask(result.tasks.first { $0.workItem.id == AirframeID("T-0121") }!))
    #expect(taskProjection.contains("**Status:** Active"))
    #expect(indexProjection.contains("| Active | 1 |"))
    #expect(indexProjection.contains("| Backlog | 1 |"))
}

@Test func canonicalWorkflowPolicyCatalogDefinesArtifactLifecycles() throws {
    let catalog = AirframeCanonicalWorkflowPolicyCatalog.airframeDefault
    let taskWorkflow = try #require(catalog.definition(for: .task))
    let issueWorkflow = try #require(catalog.definition(for: .issue))
    let sprintWorkflow = try #require(catalog.definition(for: .sprint))
    let epicWorkflow = try #require(catalog.definition(for: .epic))

    #expect(taskWorkflow.allowedStatuses == [.backlog, .active, .implementedNotVerified, .implementedVerified, .closed])
    #expect(issueWorkflow.allowedStatuses == [.backlog, .active, .implementedNotVerified, .implementedVerified, .closed])
    #expect(sprintWorkflow.allowedStatuses == [.backlog, .planning, .active, .review, .closed])
    #expect(epicWorkflow.allowedStatuses == [.proposed, .draft, .backlog, .active, .complete, .closed])
    #expect(catalog.transitions(for: .task).contains {
        $0.fromStatus == .backlog && $0.toStatus == .active
    })
    #expect(catalog.transitions(for: .sprint).contains {
        $0.fromStatus == .active && $0.toStatus == .backlog
    })
    #expect(catalog.transitions(for: .sprint).contains {
        $0.fromStatus == .review && $0.toStatus == .backlog
    })
    #expect(catalog.transitions(for: .epic).contains {
        $0.fromStatus == .active && $0.toStatus == .backlog
    })
    #expect(catalog.transitions(for: .issue).contains {
        $0.fromStatus == .implementedNotVerified && $0.toStatus == .active
    })
    #expect(catalog.transitions(for: .issue).contains {
        $0.fromStatus == .implementedNotVerified && $0.toStatus == .backlog
    })
}

@Test func canonicalWorkflowPolicyCatalogProtectsHumanOnlyTransitions() throws {
    let catalog = AirframeCanonicalWorkflowPolicyCatalog.airframeDefault
    let taskVerify = try #require(
        catalog.transition(
            for: .task,
            from: .implementedNotVerified,
            to: .implementedVerified
        )
    )
    let sprintClose = try #require(
        catalog.transition(for: .sprint, from: .review, to: .closed)
    )
    let sprintReturnActive = try #require(
        catalog.transition(for: .sprint, from: .active, to: .backlog)
    )
    let epicClose = try #require(
        catalog.transition(for: .epic, from: .complete, to: .closed)
    )

    #expect(taskVerify.operation.category == .humanAcceptance)
    #expect(taskVerify.requiredAuthorityClasses == [.humanOwner, .humanReviewer])
    #expect(!taskVerify.requiredAuthorityClasses.contains(.llmAgent))
    #expect(sprintClose.operation.category == .sprintControl)
    #expect(sprintClose.operation.requiresConfirmation)
    #expect(sprintClose.requiredAuthorityClasses == [.humanOwner, .humanMaintainer])
    #expect(!sprintClose.requiredAuthorityClasses.contains(.llmAgent))
    #expect(!sprintClose.preconditions.isEmpty)
    #expect(sprintReturnActive.operation.category == .sprintControl)
    #expect(sprintReturnActive.operation.requiresConfirmation)
    #expect(sprintReturnActive.requiredAuthorityClasses == [.humanOwner, .humanMaintainer])
    #expect(!sprintReturnActive.requiredAuthorityClasses.contains(.llmAgent))
    #expect(!sprintReturnActive.preconditions.isEmpty)
    #expect(epicClose.operation.category == .epicControl)
    #expect(epicClose.operation.requiresConfirmation)
    #expect(epicClose.requiredAuthorityClasses == [.humanOwner, .humanMaintainer])
    #expect(!epicClose.requiredAuthorityClasses.contains(.automation))
    #expect(epicClose.preconditions == ["All Epic acceptance criteria are verified."])
}

@Test func canonicalStateValidatorDetectsClosedActiveEpicWithOpenWork() {
    let project = AirframeCanonicalProjectRecord(
        id: AirframeID("PRJ-AIRFRAME"),
        name: "Agile Airframe",
        repository: "justgus/Airframe",
        activeEpicID: AirframeID("EP-018")
    )
    let epic = AirframeCanonicalEpicRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("EP-018"),
            kind: .epic,
            title: "AgileCockpit Sprint and Epic Status Controls",
            status: .closed
        ),
        owner: "Human / Airframe Planning",
        goal: "Close Sprint and Epic workflow gaps.",
        rationale: "Planning controls need closeout support.",
        sprintIDs: [AirframeID("SP-022")],
        taskIDs: [AirframeID("T-0107")]
    )
    let sprint = AirframeCanonicalSprintRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("SP-022"),
            kind: .sprint,
            title: "Sprint and Epic Close Gating",
            status: .backlog
        ),
        epicID: AirframeID("EP-018"),
        goal: "Gate close actions.",
        taskIDs: [AirframeID("T-0107")]
    )
    let task = AirframeCanonicalTaskRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("T-0107"),
            kind: .task,
            title: "Gate Sprint close on verified Tasks and Issues",
            status: .backlog
        ),
        component: "AgileCockpit / AirframeCore",
        priority: .high,
        rationale: "Sprint close must stay blocked until work is verified.",
        epicID: AirframeID("EP-018"),
        sprintID: AirframeID("SP-022")
    )

    let diagnostics = AirframeCanonicalStateValidator().diagnostics(
        for: AirframeCanonicalStateSnapshot(
            project: project,
            epics: [epic],
            sprints: [sprint],
            tasks: [task]
        )
    )
    let reasonCodes = Set(diagnostics.diagnostics.map(\.reasonCode))

    #expect(diagnostics.status == .blocking)
    #expect(!diagnostics.isValid)
    #expect(reasonCodes.contains(.activeEpicNotActive))
    #expect(reasonCodes.contains(.closedEpicOwnsOpenWork))
    #expect(diagnostics.diagnostics.contains {
        $0.repairOptions.map(\.action).contains(.restoreEpicToActive)
    })
}

@Test func canonicalStateValidatorDetectsMissingActiveIDsAndRelationshipDrift() {
    let project = AirframeCanonicalProjectRecord(
        id: AirframeID("PRJ-AIRFRAME"),
        name: "Agile Airframe",
        repository: "justgus/Airframe",
        activeEpicID: AirframeID("EP-MISSING"),
        activeSprintID: AirframeID("SP-MISSING")
    )
    let epic = AirframeCanonicalEpicRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("EP-020"),
            kind: .epic,
            title: "Canonical Airframe Workflow State",
            status: .active
        ),
        owner: "Human / Airframe Planning",
        goal: "Move workflow state into canonical records.",
        rationale: "Markdown state can drift.",
        sprintIDs: [AirframeID("SP-025")],
        taskIDs: [AirframeID("T-0116")]
    )
    let sprint = AirframeCanonicalSprintRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("SP-025"),
            kind: .sprint,
            title: "Canonical Store Schema and Validation",
            status: .active
        ),
        epicID: AirframeID("EP-OTHER"),
        goal: "Define schema.",
        taskIDs: [AirframeID("T-0116")]
    )
    let task = AirframeCanonicalTaskRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("T-0116"),
            kind: .task,
            title: "Define canonical workflow record schemas",
            status: .active
        ),
        component: "AirframeCore",
        priority: .high,
        rationale: "Define canonical records.",
        epicID: AirframeID("EP-OTHER"),
        sprintID: AirframeID("SP-OTHER")
    )

    let diagnostics = AirframeCanonicalStateValidator().diagnostics(
        for: AirframeCanonicalStateSnapshot(
            project: project,
            epics: [epic],
            sprints: [sprint],
            tasks: [task]
        )
    )
    let reasonCodes = Set(diagnostics.diagnostics.map(\.reasonCode))

    #expect(reasonCodes.contains(.activeEpicMissing))
    #expect(reasonCodes.contains(.activeSprintMissing))
    #expect(reasonCodes.contains(.epicSprintRelationshipDrift))
    #expect(reasonCodes.contains(.epicTaskRelationshipDrift))
    #expect(reasonCodes.contains(.sprintTaskRelationshipDrift))
}

@Test func canonicalStateValidatorDetectsInvalidTestReferences() {
    let project = AirframeCanonicalProjectRecord(
        id: AirframeID("PRJ-AIRFRAME"),
        name: "Agile Airframe",
        repository: "justgus/Airframe"
    )
    let test = AirframeCanonicalTestRecord(
        id: AirframeID("TEST-MISSING-REFS"),
        title: "Broken traceability test",
        objective: "Exercise canonical diagnostics for invalid test links.",
        kind: .acceptance,
        requirementIDs: [AirframeID("REQ-MISSING")],
        acceptanceCriterionIDs: [AirframeID("AC-MISSING")],
        workItemIDs: [AirframeID("T-MISSING")]
    )
    let suite = AirframeCanonicalTestSuiteRecord(
        id: AirframeID("TS-MISSING-REFS"),
        title: "Broken traceability suite",
        objective: "Exercise canonical diagnostics for invalid suite links.",
        testIDs: [AirframeID("TEST-MISSING")],
        requirementIDs: [AirframeID("REQ-MISSING-2")],
        acceptanceCriterionIDs: [AirframeID("AC-MISSING-2")]
    )
    let run = AirframeCanonicalTestRunRecord(
        id: AirframeID("TR-MISSING-REFS"),
        testID: AirframeID("TEST-MISSING"),
        suiteID: AirframeID("TS-MISSING")
    )

    let diagnostics = AirframeCanonicalStateValidator().diagnostics(
        for: AirframeCanonicalStateSnapshot(
            project: project,
            tests: [test],
            testSuites: [suite],
            testRuns: [run]
        )
    )
    let reasonCodes = Set(diagnostics.diagnostics.map(\.reasonCode))

    #expect(diagnostics.status == .warning)
    #expect(reasonCodes.contains(.testRequirementMissing))
    #expect(reasonCodes.contains(.testAcceptanceCriterionMissing))
    #expect(reasonCodes.contains(.testWorkItemMissing))
    #expect(reasonCodes.contains(.testSuiteTestMissing))
    #expect(reasonCodes.contains(.testRunTestMissing))
    #expect(reasonCodes.contains(.testRunSuiteMissing))
}

@Test func canonicalStateValidatorDetectsSoleActiveSprintPointerMismatch() {
    let project = AirframeCanonicalProjectRecord(
        id: AirframeID("PRJ-AIRFRAME"),
        name: "Agile Airframe",
        repository: "justgus/Airframe",
        activeSprintID: nil,
        sprintIDs: [AirframeID("SP-034")]
    )
    let sprint = canonicalSprint(
        id: "SP-034",
        status: .active,
        epicID: AirframeID("EP-022")
    )

    let diagnostics = AirframeCanonicalStateValidator().diagnostics(
        for: AirframeCanonicalStateSnapshot(
            project: project,
            sprints: [sprint]
        )
    )
    let diagnostic = diagnostics.diagnostics.first { $0.reasonCode == .activeSprintPointerMismatch }

    #expect(diagnostics.status == .blocking)
    #expect(diagnostic?.affectedIDs == [AirframeID("PRJ-AIRFRAME"), AirframeID("SP-034")])
    #expect(diagnostic?.message.contains("project.activeSprintID is None") == true)
    #expect(diagnostic?.repairOptions.first?.action == .setActiveSprintID)
    #expect(diagnostic?.repairOptions.first?.requiresHumanApproval == false)
}

@Test func canonicalStateValidatorDetectsSoleActiveEpicPointerMismatch() {
    let project = AirframeCanonicalProjectRecord(
        id: AirframeID("PRJ-AIRFRAME"),
        name: "Agile Airframe",
        repository: "justgus/Airframe",
        activeEpicID: nil,
        epicIDs: [AirframeID("EP-022")]
    )
    let epic = canonicalEpic(id: "EP-022", status: .active)

    let diagnostics = AirframeCanonicalStateValidator().diagnostics(
        for: AirframeCanonicalStateSnapshot(
            project: project,
            epics: [epic]
        )
    )
    let diagnostic = diagnostics.diagnostics.first { $0.reasonCode == .activeEpicPointerMismatch }

    #expect(diagnostics.status == .blocking)
    #expect(diagnostic?.affectedIDs == [AirframeID("PRJ-AIRFRAME"), AirframeID("EP-022")])
    #expect(diagnostic?.message.contains("project.activeEpicID is None") == true)
    #expect(diagnostic?.repairOptions.first?.action == .setActiveEpicID)
    #expect(diagnostic?.repairOptions.first?.requiresHumanApproval == false)
}

@Test func canonicalStateRepairerCanSetSoleActiveEpicPointer() throws {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AirframeCoreStateRepair")
        .appending(path: UUID().uuidString)
    let repository = AirframeCanonicalStoreRepository(rootURL: rootURL)
    let project = AirframeCanonicalProjectRecord(
        id: AirframeID("PRJ-AIRFRAME"),
        name: "Agile Airframe",
        repository: "justgus/Airframe",
        activeEpicID: nil,
        epicIDs: [AirframeID("EP-022")]
    )
    try repository.store.save(project)
    try repository.store.save(canonicalEpic(id: "EP-022", status: .active))
    let repairOption = try #require(
        AirframeCanonicalStateValidator().diagnostics(
            for: AirframeCanonicalStateSnapshot(
                project: project,
                epics: [canonicalEpic(id: "EP-022", status: .active)]
            )
        ).diagnostics.first { $0.reasonCode == .activeEpicPointerMismatch }?.repairOptions.first
    )

    let result = try AirframeCanonicalStateRepairer().apply(
        repairOption: repairOption,
        repository: repository
    )
    let repairedProject = try #require(try repository.store.load(AirframeCanonicalProjectRecord.self, id: project.id))

    #expect(result.appliedCount == 1)
    #expect(repairedProject.activeEpicID == AirframeID("EP-022"))
}

@Test func canonicalStateValidatorDetectsMultipleActiveSprintsWithoutRepairSelection() {
    let project = AirframeCanonicalProjectRecord(
        id: AirframeID("PRJ-AIRFRAME"),
        name: "Agile Airframe",
        repository: "justgus/Airframe",
        activeSprintID: AirframeID("SP-034"),
        sprintIDs: [AirframeID("SP-034"), AirframeID("SP-035")]
    )
    let sprint034 = canonicalSprint(
        id: "SP-034",
        status: .active,
        epicID: AirframeID("EP-022")
    )
    let sprint035 = canonicalSprint(
        id: "SP-035",
        status: .active,
        epicID: AirframeID("EP-022")
    )

    let diagnostics = AirframeCanonicalStateValidator().diagnostics(
        for: AirframeCanonicalStateSnapshot(
            project: project,
            sprints: [sprint034, sprint035]
        )
    )
    let diagnostic = diagnostics.diagnostics.first { $0.reasonCode == .multipleActiveSprints }

    #expect(diagnostics.status == .blocking)
    #expect(diagnostic?.affectedIDs == [AirframeID("PRJ-AIRFRAME"), AirframeID("SP-034"), AirframeID("SP-035")])
    #expect(diagnostic?.repairOptions.isEmpty == true)
}

@Test func canonicalBackendReconcilerDetectsBackendStatusDriftAndHumanOnlyTransitions() {
    let canonicalRecord = AirframeLocalWorkRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("T-0091"),
            kind: .task,
            title: "Add local create command support",
            status: .implementedVerified
        ),
        epicID: AirframeID("EP-017"),
        sprintID: AirframeID("SP-018")
    )
    let backendRecord = AirframeLocalWorkRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("T-0091"),
            kind: .task,
            title: "Add local create command support",
            status: .implementedNotVerified
        ),
        epicID: AirframeID("EP-017"),
        sprintID: AirframeID("SP-018")
    )

    let diagnostics = AirframeCanonicalBackendReconciler().diagnostics(
        canonicalRecords: [canonicalRecord],
        backendRecords: [backendRecord]
    )
    let diagnostic = diagnostics.first

    #expect(diagnostics.map(\.reasonCode) == [.backendStatusDrift])
    #expect(diagnostic?.message.contains("canonical status is Implemented - Verified") == true)
    #expect(diagnostic?.repairOptions.first?.action == .applyBackendStatusLabels)
    #expect(diagnostic?.repairOptions.first?.requiresHumanApproval == true)
}

@Test func canonicalBackendReconcilerDetectsAgentAllowedBackendRelationshipDrift() {
    let canonicalRecord = AirframeLocalWorkRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("T-0092"),
            kind: .task,
            title: "Add local update command support",
            status: .active
        ),
        epicID: AirframeID("EP-017"),
        sprintID: AirframeID("SP-018")
    )
    let backendRecord = AirframeLocalWorkRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("T-0092"),
            kind: .task,
            title: "Add local update command support",
            status: .active
        ),
        epicID: AirframeID("EP-017"),
        sprintID: AirframeID("SP-017")
    )

    let diagnostics = AirframeCanonicalBackendReconciler().diagnostics(
        canonicalRecords: [canonicalRecord],
        backendRecords: [backendRecord]
    )
    let diagnostic = diagnostics.first

    #expect(diagnostics.map(\.reasonCode) == [.backendRelationshipDrift])
    #expect(diagnostic?.repairOptions.first?.action == .applyBackendRelationshipLabels)
    #expect(diagnostic?.repairOptions.first?.requiresHumanApproval == false)
}

@Test func canonicalBackendRepairerAppliesGitHubBackendLabelReconciliation() throws {
    let canonicalRecord = AirframeLocalWorkRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("T-0128"),
            kind: .task,
            title: "Move AgileCockpit dashboard and planning views to canonical records",
            status: .implementedNotVerified,
            githubIssue: 128
        ),
        epicID: AirframeID("EP-020"),
        sprintID: AirframeID("SP-028"),
        priority: .high
    )
    let backendRecord = AirframeLocalWorkRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("T-0128"),
            kind: .task,
            title: "Move AgileCockpit dashboard and planning views to canonical records",
            status: .active,
            githubIssue: 128
        ),
        epicID: AirframeID("EP-017"),
        sprintID: AirframeID("SP-017"),
        priority: .high
    )
    let transport = RecordingGitHubIssueTransport(
        issues: [
            AirframeGitHubIssueRecord(
                number: 128,
                title: "[T-0128] Move AgileCockpit dashboard and planning views to canonical records",
                labels: ["airframe-task", "status-active", "epic-EP-017", "sprint-SP-017", "priority-high"],
                body: """
                Airframe Type: Task
                Airframe ID: T-0128
                Epic: EP-017
                Sprint: SP-017
                """
            )
        ]
    )
    let backend = AirframeGitHubIssuesBackend(
        configuration: AirframeGitHubBackendConfiguration(repositorySlug: "justgus/Airframe"),
        transport: transport,
        controlledMutationsEnabled: true
    )
    let repairOption = try #require(
        AirframeCanonicalBackendReconciler().diagnostics(
            canonicalRecords: [canonicalRecord],
            backendRecords: [backendRecord]
        ).first?.repairOptions.first
    )

    let result = try AirframeCanonicalBackendRepairer().apply(
        repairOption: repairOption,
        canonicalRecords: [canonicalRecord],
        backend: backend,
        approval: AirframeGitHubMutationApproval(
            isApproved: true,
            approvedBy: "Human",
            reason: "Repair backend drift"
        ),
        context: try certifiedContext(authorityClass: .llmAgent),
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )

    #expect(result.appliedCount == 1)
    #expect(transport.updatedIssues.count == 1)
    #expect(transport.updatedIssues.first?.removedLabels.contains("status-active") == true)
    #expect(transport.updatedIssues.first?.removedLabels.contains("epic-EP-017") == true)
    #expect(transport.updatedIssues.first?.removedLabels.contains("sprint-SP-017") == true)
    #expect(transport.updatedIssues.first?.addedLabels.contains("status-unverified") == true)
    #expect(transport.updatedIssues.first?.addedLabels.contains("epic-EP-020") == true)
    #expect(transport.updatedIssues.first?.addedLabels.contains("sprint-SP-028") == true)
}

@Test func canonicalStateValidatorAcceptsConsistentActiveState() {
    let project = AirframeCanonicalProjectRecord(
        id: AirframeID("PRJ-AIRFRAME"),
        name: "Agile Airframe",
        repository: "justgus/Airframe",
        activeEpicID: AirframeID("EP-020"),
        activeSprintID: AirframeID("SP-025")
    )
    let epic = AirframeCanonicalEpicRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("EP-020"),
            kind: .epic,
            title: "Canonical Airframe Workflow State",
            status: .active
        ),
        owner: "Human / Airframe Planning",
        goal: "Move workflow state into canonical records.",
        rationale: "Markdown state can drift.",
        sprintIDs: [AirframeID("SP-025")],
        taskIDs: [AirframeID("T-0119")]
    )
    let sprint = AirframeCanonicalSprintRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("SP-025"),
            kind: .sprint,
            title: "Canonical Store Schema and Validation",
            status: .active
        ),
        epicID: AirframeID("EP-020"),
        goal: "Define diagnostics.",
        taskIDs: [AirframeID("T-0119")]
    )
    let task = AirframeCanonicalTaskRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("T-0119"),
            kind: .task,
            title: "Add canonical state validation diagnostics",
            status: .active
        ),
        component: "AirframeCore",
        priority: .high,
        rationale: "Detect inconsistent state.",
        epicID: AirframeID("EP-020"),
        sprintID: AirframeID("SP-025")
    )

    let diagnostics = AirframeCanonicalStateValidator().diagnostics(
        for: AirframeCanonicalStateSnapshot(
            project: project,
            epics: [epic],
            sprints: [sprint],
            tasks: [task]
        )
    )

    #expect(diagnostics.status == .info)
    #expect(diagnostics.isValid)
    #expect(diagnostics.diagnostics.isEmpty)
}

@Test func canonicalStateValidatorAcceptsConfiguredActiveSprintInReview() {
    let project = AirframeCanonicalProjectRecord(
        id: AirframeID("PRJ-AIRFRAME"),
        name: "Agile Airframe",
        repository: "justgus/Airframe",
        activeEpicID: AirframeID("EP-020"),
        activeSprintID: AirframeID("SP-025")
    )
    let epic = AirframeCanonicalEpicRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("EP-020"),
            kind: .epic,
            title: "Canonical Airframe Workflow State",
            status: .active
        ),
        owner: "Human / Airframe Planning",
        goal: "Move workflow state into canonical records.",
        rationale: "Markdown state can drift.",
        sprintIDs: [AirframeID("SP-025")]
    )
    let sprint = AirframeCanonicalSprintRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("SP-025"),
            kind: .sprint,
            title: "Canonical Store Schema and Validation",
            status: .review
        ),
        epicID: AirframeID("EP-020"),
        goal: "Define diagnostics."
    )

    let diagnostics = AirframeCanonicalStateValidator().diagnostics(
        for: AirframeCanonicalStateSnapshot(
            project: project,
            epics: [epic],
            sprints: [sprint]
        )
    )

    #expect(diagnostics.status == .info)
    #expect(diagnostics.isValid)
    #expect(diagnostics.diagnostics.isEmpty)
}

@Test func planningModelsTrackEpicCriteriaAndCloseEligibility() {
    let summary = AirframeEpicAcceptanceCriteriaSummary(
        epicID: AirframeID("EP-018"),
        criteria: [
            AirframeEpicAcceptanceCriterion(
                id: AirframeID("EP-018-AC-01"),
                text: "AgileCockpit shows Epic acceptance criteria.",
                isVerified: true
            ),
            AirframeEpicAcceptanceCriterion(
                id: AirframeID("EP-018-AC-02"),
                text: "Sprint close is gated.",
                isVerified: false
            )
        ]
    )
    let epicEligibility = AirframeEpicCloseEligibility(criteriaSummary: summary)
    let sprintEligibility = AirframeSprintCloseEligibility(
        sprintID: AirframeID("SP-020"),
        assignedWorkItems: [
            AirframeWorkItem(
                id: AirframeID("T-0101"),
                kind: .task,
                title: "Define Epic acceptance criteria verification model",
                status: .implementedVerified
            ),
            AirframeWorkItem(
                id: AirframeID("T-0102"),
                kind: .task,
                title: "Extend planning model for Epic and Sprint close eligibility",
                status: .active
            )
        ]
    )

    #expect(summary.totalCount == 2)
    #expect(summary.verifiedCount == 1)
    #expect(!summary.allCriteriaVerified)
    #expect(!epicEligibility.eligibility.isEligible)
    #expect(epicEligibility.eligibility.blockingReasons == ["EP-018-AC-02 is not verified."])
    #expect(!sprintEligibility.eligibility.isEligible)
    #expect(sprintEligibility.blockingWorkItems.map(\.id) == [AirframeID("T-0102")])
}

@Test func canonicalAcceptanceCriterionDecodesLegacyVerificationState() throws {
    let data = Data("""
    {
      "metadata": { "schemaVersion": { "major": 1, "minor": 0, "patch": 0 } },
      "id": { "rawValue": "EP-001-AC-01" },
      "ownerID": { "rawValue": "EP-001" },
      "text": "Legacy criterion",
      "isVerified": true,
      "evidenceIDs": []
    }
    """.utf8)

    let criterion = try JSONDecoder().decode(AirframeCanonicalAcceptanceCriterionRecord.self, from: data)
    #expect(criterion.disposition == .verified)
    #expect(criterion.isVerified)

    let summaryData = Data("""
    {
      "epicID": { "rawValue": "EP-001" },
      "criteria": [
        {
          "id": { "rawValue": "EP-001-AC-01" },
          "text": "Legacy criterion",
          "isVerified": true
        }
      ]
    }
    """.utf8)
    let summary = try JSONDecoder().decode(AirframeEpicAcceptanceCriteriaSummary.self, from: summaryData)
    #expect(summary.criteria.first?.disposition == .verified)
    #expect(!summary.allowsHistoricalCloseDisposition)
}

@Test func historicalCloseDispositionDoesNotAuthorizeCurrentEpicClose() {
    let criterion = AirframeEpicAcceptanceCriterion(
        id: AirframeID("EP-025-AC-01"),
        text: "Current criterion",
        disposition: .grandfatheredHistoricalClose
    )
    let currentSummary = AirframeEpicAcceptanceCriteriaSummary(
        epicID: AirframeID("EP-025"),
        criteria: [criterion]
    )
    let historicalSummary = AirframeEpicAcceptanceCriteriaSummary(
        epicID: AirframeID("EP-001"),
        criteria: [criterion],
        allowsHistoricalCloseDisposition: true
    )

    #expect(!AirframeEpicCloseEligibility(criteriaSummary: currentSummary).eligibility.isEligible)
    #expect(AirframeEpicCloseEligibility(criteriaSummary: historicalSummary).eligibility.isEligible)
    #expect(!criterion.isVerified)
}

@Test func historicalCloseMigrationPreviewFindsOnlyThe42ApprovedCriteria() throws {
    let historicalEpics = (1...8).map {
        canonicalEpic(id: String(format: "EP-%03d", $0), status: .closed)
    }
    let criteria = (1...42).map { index in
        AirframeCanonicalAcceptanceCriterionRecord(
            id: AirframeID(String(format: "HIST-AC-%02d", index)),
            ownerID: AirframeID(String(format: "EP-%03d", ((index - 1) % 8) + 1)),
            text: "Historical criterion \(index)"
        )
    }
    let ineligibleCriterion = AirframeCanonicalAcceptanceCriterionRecord(
        id: AirframeID("EP-009-AC-01"),
        ownerID: AirframeID("EP-009"),
        text: "Not approved for migration"
    )
    let migration = AirframeHistoricalCloseAcceptanceMigration()
    let preview = migration.preview(
        epics: historicalEpics + [canonicalEpic(id: "EP-009", status: .closed)],
        criteria: criteria + [ineligibleCriterion]
    )

    #expect(preview.eligibleEpicIDs.count == 8)
    #expect(preview.criterionCount == 42)

    let migrated = try migration.migrate(
        epics: historicalEpics,
        criteria: criteria,
        explicitlyApprovedEpicIDs: AirframeHistoricalCloseAcceptanceMigration.approvedHistoricalEpicIDs
    )
    #expect(migrated.allSatisfy { $0.disposition == .grandfatheredHistoricalClose })
    #expect(migrated.allSatisfy { !$0.isVerified })

    #expect(throws: AirframeHistoricalCloseAcceptanceMigrationError.ineligibleEpicIDs([AirframeID("EP-009")])) {
        try migration.migrate(
            epics: historicalEpics + [canonicalEpic(id: "EP-009", status: .closed)],
            criteria: criteria + [ineligibleCriterion],
            explicitlyApprovedEpicIDs: [AirframeID("EP-009")]
        )
    }
}

@Test func planningModelsAllowCloseWhenPrerequisitesAreVerified() {
    let criteriaSummary = AirframeEpicAcceptanceCriteriaSummary(
        epicID: AirframeID("EP-018"),
        criteria: [
            AirframeEpicAcceptanceCriterion(
                id: AirframeID("EP-018-AC-01"),
                text: "Criterion is verified.",
                isVerified: true
            )
        ]
    )
    let sprintEligibility = AirframeSprintCloseEligibility(
        sprintID: AirframeID("SP-020"),
        assignedWorkItems: [
            AirframeWorkItem(
                id: AirframeID("T-0101"),
                kind: .task,
                title: "Verified task",
                status: .implementedVerified
            ),
            AirframeWorkItem(
                id: AirframeID("I-0001"),
                kind: .issue,
                title: "Verified issue",
                status: .implementedVerified
            )
        ]
    )

    #expect(AirframeEpicCloseEligibility(criteriaSummary: criteriaSummary).eligibility.isEligible)
    #expect(sprintEligibility.eligibility.isEligible)
    #expect(sprintEligibility.blockingWorkItems.isEmpty)
}

@Test func certifiedContextBindsActorCredentialAndProjectScope() throws {
    let actor = AirframeActor(
        id: AirframeID("ACTOR-LLM"),
        displayName: "Codex",
        authorityClass: .llmAgent,
        credentialSource: .cliEnvironment
    )
    let credential = AirframeCredentialContext(
        credentialID: AirframeID("CRED-CLI"),
        actorID: actor.id,
        credentialSource: .cliEnvironment,
        executionProjectID: AirframeID("PRJ-AIRFRAME"),
        allowedProjectIDs: [AirframeID("PRJ-AIRFRAME")]
    )

    let context = try AirframeCertifiedContext(
        actor: actor,
        credential: credential,
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )

    #expect(context.actor.authorityClass == .llmAgent)
    #expect(context.executionProjectID == AirframeID("PRJ-AIRFRAME"))
    #expect(context.targetProjectID == AirframeID("PRJ-AIRFRAME"))
}

@Test func certifiedContextRejectsCallerSpoofedActorIdentity() {
    let actor = AirframeActor(
        id: AirframeID("ACTOR-SPOOFED"),
        displayName: "Spoofed Owner",
        authorityClass: .humanOwner,
        credentialSource: .cliEnvironment
    )
    let credential = AirframeCredentialContext(
        credentialID: AirframeID("CRED-CLI"),
        actorID: AirframeID("ACTOR-LLM"),
        credentialSource: .cliEnvironment,
        executionProjectID: AirframeID("PRJ-AIRFRAME"),
        allowedProjectIDs: [AirframeID("PRJ-AIRFRAME")]
    )

    #expect(
        throws: AirframeCertificationError.actorCredentialMismatch(
            actorID: AirframeID("ACTOR-SPOOFED"),
            credentialActorID: AirframeID("ACTOR-LLM")
        )
    ) {
        try AirframeCertifiedContext(
            actor: actor,
            credential: credential,
            targetProjectID: AirframeID("PRJ-AIRFRAME")
        )
    }
}

@Test func certifiedContextRejectsOutOfScopeTargetProject() {
    let actor = AirframeActor(
        id: AirframeID("ACTOR-LLM"),
        displayName: "Codex",
        authorityClass: .llmAgent,
        credentialSource: .cliEnvironment
    )
    let credential = AirframeCredentialContext(
        credentialID: AirframeID("CRED-CLI"),
        actorID: actor.id,
        credentialSource: .cliEnvironment,
        executionProjectID: AirframeID("PRJ-AIRFRAME"),
        allowedProjectIDs: [AirframeID("PRJ-AIRFRAME")]
    )

    #expect(throws: AirframeCertificationError.targetProjectOutOfScope(AirframeID("PRJ-OTHER"))) {
        try AirframeCertifiedContext(
            actor: actor,
            credential: credential,
            targetProjectID: AirframeID("PRJ-OTHER")
        )
    }
}

@Test func authorityEvaluatorAllowsLLMProposalAndEvidenceOperations() throws {
    let context = try certifiedContext(authorityClass: .llmAgent)
    let evaluator = AirframeAuthorityEvaluator()

    let proposalDecision = evaluator.evaluate(
        context: context,
        operation: AirframeOperation(id: AirframeID("OP-PROPOSE-TASK"), category: .proposal),
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )
    let evidenceDecision = evaluator.evaluate(
        context: context,
        operation: AirframeOperation(id: AirframeID("OP-ATTACH-EVIDENCE"), category: .evidence),
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )

    #expect(proposalDecision == .allowed())
    #expect(evidenceDecision.isAllowed)
}

@Test func authorityEvaluatorDeniesLLMHumanOnlyOperation() throws {
    let context = try certifiedContext(authorityClass: .llmAgent)

    let decision = AirframeAuthorityEvaluator().evaluate(
        context: context,
        operation: AirframeOperation(id: AirframeID("OP-ACCEPT-WORK"), category: .humanAcceptance),
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )

    #expect(decision == .denied(reason: .authorityClassNotPermitted))
    #expect(decision.reason == .authorityClassNotPermitted)
}

@Test func authorityEvaluatorDeniesProjectMismatch() throws {
    let context = try certifiedContext(authorityClass: .humanOwner)

    let decision = AirframeAuthorityEvaluator().evaluate(
        context: context,
        operation: AirframeOperation(id: AirframeID("OP-PROPOSE-TASK"), category: .proposal),
        targetProjectID: AirframeID("PRJ-OTHER")
    )

    #expect(decision == .denied(reason: .projectScopeMismatch))
}

@Test func authorityEvaluatorDeniesUncertifiedContext() {
    let decision = AirframeAuthorityEvaluator().evaluate(
        context: nil,
        operation: AirframeOperation(id: AirframeID("OP-READ"), category: .read),
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )

    #expect(decision == .denied(reason: .uncertifiedContext))
}

@Test func authorityEvaluatorReturnsRequiresConfirmation() throws {
    let context = try certifiedContext(authorityClass: .humanOwner)

    let decision = AirframeAuthorityEvaluator().evaluate(
        context: context,
        operation: AirframeOperation(
            id: AirframeID("OP-CLOSE-SPRINT"),
            category: .sprintControl,
            requiresConfirmation: true
        ),
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )

    #expect(decision == .requiresConfirmation())
    #expect(decision.reason == .requiresConfirmation)
}

@Test func workflowEvaluatorAllowsValidAuthorizedTransition() throws {
    let context = try certifiedContext(authorityClass: .llmAgent)
    let transition = AirframeWorkflowTransition(
        workItemID: AirframeID("T-0014"),
        kind: .task,
        fromStatus: .active,
        toStatus: .implementedNotVerified,
        operation: AirframeOperation(id: AirframeID("OP-MARK-IMPLEMENTED"), category: .workflowTransition)
    )

    let decision = AirframeWorkflowTransitionEvaluator().evaluate(
        context: context,
        transition: transition,
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )

    #expect(decision == .allowed)
    #expect(decision.isAllowed)
}

@Test func workflowEvaluatorAllowsIssueRollbackTransitions() throws {
    let context = try certifiedContext(authorityClass: .llmAgent)
    let evaluator = AirframeWorkflowTransitionEvaluator()
    let toActive = AirframeWorkflowTransition(
        workItemID: AirframeID("I-0029"),
        kind: .issue,
        fromStatus: .implementedNotVerified,
        toStatus: .active,
        operation: AirframeOperation(id: AirframeID("OP-RETURN-ISSUE-TO-ACTIVE"), category: .workflowTransition)
    )
    let toBacklog = AirframeWorkflowTransition(
        workItemID: AirframeID("I-0029"),
        kind: .issue,
        fromStatus: .implementedNotVerified,
        toStatus: .backlog,
        operation: AirframeOperation(id: AirframeID("OP-RETURN-ISSUE-TO-BACKLOG"), category: .workflowTransition)
    )

    #expect(
        evaluator.evaluate(
            context: context,
            transition: toActive,
            targetProjectID: AirframeID("PRJ-AIRFRAME")
        ) == .allowed
    )
    #expect(
        evaluator.evaluate(
            context: context,
            transition: toBacklog,
            targetProjectID: AirframeID("PRJ-AIRFRAME")
        ) == .allowed
    )
}

@Test func workflowEvaluatorDeniesInvalidTransitionBeforeAuthority() throws {
    let context = try certifiedContext(authorityClass: .humanOwner)
    let transition = AirframeWorkflowTransition(
        workItemID: AirframeID("T-0014"),
        kind: .task,
        fromStatus: .backlog,
        toStatus: .implementedVerified,
        operation: AirframeOperation(id: AirframeID("OP-SKIP-VERIFY"), category: .humanAcceptance)
    )

    let decision = AirframeWorkflowTransitionEvaluator().evaluate(
        context: context,
        transition: transition,
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )

    #expect(decision == .denied(reason: .invalidTransition, authorityReason: nil))
}

@Test func workflowEvaluatorCarriesAuthorityDenialReason() throws {
    let context = try certifiedContext(authorityClass: .llmAgent)
    let transition = AirframeWorkflowTransition(
        workItemID: AirframeID("T-0013"),
        kind: .task,
        fromStatus: .implementedNotVerified,
        toStatus: .implementedVerified,
        operation: AirframeOperation(id: AirframeID("OP-HUMAN-VERIFY"), category: .humanAcceptance)
    )

    let decision = AirframeWorkflowTransitionEvaluator().evaluate(
        context: context,
        transition: transition,
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )

    #expect(
        decision == .denied(
            reason: .authorityDenied,
            authorityReason: .authorityClassNotPermitted
        )
    )
}

@Test func auditStoreRecordsAllowedAndDeniedWriteAttempts() throws {
    let context = try certifiedContext(authorityClass: .llmAgent)
    var store = AirframeAuditEventStore()

    let allowed = store.record(
        id: AirframeID("AUD-0001"),
        context: context,
        action: "OP-ATTACH-EVIDENCE",
        workItemID: AirframeID("T-0013"),
        decision: .allowed(),
        targetProjectID: AirframeID("PRJ-AIRFRAME"),
        timestamp: Date(timeIntervalSince1970: 0)
    )
    let denied = store.record(
        id: AirframeID("AUD-0002"),
        context: context,
        action: "OP-ACCEPT-WORK",
        workItemID: AirframeID("T-0013"),
        decision: .denied(reason: .authorityClassNotPermitted),
        targetProjectID: AirframeID("PRJ-AIRFRAME"),
        timestamp: Date(timeIntervalSince1970: 1)
    )

    #expect(store.events.count == 2)
    #expect(allowed.reason == .allowed)
    #expect(denied.reason == .authorityClassNotPermitted)
    #expect(denied.actorID == AirframeID("ACTOR-LLMAgent"))
}

@Test func sampleConfigurationLoadsDeterministicProjectContext() throws {
    let context = try AirframeConfigurationLoader().loadSampleContext()

    #expect(context.workspaceName == "Airframe")
    #expect(context.projectName == "Agile Airframe")
    #expect(context.project.activeSprintID == nil)
    #expect(context.project.activeEpicID == nil)
    #expect(context.summaryLines.contains("Repository: justgus/Airframe"))
}

@Test func sampleConfigurationProducesReleaseCandidateDiagnostics() throws {
    let configuration = try AirframeConfigurationLoader().loadSampleConfiguration()
    let diagnostics = AirframeConfigurationLoader().diagnostics(for: configuration)

    #expect(diagnostics.status == .ok)
    #expect(diagnostics.isValid)
    #expect(diagnostics.workspaceID == AirframeID("WS-AIRFRAME"))
    #expect(diagnostics.defaultProjectID == AirframeID("PRJ-AIRFRAME"))
    #expect(diagnostics.projectCount == 1)
    #expect(diagnostics.backendKind == "github-fixture")
    #expect(diagnostics.backendLocation == "justgus/Airframe")
    #expect(diagnostics.issues.isEmpty)
}

@Test func runtimeConfigurationResolverLoadsExplicitLiveConfigurationAndStorePath() throws {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AirframeCoreRuntimeResolver-\(UUID().uuidString)")
    try FileManager.default.createDirectory(
        at: rootURL.appending(path: ".airframe"),
        withIntermediateDirectories: true
    )
    let configurationURL = rootURL.appending(path: ".airframe").appending(path: "airframe-workspace.json")
    try liveConfigurationData.write(to: configurationURL)

    let resolver = AirframeRuntimeConfigurationResolver(
        environment: [:],
        currentDirectoryURL: rootURL
    )
    let context = try resolver.loadContext()
    let diagnostics = AirframeConfigurationLoader().diagnostics(for: context.configuration)

    #expect(context.workspaceName == "Airframe Live Demo")
    #expect(context.project.activeSprintID == AirframeID("SP-009"))
    #expect(context.project.activeEpicID == AirframeID("EP-009"))
    #expect(diagnostics.status == .ok)
    #expect(resolver.storeURL().path.hasSuffix(".airframe/airframe-local-backend.json"))
}

@Test func runtimeConfigurationResolverPrefersEnvironmentPaths() throws {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AirframeCoreRuntimeEnvironment-\(UUID().uuidString)")
    let configURL = rootURL.appending(path: "live-config.json")
    let storeURL = rootURL.appending(path: "custom-store.json")
    try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
    try liveConfigurationData.write(to: configURL)

    let resolver = AirframeRuntimeConfigurationResolver(
        environment: [
            "AIRFRAME_CONFIG_PATH": configURL.path,
            "AIRFRAME_STORE_PATH": storeURL.path
        ],
        currentDirectoryURL: URL(filePath: "/tmp/unused-airframe-runtime")
    )

    #expect(try resolver.loadContext().workspaceName == "Airframe Live Demo")
    #expect(resolver.storeURL() == storeURL)
}

@Test func missingConfigurationReturnsStructuredError() {
    let missingURL = URL(filePath: "/tmp/airframe-missing-config.json")

    #expect(throws: AirframeConfigurationError.missingFile(missingURL.path)) {
        try AirframeConfigurationLoader().load(from: missingURL)
    }
}

@Test func malformedConfigurationReturnsStructuredError() {
    let data = Data("{".utf8)

    #expect(throws: AirframeConfigurationError.self) {
        try AirframeConfigurationLoader().load(data: data)
    }
}

@Test func invalidConfigurationReturnsStructuredError() {
    let data = Data(
        """
        {
          "schemaVersion": 1,
          "workspace": { "id": { "rawValue": "WS-AIRFRAME" }, "name": "Airframe", "rootPath": "." },
          "projects": [],
          "defaultProjectID": { "rawValue": "PRJ-AIRFRAME" },
          "backend": { "kind": "local-fixture", "location": "docs" }
        }
        """.utf8
    )

    #expect(throws: AirframeConfigurationError.invalidConfiguration("At least one project is required.")) {
        try AirframeConfigurationLoader().load(data: data)
    }
}

@Test func invalidConfigurationDiagnosticsExplainBackendAndProjectFailures() throws {
    let data = Data(
        """
        {
          "schemaVersion": 1,
          "workspace": { "id": { "rawValue": "WS-AIRFRAME" }, "name": "Airframe", "rootPath": "." },
          "projects": [
            {
              "id": { "rawValue": "PRJ-AIRFRAME" },
              "name": "Agile Airframe",
              "repository": "",
              "activeSprintID": { "rawValue": "" },
              "activeEpicID": { "rawValue": "EP-008" }
            }
          ],
          "defaultProjectID": { "rawValue": "PRJ-MISSING" },
          "backend": { "kind": "github-live", "location": "Airframe" }
        }
        """.utf8
    )

    let diagnostics = try AirframeConfigurationLoader().diagnostics(data: data)
    let codes = Set(diagnostics.issues.map(\.code))

    #expect(diagnostics.status == .error)
    #expect(!diagnostics.isValid)
    #expect(codes.contains("missingDefaultProject"))
    #expect(codes.contains("missingProjectRepository"))
    #expect(codes.contains("missingActiveSprintID"))
    #expect(codes.contains("unsupportedBackendKind"))
    #expect(codes.contains("invalidGitHubRepository"))
}

@Test func localBackendCreatesQueriesAndUpdatesWorkRecords() throws {
    let backend = try makeLocalBackend()
    let record = localTaskRecord(id: "T-0018", title: "Define backend adapter protocol and capabilities")

    try backend.createWorkRecord(record)
    let stored = try backend.workRecord(id: AirframeID("T-0018"))

    #expect(backend.capabilities.supportsCreateWorkItem)
    #expect(stored?.workItem.title == "Define backend adapter protocol and capabilities")
    #expect(try backend.listWorkItems().map(\.id) == [AirframeID("T-0018")])

    let updated = AirframeWorkItem(
        id: AirframeID("T-0018"),
        kind: .task,
        title: "Define local backend adapter protocol and capabilities",
        status: .active,
        githubIssue: 18
    )
    try backend.updateWorkItem(updated)

    #expect(try backend.workRecord(id: AirframeID("T-0018"))?.workItem.title == updated.title)
}

@Test func localBackendRejectsDuplicateWorkRecords() throws {
    let backend = try makeLocalBackend()
    let record = localTaskRecord(id: "T-0018", title: "Define backend adapter protocol and capabilities")

    try backend.createWorkRecord(record)

    #expect(throws: AirframeBackendError.duplicateWorkItem(AirframeID("T-0018"))) {
        try backend.createWorkRecord(record)
    }
}

@Test func localBackendAttachesEvidenceAndMarksTaskReadyForVerification() throws {
    let backend = try makeLocalBackend()
    let context = try certifiedContext(authorityClass: .llmAgent)
    let record = localTaskRecord(id: "T-0020", title: "Implement evidence attachment workflow")
    let evidence = AirframeEvidence(
        id: AirframeID("EV-0020-001"),
        summary: "Core local backend tests passed",
        artifact: "swift test --package-path AirframeCore"
    )

    try backend.createWorkRecord(record)
    try backend.attachEvidence(evidence, to: AirframeID("T-0020"))
    try backend.transitionWorkItem(
        id: AirframeID("T-0020"),
        to: .implementedNotVerified,
        context: context,
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )

    #expect(try backend.evidence(for: AirframeID("T-0020")) == [evidence])
    #expect(try backend.workRecord(id: AirframeID("T-0020"))?.workItem.status == .implementedNotVerified)
}

@Test func localBackendDeniesHumanVerificationForLLMActor() throws {
    let backend = try makeLocalBackend()
    let context = try certifiedContext(authorityClass: .llmAgent)
    let record = localTaskRecord(
        id: "T-0020",
        title: "Implement evidence attachment workflow",
        status: .implementedNotVerified
    )

    try backend.createWorkRecord(record)

    #expect(throws: AirframeBackendError.authorityDenied(.authorityClassNotPermitted)) {
        try backend.transitionWorkItem(
            id: AirframeID("T-0020"),
            to: .implementedVerified,
            context: context,
            targetProjectID: AirframeID("PRJ-AIRFRAME")
        )
    }
}

@Test func localBackendAppliesHumanVerificationActionsForHumanReviewer() throws {
    let backend = try makeLocalBackend()
    let context = try certifiedContext(authorityClass: .humanReviewer)
    let accepted = localTaskRecord(
        id: "T-0032",
        title: "Implement human verification actions",
        status: .implementedNotVerified
    )
    let needsEvidence = localTaskRecord(
        id: "T-0031",
        title: "Implement verification queue and review flow",
        status: .implementedNotVerified
    )

    try backend.createWorkRecord(accepted)
    try backend.createWorkRecord(needsEvidence)

    let acceptedResult = try backend.applyHumanVerification(
        action: .accept,
        to: AirframeID("T-0032"),
        context: context,
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )
    let evidenceResult = try backend.applyHumanVerification(
        action: .requestMoreEvidence,
        to: AirframeID("T-0031"),
        context: context,
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )

    #expect(acceptedResult.decision.isAllowed)
    #expect(acceptedResult.workItem.status == .implementedVerified)
    #expect(evidenceResult.action == .requestMoreEvidence)
    #expect(evidenceResult.workItem.status == .active)
    #expect(try backend.workRecord(id: AirframeID("T-0032"))?.workItem.status == .implementedVerified)
    #expect(try backend.workRecord(id: AirframeID("T-0031"))?.workItem.status == .active)
}

@Test func localBackendRejectsVerificationActionOutsideReadyState() throws {
    let backend = try makeLocalBackend()
    let context = try certifiedContext(authorityClass: .humanReviewer)
    let record = localTaskRecord(
        id: "T-0032",
        title: "Implement human verification actions",
        status: .active
    )

    try backend.createWorkRecord(record)

    #expect(throws: AirframeBackendError.invalidTransition(from: .active, to: .implementedVerified)) {
        try backend.applyHumanVerification(
            action: .accept,
            to: AirframeID("T-0032"),
            context: context,
            targetProjectID: AirframeID("PRJ-AIRFRAME")
        )
    }
}

@Test func localBackendGeneratesTaskPacketFromStoredRecord() throws {
    let backend = try makeLocalBackend()
    let record = localTaskRecord(
        id: "T-0021",
        title: "Implement task packet generation",
        acceptanceCriteria: ["Task packets include objective, acceptance criteria, constraints, and report format."],
        scope: ["AirframeCore local backend"],
        constraints: ["Do not scrape markdown for canonical state."],
        evidenceRequirements: ["Core tests pass."],
        protectedPaths: ["docs/Tasks/Verified"]
    )

    try backend.createWorkRecord(record)
    let packet = try backend.taskPacket(for: AirframeID("T-0021"))

    #expect(packet.workItem.id == AirframeID("T-0021"))
    #expect(packet.objective == "Implement task packet generation")
    #expect(packet.acceptanceCriteria == record.acceptanceCriteria)
    #expect(packet.constraints.contains("Do not scrape markdown for canonical state."))
    #expect(packet.protectedPaths == ["docs/Tasks/Verified"])
    #expect(packet.reportFormat.contains("verification commands"))
}

@Test func localBackendProducesDashboardSummaryFromLocalRecords() throws {
    let backend = try makeLocalBackend()

    try backend.createWorkRecord(localTaskRecord(id: "T-0018", title: "Define backend adapter protocol"))
    try backend.createWorkRecord(localTaskRecord(
        id: "T-0020",
        title: "Implement evidence attachment workflow",
        status: .implementedNotVerified
    ))
    try backend.createWorkRecord(localTaskRecord(
        id: "T-0012",
        title: "Implement actor and certified context model",
        status: .implementedVerified
    ))
    try backend.createWorkRecord(AirframeLocalWorkRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("I-0001"),
            kind: .issue,
            title: "Example local issue",
            status: .active
        ),
        priority: .medium
    ))
    try backend.attachEvidence(
        AirframeEvidence(id: AirframeID("EV-001"), summary: "Evidence", artifact: "artifact.txt"),
        to: AirframeID("T-0020")
    )

    let summary = try backend.dashboardSummary()

    #expect(summary.totalWorkItemCount == 4)
    #expect(summary.activeTaskCount == 1)
    #expect(summary.unverifiedTaskCount == 1)
    #expect(summary.verifiedTaskCount == 1)
    #expect(summary.issueCount == 1)
    #expect(summary.nextTask?.id == AirframeID("T-0018"))
    #expect(summary.recentEvidenceCount == 1)
}

@Test func canonicalProjectSummaryReportsTaskIssueCountsAndNextTask() {
    let tasks = [
        canonicalTaskRecord(id: "T-0003", title: "Third active task", status: .active),
        canonicalTaskRecord(id: "T-0001", title: "First active task", status: .active),
        canonicalTaskRecord(id: "T-0002", title: "Implemented task", status: .implementedNotVerified),
        canonicalTaskRecord(id: "T-0004", title: "Verified task", status: .implementedVerified)
    ]
    let issues = [
        AirframeCanonicalIssueRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("I-0001"),
                kind: .issue,
                title: "Tracked issue",
                status: .active
            ),
            severity: .high,
            observedBehavior: "Observed",
            expectedBehavior: "Expected"
        )
    ]
    let evidence = [
        AirframeCanonicalEvidenceSummaryRecord(
            id: AirframeID("EV-0001"),
            workItemIDs: [AirframeID("T-0004")],
            summary: "Tests passed",
            result: .passed
        )
    ]

    let summary = AirframeCanonicalProjectSummary().dashboardSummary(
        epics: [
            AirframeCanonicalEpicRecord(
                workItem: AirframeWorkItem(
                    id: AirframeID("EP-0001"),
                    kind: .epic,
                    title: "Tracked epic",
                    status: .active
                ),
                owner: "Human",
                goal: "Goal",
                rationale: "Rationale"
            )
        ],
        sprints: [
            AirframeCanonicalSprintRecord(
                workItem: AirframeWorkItem(
                    id: AirframeID("SP-0001"),
                    kind: .sprint,
                    title: "Tracked sprint",
                    status: .active
                ),
                epicID: AirframeID("EP-0001"),
                goal: "Goal"
            )
        ],
        tasks: tasks,
        issues: issues,
        evidence: evidence
    )

    #expect(summary.totalWorkItemCount == 7)
    #expect(summary.activeTaskCount == 2)
    #expect(summary.unverifiedTaskCount == 1)
    #expect(summary.verifiedTaskCount == 1)
    #expect(summary.issueCount == 1)
    #expect(summary.nextTask?.id == AirframeID("T-0001"))
    #expect(summary.recentEvidenceCount == 1)
}

@Test func canonicalTaskPacketAssemblerIncludesEvidenceAndRelationshipDiagnostics() {
    let task = AirframeCanonicalTaskRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("T-0125"),
            kind: .task,
            title: "Move AICockpit task packet generation to canonical records",
            status: .active,
            githubIssue: 125
        ),
        component: "AICockpit / AirframeCore",
        priority: .high,
        rationale: "Agent task packets need reliable structured state.",
        epicID: AirframeID("EP-020"),
        sprintID: AirframeID("SP-027"),
        acceptanceCriteria: ["Task packets are assembled from canonical records."],
        componentsAffected: ["AICockpit", "AirframeCore"],
        testSteps: ["swift test --package-path AirframeCore"],
        notes: ["Preserve output compatibility."]
    )
    let epic = AirframeCanonicalEpicRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("EP-020"),
            kind: .epic,
            title: "Canonical Airframe Workflow State",
            status: .active
        ),
        owner: "Human",
        goal: "Canonical state",
        rationale: "Rationale",
        taskIDs: [AirframeID("T-0125")]
    )
    let evidence = AirframeCanonicalEvidenceSummaryRecord(
        id: AirframeID("EV-0125-001"),
        workItemIDs: [AirframeID("T-0125")],
        summary: "Core tests passed",
        result: .passed,
        artifactReferences: ["swift test --package-path AirframeCore"]
    )

    let packet = AirframeCanonicalTaskPacketAssembler().taskPacket(
        for: task,
        epics: [epic],
        sprints: [],
        evidence: [evidence]
    )

    #expect(packet.workItem.id == AirframeID("T-0125"))
    #expect(packet.scope == ["AICockpit", "AirframeCore"])
    #expect(packet.acceptanceCriteria == ["Task packets are assembled from canonical records."])
    #expect(packet.existingEvidence.first?.id == AirframeID("EV-0125-001"))
    #expect(packet.existingEvidence.first?.artifact == "swift test --package-path AirframeCore")
    #expect(packet.diagnostics.map(\.reasonCode) == [.taskSprintMissing])
    #expect(packet.diagnostics.first?.affectedIDs == [AirframeID("T-0125"), AirframeID("SP-027")])
}

@Test func dashboardStatusSummaryGroupsArtifactSpecificStatusRows() {
    let records = [
        localWorkRecord(id: "EP-0001", kind: .epic, title: "Defined epic", status: .backlog),
        localWorkRecord(id: "SP-0001", kind: .sprint, title: "Planned sprint", status: .planning),
        localWorkRecord(id: "T-0001", kind: .task, title: "Implemented task", status: .implementedNotVerified),
        localWorkRecord(id: "I-0001", kind: .issue, title: "Resolved issue", status: .implementedNotVerified)
    ]

    let summary = AirframeDashboardStatusSummary(records: records)

    #expect(summary.tiles.map(\.id) == ["epics", "sprints", "tasks", "issues"])
    #expect(summary.tiles.first { $0.id == "epics" }?.rows.map(\.title) == ["Proposed", "Draft", "Backlog", "Active", "Complete", "Closed"])
    #expect(summary.tiles.first { $0.id == "sprints" }?.rows.map(\.title) == ["Backlog", "Planning", "Active", "Review", "Closed"])
    #expect(summary.tiles.first { $0.id == "tasks" }?.rows.map(\.title) == ["Backlog", "Active", "Implemented", "Verified", "Closed"])
    #expect(summary.tiles.first { $0.id == "issues" }?.rows.map(\.title) == ["Backlog", "In Progress", "Resolved", "Verified", "Closed"])
    #expect(summary.tiles.first { $0.id == "tasks" }?.rows.first { $0.title == "Implemented" }?.symbol == "🟢")
    #expect(summary.tiles.first { $0.id == "tasks" }?.rows.first { $0.title == "Implemented" }?.count == 1)
    #expect(summary.tiles.first { $0.id == "issues" }?.rows.first { $0.title == "Resolved" }?.workItems.first?.id == AirframeID("I-0001"))
}

@Test func githubBackendConfigurationAndCapabilitiesAreRepresented() {
    let reference = AirframeBackendReference(kind: "github-fixture", location: "justgus/Airframe")
    let configuration = reference.githubConfiguration
    let capabilities = AirframeBackendCapabilities.githubFixture

    #expect(reference.backendKind == .githubFixture)
    #expect(configuration.owner == "justgus")
    #expect(configuration.repository == "Airframe")
    #expect(capabilities.backendKind == "github-fixture")
    #expect(capabilities.supportsGitHubIssues)
    #expect(capabilities.supportsGitHubLabels)
    #expect(capabilities.supportsSprintEpicMapping)
    #expect(capabilities.supportsEvidenceReferences)
}

@Test func githubIssueMapperMapsTasksIssuesAndStatusLabels() {
    let mapper = AirframeGitHubIssueMapper(
        configuration: AirframeGitHubBackendConfiguration(repositorySlug: "justgus/Airframe")
    )
    let task = localTaskRecord(
        id: "T-0037",
        title: "Implement GitHub issue/task mapping",
        status: .implementedNotVerified
    )
    let issueRecord = AirframeLocalWorkRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("I-0041"),
            kind: .issue,
            title: "GitHub issue import failed",
            status: .active,
            githubIssue: 41
        ),
        epicID: AirframeID("EP-007"),
        sprintID: AirframeID("SP-007"),
        priority: .medium
    )

    let taskIssue = mapper.issue(from: task)
    let mappedIssue = mapper.issue(from: issueRecord)
    let roundTrippedTask = mapper.record(from: taskIssue)

    #expect(taskIssue.number == 37)
    #expect(taskIssue.labels.contains("airframe-task"))
    #expect(taskIssue.labels.contains("status-unverified"))
    #expect(mappedIssue.labels.contains("airframe-issue"))
    #expect(roundTrippedTask.workItem.id == AirframeID("T-0037"))
    #expect(roundTrippedTask.workItem.status == .implementedNotVerified)
    #expect(roundTrippedTask.workItem.githubIssue == 37)
}

@Test func githubIssueMapperPrefersAirframeBodyMetadataOverIssueNumber() {
    let mapper = AirframeGitHubIssueMapper(
        configuration: AirframeGitHubBackendConfiguration(repositorySlug: "justgus/Airframe")
    )
    let issue = AirframeGitHubIssueRecord(
        number: 51,
        title: "[T-0051] Define live GitHub issue transport and failure contract",
        labels: ["airframe-task", "status-active", "epic-EP-010", "sprint-SP-010", "priority-high"],
        body: """
        Airframe Type: Task
        Airframe ID: T-0051
        Epic: EP-010
        Sprint: SP-010
        Priority: High
        Status: Active

        ## Scope
        - Define the read-only gh CLI transport contract.

        ## Acceptance Criteria
        - GitHub access failure cases have explicit Airframe-facing error messages.
        """
    )

    let record = mapper.record(from: issue)

    #expect(record.workItem.id == AirframeID("T-0051"))
    #expect(record.workItem.title == "Define live GitHub issue transport and failure contract")
    #expect(record.workItem.githubIssue == 51)
    #expect(record.epicID == AirframeID("EP-010"))
    #expect(record.sprintID == AirframeID("SP-010"))
    #expect(record.priority == .high)
    #expect(record.scope == ["Define the read-only gh CLI transport contract."])
    #expect(record.acceptanceCriteria == ["GitHub access failure cases have explicit Airframe-facing error messages."])
}

@Test func githubIssueMapperKeepsVerifiedStatusForClosedVerifiedIssues() {
    let mapper = AirframeGitHubIssueMapper(
        configuration: AirframeGitHubBackendConfiguration(repositorySlug: "justgus/Airframe")
    )
    let issue = AirframeGitHubIssueRecord(
        number: 45,
        title: "[T-0045] Write release candidate verification documentation",
        state: "closed",
        labels: ["airframe-task", "status-verified", "epic-EP-008", "sprint-SP-008"],
        body: """
        Airframe Type: Task
        Airframe ID: T-0045
        Epic: EP-008
        Sprint: SP-008
        """
    )

    let record = mapper.record(from: issue)

    #expect(record.workItem.id == AirframeID("T-0045"))
    #expect(record.workItem.status == .implementedVerified)
}

@Test func githubIssueMapperMapsSprintEpicEvidenceAndAuditReferences() {
    let mapper = AirframeGitHubIssueMapper(
        configuration: AirframeGitHubBackendConfiguration(repositorySlug: "justgus/Airframe")
    )
    let record = localTaskRecord(
        id: "T-0038",
        title: "Implement GitHub sprint/epic/evidence mapping",
        acceptanceCriteria: ["Sprint, epic, evidence, and audit references map where supported."],
        scope: ["AirframeCore GitHub mapper"],
        constraints: ["Keep provider behavior behind AirframeCore backend APIs."],
        evidenceRequirements: ["Core tests pass."],
        protectedPaths: ["docs/Tasks/Verified"]
    )
    let evidence = [
        AirframeEvidence(
            id: AirframeID("EV-0038-001"),
            summary: "GitHub mapper tests passed",
            artifact: "swift test --package-path AirframeCore"
        )
    ]

    let issue = mapper.issue(from: record, evidence: evidence)
    let roundTrippedRecord = mapper.record(from: issue)
    let roundTrippedEvidence = mapper.evidence(from: issue)

    #expect(issue.labels.contains("sprint-SP-004"))
    #expect(issue.labels.contains("epic-EP-004"))
    #expect(issue.body.contains("## Evidence"))
    #expect(roundTrippedRecord.sprintID == AirframeID("SP-004"))
    #expect(roundTrippedRecord.epicID == AirframeID("EP-004"))
    #expect(roundTrippedRecord.acceptanceCriteria == record.acceptanceCriteria)
    #expect(roundTrippedRecord.protectedPaths == ["docs/Tasks/Verified"])
    #expect(roundTrippedEvidence == evidence)
}

@Test func githubIssuesBackendMapsReadOnlyLiveIssuesThroughCanonicalAPIs() throws {
    let transport = StubGitHubIssueTransport(issues: [
        AirframeGitHubIssueRecord(
            number: 51,
            title: "[T-0051] Define live GitHub issue transport and failure contract",
            labels: ["airframe-task", "status-active", "epic-EP-010", "sprint-SP-010"],
            body: """
            Airframe Type: Task
            Airframe ID: T-0051
            Epic: EP-010
            Sprint: SP-010

            ## Scope
            - Define gh transport behavior.

            ## Acceptance Criteria
            - Read-only commands map live issues.

            ## Evidence
            - EV-0051-001 | Core tests passed | swift test --package-path AirframeCore
            """
        ),
        AirframeGitHubIssueRecord(
            number: 99,
            title: "Unmapped GitHub issue",
            labels: [],
            body: ""
        )
    ])
    let backend = AirframeGitHubIssuesBackend(
        configuration: AirframeGitHubBackendConfiguration(repositorySlug: "justgus/Airframe"),
        transport: transport
    )

    let records = try backend.listWorkRecords()
    let packet = try backend.taskPacket(for: AirframeID("T-0051"))
    let summary = try backend.dashboardSummary()

    #expect(backend.capabilities.backendKind == "github-issues")
    #expect(!backend.capabilities.supportsCreateWorkItem)
    #expect(records.map(\.workItem.id) == [AirframeID("T-0051")])
    #expect(packet.workItem.id == AirframeID("T-0051"))
    #expect(packet.existingEvidence.first?.id == AirframeID("EV-0051-001"))
    #expect(summary.totalWorkItemCount == 1)
    #expect(summary.activeTaskCount == 1)
    #expect(summary.nextTask?.id == AirframeID("T-0051"))
}

@Test func githubIssuesBackendRejectsMutationsWithReadOnlyError() throws {
    let backend = AirframeGitHubIssuesBackend(
        configuration: AirframeGitHubBackendConfiguration(repositorySlug: "justgus/Airframe"),
        transport: StubGitHubIssueTransport(issues: [])
    )
    let record = localTaskRecord(id: "T-0051", title: "Define live GitHub issue transport")

    #expect(throws: AirframeBackendError.readOnlyBackend("work item creation")) {
        try backend.createWorkRecord(record)
    }
}

@Test func githubIssuesBackendRequiresApprovalBeforeControlledCommentWrites() throws {
    let transport = RecordingGitHubIssueTransport(issues: [controlledMutationIssue()])
    let backend = AirframeGitHubIssuesBackend(
        configuration: AirframeGitHubBackendConfiguration(repositorySlug: "justgus/Airframe"),
        transport: transport,
        controlledMutationsEnabled: true
    )

    #expect(throws: AirframeBackendError.requiresConfirmation(.requiresConfirmation)) {
        try backend.addIssueComment(
            to: AirframeID("T-0067"),
            body: "Evidence is ready.",
            approval: nil,
            context: try certifiedContext(authorityClass: .llmAgent),
            targetProjectID: AirframeID("PRJ-AIRFRAME")
        )
    }
    #expect(transport.comments.isEmpty)
}

@Test func githubIssuesBackendAddsApprovedEvidenceCommentAndAuditResult() throws {
    let transport = RecordingGitHubIssueTransport(issues: [controlledMutationIssue()])
    let backend = AirframeGitHubIssuesBackend(
        configuration: AirframeGitHubBackendConfiguration(repositorySlug: "justgus/Airframe"),
        transport: transport,
        controlledMutationsEnabled: true
    )

    let result = try backend.attachEvidenceComment(
        AirframeEvidence(
            id: AirframeID("EV-0067-001"),
            summary: "Controlled mutation tests passed",
            artifact: "swift test --package-path AirframeCore"
        ),
        to: AirframeID("T-0067"),
        approval: AirframeGitHubMutationApproval(
            isApproved: true,
            approvedBy: "Human",
            reason: "SP-013 verification"
        ),
        context: try certifiedContext(authorityClass: .llmAgent),
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )

    #expect(result.mutation == "githubEvidenceComment")
    #expect(result.githubIssue == 67)
    #expect(result.auditEvent.action == "OP-GITHUB-EVIDENCE-COMMENT")
    #expect(transport.comments.count == 1)
    #expect(transport.comments.first?.body.contains("EV-0067-001") == true)
}

@Test func githubIssuesBackendTransitionsStatusLabelsAfterApproval() throws {
    let transport = RecordingGitHubIssueTransport(issues: [controlledMutationIssue()])
    let backend = AirframeGitHubIssuesBackend(
        configuration: AirframeGitHubBackendConfiguration(repositorySlug: "justgus/Airframe"),
        transport: transport,
        controlledMutationsEnabled: true
    )

    let result = try backend.transitionGitHubStatus(
        workItemID: AirframeID("T-0067"),
        to: .implementedNotVerified,
        approval: AirframeGitHubMutationApproval(
            isApproved: true,
            approvedBy: "Human",
            reason: "Mark ready"
        ),
        context: try certifiedContext(authorityClass: .llmAgent),
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )

    #expect(result.workItem.status == .implementedNotVerified)
    #expect(transport.statusTransitions == [
        RecordingGitHubIssueTransport.StatusTransition(
            issueNumber: 67,
            removedLabels: ["status-active"],
            addedLabel: "status-unverified"
        )
    ])
}

@Test func githubIssuesBackendCreatesTaskIssueAfterApproval() throws {
    let transport = RecordingGitHubIssueTransport(issues: [])
    let backend = AirframeGitHubIssuesBackend(
        configuration: AirframeGitHubBackendConfiguration(repositorySlug: "justgus/Airframe"),
        transport: transport,
        controlledMutationsEnabled: true
    )
    let record = localTaskRecord(id: "T-0093", title: "Implement controlled GitHub mutation support")

    let result = try backend.createGitHubWorkRecord(
        record,
        approval: AirframeGitHubMutationApproval(
            isApproved: true,
            approvedBy: "Human",
            reason: "SP-018 GitHub create"
        ),
        context: try certifiedContext(authorityClass: .llmAgent),
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )

    #expect(result.mutation == "githubWorkItemCreation")
    #expect(result.workItem.id == AirframeID("T-0093"))
    #expect(transport.createdIssues.count == 1)
    #expect(transport.createdIssues.first?.title == "[T-0093] Implement controlled GitHub mutation support")
    #expect(transport.createdIssues.first?.labels.contains("airframe-task") == true)
    #expect(transport.createdIssues.first?.labels.contains("status-active") == true)
}

@Test func githubIssuesBackendRequiresApprovalBeforeCreateTransportCall() throws {
    let transport = RecordingGitHubIssueTransport(issues: [])
    let backend = AirframeGitHubIssuesBackend(
        configuration: AirframeGitHubBackendConfiguration(repositorySlug: "justgus/Airframe"),
        transport: transport,
        controlledMutationsEnabled: true
    )

    #expect(throws: AirframeBackendError.requiresConfirmation(.requiresConfirmation)) {
        try backend.createGitHubWorkRecord(
            localTaskRecord(id: "T-0093", title: "Implement controlled GitHub mutation support"),
            approval: nil,
            context: try certifiedContext(authorityClass: .llmAgent),
            targetProjectID: AirframeID("PRJ-AIRFRAME")
        )
    }
    #expect(transport.createdIssues.isEmpty)
}

@Test func githubIssuesBackendUpdatesIssueFieldsAndLabelsAfterApproval() throws {
    let transport = RecordingGitHubIssueTransport(issues: [controlledMutationIssue()])
    let backend = AirframeGitHubIssuesBackend(
        configuration: AirframeGitHubBackendConfiguration(repositorySlug: "justgus/Airframe"),
        transport: transport,
        controlledMutationsEnabled: true
    )
    let updated = AirframeLocalWorkRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("T-0067"),
            kind: .task,
            title: "Updated controlled GitHub mutation support",
            status: .implementedNotVerified,
            githubIssue: 67
        ),
        epicID: AirframeID("EP-017"),
        sprintID: AirframeID("SP-018"),
        priority: .low,
        acceptanceCriteria: ["GitHub issue updates are controlled."]
    )

    let result = try backend.updateGitHubWorkRecord(
        updated,
        approval: AirframeGitHubMutationApproval(
            isApproved: true,
            approvedBy: "Human",
            reason: "SP-018 GitHub update"
        ),
        context: try certifiedContext(authorityClass: .llmAgent),
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )

    #expect(result.mutation == "githubWorkItemUpdate")
    #expect(result.workItem.status == .implementedNotVerified)
    #expect(transport.updatedIssues.count == 1)
    #expect(transport.updatedIssues.first?.title == "[T-0067] Updated controlled GitHub mutation support")
    #expect(transport.updatedIssues.first?.removedLabels.contains("status-active") == true)
    #expect(transport.updatedIssues.first?.addedLabels.contains("status-unverified") == true)
    #expect(transport.updatedIssues.first?.addedLabels.contains("sprint-SP-018") == true)
}

@Test func githubIssuesBackendDeniesLLMVerifiedStatusTransition() throws {
    let transport = RecordingGitHubIssueTransport(issues: [
        controlledMutationIssue(statusLabel: "status-unverified")
    ])
    let backend = AirframeGitHubIssuesBackend(
        configuration: AirframeGitHubBackendConfiguration(repositorySlug: "justgus/Airframe"),
        transport: transport,
        controlledMutationsEnabled: true
    )

    #expect(throws: AirframeBackendError.authorityDenied(.authorityClassNotPermitted)) {
        try backend.transitionGitHubStatus(
            workItemID: AirframeID("T-0067"),
            to: .implementedVerified,
            approval: AirframeGitHubMutationApproval(
                isApproved: true,
                approvedBy: "Human",
                reason: "AICockpit must not verify"
            ),
            context: try certifiedContext(authorityClass: .llmAgent),
            targetProjectID: AirframeID("PRJ-AIRFRAME")
        )
    }
    #expect(transport.statusTransitions.isEmpty)
}

@Test func githubIssuesBackendAppliesHumanVerificationWithReviewerContext() throws {
    let transport = RecordingGitHubIssueTransport(issues: [
        controlledMutationIssue(statusLabel: "status-unverified")
    ])
    let backend = AirframeGitHubIssuesBackend(
        configuration: AirframeGitHubBackendConfiguration(repositorySlug: "justgus/Airframe"),
        transport: transport,
        controlledMutationsEnabled: true
    )

    let result = try backend.applyHumanVerification(
        action: .accept,
        to: AirframeID("T-0067"),
        context: try certifiedContext(authorityClass: .humanReviewer),
        targetProjectID: AirframeID("PRJ-AIRFRAME")
    )

    #expect(result.workItem.status == .implementedVerified)
    #expect(result.decision.isAllowed)
    #expect(transport.statusTransitions == [
        RecordingGitHubIssueTransport.StatusTransition(
            issueNumber: 67,
            removedLabels: ["status-unverified"],
            addedLabel: "status-verified"
        )
    ])
}

@Test func githubIssuesBackendDeniesHumanVerificationForLLMContext() throws {
    let transport = RecordingGitHubIssueTransport(issues: [
        controlledMutationIssue(statusLabel: "status-unverified")
    ])
    let backend = AirframeGitHubIssuesBackend(
        configuration: AirframeGitHubBackendConfiguration(repositorySlug: "justgus/Airframe"),
        transport: transport,
        controlledMutationsEnabled: true
    )

    #expect(throws: AirframeBackendError.authorityDenied(.authorityClassNotPermitted)) {
        try backend.applyHumanVerification(
            action: .accept,
            to: AirframeID("T-0067"),
            context: try certifiedContext(authorityClass: .llmAgent),
            targetProjectID: AirframeID("PRJ-AIRFRAME")
        )
    }
    #expect(transport.statusTransitions.isEmpty)
}

@Test func githubFixtureBackendUsesCanonicalBackendAPIs() throws {
    let storeURL = FileManager.default.temporaryDirectory
        .appending(path: "AirframeCoreTests")
        .appending(path: UUID().uuidString)
        .appending(path: "github-fixture-backend.json")
    let backend = AirframeGitHubFixtureBackend(
        storeURL: storeURL,
        configuration: AirframeGitHubBackendConfiguration(repositorySlug: "justgus/Airframe")
    )
    let record = localTaskRecord(id: "T-0039", title: "Integrate GitHub backend with AICockpit")
    let evidence = AirframeEvidence(
        id: AirframeID("EV-0039-001"),
        summary: "CLI fixture command passed",
        artifact: "swift test --package-path AICockpit"
    )

    try backend.createWorkRecord(record)
    try backend.attachEvidence(evidence, to: AirframeID("T-0039"))

    let summary = try backend.dashboardSummary()
    let issues = try backend.githubIssues()

    #expect(backend.capabilities.backendKind == "github-fixture")
    #expect(summary.nextTask?.id == AirframeID("T-0039"))
    #expect(issues.first?.labels.contains("airframe-task") == true)
    #expect(issues.first?.body.contains("EV-0039-001") == true)
}

private struct StubGitHubIssueTransport: AirframeGitHubIssueTransport {
    let issues: [AirframeGitHubIssueRecord]

    func listIssues(configuration: AirframeGitHubBackendConfiguration) throws -> [AirframeGitHubIssueRecord] {
        issues
    }

    func issue(number: Int, configuration: AirframeGitHubBackendConfiguration) throws -> AirframeGitHubIssueRecord {
        guard let issue = issues.first(where: { $0.number == number }) else {
            throw AirframeBackendError.githubAccessFailed("missing stub issue #\(number)")
        }
        return issue
    }
}

private func controlledMutationIssue(statusLabel: String = "status-active") -> AirframeGitHubIssueRecord {
    AirframeGitHubIssueRecord(
        number: 67,
        title: "[T-0067] Add GitHub issue comment mutation support",
        labels: ["airframe-task", statusLabel, "epic-EP-013", "sprint-SP-013"],
        body: """
        Airframe Type: Task
        Airframe ID: T-0067
        Epic: EP-013
        Sprint: SP-013
        """
    )
}

private final class RecordingGitHubIssueTransport: @unchecked Sendable, AirframeGitHubIssueTransport {
    struct Comment: Equatable {
        let issueNumber: Int
        let body: String
    }

    struct StatusTransition: Equatable {
        let issueNumber: Int
        let removedLabels: [String]
        let addedLabel: String
    }

    struct CreatedIssue: Equatable {
        let title: String
        let body: String
        let labels: [String]
    }

    struct UpdatedIssue: Equatable {
        let issueNumber: Int
        let title: String?
        let body: String?
        let removedLabels: [String]
        let addedLabels: [String]
    }

    private var issues: [AirframeGitHubIssueRecord]
    private(set) var comments: [Comment] = []
    private(set) var statusTransitions: [StatusTransition] = []
    private(set) var createdIssues: [CreatedIssue] = []
    private(set) var updatedIssues: [UpdatedIssue] = []

    init(issues: [AirframeGitHubIssueRecord]) {
        self.issues = issues
    }

    func listIssues(configuration: AirframeGitHubBackendConfiguration) throws -> [AirframeGitHubIssueRecord] {
        issues
    }

    func issue(number: Int, configuration: AirframeGitHubBackendConfiguration) throws -> AirframeGitHubIssueRecord {
        guard let issue = issues.first(where: { $0.number == number }) else {
            throw AirframeBackendError.githubAccessFailed("missing stub issue #\(number)")
        }
        return issue
    }

    func createIssue(
        title: String,
        body: String,
        labels: [String],
        configuration: AirframeGitHubBackendConfiguration
    ) throws -> AirframeGitHubIssueRecord {
        let issueNumber = issues.count + 1
        let issue = AirframeGitHubIssueRecord(
            number: issueNumber,
            title: title,
            labels: labels,
            body: body
        )
        createdIssues.append(CreatedIssue(title: title, body: body, labels: labels))
        issues.append(issue)
        return issue
    }

    func updateIssue(
        issueNumber: Int,
        title: String?,
        body: String?,
        removing oldLabels: [String],
        adding newLabels: [String],
        configuration: AirframeGitHubBackendConfiguration
    ) throws {
        updatedIssues.append(
            UpdatedIssue(
                issueNumber: issueNumber,
                title: title,
                body: body,
                removedLabels: oldLabels,
                addedLabels: newLabels
            )
        )
    }

    func addComment(
        issueNumber: Int,
        body: String,
        configuration: AirframeGitHubBackendConfiguration
    ) throws {
        comments.append(Comment(issueNumber: issueNumber, body: body))
    }

    func replaceStatusLabel(
        issueNumber: Int,
        removing oldStatusLabels: [String],
        adding newStatusLabel: String,
        configuration: AirframeGitHubBackendConfiguration
    ) throws {
        statusTransitions.append(
            StatusTransition(
                issueNumber: issueNumber,
                removedLabels: oldStatusLabels,
                addedLabel: newStatusLabel
            )
        )
    }
}

private func certifiedContext(
    authorityClass: AirframeAuthorityClass,
    projectID: AirframeID = AirframeID("PRJ-AIRFRAME")
) throws -> AirframeCertifiedContext {
    let actor = AirframeActor(
        id: AirframeID("ACTOR-\(authorityClass.rawValue)"),
        displayName: authorityClass.rawValue,
        authorityClass: authorityClass,
        credentialSource: .configuredIdentity
    )
    let credential = AirframeCredentialContext(
        credentialID: AirframeID("CRED-\(authorityClass.rawValue)"),
        actorID: actor.id,
        credentialSource: .configuredIdentity,
        executionProjectID: projectID,
        allowedProjectIDs: [projectID]
    )

    return try AirframeCertifiedContext(
        actor: actor,
        credential: credential,
        targetProjectID: projectID
    )
}

private func makeLocalBackend() throws -> AirframeLocalFilesystemBackend {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AirframeCoreTests")
        .appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
    return AirframeLocalFilesystemBackend(rootURL: rootURL)
}

private func localTaskRecord(
    id: String,
    title: String,
    status: AirframeWorkStatus = .active,
    acceptanceCriteria: [String] = ["The work item can be implemented and verified."],
    scope: [String] = ["AirframeCore"],
    constraints: [String] = ["Preserve authority and workflow policy in AirframeCore."],
    evidenceRequirements: [String] = ["Record test commands."],
    protectedPaths: [String] = []
) -> AirframeLocalWorkRecord {
    AirframeLocalWorkRecord(
        workItem: AirframeWorkItem(
            id: AirframeID(id),
            kind: .task,
            title: title,
            status: status,
            githubIssue: Int(id.dropFirst(2))
        ),
        epicID: AirframeID("EP-004"),
        sprintID: AirframeID("SP-004"),
        priority: .high,
        acceptanceCriteria: acceptanceCriteria,
        scope: scope,
        constraints: constraints,
        evidenceRequirements: evidenceRequirements,
        protectedPaths: protectedPaths
    )
}

private func canonicalTaskRecord(
    id: String,
    title: String,
    status: AirframeWorkStatus
) -> AirframeCanonicalTaskRecord {
    AirframeCanonicalTaskRecord(
        workItem: AirframeWorkItem(
            id: AirframeID(id),
            kind: .task,
            title: title,
            status: status,
            githubIssue: Int(id.dropFirst(2))
        ),
        component: "AirframeCore",
        priority: .high,
        rationale: "Canonical summary coverage."
    )
}

@Test func canonicalStateValidatorDetectsMembershipIssueLinksAndAcceptanceLifecycleDrift() {
    let project = AirframeCanonicalProjectRecord(
        id: AirframeID("PRJ-AIRFRAME"),
        name: "Agile Airframe",
        repository: "justgus/Airframe",
        epicIDs: [AirframeID("EP-017")],
        taskIDs: [AirframeID("T-0001"), AirframeID("T-0001")],
        issueIDs: [AirframeID("I-0001"), AirframeID("I-0001")]
    )
    let epic = canonicalEpic(id: "EP-017", status: .active)
    let issue = canonicalIssue(
        id: AirframeID("I-0001"),
        epicID: AirframeID("EP-017"),
        sprintID: AirframeID("SP-038")
    )
    let criterion = AirframeCanonicalAcceptanceCriterionRecord(
        id: AirframeID("EP-017-AC-01"),
        ownerID: AirframeID("EP-017"),
        text: "Current work cannot use historical-close disposition.",
        disposition: .grandfatheredHistoricalClose
    )

    let diagnostics = AirframeCanonicalStateValidator().diagnostics(
        for: AirframeCanonicalStateSnapshot(
            project: project,
            epics: [epic],
            issues: [issue],
            acceptanceCriteria: [criterion]
        )
    )
    let reasonCodes = Set(diagnostics.diagnostics.map(\.reasonCode))

    #expect(reasonCodes.contains(.duplicateProjectMembership))
    #expect(reasonCodes.contains(.epicIssueRelationshipDrift))
    #expect(reasonCodes.contains(.acceptanceLifecycleInconsistent))
    #expect(diagnostics.diagnostics.contains {
        $0.reasonCode == .duplicateProjectMembership &&
        $0.repairOptions.map(\.action).contains(.deduplicateProjectMembership)
    })
    #expect(diagnostics.diagnostics.contains {
        $0.reasonCode == .epicIssueRelationshipDrift &&
        $0.repairOptions.map(\.action).contains(.reconcileEpicIssueLinks)
    })
}

private func canonicalEpic(
    id: String,
    status: AirframeWorkStatus,
    taskIDs: [AirframeID] = [],
    issueIDs: [AirframeID] = []
) -> AirframeCanonicalEpicRecord {
    AirframeCanonicalEpicRecord(
        workItem: AirframeWorkItem(
            id: AirframeID(id),
            kind: .epic,
            title: "Test Epic \(id)",
            status: status
        ),
        owner: "Airframe Tests",
        goal: "Exercise canonical relationship moves.",
        rationale: "Regression coverage for stale reverse links.",
        taskIDs: taskIDs,
        issueIDs: issueIDs
    )
}

private func canonicalSprint(
    id: String,
    status: AirframeWorkStatus,
    epicID: AirframeID,
    taskIDs: [AirframeID] = [],
    issueIDs: [AirframeID] = []
) -> AirframeCanonicalSprintRecord {
    AirframeCanonicalSprintRecord(
        workItem: AirframeWorkItem(
            id: AirframeID(id),
            kind: .sprint,
            title: "Test Sprint \(id)",
            status: status
        ),
        epicID: epicID,
        goal: "Exercise canonical relationship moves.",
        taskIDs: taskIDs,
        issueIDs: issueIDs
    )
}

private func canonicalTask(
    id: AirframeID,
    epicID: AirframeID,
    sprintID: AirframeID
) -> AirframeCanonicalTaskRecord {
    AirframeCanonicalTaskRecord(
        workItem: AirframeWorkItem(
            id: id,
            kind: .task,
            title: "Test Task \(id.rawValue)",
            status: .active
        ),
        component: "AirframeCore",
        priority: .high,
        rationale: "Regression coverage for stale reverse links.",
        epicID: epicID,
        sprintID: sprintID
    )
}

private func canonicalIssue(
    id: AirframeID,
    epicID: AirframeID,
    sprintID: AirframeID
) -> AirframeCanonicalIssueRecord {
    AirframeCanonicalIssueRecord(
        workItem: AirframeWorkItem(
            id: id,
            kind: .issue,
            title: "Test Issue \(id.rawValue)",
            status: .active
        ),
        severity: .high,
        observedBehavior: "A moved work item can remain linked from its previous owner.",
        expectedBehavior: "Moving a work item clears stale owner links.",
        epicID: epicID,
        sprintID: sprintID
    )
}

private func localWorkRecord(
    id: String,
    kind: AirframeWorkItemKind,
    title: String,
    status: AirframeWorkStatus
) -> AirframeLocalWorkRecord {
    AirframeLocalWorkRecord(
        workItem: AirframeWorkItem(
            id: AirframeID(id),
            kind: kind,
            title: title,
            status: status,
            githubIssue: Int(id.split(separator: "-").last.map(String.init) ?? "")
        )
    )
}

private let liveConfigurationData = Data(
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
)

@Test func criterionMatchIndexPreservesOwnerTextAndExplicitTestLinks() {
    let owned = AirframeCanonicalRequirementRecord(id: AirframeID("REQ-OWNED"), title: "Opaque", statement: "Separate", status: .draft)
    let matched = AirframeCanonicalRequirementRecord(id: AirframeID("REQ-MATCHED"), title: "Copper silver bronze", statement: "Copper silver bronze", status: .draft)
    let unrelated = AirframeCanonicalRequirementRecord(id: AirframeID("REQ-OTHER"), title: "Unrelated", statement: "Different", status: .draft)
    let criterion = AirframeCanonicalAcceptanceCriterionRecord(id: AirframeID("AC-MATCH"), ownerID: owned.id, text: "Copper silver bronze", isVerified: false)
    let test = AirframeCanonicalTestRecord(id: AirframeID("TEST-MATCH"), title: "Check", objective: "Check", kind: .unit, status: .ready, requirementIDs: [unrelated.id], acceptanceCriterionIDs: [criterion.id, AirframeID("MISSING")])
    let index = AirframeRequirementTraceabilityIndex(requirements: [owned, matched, unrelated], acceptanceCriteria: [criterion], tests: [test])
    #expect(Set(index.requirementIDs(for: criterion.id)) == Set([owned.id, matched.id]))
    #expect(Set(index.requirementIDs(for: test.id)) == Set([owned.id, matched.id, unrelated.id]))
    for requirement in [owned, matched, unrelated] {
        #expect(index.traceSummary(for: requirement.id).testIDs.contains(test.id))
    }
    #expect(index.requirementIDs(for: AirframeID("MISSING")).isEmpty)
}
