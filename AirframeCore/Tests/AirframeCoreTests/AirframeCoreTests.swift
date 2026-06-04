import Testing
import AirframeCore
import Foundation

@Test func coreInfoProvidesBaselineIdentity() {
    let info = AirframeCoreInfo.current

    #expect(info.name == "AirframeCore")
    #expect(info.version == "0.1.0")
    #expect(info.summary == "AirframeCore 0.1.0")
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
    #expect(context.project.activeSprintID == AirframeID("SP-008"))
    #expect(context.project.activeEpicID == AirframeID("EP-008"))
    #expect(context.summaryLines.contains("Repository: justgus/Airframe"))
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
