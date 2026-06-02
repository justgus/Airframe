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
    #expect(context.project.activeSprintID == AirframeID("SP-003"))
    #expect(context.project.activeEpicID == AirframeID("EP-003"))
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
