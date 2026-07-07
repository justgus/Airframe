import AirframeCore
import Foundation

public struct AICockpitCommandResult: Equatable, Sendable {
    public let exitCode: Int32
    public let standardOutput: String
    public let standardError: String

    public init(exitCode: Int32, standardOutput: String = "", standardError: String = "") {
        self.exitCode = exitCode
        self.standardOutput = standardOutput
        self.standardError = standardError
    }
}

public enum AICockpitCommand {
    public static func main(arguments: [String]) -> Int32 {
        let result = response(arguments: arguments)

        if !result.standardOutput.isEmpty {
            print(result.standardOutput)
        }

        if !result.standardError.isEmpty {
            fputs(result.standardError, stderr)
        }

        return result.exitCode
    }

    public static func response(arguments: [String]) -> AICockpitCommandResult {
        response(arguments: arguments, refreshNotifier: AirframeDistributedRefreshNotifier())
    }

    static func response(
        arguments: [String],
        refreshNotifier: any AICockpitRefreshNotifying
    ) -> AICockpitCommandResult {
        let parsed = AICockpitArguments(arguments)
        let outputFormat = parsed.value(for: "--output").flatMap(AICockpitOutputFormat.init(rawValue:)) ?? .markdown

        if arguments.isEmpty || arguments.contains("--help") || arguments.contains("-h") {
            return AICockpitCommandResult(exitCode: 0, standardOutput: helpText())
        }

        if arguments == ["version"] || arguments == ["--version"] {
            return AICockpitCommandResult(exitCode: 0, standardOutput: AirframeCoreInfo.current.summary)
        }

        if parsed.positionals == ["context"] {
            do {
                let context = try parsed.runtimeResolver.loadContext(explicitPath: parsed.value(for: "--config"))
                let displayContext = try parsed.canonicalProjectContextIfAvailable(context) ?? context
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: contextText(for: displayContext)
                )
            } catch {
                return AICockpitCommandResult(
                    exitCode: 78,
                    standardError: "aicockpit: \(error)\n"
                )
            }
        }

        if parsed.positionals == ["config", "diagnose"] {
            do {
                let configuration = try parsed.runtimeResolver.loadConfiguration(explicitPath: parsed.value(for: "--config"))
                let diagnostics = contextualConfigurationDiagnostics(
                    AirframeConfigurationLoader().diagnostics(for: configuration),
                    configuration: configuration,
                    parsed: parsed
                )
                return AICockpitCommandResult(
                    exitCode: diagnostics.isValid ? 0 : 78,
                    standardOutput: try render(
                        AICockpitCommandEnvelope(
                            status: diagnostics.isValid ? "ok" : "error",
                            kind: "configurationDiagnostics",
                            message: diagnostics.isValid ? "Configuration diagnostics passed" : "Configuration diagnostics failed",
                            backendCapabilities: nil,
                            workItem: nil,
                            taskPacket: nil,
                            dashboardSummary: nil,
                            configurationDiagnostics: diagnostics,
                            evidence: []
                        ),
                        as: outputFormat
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "configurationLoadFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals == ["state", "diagnostics"] {
            return executeBackendCommand(outputFormat: outputFormat, parsed: parsed) { backend, _ in
                let projectContext = try parsed.runtimeResolver.loadContext(explicitPath: parsed.value(for: "--config"))
                let rootURL = try? parsed.workspaceRootURL(projectContext: projectContext)
                let canonicalStoreURL = rootURL?.appending(path: ".airframe/state")
                let canonicalRecords: [AirframeLocalWorkRecord]
                let snapshot: AirframeCanonicalStateSnapshot
                if let rootURL,
                   let canonicalStoreURL,
                   FileManager.default.fileExists(atPath: canonicalStoreURL.path) {
                    let repository = AirframeCanonicalStoreRepository(rootURL: rootURL)
                    canonicalRecords = try repository.workRecords()
                    snapshot = try repository.snapshot(project: projectContext.project)
                } else {
                    canonicalRecords = try backend.listWorkRecords()
                    snapshot = AirframeCanonicalStateSnapshotBuilder().snapshot(
                        project: projectContext.project,
                        records: canonicalRecords
                    )
                }
                let stateDiagnostics = AirframeCanonicalStateValidator().diagnostics(for: snapshot)
                let reconciliationDiagnostics = try AirframeCanonicalBackendReconciler().diagnostics(
                    canonicalRecords: canonicalRecords,
                    backendRecords: backend.listWorkRecords()
                )
                let diagnostics = AirframeCanonicalDiagnostics(
                    diagnostics: stateDiagnostics.diagnostics + reconciliationDiagnostics
                )
                return try render(
                    AICockpitCommandEnvelope(
                        status: diagnostics.isValid ? "ok" : "error",
                        kind: "canonicalStateDiagnostics",
                        message: diagnostics.isValid ? "Canonical state diagnostics passed" : "Canonical state diagnostics found issues",
                        backendCapabilities: backend.capabilities,
                        workItem: nil,
                        taskPacket: nil,
                        dashboardSummary: nil,
                        canonicalDiagnostics: diagnostics,
                        evidence: []
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals.count == 2,
           parsed.positionals[0] == "requirements",
           parsed.positionals[1] == "import" {
            do {
                let projectContext = try parsed.runtimeResolver.loadContext(explicitPath: parsed.value(for: "--config"))
                let rootURL = try parsed.workspaceRootURL(projectContext: projectContext)
                let repository = AirframeCanonicalStoreRepository(rootURL: rootURL)
                let state = try repository.loadState()
                let format = try parsed.requiredRequirementInterchangeFormat()
                let input = try String(
                    contentsOf: URL(filePath: try parsed.requiredValue(for: "--file")),
                    encoding: .utf8
                )
                let interchange = AirframeRequirementInterchange()
                let document: AirframeRequirementInterchangeDocument
                let preview: AirframeRequirementImportPreview
                switch format {
                case .csv:
                    document = try interchange.importCSV(input)
                    preview = try interchange.previewImportCSV(
                        input,
                        existingRequirements: state.requirements,
                        existingRevisions: state.requirementRevisions
                    )
                case .json:
                    document = try interchange.importJSON(input)
                    preview = try interchange.previewImportJSON(
                        input,
                        existingRequirements: state.requirements,
                        existingRevisions: state.requirementRevisions
                    )
                }
                if parsed.value(for: "--apply") == "true" {
                    guard preview.conflictedCount == 0 else {
                        throw AICockpitCommandError.invalidArguments("requirements import --apply cannot proceed with conflicted records")
                    }
                    let incomingRequirementIDs = Set(document.requirements.map(\.id))
                    for requirement in state.requirements where !incomingRequirementIDs.contains(requirement.id) {
                        try repository.store.delete(AirframeCanonicalRequirementRecord.self, id: requirement.id)
                    }
                    for revision in state.requirementRevisions where !incomingRequirementIDs.contains(revision.requirementID) {
                        try repository.store.delete(AirframeCanonicalRequirementRevisionRecord.self, id: revision.id)
                    }
                    try document.requirements.forEach(repository.store.save)
                    try document.revisions.forEach(repository.store.save)
                    return AICockpitCommandResult(
                        exitCode: 0,
                        standardOutput: try renderRequirementImportPreview(
                            preview,
                            format: format,
                            applied: true,
                            as: outputFormat
                        )
                    )
                }
                guard parsed.value(for: "--dry-run") == "true" || parsed.value(for: "--apply") != "true" else {
                    throw AICockpitCommandError.invalidArguments("requirements import requires --dry-run or --apply")
                }
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try renderRequirementImportPreview(
                        preview,
                        format: format,
                        applied: false,
                        as: outputFormat
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 65,
                    code: "requirementsImportFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals.count == 2,
           parsed.positionals[0] == "requirements",
           parsed.positionals[1] == "export" {
            do {
                let projectContext = try parsed.runtimeResolver.loadContext(explicitPath: parsed.value(for: "--config"))
                let rootURL = try parsed.workspaceRootURL(projectContext: projectContext)
                let state = try AirframeCanonicalStoreRepository(rootURL: rootURL).loadState()
                let format = try parsed.requiredRequirementInterchangeFormat()
                let interchange = AirframeRequirementInterchange()
                switch format {
                case .csv:
                    return AICockpitCommandResult(
                        exitCode: 0,
                        standardOutput: try interchange.exportCSV(
                            requirements: state.requirements,
                            revisions: state.requirementRevisions
                        )
                    )
                case .json:
                    return AICockpitCommandResult(
                        exitCode: 0,
                        standardOutput: try interchange.exportJSON(
                            requirements: state.requirements,
                            revisions: state.requirementRevisions
                        )
                    )
                }
            } catch {
                return errorResult(
                    exitCode: 65,
                    code: "requirementsExportFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals == ["state", "import-markdown"] {
            do {
                let projectContext = try parsed.runtimeResolver.loadContext(explicitPath: parsed.value(for: "--config"))
                let rootURL = try parsed.workspaceRootURL(projectContext: projectContext)
                let documents = try markdownArtifactDocuments(rootURL: rootURL)
                let importResult = AirframeMarkdownArtifactImporter().importDocuments(documents)
                try AirframeCanonicalStoreRepository(rootURL: rootURL).saveImportedState(
                    importResult,
                    context: projectContext
                )
                return AICockpitCommandResult(
                    exitCode: importResult.isClean ? 0 : 78,
                    standardOutput: try renderImportResult(
                        importResult,
                        rootURL: rootURL,
                        outputFormat: outputFormat
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalImportFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals == ["state", "export-markdown"] {
            do {
                let projectContext = try parsed.runtimeResolver.loadContext(explicitPath: parsed.value(for: "--config"))
                let rootURL = try parsed.workspaceRootURL(projectContext: projectContext)
                let count = try exportMarkdownProjections(rootURL: rootURL)
                let output = """
                # Airframe Command

                - status: ok
                - kind: canonicalMarkdownExport
                - message: Markdown projections exported
                - exportedFiles: \(count)
                """
                return AICockpitCommandResult(exitCode: 0, standardOutput: output)
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalExportFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals == ["state", "repair"] {
            return executeBackendCommand(
                outputFormat: outputFormat,
                parsed: parsed,
                controlledMutationsEnabled: true,
                refreshNotifier: refreshNotifier
            ) { backend, context in
                let projectContext = try parsed.runtimeResolver.loadContext(explicitPath: parsed.value(for: "--config"))
                let rootURL = try parsed.workspaceRootURL(projectContext: projectContext)
                let repository = AirframeCanonicalStoreRepository(rootURL: rootURL)
                let canonicalRecords = try repository.workRecords()
                let snapshot = try repository.snapshot(project: projectContext.project)
                let backendRecords = try backend.listWorkRecords()
                let backendDiagnostics = AirframeCanonicalBackendReconciler().diagnostics(
                    canonicalRecords: canonicalRecords,
                    backendRecords: backendRecords
                )
                let stateDiagnostics = AirframeCanonicalStateValidator()
                    .diagnostics(for: snapshot)
                    .diagnostics
                let action = try parsed.requiredRepairAction()
                let requestedIDs = parsed.repeatedValues(for: "--id").map(AirframeID.init)
                let diagnostics = stateDiagnostics + backendDiagnostics
                let repairOptions = diagnostics.flatMap(\.repairOptions).filter { option in
                    option.action == action
                        && (requestedIDs.isEmpty || !Set(option.affectedIDs).isDisjoint(with: requestedIDs))
                }
                guard !repairOptions.isEmpty else {
                    throw AICockpitCommandError.invalidArguments("no matching repair option")
                }
                let approval = backend is AirframeGitHubIssuesBackend ? try parsed.githubMutationApproval() : nil
                let applications = try repairOptions.flatMap { option in
                    var scopedOption = option
                    if !requestedIDs.isEmpty {
                        scopedOption = AirframeCanonicalRepairOption(
                            action: option.action,
                            title: option.title,
                            affectedIDs: option.affectedIDs,
                            requiresHumanApproval: option.requiresHumanApproval
                        )
                    }
                    if scopedOption.requiresHumanApproval {
                        _ = try parsed.githubMutationApproval()
                        scopedOption = AirframeCanonicalRepairOption(
                            action: scopedOption.action,
                            title: scopedOption.title,
                            affectedIDs: scopedOption.affectedIDs,
                            requiresHumanApproval: false
                        )
                    }
                    if scopedOption.action == .applyBackendStatusLabels
                        || scopedOption.action == .applyBackendRelationshipLabels {
                        return try AirframeCanonicalBackendRepairer().apply(
                            repairOption: scopedOption,
                            canonicalRecords: canonicalRecords,
                            backend: backend,
                            approval: approval,
                            context: context,
                            targetProjectID: context.targetProjectID
                        ).applications
                    }
                    return try AirframeCanonicalStateRepairer().apply(
                        repairOption: scopedOption,
                        repository: repository
                    ).applications
                }
                return try renderRepairResult(
                    AirframeCanonicalBackendRepairResult(applications: applications),
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals == ["authority", "demo-denied"] {
            do {
                let context = try parsed.runtimeResolver.loadContext(explicitPath: parsed.value(for: "--config"))
                let certifiedContext = try sampleLLMContext(projectID: context.project.id)
                let operation = AirframeOperation(
                    id: AirframeID("OP-ACCEPT-WORK"),
                    category: .humanAcceptance
                )
                let decision = AirframeAuthorityEvaluator().evaluate(
                    context: certifiedContext,
                    operation: operation,
                    targetProjectID: context.project.id
                )

                return AICockpitCommandResult(
                    exitCode: decision.isAllowed ? 0 : 77,
                    standardOutput: deniedOperationText(
                        decision: decision,
                        operation: operation,
                        actorID: certifiedContext.actor.id,
                        projectID: context.project.id
                    )
                )
            } catch {
                return AICockpitCommandResult(
                    exitCode: 78,
                    standardError: "aicockpit: \(error)\n"
                )
            }
        }

        if parsed.positionals == ["project", "summary"] {
            return executeBackendCommand(outputFormat: outputFormat, parsed: parsed) { backend, _ in
                let summary = try backend.dashboardSummary()
                return try render(
                    AICockpitCommandEnvelope(
                        status: "ok",
                        kind: "projectSummary",
                        message: "Project summary",
                        backendCapabilities: backend.capabilities,
                        workItem: nil,
                        taskPacket: nil,
                        dashboardSummary: summary,
                        evidence: []
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals == ["tests", "list"] {
            do {
                let repository = try canonicalTestRepository(parsed: parsed)
                let tests = try repository.loadState().tests
                    .sorted { $0.id.rawValue < $1.id.rawValue }
                    .map(AICockpitTestSummary.init)
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try render(
                        AICockpitTestCommandEnvelope(
                            status: "ok",
                            kind: "canonicalTestList",
                            message: "Canonical tests listed",
                            backendCapabilities: .canonicalStore,
                            test: nil,
                            tests: tests,
                            validationDiagnostics: nil
                        ),
                        as: outputFormat
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalTestCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals == ["acceptance-criteria", "list"] {
            do {
                let repository = try canonicalTestRepository(parsed: parsed)
                let criteria = try repository.loadState().acceptanceCriteria
                    .sorted { $0.id.rawValue < $1.id.rawValue }
                    .map(AICockpitAcceptanceCriterionSummary.init)
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try render(
                        AICockpitAcceptanceCriteriaCommandEnvelope(
                            status: "ok",
                            kind: "canonicalAcceptanceCriteriaList",
                            message: "Canonical acceptance criteria listed",
                            backendCapabilities: .canonicalStore,
                            criterion: nil,
                            criteria: criteria,
                            epicCoverage: nil
                        ),
                        as: outputFormat
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalAcceptanceCriteriaCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals == ["plans", "list"] {
            do {
                let repository = try canonicalTestRepository(parsed: parsed)
                let plans = try repository.loadState().implementationPlans
                    .sorted { $0.id.rawValue < $1.id.rawValue }
                    .map(AICockpitPlanSummary.init)
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try render(
                        AICockpitPlanCommandEnvelope(
                            status: "ok",
                            kind: "canonicalPlanList",
                            message: "Canonical implementation plans listed",
                            backendCapabilities: .canonicalStore,
                            plan: nil,
                            plans: plans
                        ),
                        as: outputFormat
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalPlanCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals == ["plans", "submit"] {
            do {
                try assertLLMAllowed(parsed: parsed, operationID: "OP-SUBMIT-IMPLEMENTATION-PLAN", category: .proposal)
                let repository = try canonicalTestRepository(parsed: parsed)
                let context = try parsed.canonicalAwareProjectContext()
                let plan = try buildPlanRecord(parsed: parsed, projectContext: context)
                try repository.store.save(plan)
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try render(
                        AICockpitPlanCommandEnvelope(
                            status: "ok",
                            kind: "canonicalPlanSubmission",
                            message: "Canonical implementation plan submitted",
                            backendCapabilities: .canonicalStore,
                            plan: plan,
                            plans: []
                        ),
                        as: outputFormat
                    )
                )
            } catch AICockpitCommandError.denied(let decision, let operation) {
                return AICockpitCommandResult(
                    exitCode: 77,
                    standardOutput: deniedOperationText(
                        decision: decision,
                        operation: operation,
                        actorID: AirframeID("ACTOR-LLM"),
                        projectID: AirframeID("PRJ-AIRFRAME")
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalPlanCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3,
           parsed.positionals[0] == "plans",
           parsed.positionals[1] == "inspect" {
            do {
                let repository = try canonicalTestRepository(parsed: parsed)
                let planID = AirframeID(parsed.positionals[2])
                guard let plan = try repository.store.load(AirframeCanonicalImplementationPlanRecord.self, id: planID) else {
                    throw AirframeBackendError.missingWorkItem(planID)
                }
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try render(
                        AICockpitPlanCommandEnvelope(
                            status: "ok",
                            kind: "canonicalPlanInspection",
                            message: "Canonical implementation plan loaded",
                            backendCapabilities: .canonicalStore,
                            plan: plan,
                            plans: []
                        ),
                        as: outputFormat
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalPlanCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3,
           parsed.positionals[0] == "plans",
           ["approve", "defer", "reject"].contains(parsed.positionals[1]) {
            do {
                let context = try parsed.canonicalAwareProjectContext()
                let certifiedContext = try sampleLLMContext(projectID: context.project.id)
                let operation = AirframeOperation(
                    id: AirframeID("OP-HUMAN-\(parsed.positionals[1].uppercased())-PLAN"),
                    category: .planDecision
                )
                let decision = AirframeAuthorityEvaluator().evaluate(
                    context: certifiedContext,
                    operation: operation,
                    targetProjectID: context.project.id
                )
                guard decision.isAllowed else {
                    throw AICockpitCommandError.denied(decision, operation)
                }
                return errorResult(
                    exitCode: 78,
                    code: "unsupportedPlanDecision",
                    message: "plan decisions are human-only in AgileCockpit",
                    outputFormat: outputFormat
                )
            } catch AICockpitCommandError.denied(let decision, let operation) {
                return AICockpitCommandResult(
                    exitCode: 77,
                    standardOutput: deniedOperationText(
                        decision: decision,
                        operation: operation,
                        actorID: AirframeID("ACTOR-LLM"),
                        projectID: AirframeID("PRJ-AIRFRAME")
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalPlanCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3,
           parsed.positionals[0] == "acceptance-criteria",
           parsed.positionals[1] == "inspect" {
            do {
                let repository = try canonicalTestRepository(parsed: parsed)
                let criterionID = AirframeID(parsed.positionals[2])
                guard let criterion = try repository.store.load(AirframeCanonicalAcceptanceCriterionRecord.self, id: criterionID) else {
                    throw AirframeBackendError.missingWorkItem(criterionID)
                }
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try render(
                        AICockpitAcceptanceCriteriaCommandEnvelope(
                            status: "ok",
                            kind: "canonicalAcceptanceCriterionInspection",
                            message: "Canonical acceptance criterion loaded",
                            backendCapabilities: .canonicalStore,
                            criterion: criterion,
                            criteria: [],
                            epicCoverage: nil
                        ),
                        as: outputFormat
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalAcceptanceCriteriaCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals == ["acceptance-criteria", "create"] {
            do {
                try assertLLMAllowed(parsed: parsed, operationID: "OP-CREATE-ACCEPTANCE-CRITERION", category: .proposal)
                let repository = try canonicalTestRepository(parsed: parsed)
                let criterion = try buildAcceptanceCriterionRecord(parsed: parsed, existing: nil)
                try repository.store.save(criterion)
                try linkAcceptanceCriterionToOwner(criterion.id, ownerID: criterion.ownerID, repository: repository)
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try render(
                        AICockpitAcceptanceCriteriaCommandEnvelope(
                            status: "ok",
                            kind: "canonicalAcceptanceCriterionCreation",
                            message: "Canonical acceptance criterion created",
                            backendCapabilities: .canonicalStore,
                            criterion: criterion,
                            criteria: [],
                            epicCoverage: nil
                        ),
                        as: outputFormat
                    )
                )
            } catch AICockpitCommandError.denied(let decision, let operation) {
                return AICockpitCommandResult(
                    exitCode: 77,
                    standardOutput: deniedOperationText(
                        decision: decision,
                        operation: operation,
                        actorID: AirframeID("ACTOR-LLM"),
                        projectID: AirframeID("PRJ-AIRFRAME")
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalAcceptanceCriteriaCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3,
           parsed.positionals[0] == "acceptance-criteria",
           parsed.positionals[1] == "update" {
            do {
                try assertLLMAllowed(parsed: parsed, operationID: "OP-UPDATE-ACCEPTANCE-CRITERION", category: .workflowTransition)
                let repository = try canonicalTestRepository(parsed: parsed)
                let criterionID = AirframeID(parsed.positionals[2])
                guard let existing = try repository.store.load(AirframeCanonicalAcceptanceCriterionRecord.self, id: criterionID) else {
                    throw AirframeBackendError.missingWorkItem(criterionID)
                }
                let updated = try buildAcceptanceCriterionRecord(parsed: parsed, existing: existing)
                try repository.store.save(updated)
                try linkAcceptanceCriterionToOwner(updated.id, ownerID: updated.ownerID, repository: repository)
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try render(
                        AICockpitAcceptanceCriteriaCommandEnvelope(
                            status: "ok",
                            kind: "canonicalAcceptanceCriterionUpdate",
                            message: "Canonical acceptance criterion updated",
                            backendCapabilities: .canonicalStore,
                            criterion: updated,
                            criteria: [],
                            epicCoverage: nil
                        ),
                        as: outputFormat
                    )
                )
            } catch AICockpitCommandError.denied(let decision, let operation) {
                return AICockpitCommandResult(
                    exitCode: 77,
                    standardOutput: deniedOperationText(
                        decision: decision,
                        operation: operation,
                        actorID: AirframeID("ACTOR-LLM"),
                        projectID: AirframeID("PRJ-AIRFRAME")
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalAcceptanceCriteriaCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3,
           parsed.positionals[0] == "acceptance-criteria",
           parsed.positionals[1] == "link" {
            do {
                try assertLLMAllowed(parsed: parsed, operationID: "OP-LINK-ACCEPTANCE-CRITERION", category: .workflowTransition)
                let repository = try canonicalTestRepository(parsed: parsed)
                let criterionID = AirframeID(parsed.positionals[2])
                guard let existing = try repository.store.load(AirframeCanonicalAcceptanceCriterionRecord.self, id: criterionID) else {
                    throw AirframeBackendError.missingWorkItem(criterionID)
                }
                let ownerID = parsed.value(for: "--owner").map(AirframeID.init) ?? existing.ownerID
                let updated = AirframeCanonicalAcceptanceCriterionRecord(
                    id: existing.id,
                    ownerID: ownerID,
                    text: existing.text,
                    isVerified: existing.isVerified,
                    evidenceIDs: existing.evidenceIDs,
                    metadata: existing.metadata
                )
                try repository.store.save(updated)
                try linkAcceptanceCriterionToOwner(updated.id, ownerID: updated.ownerID, repository: repository)
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try render(
                        AICockpitAcceptanceCriteriaCommandEnvelope(
                            status: "ok",
                            kind: "canonicalAcceptanceCriterionLink",
                            message: "Canonical acceptance criterion linked",
                            backendCapabilities: .canonicalStore,
                            criterion: updated,
                            criteria: [],
                            epicCoverage: nil
                        ),
                        as: outputFormat
                    )
                )
            } catch AICockpitCommandError.denied(let decision, let operation) {
                return AICockpitCommandResult(
                    exitCode: 77,
                    standardOutput: deniedOperationText(
                        decision: decision,
                        operation: operation,
                        actorID: AirframeID("ACTOR-LLM"),
                        projectID: AirframeID("PRJ-AIRFRAME")
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalAcceptanceCriteriaCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals == ["test-suites", "list"] {
            do {
                let repository = try canonicalTestRepository(parsed: parsed)
                let suites = try repository.loadState().testSuites
                    .sorted { $0.id.rawValue < $1.id.rawValue }
                    .map(AICockpitTestSuiteSummary.init)
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try render(
                        AICockpitTestSuiteCommandEnvelope(
                            status: "ok",
                            kind: "canonicalTestSuiteList",
                            message: "Canonical test suites listed",
                            backendCapabilities: .canonicalStore,
                            suite: nil,
                            suites: suites
                        ),
                        as: outputFormat
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalTestSuiteCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3,
           parsed.positionals[0] == "test-suites",
           parsed.positionals[1] == "inspect" {
            do {
                let repository = try canonicalTestRepository(parsed: parsed)
                let suiteID = AirframeID(parsed.positionals[2])
                guard let suite = try repository.store.load(AirframeCanonicalTestSuiteRecord.self, id: suiteID) else {
                    throw AirframeBackendError.missingWorkItem(suiteID)
                }
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try render(
                        AICockpitTestSuiteCommandEnvelope(
                            status: "ok",
                            kind: "canonicalTestSuiteInspection",
                            message: "Canonical test suite loaded",
                            backendCapabilities: .canonicalStore,
                            suite: suite,
                            suites: []
                        ),
                        as: outputFormat
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalTestSuiteCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals == ["test-suites", "create"] {
            do {
                try assertLLMAllowed(parsed: parsed, operationID: "OP-CREATE-TEST-SUITE", category: .proposal)
                let repository = try canonicalTestRepository(parsed: parsed)
                let suite = try buildTestSuiteRecord(parsed: parsed, existing: nil)
                try repository.store.save(suite)
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try render(
                        AICockpitTestSuiteCommandEnvelope(
                            status: "ok",
                            kind: "canonicalTestSuiteCreation",
                            message: "Canonical test suite created",
                            backendCapabilities: .canonicalStore,
                            suite: suite,
                            suites: []
                        ),
                        as: outputFormat
                    )
                )
            } catch AICockpitCommandError.denied(let decision, let operation) {
                return AICockpitCommandResult(
                    exitCode: 77,
                    standardOutput: deniedOperationText(
                        decision: decision,
                        operation: operation,
                        actorID: AirframeID("ACTOR-LLM"),
                        projectID: AirframeID("PRJ-AIRFRAME")
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalTestSuiteCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3,
           parsed.positionals[0] == "test-suites",
           parsed.positionals[1] == "update" {
            do {
                try assertLLMAllowed(parsed: parsed, operationID: "OP-UPDATE-TEST-SUITE", category: .workflowTransition)
                let repository = try canonicalTestRepository(parsed: parsed)
                let suiteID = AirframeID(parsed.positionals[2])
                guard let existing = try repository.store.load(AirframeCanonicalTestSuiteRecord.self, id: suiteID) else {
                    throw AirframeBackendError.missingWorkItem(suiteID)
                }
                let updated = try buildTestSuiteRecord(parsed: parsed, existing: existing)
                try repository.store.save(updated)
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try render(
                        AICockpitTestSuiteCommandEnvelope(
                            status: "ok",
                            kind: "canonicalTestSuiteUpdate",
                            message: "Canonical test suite updated",
                            backendCapabilities: .canonicalStore,
                            suite: updated,
                            suites: []
                        ),
                        as: outputFormat
                    )
                )
            } catch AICockpitCommandError.denied(let decision, let operation) {
                return AICockpitCommandResult(
                    exitCode: 77,
                    standardOutput: deniedOperationText(
                        decision: decision,
                        operation: operation,
                        actorID: AirframeID("ACTOR-LLM"),
                        projectID: AirframeID("PRJ-AIRFRAME")
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalTestSuiteCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3,
           parsed.positionals[0] == "epic",
           ["coverage", "ready"].contains(parsed.positionals[1]) {
            do {
                let repository = try canonicalTestRepository(parsed: parsed)
                let state = try repository.loadState()
                let epicID = AirframeID(parsed.positionals[2])
                let coverage = try epicCoverage(epicID: epicID, state: state)
                return AICockpitCommandResult(
                    exitCode: coverage.isReady ? 0 : 78,
                    standardOutput: try render(
                        AICockpitAcceptanceCriteriaCommandEnvelope(
                            status: coverage.isReady ? "ok" : "blocked",
                            kind: parsed.positionals[1] == "ready" ? "canonicalEpicReadiness" : "canonicalEpicCoverage",
                            message: coverage.isReady ? "Epic coverage is ready" : "Epic coverage has gaps",
                            backendCapabilities: .canonicalStore,
                            criterion: nil,
                            criteria: [],
                            epicCoverage: coverage
                        ),
                        as: outputFormat
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalEpicCoverageCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3,
           parsed.positionals[0] == "tests",
           parsed.positionals[1] == "inspect" {
            do {
                let repository = try canonicalTestRepository(parsed: parsed)
                let testID = AirframeID(parsed.positionals[2])
                guard let test = try repository.loadState().tests.first(where: { $0.id == testID }) else {
                    throw AirframeBackendError.missingWorkItem(testID)
                }
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try render(
                        AICockpitTestCommandEnvelope(
                            status: "ok",
                            kind: "canonicalTestInspection",
                            message: "Canonical test loaded",
                            backendCapabilities: .canonicalStore,
                            test: test,
                            tests: [],
                            validationDiagnostics: nil
                        ),
                        as: outputFormat
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalTestCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals == ["tests", "validate"] {
            do {
                let repository = try canonicalTestRepository(parsed: parsed)
                let projectContext = try parsed.runtimeResolver.loadContext(explicitPath: parsed.value(for: "--config"))
                let snapshot = try repository.snapshot(project: projectContext.project)
                let diagnostics = AirframeCanonicalStateValidator().diagnostics(for: snapshot)
                return AICockpitCommandResult(
                    exitCode: diagnostics.isValid ? 0 : 78,
                    standardOutput: try render(
                        AICockpitTestCommandEnvelope(
                            status: diagnostics.isValid ? "ok" : "error",
                            kind: "canonicalTestValidation",
                            message: diagnostics.isValid ? "Canonical test traceability is valid" : "Canonical test traceability has issues",
                            backendCapabilities: .canonicalStore,
                            test: nil,
                            tests: [],
                            validationDiagnostics: diagnostics
                        ),
                        as: outputFormat
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalTestCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals.count == 2,
           parsed.positionals[0] == "tests",
           parsed.positionals[1] == "create" {
            do {
                let projectID = try parsed.canonicalAwareProjectContext().project.id
                let operation = AirframeOperation(id: AirframeID("OP-CREATE-TEST"), category: .proposal)
                let context = try sampleLLMContext(projectID: projectID)
                let decision = AirframeAuthorityEvaluator().evaluate(
                    context: context,
                    operation: operation,
                    targetProjectID: context.targetProjectID
                )
                guard decision.isAllowed else {
                    throw AICockpitCommandError.denied(decision, operation)
                }

                let repository = try canonicalTestRepository(parsed: parsed)
                let test = try buildTestRecord(parsed: parsed, existing: nil)
                try repository.store.save(test)
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try render(
                        AICockpitTestCommandEnvelope(
                            status: "ok",
                            kind: "canonicalTestCreation",
                            message: "Canonical test created",
                            backendCapabilities: .canonicalStore,
                            test: test,
                            tests: [],
                            validationDiagnostics: nil
                        ),
                        as: outputFormat
                    )
                )
            } catch AICockpitCommandError.denied(let decision, let operation) {
                return AICockpitCommandResult(
                    exitCode: 77,
                    standardOutput: deniedOperationText(
                        decision: decision,
                        operation: operation,
                        actorID: AirframeID("ACTOR-LLM"),
                        projectID: AirframeID("PRJ-AIRFRAME")
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalTestCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3,
           parsed.positionals[0] == "tests",
           parsed.positionals[1] == "update" {
            do {
                let projectID = try parsed.canonicalAwareProjectContext().project.id
                let operation = AirframeOperation(id: AirframeID("OP-UPDATE-TEST"), category: .workflowTransition)
                let context = try sampleLLMContext(projectID: projectID)
                let decision = AirframeAuthorityEvaluator().evaluate(
                    context: context,
                    operation: operation,
                    targetProjectID: context.targetProjectID
                )
                guard decision.isAllowed else {
                    throw AICockpitCommandError.denied(decision, operation)
                }

                let repository = try canonicalTestRepository(parsed: parsed)
                let testID = AirframeID(parsed.positionals[2])
                guard let existing = try repository.store.load(AirframeCanonicalTestRecord.self, id: testID) else {
                    throw AirframeBackendError.missingWorkItem(testID)
                }
                let updated = try buildTestRecord(parsed: parsed, existing: existing)
                try repository.store.save(updated)
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try render(
                        AICockpitTestCommandEnvelope(
                            status: "ok",
                            kind: "canonicalTestUpdate",
                            message: "Canonical test updated",
                            backendCapabilities: .canonicalStore,
                            test: updated,
                            tests: [],
                            validationDiagnostics: nil
                        ),
                        as: outputFormat
                    )
                )
            } catch AICockpitCommandError.denied(let decision, let operation) {
                return AICockpitCommandResult(
                    exitCode: 77,
                    standardOutput: deniedOperationText(
                        decision: decision,
                        operation: operation,
                        actorID: AirframeID("ACTOR-LLM"),
                        projectID: AirframeID("PRJ-AIRFRAME")
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 78,
                    code: "canonicalTestCommandFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals == ["task", "propose"] || parsed.positionals == ["issue", "propose"] {
            return executeBackendCommand(
                outputFormat: outputFormat,
                parsed: parsed,
                controlledMutationsEnabled: true,
                refreshNotifier: refreshNotifier
            ) { backend, context in
                let kind: AirframeWorkItemKind = parsed.positionals[0] == "task" ? .task : .issue
                let operation = AirframeOperation(
                    id: AirframeID(kind == .task ? "OP-PROPOSE-TASK" : "OP-PROPOSE-ISSUE"),
                    category: .proposal
                )
                let decision = AirframeAuthorityEvaluator().evaluate(
                    context: context,
                    operation: operation,
                    targetProjectID: context.targetProjectID
                )
                guard decision.isAllowed else {
                    throw AICockpitCommandError.denied(decision, operation)
                }

                let id = AirframeID(try parsed.requiredValue(for: "--id"))
                let title = try parsed.requiredValue(for: "--title")
                let projectContext = try parsed.canonicalAwareProjectContext()
                let record = AirframeLocalWorkRecord(
                    workItem: AirframeWorkItem(
                        id: id,
                        kind: kind,
                        title: title,
                        status: .active,
                        githubIssue: parsed.value(for: "--github").flatMap(Int.init)
                    ),
                    epicID: parsed.value(for: "--epic").map(AirframeID.init) ?? projectContext.project.activeEpicID,
                    sprintID: parsed.value(for: "--sprint").map(AirframeID.init) ?? projectContext.project.activeSprintID,
                    priority: parsed.value(for: "--priority").flatMap(AirframeWorkPriority.init(rawValue:)) ?? .medium,
                    acceptanceCriteria: parsed.repeatedValues(for: "--acceptance"),
                    scope: parsed.repeatedValues(for: "--scope"),
                    constraints: parsed.repeatedValues(for: "--constraint"),
                    evidenceRequirements: parsed.repeatedValues(for: "--evidence-required"),
                    protectedPaths: parsed.repeatedValues(for: "--protected-path")
                )
                if let githubBackend = backend as? AirframeGitHubIssuesBackend {
                    let result = try githubBackend.createGitHubWorkRecord(
                        record,
                        approval: try parsed.githubMutationApproval(),
                        context: context,
                        targetProjectID: context.targetProjectID
                    )
                    return try render(
                        AICockpitCommandEnvelope(
                            status: "ok",
                            kind: "\(kind.rawValue)Creation",
                            message: "\(kind.rawValue.capitalized) created",
                            backendCapabilities: githubBackend.capabilities,
                            workItem: result.workItem,
                            taskPacket: nil,
                            dashboardSummary: nil,
                            evidence: [],
                            mutationResult: result
                        ),
                        as: outputFormat
                    )
                }
                try backend.createWorkRecord(record)
                if kind == .issue, backend.capabilities.backendKind == "canonical" {
                    try enrichCanonicalIssue(AirframeID(try parsed.requiredValue(for: "--id")), parsed: parsed)
                }
                return try render(
                    AICockpitCommandEnvelope(
                    status: "ok",
                    kind: "\(kind.rawValue)Proposal",
                    message: "\(kind.rawValue.capitalized) proposed",
                    backendCapabilities: backend.capabilities,
                    workItem: record.workItem,
                    taskPacket: nil,
                    dashboardSummary: nil,
                        evidence: []
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals.count == 2,
           let kind = workItemKind(commandName: parsed.positionals[0]),
           parsed.positionals[1] == "create" {
            return executeBackendCommand(
                outputFormat: outputFormat,
                parsed: parsed,
                controlledMutationsEnabled: true,
                refreshNotifier: refreshNotifier
            ) { backend, context in
                let operation = AirframeOperation(
                    id: AirframeID("OP-CREATE-\(kind.rawValue.uppercased())"),
                    category: .proposal
                )
                let decision = AirframeAuthorityEvaluator().evaluate(
                    context: context,
                    operation: operation,
                    targetProjectID: context.targetProjectID
                )
                guard decision.isAllowed else {
                    throw AICockpitCommandError.denied(decision, operation)
                }

                let id = AirframeID(try parsed.requiredValue(for: "--id"))
                try validateID(id, for: kind)
                let projectContext = try parsed.canonicalAwareProjectContext()
                let status = try parsed.optionalCommandStatus(
                    for: "--status",
                    kind: kind,
                    defaultStatus: defaultCreateStatus(for: kind)
                )
                let record = AirframeLocalWorkRecord(
                    workItem: AirframeWorkItem(
                        id: id,
                        kind: kind,
                        title: try parsed.requiredValue(for: "--title"),
                        status: status,
                        githubIssue: parsed.value(for: "--github").flatMap(Int.init)
                    ),
                    epicID: parsed.value(for: "--epic").map(AirframeID.init) ?? defaultEpicID(for: kind, projectContext: projectContext),
                    sprintID: parsed.value(for: "--sprint").map(AirframeID.init) ?? defaultSprintID(for: kind, projectContext: projectContext),
                    priority: parsed.priorityValue,
                    acceptanceCriteria: parsed.repeatedValues(for: "--acceptance"),
                    scope: parsed.repeatedValues(for: "--scope"),
                    constraints: parsed.repeatedValues(for: "--constraint"),
                    evidenceRequirements: parsed.repeatedValues(for: "--evidence-required"),
                    protectedPaths: parsed.repeatedValues(for: "--protected-path")
                )
                if let githubBackend = backend as? AirframeGitHubIssuesBackend {
                    let result = try githubBackend.createGitHubWorkRecord(
                        record,
                        approval: try parsed.githubMutationApproval(),
                        context: context,
                        targetProjectID: context.targetProjectID
                    )
                    return try render(
                        AICockpitCommandEnvelope(
                            status: "ok",
                            kind: "\(kind.rawValue)Creation",
                            message: "\(kind.rawValue.capitalized) created",
                            backendCapabilities: githubBackend.capabilities,
                            workItem: result.workItem,
                            taskPacket: nil,
                            dashboardSummary: nil,
                            evidence: [],
                            mutationResult: result
                        ),
                        as: outputFormat
                    )
                }
                try backend.createWorkRecord(record)
                if kind == .issue, backend.capabilities.backendKind == "canonical" {
                    try enrichCanonicalIssue(id, parsed: parsed)
                }
                return try render(
                    AICockpitCommandEnvelope(
                        status: "ok",
                        kind: "\(kind.rawValue)Creation",
                        message: "\(kind.rawValue.capitalized) created",
                        backendCapabilities: backend.capabilities,
                        workItem: record.workItem,
                        taskPacket: nil,
                        dashboardSummary: nil,
                        evidence: []
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3,
           let kind = workItemKind(commandName: parsed.positionals[0]),
           parsed.positionals[1] == "update" {
            return executeBackendCommand(
                outputFormat: outputFormat,
                parsed: parsed,
                controlledMutationsEnabled: true,
                refreshNotifier: refreshNotifier
            ) { backend, context in
                let operation = AirframeOperation(
                    id: AirframeID("OP-UPDATE-\(kind.rawValue.uppercased())"),
                    category: .workflowTransition
                )
                let decision = AirframeAuthorityEvaluator().evaluate(
                    context: context,
                    operation: operation,
                    targetProjectID: context.targetProjectID
                )
                guard decision.isAllowed else {
                    throw AICockpitCommandError.denied(decision, operation)
                }

                let workItemID = AirframeID(parsed.positionals[2])
                try validateID(workItemID, for: kind)
                let githubApproval = backend is AirframeGitHubIssuesBackend ? try parsed.githubMutationApproval() : nil
                guard let existing = try backend.workRecord(id: workItemID) else {
                    throw AirframeBackendError.missingWorkItem(workItemID)
                }
                guard existing.workItem.kind == kind else {
                    throw AirframeBackendError.unsupportedWorkItemKind(existing.workItem.kind)
                }
                let newStatus = try parsed.optionalCommandStatus(
                    for: "--status",
                    kind: kind,
                    defaultStatus: existing.workItem.status
                )
                if newStatus != existing.workItem.status {
                    try validateWorkflowTransition(
                        id: workItemID,
                        kind: kind,
                        from: existing.workItem.status,
                        to: newStatus,
                        context: context,
                        targetProjectID: context.targetProjectID
                    )
                }
                let updatedWorkItem = AirframeWorkItem(
                    id: existing.workItem.id,
                    kind: kind,
                    title: parsed.value(for: "--title") ?? existing.workItem.title,
                    status: newStatus,
                    githubIssue: parsed.value(for: "--github").flatMap(Int.init) ?? existing.workItem.githubIssue
                )
                let updatedRecord = AirframeLocalWorkRecord(
                    workItem: updatedWorkItem,
                    epicID: parsed.value(for: "--epic").map(AirframeID.init) ?? existing.epicID,
                    sprintID: parsed.value(for: "--sprint").map(AirframeID.init) ?? existing.sprintID,
                    priority: parsed.priorityValue(defaultingTo: existing.priority),
                    acceptanceCriteria: replacementOrExisting(parsed.repeatedValues(for: "--acceptance"), existing.acceptanceCriteria),
                    scope: replacementOrExisting(parsed.repeatedValues(for: "--scope"), existing.scope),
                    constraints: replacementOrExisting(parsed.repeatedValues(for: "--constraint"), existing.constraints),
                    evidenceRequirements: replacementOrExisting(parsed.repeatedValues(for: "--evidence-required"), existing.evidenceRequirements),
                    protectedPaths: replacementOrExisting(parsed.repeatedValues(for: "--protected-path"), existing.protectedPaths),
                    reportFormat: parsed.value(for: "--report-format") ?? existing.reportFormat
                )
                if let githubBackend = backend as? AirframeGitHubIssuesBackend {
                    let result = try githubBackend.updateGitHubWorkRecord(
                        updatedRecord,
                        approval: githubApproval,
                        context: context,
                        targetProjectID: context.targetProjectID
                    )
                    return try render(
                        AICockpitCommandEnvelope(
                            status: "ok",
                            kind: "\(kind.rawValue)Update",
                            message: "\(kind.rawValue.capitalized) updated",
                            backendCapabilities: githubBackend.capabilities,
                            workItem: result.workItem,
                            taskPacket: nil,
                            dashboardSummary: nil,
                            evidence: [],
                            mutationResult: result
                        ),
                        as: outputFormat
                    )
                }
                try backend.updateWorkRecord(updatedRecord)
                if kind == .issue, backend.capabilities.backendKind == "canonical" {
                    try enrichCanonicalIssue(workItemID, parsed: parsed)
                }
                return try render(
                    AICockpitCommandEnvelope(
                        status: "ok",
                        kind: "\(kind.rawValue)Update",
                        message: "\(kind.rawValue.capitalized) updated",
                        backendCapabilities: backend.capabilities,
                        workItem: updatedWorkItem,
                        taskPacket: nil,
                        dashboardSummary: nil,
                        evidence: []
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3,
           let kind = workItemKind(commandName: parsed.positionals[0]),
           parsed.positionals[1] == "status" {
            return executeBackendCommand(
                outputFormat: outputFormat,
                parsed: parsed,
                controlledMutationsEnabled: true,
                refreshNotifier: refreshNotifier
            ) { backend, context in
                let workItemID = AirframeID(parsed.positionals[2])
                try validateID(workItemID, for: kind)
                let status = try parsed.requiredCommandStatus(for: "--to", kind: kind)
                if let githubBackend = backend as? AirframeGitHubIssuesBackend {
                    let result = try githubBackend.transitionGitHubStatus(
                        workItemID: workItemID,
                        to: status,
                        approval: try parsed.githubMutationApproval(),
                        context: context,
                        targetProjectID: context.targetProjectID
                    )
                    return try render(
                        AICockpitCommandEnvelope(
                            status: "ok",
                            kind: "\(kind.rawValue)Status",
                            message: "\(kind.rawValue.capitalized) status updated",
                            backendCapabilities: githubBackend.capabilities,
                            workItem: result.workItem,
                            taskPacket: nil,
                            dashboardSummary: nil,
                            evidence: [],
                            mutationResult: result
                        ),
                        as: outputFormat
                    )
                }
                try backend.transitionWorkItem(
                    id: workItemID,
                    to: status,
                    context: context,
                    targetProjectID: context.targetProjectID
                )
                let workItem = try backend.workRecord(id: workItemID)?.workItem
                return try render(
                    AICockpitCommandEnvelope(
                        status: "ok",
                        kind: "\(kind.rawValue)Status",
                        message: "\(kind.rawValue.capitalized) status updated",
                        backendCapabilities: backend.capabilities,
                        workItem: workItem,
                        taskPacket: nil,
                        dashboardSummary: nil,
                        evidence: []
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals.count == 2,
           let kind = workItemKind(commandName: parsed.positionals[0]),
           parsed.positionals[1] == "list" {
            return executeBackendCommand(outputFormat: outputFormat, parsed: parsed) { backend, _ in
                let records = try backend.listWorkRecords()
                    .filter { $0.workItem.kind == kind }
                    .sorted { $0.workItem.id.rawValue < $1.workItem.id.rawValue }
                return try render(
                    AICockpitArtifactCommandEnvelope(
                        status: "ok",
                        kind: "\(kind.rawValue)List",
                        message: "\(kind.rawValue.capitalized) records listed",
                        workItems: records.map(\.workItem)
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3,
           let kind = workItemKind(commandName: parsed.positionals[0]),
           parsed.positionals[1] == "inspect" {
            return executeBackendCommand(outputFormat: outputFormat, parsed: parsed) { backend, _ in
                let id = AirframeID(parsed.positionals[2])
                try validateID(id, for: kind)
                guard let record = try backend.workRecord(id: id) else {
                    throw AirframeBackendError.missingWorkItem(id)
                }
                guard record.workItem.kind == kind else {
                    throw AirframeBackendError.unsupportedWorkItemKind(record.workItem.kind)
                }
                let links = try? artifactLinks(for: id, parsed: parsed)
                return try render(
                    AICockpitArtifactCommandEnvelope(
                        status: "ok",
                        kind: "\(kind.rawValue)Inspection",
                        message: "\(kind.rawValue.capitalized) inspected",
                        workItem: record.workItem,
                        links: links
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3,
           let kind = workItemKind(commandName: parsed.positionals[0]),
           parsed.positionals[1] == "link" {
            do {
                let id = AirframeID(parsed.positionals[2])
                try linkCanonicalArtifact(kind: kind, id: id, parsed: parsed)
                let links = try artifactLinks(for: id, parsed: parsed)
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try render(
                        AICockpitArtifactCommandEnvelope(
                            status: "ok",
                            kind: "\(kind.rawValue)Links",
                            message: "\(kind.rawValue.capitalized) links updated",
                            workItem: links.workItem,
                            links: links
                        ),
                        as: outputFormat
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 65,
                    code: "artifactLinkFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals.count == 2,
           let kind = workItemKind(commandName: parsed.positionals[0]),
           parsed.positionals[1] == "gaps" {
            do {
                let repository = try canonicalTestRepository(parsed: parsed)
                let state = try repository.loadState()
                let records = repository.workRecords(from: state)
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: try render(
                        AICockpitArtifactCommandEnvelope(
                            status: "ok",
                            kind: "\(kind.rawValue)Gaps",
                            message: "\(kind.rawValue.capitalized) relationship gaps reported",
                            gaps: artifactGapMessages(kind: kind, records: records, state: state)
                        ),
                        as: outputFormat
                    )
                )
            } catch {
                return errorResult(
                    exitCode: 65,
                    code: "artifactGapsFailed",
                    message: "\(error)",
                    outputFormat: outputFormat
                )
            }
        }

        if parsed.positionals == ["task", "next"] {
            return executeBackendCommand(outputFormat: outputFormat, parsed: parsed) { backend, _ in
                let nextTask = try backend.dashboardSummary().nextTask
                return try render(
                    AICockpitCommandEnvelope(
                        status: nextTask == nil ? "empty" : "ok",
                        kind: "nextTask",
                        message: nextTask == nil ? "No active task is available" : "Next active task",
                        backendCapabilities: backend.capabilities,
                        workItem: nextTask,
                        taskPacket: nil,
                        dashboardSummary: nil,
                        evidence: []
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3 && parsed.positionals[0] == "task" && parsed.positionals[1] == "packet" {
            return executeBackendCommand(outputFormat: outputFormat, parsed: parsed) { backend, _ in
                let packet = try backend.taskPacket(for: AirframeID(parsed.positionals[2]))
                return try render(
                    AICockpitCommandEnvelope(
                        status: "ok",
                        kind: "taskPacket",
                        message: "Task packet generated",
                        backendCapabilities: backend.capabilities,
                        workItem: packet.workItem,
                        taskPacket: packet,
                        dashboardSummary: nil,
                        evidence: packet.existingEvidence
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3 && parsed.positionals[0] == "evidence" && parsed.positionals[1] == "attach" {
            return executeBackendCommand(
                outputFormat: outputFormat,
                parsed: parsed,
                refreshNotifier: refreshNotifier
            ) { backend, context in
                let operation = AirframeOperation(id: AirframeID("OP-ATTACH-EVIDENCE"), category: .evidence)
                let decision = AirframeAuthorityEvaluator().evaluate(
                    context: context,
                    operation: operation,
                    targetProjectID: context.targetProjectID
                )
                guard decision.isAllowed else {
                    throw AICockpitCommandError.denied(decision, operation)
                }

                let evidence = AirframeEvidence(
                    id: AirframeID(try parsed.requiredValue(for: "--id")),
                    summary: try parsed.requiredValue(for: "--summary"),
                    artifact: try parsed.requiredValue(for: "--artifact")
                )
                try backend.attachEvidence(evidence, to: AirframeID(parsed.positionals[2]))
                return try render(
                    AICockpitCommandEnvelope(
                        status: "ok",
                        kind: "evidenceAttachment",
                        message: "Evidence attached",
                        backendCapabilities: backend.capabilities,
                        workItem: try backend.workRecord(id: AirframeID(parsed.positionals[2]))?.workItem,
                        taskPacket: nil,
                        dashboardSummary: nil,
                        evidence: [evidence]
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3 && parsed.positionals[0] == "github" && parsed.positionals[1] == "comment" {
            return executeBackendCommand(
                outputFormat: outputFormat,
                parsed: parsed,
                controlledMutationsEnabled: true,
                refreshNotifier: refreshNotifier
            ) { backend, context in
                guard let githubBackend = backend as? AirframeGitHubIssuesBackend else {
                    throw AICockpitCommandError.invalidArguments("github comment requires backend github-issues")
                }
                let result = try githubBackend.addIssueComment(
                    to: AirframeID(parsed.positionals[2]),
                    body: try parsed.requiredValue(for: "--body"),
                    approval: try parsed.githubMutationApproval(),
                    context: context,
                    targetProjectID: context.targetProjectID
                )
                return try render(
                    AICockpitCommandEnvelope(
                        status: "ok",
                        kind: "githubIssueComment",
                        message: "GitHub issue comment created",
                        backendCapabilities: githubBackend.capabilities,
                        workItem: result.workItem,
                        taskPacket: nil,
                        dashboardSummary: nil,
                        evidence: [],
                        mutationResult: result
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3 && parsed.positionals[0] == "github" && parsed.positionals[1] == "evidence-comment" {
            return executeBackendCommand(
                outputFormat: outputFormat,
                parsed: parsed,
                controlledMutationsEnabled: true,
                refreshNotifier: refreshNotifier
            ) { backend, context in
                guard let githubBackend = backend as? AirframeGitHubIssuesBackend else {
                    throw AICockpitCommandError.invalidArguments("github evidence-comment requires backend github-issues")
                }
                let evidence = AirframeEvidence(
                    id: AirframeID(try parsed.requiredValue(for: "--id")),
                    summary: try parsed.requiredValue(for: "--summary"),
                    artifact: try parsed.requiredValue(for: "--artifact")
                )
                let result = try githubBackend.attachEvidenceComment(
                    evidence,
                    to: AirframeID(parsed.positionals[2]),
                    approval: try parsed.githubMutationApproval(),
                    context: context,
                    targetProjectID: context.targetProjectID
                )
                return try render(
                    AICockpitCommandEnvelope(
                        status: "ok",
                        kind: "githubEvidenceComment",
                        message: "GitHub evidence comment created",
                        backendCapabilities: githubBackend.capabilities,
                        workItem: result.workItem,
                        taskPacket: nil,
                        dashboardSummary: nil,
                        evidence: [evidence],
                        mutationResult: result
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3 && parsed.positionals[0] == "github" && parsed.positionals[1] == "status" {
            return executeBackendCommand(
                outputFormat: outputFormat,
                parsed: parsed,
                controlledMutationsEnabled: true,
                refreshNotifier: refreshNotifier
            ) { backend, context in
                guard let githubBackend = backend as? AirframeGitHubIssuesBackend else {
                    throw AICockpitCommandError.invalidArguments("github status requires backend github-issues")
                }
                let status = try parsed.requiredStatus(for: "--to")
                let result = try githubBackend.transitionGitHubStatus(
                    workItemID: AirframeID(parsed.positionals[2]),
                    to: status,
                    approval: try parsed.githubMutationApproval(),
                    context: context,
                    targetProjectID: context.targetProjectID
                )
                return try render(
                    AICockpitCommandEnvelope(
                        status: "ok",
                        kind: "githubStatusLabelTransition",
                        message: "GitHub status label transitioned",
                        backendCapabilities: githubBackend.capabilities,
                        workItem: result.workItem,
                        taskPacket: nil,
                        dashboardSummary: nil,
                        evidence: [],
                        mutationResult: result
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3 && parsed.positionals[0] == "work" && parsed.positionals[1] == "ready" {
            return executeBackendCommand(
                outputFormat: outputFormat,
                parsed: parsed,
                refreshNotifier: refreshNotifier
            ) { backend, context in
                let workItemID = AirframeID(parsed.positionals[2])
                try backend.transitionWorkItem(
                    id: workItemID,
                    to: .implementedNotVerified,
                    context: context,
                    targetProjectID: context.targetProjectID
                )
                let workItem = try backend.workRecord(id: workItemID)?.workItem
                return try render(
                    AICockpitCommandEnvelope(
                        status: "ok",
                        kind: "readyForVerification",
                        message: "Work marked ready for human verification",
                        backendCapabilities: backend.capabilities,
                        workItem: workItem,
                        taskPacket: nil,
                        dashboardSummary: nil,
                        evidence: try backend.evidence(for: workItemID)
                    ),
                    as: outputFormat
                )
            }
        }

        return errorResult(
            exitCode: 64,
            code: "unknownCommand",
            message: "unknown command",
            outputFormat: outputFormat,
            markdownSuffix: "\n\(helpText())"
        )
    }

    public static func helpText() -> String {
        """
        aicockpit

        Agent-facing command interface for Agile Airframe.

        Usage:
          aicockpit --help
          aicockpit version
          aicockpit context [--config path]
          aicockpit config diagnose [--config path] [--output markdown|json]
          aicockpit state diagnostics [--config path] [--backend canonical|local-fixture|github-fixture|github-issues] [--store path] [--output markdown|json]
          aicockpit state import-markdown [--config path] [--output markdown|json]
          aicockpit state export-markdown [--config path]
          aicockpit requirements import --format csv|json --file path --dry-run [--config path] [--output markdown|json]
          aicockpit requirements import --format csv|json --file path --apply [--config path] [--output markdown|json]
          aicockpit requirements export --format csv|json [--config path]
          aicockpit acceptance-criteria list [--config path] [--output markdown|json]
          aicockpit acceptance-criteria inspect AC-ID [--config path] [--output markdown|json]
          aicockpit acceptance-criteria create --id AC-ID --owner EP-ID --text text [--verified true|false] [--evidence EV-ID] [--config path] [--output markdown|json]
          aicockpit acceptance-criteria update AC-ID [--owner EP-ID] [--text text] [--verified true|false] [--evidence EV-ID] [--config path] [--output markdown|json]
          aicockpit acceptance-criteria link AC-ID --owner EP-ID [--config path] [--output markdown|json]
          aicockpit plans list [--config path] [--output markdown|json]
          aicockpit plans inspect PLAN-ID [--config path] [--output markdown|json]
          aicockpit plans submit --id PLAN-ID --title title --summary text [--epic EP-ID] [--sprint SP-ID] [--task T-ID] [--scope text] [--file-change text] [--command text] [--external-effect text] [--verification text] [--note text] [--config path] [--output markdown|json]
          aicockpit plans approve|defer|reject PLAN-ID [--note text] [--config path] [--output markdown|json]
          aicockpit tests list [--config path] [--output markdown|json]
          aicockpit tests inspect TEST-ID [--config path] [--output markdown|json]
          aicockpit tests create --id TEST-ID --title title --objective text [--kind unit|integration|ui|acceptance|regression|dataValidation|manual] [--status draft|ready|active|retired] [--requirement REQ-ID] [--acceptance-criterion AC-ID] [--work-item ID] [--evidence EV-ID] [--step text] [--expected text] [--automation-command command] [--artifact path] [--note text] [--config path] [--output markdown|json]
          aicockpit tests update TEST-ID [--title title] [--objective text] [--kind unit|integration|ui|acceptance|regression|dataValidation|manual] [--status draft|ready|active|retired] [--requirement REQ-ID] [--acceptance-criterion AC-ID] [--work-item ID] [--evidence EV-ID] [--step text] [--expected text] [--automation-command command] [--artifact path] [--note text] [--config path] [--output markdown|json]
          aicockpit tests validate [--config path] [--output markdown|json]
          aicockpit test-suites list [--config path] [--output markdown|json]
          aicockpit test-suites inspect TS-ID [--config path] [--output markdown|json]
          aicockpit test-suites create --id TS-ID --title title --objective text [--status draft|ready|active|retired] [--test TEST-ID] [--requirement REQ-ID] [--acceptance-criterion AC-ID] [--note text] [--config path] [--output markdown|json]
          aicockpit test-suites update TS-ID [--title title] [--objective text] [--status draft|ready|active|retired] [--test TEST-ID] [--requirement REQ-ID] [--acceptance-criterion AC-ID] [--note text] [--config path] [--output markdown|json]
          aicockpit state repair --action applyBackendStatusLabels|applyBackendRelationshipLabels|clearActiveEpicID|clearActiveSprintID|restoreEpicToActive|restoreSprintToActive|setActiveEpicID|setActiveSprintID|reconcileEpicSprintLinks|reconcileEpicTaskLinks|reconcileSprintTaskLinks [--id ID] --approve --approved-by name [--config path] [--backend canonical|github-issues|local-fixture|github-fixture] [--output markdown|json]
          aicockpit authority demo-denied [--config path]
          aicockpit project summary [--config path] [--backend canonical|local-fixture|github-fixture|github-issues] [--store path] [--output markdown|json]
          aicockpit task propose --id T-XXXX --title title [--config path] [--backend canonical|local-fixture|github-fixture] [--store path]
          aicockpit issue propose --id I-XXXX --title title [--config path] [--backend canonical|local-fixture|github-fixture] [--store path]
          aicockpit task create --id T-XXXX --title title [--status backlog|active] [--config path] [--backend canonical|local-fixture|github-fixture] [--store path]
          aicockpit issue create --id I-XXXX --title title [--status backlog|active] [--observed text] [--expected text] [--repro text] [--component name] [--note text] [--config path] [--backend canonical|local-fixture|github-fixture] [--store path]
          aicockpit sprint create --id SP-XXXX --title title [--status backlog|planning] [--config path] [--backend canonical|local-fixture|github-fixture] [--store path]
          aicockpit epic create --id EP-XXXX --title title [--status proposed|draft|backlog] [--config path] [--backend canonical|local-fixture|github-fixture] [--store path]
          aicockpit task|issue|sprint|epic update ID [--title title] [--status value] [--observed text] [--expected text] [--repro text] [--component name] [--note text] [--config path] [--backend canonical|local-fixture|github-fixture] [--store path]
          aicockpit task|issue|sprint|epic status ID --to value [--config path] [--backend canonical|local-fixture|github-fixture] [--store path]
          aicockpit task|issue|sprint|epic list [--config path] [--backend canonical|local-fixture|github-fixture|github-issues] [--store path] [--output markdown|json]
          aicockpit task|issue|sprint|epic inspect ID [--config path] [--backend canonical|local-fixture|github-fixture|github-issues] [--store path] [--output markdown|json]
          aicockpit task|issue|sprint|epic link ID [--epic EP-ID] [--sprint SP-ID] [--task T-ID] [--issue I-ID] [--requirement REQ-ID] [--acceptance-criterion AC-ID] [--test TEST-ID] [--config path] [--output markdown|json]
          aicockpit task|issue|sprint|epic gaps [--config path] [--output markdown|json]
          aicockpit epic coverage EP-ID [--config path] [--output markdown|json]
          aicockpit epic ready EP-ID [--config path] [--output markdown|json]
          aicockpit task next [--config path] [--backend canonical|local-fixture|github-fixture|github-issues] [--store path] [--output markdown|json]
          aicockpit task packet T-XXXX [--config path] [--backend canonical|local-fixture|github-fixture|github-issues] [--store path] [--output markdown|json]
          aicockpit evidence attach T-XXXX --id EV-XXXX --summary text --artifact path [--config path] [--backend local-fixture|github-fixture] [--store path]
          aicockpit work ready T-XXXX [--config path] [--backend local-fixture|github-fixture] [--store path]
          aicockpit github comment T-XXXX --body text --approve --approved-by name [--config path] [--backend github-issues] [--output markdown|json]
          aicockpit github evidence-comment T-XXXX --id EV-XXXX --summary text --artifact path --approve --approved-by name [--config path] [--backend github-issues] [--output markdown|json]
          aicockpit github status T-XXXX --to active|unverified|verified|backlog|closed --approve --approved-by name [--config path] [--backend github-issues] [--output markdown|json]

        Linked Core:
          \(AirframeCoreInfo.current.summary)
        """
    }

    public static func contextText(for context: AirframeProjectContext) -> String {
        """
        Airframe Context
        \(context.summaryLines.joined(separator: "\n"))
        """
    }

    public static func deniedOperationText(
        decision: AirframeAuthorityDecision,
        operation: AirframeOperation,
        actorID: AirframeID,
        projectID: AirframeID
    ) -> String {
        """
        Airframe Authority Decision
        status: \(decision.isAllowed ? "allowed" : "denied")
        reason: \(decision.reason.rawValue)
        operation: \(operation.id.rawValue)
        category: \(operation.category.rawValue)
        actor: \(actorID.rawValue)
        project: \(projectID.rawValue)
        """
    }

    private static func workItemKind(commandName: String) -> AirframeWorkItemKind? {
        switch commandName {
        case "task":
            .task
        case "issue":
            .issue
        case "sprint":
            .sprint
        case "epic":
            .epic
        default:
            nil
        }
    }

    private static func validateID(_ id: AirframeID, for kind: AirframeWorkItemKind) throws {
        let prefix = switch kind {
        case .task:
            "T-"
        case .issue:
            "I-"
        case .sprint:
            "SP-"
        case .epic:
            "EP-"
        }
        guard id.rawValue.hasPrefix(prefix) else {
            throw AICockpitCommandError.invalidArguments("\(kind.rawValue) id must start with \(prefix)")
        }
    }

    private static func defaultCreateStatus(for kind: AirframeWorkItemKind) -> AirframeWorkStatus {
        switch kind {
        case .task, .issue, .sprint:
            .backlog
        case .epic:
            .proposed
        }
    }

    private static func defaultEpicID(
        for kind: AirframeWorkItemKind,
        projectContext: AirframeProjectContext
    ) -> AirframeID? {
        switch kind {
        case .task, .issue, .sprint:
            projectContext.project.activeEpicID
        case .epic:
            nil
        }
    }

    private static func defaultSprintID(
        for kind: AirframeWorkItemKind,
        projectContext: AirframeProjectContext
    ) -> AirframeID? {
        switch kind {
        case .task, .issue:
            projectContext.project.activeSprintID
        case .sprint, .epic:
            nil
        }
    }

    private static func replacementOrExisting<T>(_ replacement: [T], _ existing: [T]) -> [T] {
        replacement.isEmpty ? existing : replacement
    }

    private static func validateWorkflowTransition(
        id: AirframeID,
        kind: AirframeWorkItemKind,
        from: AirframeWorkStatus,
        to status: AirframeWorkStatus,
        context: AirframeCertifiedContext,
        targetProjectID: AirframeID
    ) throws {
        let operation = AirframeOperation(
            id: operationID(for: status),
            category: status == .implementedVerified ? .humanAcceptance : .workflowTransition
        )
        let transition = AirframeWorkflowTransition(
            workItemID: id,
            kind: kind,
            fromStatus: from,
            toStatus: status,
            operation: operation
        )
        let decision = AirframeWorkflowTransitionEvaluator().evaluate(
            context: context,
            transition: transition,
            targetProjectID: targetProjectID
        )
        switch decision {
        case .allowed:
            return
        case .requiresConfirmation(let reason):
            throw AirframeBackendError.requiresConfirmation(reason)
        case .denied(let reason, let authorityReason):
            if reason == .invalidTransition {
                throw AirframeBackendError.invalidTransition(from: from, to: status)
            }
            throw AirframeBackendError.authorityDenied(authorityReason)
        }
    }

    private static func operationID(for status: AirframeWorkStatus) -> AirframeID {
        switch status {
        case .proposed:
            AirframeID("OP-PROPOSE-WORK")
        case .draft:
            AirframeID("OP-DRAFT-WORK")
        case .backlog:
            AirframeID("OP-RETURN-TO-BACKLOG")
        case .planning:
            AirframeID("OP-PLAN-WORK")
        case .active:
            AirframeID("OP-ACTIVATE-WORK")
        case .review:
            AirframeID("OP-REVIEW-WORK")
        case .implementedNotVerified:
            AirframeID("OP-READY-FOR-VERIFICATION")
        case .implementedVerified:
            AirframeID("OP-HUMAN-VERIFY")
        case .complete:
            AirframeID("OP-COMPLETE-WORK")
        case .closed:
            AirframeID("OP-CLOSE-WORK")
        }
    }

    private static func sampleLLMContext(projectID: AirframeID) throws -> AirframeCertifiedContext {
        let actor = AirframeActor(
            id: AirframeID("ACTOR-LLM"),
            displayName: "AICockpit Agent",
            authorityClass: .llmAgent,
            credentialSource: .cliEnvironment
        )
        let credential = AirframeCredentialContext(
            credentialID: AirframeID("CRED-AICOCKPIT-CLI"),
            actorID: actor.id,
            credentialSource: .cliEnvironment,
            executionProjectID: projectID,
            allowedProjectIDs: [projectID]
        )

        return try AirframeCertifiedContext(
            actor: actor,
            credential: credential,
            targetProjectID: projectID
        )
    }

    private static func executeBackendCommand(
        outputFormat: AICockpitOutputFormat,
        parsed: AICockpitArguments,
        controlledMutationsEnabled: Bool = false,
        refreshNotifier: (any AICockpitRefreshNotifying)? = nil,
        body: (any AirframeBackend, AirframeCertifiedContext) throws -> String
    ) -> AICockpitCommandResult {
        do {
            let context = try parsed.runtimeResolver.loadContext(explicitPath: parsed.value(for: "--config"))
            let certifiedContext = try sampleLLMContext(projectID: context.project.id)
            let backend = try parsed.backend(
                projectContext: context,
                controlledMutationsEnabled: controlledMutationsEnabled
            )
            let output = try body(backend, certifiedContext)
            refreshNotifier?.postRefresh()
            return AICockpitCommandResult(exitCode: 0, standardOutput: output)
        } catch AICockpitCommandError.denied(let decision, let operation) {
            return AICockpitCommandResult(
                exitCode: 77,
                standardOutput: deniedOperationText(
                    decision: decision,
                    operation: operation,
                    actorID: AirframeID("ACTOR-LLM"),
                    projectID: AirframeID("PRJ-AIRFRAME")
                )
            )
        } catch AICockpitCommandError.invalidArguments(let message) {
            return errorResult(
                exitCode: 64,
                code: "invalidArguments",
                message: message,
                outputFormat: outputFormat
            )
        } catch {
            return errorResult(
                exitCode: 78,
                code: "backendCommandFailed",
                message: "\(error)",
                outputFormat: outputFormat
            )
        }
    }

    private static func contextualConfigurationDiagnostics(
        _ diagnostics: AirframeConfigurationDiagnostics,
        configuration: AirframeWorkspaceConfiguration,
        parsed: AICockpitArguments
    ) -> AirframeConfigurationDiagnostics {
        guard diagnostics.isValid,
              configuration.backend.kind.hasPrefix("github"),
              let projectContext = try? AirframeConfigurationLoader().context(for: configuration),
              let rootURL = try? parsed.workspaceRootURL(projectContext: projectContext),
              FileManager.default.fileExists(atPath: rootURL.appending(path: ".airframe/state").path) else {
            return diagnostics
        }

        var issues = diagnostics.issues
        issues.append(
            AirframeConfigurationDiagnosticIssue(
                severity: .warning,
                code: "canonicalStoreUsesLocalBackend",
                message: "Canonical state exists at .airframe/state; local operation uses the canonical backend before live GitHub, so GitHub-backed paths are optional."
            )
        )
        let status: AirframeConfigurationDiagnosticSeverity
        if issues.contains(where: { $0.severity == .error }) {
            status = .error
        } else if issues.contains(where: { $0.severity == .warning }) {
            status = .warning
        } else {
            status = .ok
        }
        return AirframeConfigurationDiagnostics(
            status: status,
            workspaceID: diagnostics.workspaceID,
            defaultProjectID: diagnostics.defaultProjectID,
            projectCount: diagnostics.projectCount,
            backendKind: diagnostics.backendKind,
            backendLocation: diagnostics.backendLocation,
            issues: issues
        )
    }

    private static func errorResult(
        exitCode: Int32,
        code: String,
        message: String,
        outputFormat: AICockpitOutputFormat,
        markdownSuffix: String = ""
    ) -> AICockpitCommandResult {
        switch outputFormat {
        case .markdown:
            return AICockpitCommandResult(
                exitCode: exitCode,
                standardError: "aicockpit: \(message)\n\(markdownSuffix)"
            )
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let envelope = AICockpitErrorEnvelope(
                status: "error",
                code: code,
                message: message
            )
            let output = (try? String(decoding: encoder.encode(envelope), as: UTF8.self)) ?? """
            {
              "status" : "error",
              "code" : "\(code)",
              "message" : "\(message)"
            }
            """
            return AICockpitCommandResult(exitCode: exitCode, standardOutput: output)
        }
    }

    private static func render(
        _ envelope: AICockpitCommandEnvelope,
        as outputFormat: AICockpitOutputFormat
    ) throws -> String {
        switch outputFormat {
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return String(decoding: try encoder.encode(envelope), as: UTF8.self)
        case .markdown:
            return envelope.markdown
        }
    }

    private static func render(
        _ envelope: AICockpitArtifactCommandEnvelope,
        as outputFormat: AICockpitOutputFormat
    ) throws -> String {
        switch outputFormat {
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return String(decoding: try encoder.encode(envelope), as: UTF8.self)
        case .markdown:
            return envelope.markdown
        }
    }

    private static func renderRequirementImportPreview(
        _ preview: AirframeRequirementImportPreview,
        format: AICockpitRequirementInterchangeFormat,
        applied: Bool,
        as outputFormat: AICockpitOutputFormat
    ) throws -> String {
        let response = AICockpitRequirementImportPreviewResponse(
            status: "ok",
            kind: applied ? "requirementsImportApply" : "requirementsImportPreview",
            message: applied ? "Requirements import applied" : "Requirements import dry run completed",
            format: format.rawValue,
            applied: applied,
            createdCount: preview.createdCount,
            updatedCount: preview.updatedCount,
            unchangedCount: preview.unchangedCount,
            removedCount: preview.removedCount,
            conflictedCount: preview.conflictedCount,
            requirements: preview.requirements,
            revisions: preview.revisions
        )
        switch outputFormat {
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return String(decoding: try encoder.encode(response), as: UTF8.self)
        case .markdown:
            return response.markdown
        }
    }

    private static func markdownArtifactDocuments(rootURL: URL) throws -> [AirframeMarkdownDocument] {
        let fileManager = FileManager.default
        let fixedPaths = [
            "docs/Epics/Epic-backlog.md",
            "docs/Epics/Epic-active.md",
            "docs/Sprints/Sprint-backlog.md",
            "docs/Sprints/Sprint-active.md",
            "docs/Tasks/Task-backlog.md",
            "docs/Tasks/Task-active.md",
            "docs/Tasks/Task-unverified.md",
            "docs/Issues/Issue-backlog.md",
            "docs/Issues/Issue-active.md"
        ]
        let directories = [
            "docs/Epics/Closed",
            "docs/Sprints/Closed",
            "docs/Sprints/Review",
            "docs/Tasks/Verified",
            "docs/Issues/Verified",
            "docs/requirements"
        ]

        let fixedURLs = fixedPaths.map { rootURL.appending(path: $0) }
        let directoryURLs = directories.flatMap { relativePath in
            let directoryURL = rootURL.appending(path: relativePath)
            guard let urls = try? fileManager.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: nil
            ) else {
                return [URL]()
            }
            return urls.filter { $0.pathExtension == "md" }
        }
        return try (fixedURLs + directoryURLs)
            .filter { fileManager.fileExists(atPath: $0.path) }
            .sorted { $0.path < $1.path }
            .map { url in
                AirframeMarkdownDocument(
                    sourcePath: url.path.replacingOccurrences(of: "\(rootURL.path)/", with: ""),
                    markdown: try String(contentsOf: url, encoding: .utf8)
                )
            }
    }

    private static func renderImportResult(
        _ result: AirframeMarkdownImportResult,
        rootURL: URL,
        outputFormat: AICockpitOutputFormat
    ) throws -> String {
        switch outputFormat {
        case .markdown:
            var lines = [
                "# Airframe Command",
                "",
                "- status: \(result.isClean ? "ok" : "error")",
                "- kind: canonicalMarkdownImport",
                "- message: Markdown artifacts imported into canonical state",
                "- state: \(rootURL.appending(path: ".airframe/state").path)",
                "- epics: \(result.epics.count)",
                "- sprints: \(result.sprints.count)",
                "- tasks: \(result.tasks.count)",
                "- issues: \(result.issues.count)",
                "- requirements: \(result.requirements.count)",
                "- acceptanceCriteria: \(result.acceptanceCriteria.count)"
            ]
            if !result.diagnostics.isEmpty {
                lines.append("")
                lines.append("## Diagnostics")
                lines.append(
                    contentsOf: result.diagnostics.map {
                        "- \($0.severity.rawValue) \($0.code.rawValue): \($0.message)"
                    }
                )
            }
            return lines.joined(separator: "\n")
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return String(decoding: try encoder.encode(result), as: UTF8.self)
        }
    }

    private static func renderRepairResult(
        _ result: AirframeCanonicalBackendRepairResult,
        outputFormat: AICockpitOutputFormat
    ) throws -> String {
        switch outputFormat {
        case .markdown:
            var lines = [
                "# Airframe Command",
                "",
                "- status: ok",
                "- kind: canonicalBackendRepair",
                "- message: Backend repair applied",
                "- applied: \(result.appliedCount)"
            ]
            if !result.applications.isEmpty {
                lines.append("")
                lines.append("## Applications")
                lines.append(contentsOf: result.applications.map {
                    "- \($0.workItemID.rawValue) \($0.action.rawValue): \($0.message)"
                })
            }
            return lines.joined(separator: "\n")
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return String(decoding: try encoder.encode(result), as: UTF8.self)
        }
    }

    private static func render(
        _ envelope: AICockpitTestCommandEnvelope,
        as outputFormat: AICockpitOutputFormat
    ) throws -> String {
        switch outputFormat {
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return String(decoding: try encoder.encode(envelope), as: UTF8.self)
        case .markdown:
            return envelope.markdown
        }
    }

    private static func render(
        _ envelope: AICockpitAcceptanceCriteriaCommandEnvelope,
        as outputFormat: AICockpitOutputFormat
    ) throws -> String {
        switch outputFormat {
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return String(decoding: try encoder.encode(envelope), as: UTF8.self)
        case .markdown:
            return envelope.markdown
        }
    }

    private static func render(
        _ envelope: AICockpitTestSuiteCommandEnvelope,
        as outputFormat: AICockpitOutputFormat
    ) throws -> String {
        switch outputFormat {
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return String(decoding: try encoder.encode(envelope), as: UTF8.self)
        case .markdown:
            return envelope.markdown
        }
    }

    private static func render(
        _ envelope: AICockpitPlanCommandEnvelope,
        as outputFormat: AICockpitOutputFormat
    ) throws -> String {
        switch outputFormat {
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return String(decoding: try encoder.encode(envelope), as: UTF8.self)
        case .markdown:
            return envelope.markdown
        }
    }

    private static func canonicalTestRepository(parsed: AICockpitArguments) throws -> AirframeCanonicalStoreRepository {
        let projectContext = try parsed.runtimeResolver.loadContext(explicitPath: parsed.value(for: "--config"))
        let rootURL = try parsed.workspaceRootURL(projectContext: projectContext)
        return AirframeCanonicalStoreRepository(rootURL: rootURL)
    }

    private static func assertLLMAllowed(
        parsed: AICockpitArguments,
        operationID: String,
        category: AirframeOperationCategory
    ) throws {
        let projectID = try parsed.canonicalAwareProjectContext().project.id
        let operation = AirframeOperation(id: AirframeID(operationID), category: category)
        let context = try sampleLLMContext(projectID: projectID)
        let decision = AirframeAuthorityEvaluator().evaluate(
            context: context,
            operation: operation,
            targetProjectID: context.targetProjectID
        )
        guard decision.isAllowed else {
            throw AICockpitCommandError.denied(decision, operation)
        }
    }

    private static func buildAcceptanceCriterionRecord(
        parsed: AICockpitArguments,
        existing: AirframeCanonicalAcceptanceCriterionRecord?
    ) throws -> AirframeCanonicalAcceptanceCriterionRecord {
        let id: AirframeID
        if let existing {
            id = existing.id
        } else {
            id = AirframeID(try parsed.requiredValue(for: "--id"))
        }
        let ownerID = parsed.value(for: "--owner").map(AirframeID.init) ?? existing?.ownerID
        guard let ownerID else {
            throw AICockpitCommandError.invalidArguments("missing required option --owner")
        }
        let text = parsed.value(for: "--text") ?? existing?.text
        guard let text, !text.isEmpty else {
            throw AICockpitCommandError.invalidArguments("missing required option --text")
        }
        let isVerified = parsed.value(for: "--verified").flatMap(Bool.init) ?? existing?.isVerified ?? false
        return AirframeCanonicalAcceptanceCriterionRecord(
            id: id,
            ownerID: ownerID,
            text: text,
            isVerified: isVerified,
            evidenceIDs: replacementOrExisting(
                parsed.repeatedValues(for: "--evidence").map(AirframeID.init),
                existing?.evidenceIDs ?? []
            ),
            metadata: existing?.metadata ?? AirframeCanonicalRecordMetadata()
        )
    }

    private static func buildPlanRecord(
        parsed: AICockpitArguments,
        projectContext: AirframeProjectContext
    ) throws -> AirframeCanonicalImplementationPlanRecord {
        let id = AirframeID(try parsed.requiredValue(for: "--id"))
        let title = try parsed.requiredValue(for: "--title")
        let summary = try parsed.requiredValue(for: "--summary")
        return AirframeCanonicalImplementationPlanRecord(
            id: id,
            title: title,
            summary: summary,
            proposedByActorID: AirframeID("ACTOR-LLM"),
            targetEpicID: parsed.value(for: "--epic").map(AirframeID.init) ?? projectContext.project.activeEpicID,
            targetSprintID: parsed.value(for: "--sprint").map(AirframeID.init) ?? projectContext.project.activeSprintID,
            targetTaskIDs: parsed.repeatedValues(for: "--task").map(AirframeID.init),
            scope: parsed.repeatedValues(for: "--scope"),
            fileChanges: parsed.repeatedValues(for: "--file-change"),
            commands: parsed.repeatedValues(for: "--command"),
            externalEffects: parsed.repeatedValues(for: "--external-effect"),
            verificationCriteria: parsed.repeatedValues(for: "--verification"),
            notes: parsed.repeatedValues(for: "--note")
        )
    }

    private static func linkAcceptanceCriterionToOwner(
        _ criterionID: AirframeID,
        ownerID: AirframeID,
        repository: AirframeCanonicalStoreRepository
    ) throws {
        var foundOwner = false
        for epic in try repository.store.list(AirframeCanonicalEpicRecord.self) {
            let shouldContain = epic.workItem.id == ownerID
            let nextIDs: [AirframeID]
            if shouldContain {
                foundOwner = true
                nextIDs = (epic.acceptanceCriterionIDs + [criterionID])
                    .reduce(into: [AirframeID]()) { result, id in
                        if !result.contains(id) {
                            result.append(id)
                        }
                    }
                    .sorted { $0.rawValue < $1.rawValue }
            } else {
                nextIDs = epic.acceptanceCriterionIDs.filter { $0 != criterionID }
            }
            guard nextIDs != epic.acceptanceCriterionIDs else { continue }
            try repository.store.save(
                AirframeCanonicalEpicRecord(
                    workItem: epic.workItem,
                    owner: epic.owner,
                    goal: epic.goal,
                    rationale: epic.rationale,
                    startDate: epic.startDate,
                    targetCloseDate: epic.targetCloseDate,
                    closeDate: epic.closeDate,
                    scope: epic.scope,
                    outOfScope: epic.outOfScope,
                    acceptanceCriterionIDs: nextIDs,
                    sprintIDs: epic.sprintIDs,
                    taskIDs: epic.taskIDs,
                    issueIDs: epic.issueIDs,
                    planningDocumentPaths: epic.planningDocumentPaths,
                    notes: epic.notes,
                    metadata: epic.metadata
                )
            )
        }
        guard foundOwner else {
            throw AirframeBackendError.missingWorkItem(ownerID)
        }
    }

    private static func buildTestSuiteRecord(
        parsed: AICockpitArguments,
        existing: AirframeCanonicalTestSuiteRecord?
    ) throws -> AirframeCanonicalTestSuiteRecord {
        let id: AirframeID
        if let existing {
            id = existing.id
        } else {
            id = AirframeID(try parsed.requiredValue(for: "--id"))
        }
        let title = parsed.value(for: "--title") ?? existing?.title
        guard let title, !title.isEmpty else {
            throw AICockpitCommandError.invalidArguments("missing required option --title")
        }
        let objective = parsed.value(for: "--objective") ?? existing?.objective
        guard let objective, !objective.isEmpty else {
            throw AICockpitCommandError.invalidArguments("missing required option --objective")
        }
        return AirframeCanonicalTestSuiteRecord(
            id: id,
            title: title,
            objective: objective,
            status: try parsed.optionalTestStatus(default: existing?.status ?? .draft),
            testIDs: replacementOrExisting(
                parsed.repeatedValues(for: "--test").map(AirframeID.init),
                existing?.testIDs ?? []
            ),
            requirementIDs: replacementOrExisting(
                parsed.repeatedValues(for: "--requirement").map(AirframeID.init),
                existing?.requirementIDs ?? []
            ),
            acceptanceCriterionIDs: replacementOrExisting(
                parsed.repeatedValues(for: "--acceptance-criterion").map(AirframeID.init),
                existing?.acceptanceCriterionIDs ?? []
            ),
            notes: replacementOrExisting(parsed.repeatedValues(for: "--note"), existing?.notes ?? []),
            metadata: existing?.metadata ?? AirframeCanonicalRecordMetadata()
        )
    }

    private static func enrichCanonicalIssue(
        _ issueID: AirframeID,
        parsed: AICockpitArguments
    ) throws {
        let repository = try canonicalTestRepository(parsed: parsed)
        guard let issue = try repository.store.load(AirframeCanonicalIssueRecord.self, id: issueID) else {
            throw AirframeBackendError.missingWorkItem(issueID)
        }
        let enriched = AirframeCanonicalIssueRecord(
            workItem: issue.workItem,
            severity: parsed.priorityValue(defaultingTo: issue.severity),
            observedBehavior: parsed.value(for: "--observed") ?? issue.observedBehavior,
            expectedBehavior: parsed.value(for: "--expected") ?? issue.expectedBehavior,
            epicID: parsed.value(for: "--epic").map(AirframeID.init) ?? issue.epicID,
            sprintID: parsed.value(for: "--sprint").map(AirframeID.init) ?? issue.sprintID,
            dateReported: parsed.value(for: "--date-reported") ?? issue.dateReported,
            dateResolved: parsed.value(for: "--date-resolved") ?? issue.dateResolved,
            dateVerified: parsed.value(for: "--date-verified") ?? issue.dateVerified,
            reproductionSteps: replacementOrExisting(parsed.repeatedValues(for: "--repro"), issue.reproductionSteps),
            affectedComponents: replacementOrExisting(parsed.repeatedValues(for: "--component"), issue.affectedComponents),
            evidenceIDs: replacementOrExisting(parsed.repeatedValues(for: "--evidence").map(AirframeID.init), issue.evidenceIDs),
            notes: replacementOrExisting(parsed.repeatedValues(for: "--note"), issue.notes),
            metadata: issue.metadata
        )
        try repository.store.save(enriched)
    }

    private static func artifactLinks(
        for id: AirframeID,
        parsed: AICockpitArguments
    ) throws -> AICockpitArtifactLinks {
        let repository = try canonicalTestRepository(parsed: parsed)
        let state = try repository.loadState()
        guard let record = repository.workRecords(from: state).first(where: { $0.workItem.id == id }) else {
            throw AirframeBackendError.missingWorkItem(id)
        }
        let testIDs = state.tests
            .filter { $0.workItemIDs.contains(id) }
            .map(\.id)
            .sorted { $0.rawValue < $1.rawValue }
        let requirementIDs: [AirframeID]
        if let task = state.tasks.first(where: { $0.workItem.id == id }) {
            requirementIDs = task.requirementIDs.sorted { $0.rawValue < $1.rawValue }
        } else {
            requirementIDs = state.requirements
                .filter { requirement in
                    requirement.traceLinks.contains {
                        $0.targetKind == record.workItem.kind.rawValue && $0.targetID == id.rawValue
                    }
                }
                .map(\.id)
                .sorted { $0.rawValue < $1.rawValue }
        }
        return AICockpitArtifactLinks(
            workItem: record.workItem,
            epicID: record.epicID,
            sprintID: record.sprintID,
            requirementIDs: requirementIDs,
            acceptanceCriterionIDs: acceptanceCriterionIDs(for: id, state: state),
            testIDs: testIDs
        )
    }

    private static func linkCanonicalArtifact(
        kind: AirframeWorkItemKind,
        id: AirframeID,
        parsed: AICockpitArguments
    ) throws {
        try assertLLMAllowed(
            parsed: parsed,
            operationID: "OP-LINK-\(kind.rawValue.uppercased())",
            category: .workflowTransition
        )
        try validateID(id, for: kind)
        let repository = try canonicalTestRepository(parsed: parsed)
        switch kind {
        case .task:
            guard let task = try repository.store.load(AirframeCanonicalTaskRecord.self, id: id) else {
                throw AirframeBackendError.missingWorkItem(id)
            }
            try repository.store.save(
                AirframeCanonicalTaskRecord(
                    workItem: task.workItem,
                    component: task.component,
                    priority: task.priority,
                    rationale: task.rationale,
                    epicID: parsed.value(for: "--epic").map(AirframeID.init) ?? task.epicID,
                    sprintID: parsed.value(for: "--sprint").map(AirframeID.init) ?? task.sprintID,
                    dateRequested: task.dateRequested,
                    dateImplemented: task.dateImplemented,
                    dateVerified: task.dateVerified,
                    currentBehavior: task.currentBehavior,
                    desiredBehavior: task.desiredBehavior,
                    requirementIDs: mergedIDs(task.requirementIDs, parsed.repeatedValues(for: "--requirement").map(AirframeID.init)),
                    acceptanceCriteria: task.acceptanceCriteria,
                    designApproach: task.designApproach,
                    componentsAffected: task.componentsAffected,
                    implementationDetails: task.implementationDetails,
                    evidenceIDs: task.evidenceIDs,
                    testSteps: task.testSteps,
                    notes: task.notes,
                    metadata: task.metadata
                )
            )
        case .issue:
            guard let issue = try repository.store.load(AirframeCanonicalIssueRecord.self, id: id) else {
                throw AirframeBackendError.missingWorkItem(id)
            }
            try repository.store.save(
                AirframeCanonicalIssueRecord(
                    workItem: issue.workItem,
                    severity: issue.severity,
                    observedBehavior: issue.observedBehavior,
                    expectedBehavior: issue.expectedBehavior,
                    epicID: parsed.value(for: "--epic").map(AirframeID.init) ?? issue.epicID,
                    sprintID: parsed.value(for: "--sprint").map(AirframeID.init) ?? issue.sprintID,
                    dateReported: issue.dateReported,
                    dateResolved: issue.dateResolved,
                    dateVerified: issue.dateVerified,
                    reproductionSteps: issue.reproductionSteps,
                    affectedComponents: issue.affectedComponents,
                    evidenceIDs: issue.evidenceIDs,
                    notes: issue.notes,
                    metadata: issue.metadata
                )
            )
        case .sprint:
            guard let sprint = try repository.store.load(AirframeCanonicalSprintRecord.self, id: id) else {
                throw AirframeBackendError.missingWorkItem(id)
            }
            try repository.store.save(
                AirframeCanonicalSprintRecord(
                    workItem: sprint.workItem,
                    epicID: parsed.value(for: "--epic").map(AirframeID.init) ?? sprint.epicID,
                    goal: sprint.goal,
                    startDate: sprint.startDate,
                    endDate: sprint.endDate,
                    capacity: sprint.capacity,
                    taskIDs: mergedIDs(sprint.taskIDs, parsed.repeatedValues(for: "--task").map(AirframeID.init)),
                    issueIDs: mergedIDs(sprint.issueIDs, parsed.repeatedValues(for: "--issue").map(AirframeID.init)),
                    notes: sprint.notes,
                    metadata: sprint.metadata
                )
            )
        case .epic:
            guard let epic = try repository.store.load(AirframeCanonicalEpicRecord.self, id: id) else {
                throw AirframeBackendError.missingWorkItem(id)
            }
            try repository.store.save(
                AirframeCanonicalEpicRecord(
                    workItem: epic.workItem,
                    owner: epic.owner,
                    goal: epic.goal,
                    rationale: epic.rationale,
                    startDate: epic.startDate,
                    targetCloseDate: epic.targetCloseDate,
                    closeDate: epic.closeDate,
                    scope: epic.scope,
                    outOfScope: epic.outOfScope,
                    acceptanceCriterionIDs: mergedIDs(epic.acceptanceCriterionIDs, parsed.repeatedValues(for: "--acceptance-criterion").map(AirframeID.init)),
                    sprintIDs: mergedIDs(epic.sprintIDs, parsed.repeatedValues(for: "--sprint").map(AirframeID.init)),
                    taskIDs: mergedIDs(epic.taskIDs, parsed.repeatedValues(for: "--task").map(AirframeID.init)),
                    issueIDs: mergedIDs(epic.issueIDs, parsed.repeatedValues(for: "--issue").map(AirframeID.init)),
                    planningDocumentPaths: epic.planningDocumentPaths,
                    notes: epic.notes,
                    metadata: epic.metadata
                )
            )
        }
        for testID in parsed.repeatedValues(for: "--test").map(AirframeID.init) {
            guard let test = try repository.store.load(AirframeCanonicalTestRecord.self, id: testID) else {
                throw AICockpitCommandError.invalidArguments("missing test \(testID.rawValue)")
            }
            try repository.store.save(
                AirframeCanonicalTestRecord(
                    id: test.id,
                    title: test.title,
                    objective: test.objective,
                    kind: test.kind,
                    status: test.status,
                    requirementIDs: test.requirementIDs,
                    acceptanceCriterionIDs: test.acceptanceCriterionIDs,
                    workItemIDs: mergedIDs(test.workItemIDs, [id]),
                    evidenceIDs: test.evidenceIDs,
                    steps: test.steps,
                    expectedResults: test.expectedResults,
                    automationCommand: test.automationCommand,
                    artifactReferences: test.artifactReferences,
                    notes: test.notes,
                    metadata: test.metadata
                )
            )
        }
    }

    private static func artifactGapMessages(
        kind: AirframeWorkItemKind,
        records: [AirframeLocalWorkRecord],
        state: AirframeCanonicalStoreState
    ) -> [String] {
        records
            .filter { $0.workItem.kind == kind }
            .flatMap { record -> [String] in
                var gaps: [String] = []
                let id = record.workItem.id
                if record.epicID == nil && (kind == .task || kind == .issue || kind == .sprint) {
                    gaps.append("\(id.rawValue) has no epic link.")
                }
                if record.sprintID == nil && (kind == .task || kind == .issue) {
                    gaps.append("\(id.rawValue) has no sprint link.")
                }
                if state.tests.allSatisfy({ !$0.workItemIDs.contains(id) }) {
                    gaps.append("\(id.rawValue) has no linked tests.")
                }
                if kind == .task,
                   let task = state.tasks.first(where: { $0.workItem.id == id }),
                   task.requirementIDs.isEmpty {
                    gaps.append("\(id.rawValue) has no requirement links.")
                }
                if kind == .epic,
                   let epic = state.epics.first(where: { $0.workItem.id == id }),
                   epic.acceptanceCriterionIDs.isEmpty {
                    gaps.append("\(id.rawValue) has no acceptance-criterion links.")
                }
                return gaps
            }
            .sorted()
    }

    private static func acceptanceCriterionIDs(
        for id: AirframeID,
        state: AirframeCanonicalStoreState
    ) -> [AirframeID] {
        let explicit = state.epics.first(where: { $0.workItem.id == id })?.acceptanceCriterionIDs ?? []
        let owned = state.acceptanceCriteria.filter { $0.ownerID == id }.map(\.id)
        return mergedIDs(explicit, owned)
    }

    private static func mergedIDs(_ existing: [AirframeID], _ additions: [AirframeID]) -> [AirframeID] {
        (existing + additions).reduce(into: [AirframeID]()) { result, id in
            if !result.contains(id) {
                result.append(id)
            }
        }.sorted { $0.rawValue < $1.rawValue }
    }

    private static func epicCoverage(
        epicID: AirframeID,
        state: AirframeCanonicalStoreState
    ) throws -> AICockpitEpicCoverage {
        guard let epic = state.epics.first(where: { $0.workItem.id == epicID }) else {
            throw AirframeBackendError.missingWorkItem(epicID)
        }
        let explicitCriterionIDs = Set(epic.acceptanceCriterionIDs)
        let ownedCriteria = state.acceptanceCriteria.filter {
            $0.ownerID == epicID || explicitCriterionIDs.contains($0.id)
        }.sorted { $0.id.rawValue < $1.id.rawValue }
        let testsByCriterion = Dictionary(grouping: state.tests.flatMap { test in
            test.acceptanceCriterionIDs.map { ($0, test.id) }
        }, by: { $0.0 }).mapValues { pairs in
            pairs.map(\.1).sorted { $0.rawValue < $1.rawValue }
        }
        let criteria = ownedCriteria.map { criterion in
            AICockpitEpicCriterionCoverage(
                id: criterion.id,
                text: criterion.text,
                isVerified: criterion.isVerified,
                testIDs: testsByCriterion[criterion.id, default: []]
            )
        }
        var blockers: [String] = []
        if criteria.isEmpty {
            blockers.append("Epic \(epicID.rawValue) has no acceptance criteria.")
        }
        for criterion in criteria where criterion.testIDs.isEmpty {
            blockers.append("Acceptance criterion \(criterion.id.rawValue) has no linked tests.")
        }
        return AICockpitEpicCoverage(
            epicID: epicID,
            status: epic.workItem.status,
            acceptanceCriteria: criteria,
            blockerMessages: blockers,
            isReady: blockers.isEmpty
        )
    }

    private static func buildTestRecord(
        parsed: AICockpitArguments,
        existing: AirframeCanonicalTestRecord?
    ) throws -> AirframeCanonicalTestRecord {
        let id: AirframeID
        if let existing {
            id = existing.id
        } else {
            id = AirframeID(try parsed.requiredValue(for: "--id"))
        }
        let title = parsed.value(for: "--title") ?? existing?.title
        guard let title, !title.isEmpty else {
            throw AICockpitCommandError.invalidArguments("missing required option --title")
        }
        let objective = parsed.value(for: "--objective") ?? existing?.objective
        guard let objective, !objective.isEmpty else {
            throw AICockpitCommandError.invalidArguments("missing required option --objective")
        }
        let kind: AirframeCanonicalTestKind
        if let rawKind = parsed.value(for: "--kind") {
            guard let parsedKind = AirframeCanonicalTestKind(rawValue: rawKind) else {
                throw AICockpitCommandError.invalidArguments("unsupported test kind \(rawKind)")
            }
            kind = parsedKind
        } else {
            kind = existing?.kind ?? .manual
        }
        return AirframeCanonicalTestRecord(
            id: id,
            title: title,
            objective: objective,
            kind: kind,
            status: try parsed.optionalTestStatus(default: existing?.status ?? .draft),
            requirementIDs: replacementOrExisting(
                parsed.repeatedValues(for: "--requirement").map(AirframeID.init),
                existing?.requirementIDs ?? []
            ),
            acceptanceCriterionIDs: replacementOrExisting(
                parsed.repeatedValues(for: "--acceptance-criterion").map(AirframeID.init),
                existing?.acceptanceCriterionIDs ?? []
            ),
            workItemIDs: replacementOrExisting(
                parsed.repeatedValues(for: "--work-item").map(AirframeID.init),
                existing?.workItemIDs ?? []
            ),
            evidenceIDs: replacementOrExisting(
                parsed.repeatedValues(for: "--evidence").map(AirframeID.init),
                existing?.evidenceIDs ?? []
            ),
            steps: replacementOrExisting(parsed.repeatedValues(for: "--step"), existing?.steps ?? []),
            expectedResults: replacementOrExisting(parsed.repeatedValues(for: "--expected"), existing?.expectedResults ?? []),
            automationCommand: parsed.value(for: "--automation-command") ?? existing?.automationCommand,
            artifactReferences: replacementOrExisting(parsed.repeatedValues(for: "--artifact"), existing?.artifactReferences ?? []),
            notes: replacementOrExisting(parsed.repeatedValues(for: "--note"), existing?.notes ?? []),
            metadata: existing?.metadata ?? AirframeCanonicalRecordMetadata()
        )
    }

    private static func exportMarkdownProjections(rootURL: URL) throws -> Int {
        let repository = AirframeCanonicalStoreRepository(rootURL: rootURL)
        let state = try repository.loadState()
        let projector = AirframeMarkdownArtifactProjector()
        let outputRoot = rootURL.appending(path: "docs/generated")
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: outputRoot, withIntermediateDirectories: true)

        var count = 0
        func write(_ contents: String, to relativePath: String) throws {
            let url = outputRoot.appending(path: relativePath)
            try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try contents.write(to: url, atomically: true, encoding: .utf8)
            count += 1
        }

        for epic in state.epics {
            let criteria = state.acceptanceCriteria.filter {
                $0.ownerID == epic.workItem.id || epic.acceptanceCriterionIDs.contains($0.id)
            }
            try write(projector.projectEpic(epic, acceptanceCriteria: criteria), to: "Epics/\(epic.workItem.id.rawValue).md")
        }
        for sprint in state.sprints {
            try write(projector.projectSprint(sprint), to: "Sprints/\(sprint.workItem.id.rawValue).md")
        }
        for task in state.tasks {
            try write(projector.projectTask(task), to: "Tasks/\(task.workItem.id.rawValue).md")
        }
        for issue in state.issues {
            try write(projector.projectIssue(issue), to: "Issues/\(issue.workItem.id.rawValue).md")
        }
        try write(projector.projectTaskIndex(state.tasks), to: "Tasks/index.md")
        for (relativePath, contents) in requirementMarkdownFiles(state: state) {
            try write(contents, to: relativePath)
        }
        return count
    }

    private static func requirementMarkdownFiles(state: AirframeCanonicalStoreState) -> [(String, String)] {
        let index = AirframeRequirementTraceabilityIndex(
            requirements: state.requirements,
            revisions: state.requirementRevisions,
            evidence: state.evidence,
            acceptanceCriteria: state.acceptanceCriteria,
            epics: state.epics,
            sprints: state.sprints,
            tasks: state.tasks,
            issues: state.issues
        )
        return Array(AirframeRequirementDocumentationProjector().projectRequirementReport(index).sorted { $0.key < $1.key })
    }

    private static func requirementIndexMarkdown(state: AirframeCanonicalStoreState) -> String {
        var lines: [String] = [
            "# Requirements",
            "",
            "Currently: **\(state.requirements.count) requirements**",
            "",
            "| Requirement | Title | Status | Source | Statement | Release Scope |",
            "| ----------- | ----- | ------ | ------ | --------- | ------------- |"
        ]
        for requirement in state.requirements.sorted(by: { $0.id.rawValue < $1.id.rawValue }) {
            lines.append(
                "| \(markdownCell(requirement.id.rawValue)) | \(markdownCell(requirement.title)) | \(markdownCell(requirement.status.description)) | \(markdownCell(requirement.sourceKind.rawValue)) | \(markdownCell(requirement.statement)) | \(markdownCell(requirement.releaseScope.isEmpty ? "None" : requirement.releaseScope.joined(separator: ", "))) |"
            )
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private static func requirementTraceabilityMatrixMarkdown(state: AirframeCanonicalStoreState) -> String {
        var lines: [String] = [
            "# Requirements Traceability Matrix",
            "",
            "| Requirement | Title | Status | Work Items | Evidence | Revisions | Trace Targets |",
            "| ----------- | ----- | ------ | ---------- | -------- | --------- | ------------- |"
        ]
        for requirement in state.requirements.sorted(by: { $0.id.rawValue < $1.id.rawValue }) {
            let workItemIDs = state.tasks
                .filter { $0.requirementIDs.contains(requirement.id) || $0.workItem.id.rawValue == requirement.id.rawValue }
                .map { $0.workItem.id.rawValue }
            let evidenceIDs = state.evidence
                .filter { $0.requirementIDs.contains(requirement.id) }
                .map { $0.id.rawValue }
            let revisions = state.requirementRevisions
                .filter { $0.requirementID == requirement.id }
                .map { $0.id.rawValue }
            let targetKinds = requirement.traceLinks.map(\.targetKind).sorted()
            lines.append(
                "| \(markdownCell(requirement.id.rawValue)) | \(markdownCell(requirement.title)) | \(markdownCell(requirement.status.description)) | \(markdownCell(workItemIDs.joined(separator: ", "))) | \(markdownCell(evidenceIDs.joined(separator: ", "))) | \(markdownCell(revisions.joined(separator: ", "))) | \(markdownCell(targetKinds.joined(separator: ", "))) |"
            )
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private static func requirementBidirectionalTraceabilityMatrixMarkdown(state: AirframeCanonicalStoreState) -> String {
        var lines: [String] = [
            "# Bidirectional Requirements Traceability Matrix",
            "",
            "| Work Item or Evidence | Requirements |",
            "| --------------------- | ------------ |"
        ]
        let identifiers = state.epics.map(\.workItem.id) + state.sprints.map(\.workItem.id) + state.tasks.map(\.workItem.id) + state.issues.map(\.workItem.id) + state.evidence.map(\.id)
        for identifier in identifiers {
            let requirementIDs = requirementIDs(for: identifier, state: state)
            guard !requirementIDs.isEmpty else { continue }
            lines.append("| \(identifier.rawValue) | \(requirementIDs.map(\.rawValue).joined(separator: ", ")) |")
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private static func requirementReleaseGateMarkdown(state: AirframeCanonicalStoreState) -> String {
        let gate = requirementGateSummary(state: state)
        var lines: [String] = [
            "# Release Gate",
            "",
            "**Release Scope:** All requirements",
            "**Can Close:** \(gate.canClose ? "Yes" : "No")",
            "",
            "| Count | Value |",
            "| ----- | ----- |",
            "| In Scope | \(gate.inScopeRequirementIDs.count) |",
            "| Implemented | \(gate.implementedCount) |",
            "| Verified | \(gate.verifiedCount) |",
            "| Validated | \(gate.validatedCount) |",
            "| Deferred | \(gate.deferredCount) |",
            "| Waived | \(gate.waivedCount) |",
            "| Blocked | \(gate.blockedCount) |"
        ]
        if !gate.blockingReasons.isEmpty {
            lines.append("")
            lines.append("## Blocking Reasons")
            lines.append(contentsOf: gate.blockingReasons.map { "- \($0)" })
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private static func requirementComplianceVerificationMatrixMarkdown(state: AirframeCanonicalStoreState) -> String {
        let gate = requirementGateSummary(state: state)
        var lines: [String] = [
            "# Compliance Verification Matrix",
            "",
            "| Count | Value |",
            "| ----- | ----- |",
            "| Requirements | \(state.requirements.count) |",
            "| Implemented | \(gate.implementedCount) |",
            "| Verified | \(gate.verifiedCount) |",
            "| Validated | \(gate.validatedCount) |",
            "| Deferred | \(gate.deferredCount) |",
            "| Waived | \(gate.waivedCount) |",
            "| Blocked | \(gate.blockedCount) |"
        ]
        if !gate.blockingReasons.isEmpty {
            lines.append("")
            lines.append("## Blocking Reasons")
            lines.append(contentsOf: gate.blockingReasons.map { "- \($0)" })
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private static func requirementIDs(for identifier: AirframeID, state: AirframeCanonicalStoreState) -> [AirframeID] {
        var ids = Set<AirframeID>()
        for task in state.tasks where task.requirementIDs.contains(identifier) {
            ids.insert(task.workItem.id)
        }
        for evidence in state.evidence where evidence.requirementIDs.contains(identifier) {
            ids.insert(evidence.id)
        }
        for requirement in state.requirements {
            if requirement.traceLinks.contains(where: { $0.targetID == identifier.rawValue }) {
                ids.insert(requirement.id)
            }
        }
        return ids.sorted { $0.rawValue < $1.rawValue }
    }

    private static func requirementGateSummary(state: AirframeCanonicalStoreState) -> (inScopeRequirementIDs: [AirframeID], implementedCount: Int, verifiedCount: Int, validatedCount: Int, deferredCount: Int, waivedCount: Int, blockedCount: Int, canClose: Bool, blockingReasons: [String]) {
        let requirements = state.requirements.sorted { $0.id.rawValue < $1.id.rawValue }
        let implementedCount = requirements.filter { $0.status == .implemented }.count
        let verifiedCount = requirements.filter { $0.status == .verified }.count
        let validatedCount = requirements.filter { $0.status == .validated }.count
        let deferredCount = requirements.filter { $0.status == .deferred }.count
        let waivedCount = requirements.filter { $0.status == .waived }.count
        let blockingReasons = requirements.compactMap { requirement -> String? in
            if requirement.status == .implemented || requirement.status == .verified || requirement.status == .validated || requirement.status == .deferred || requirement.status == .waived || requirement.status == .superseded || requirement.status == .removed {
                return nil
            }
            return "Requirement \(requirement.id.rawValue) is \(requirement.status.description)."
        }
        return (
            inScopeRequirementIDs: requirements.map(\.id),
            implementedCount: implementedCount,
            verifiedCount: verifiedCount,
            validatedCount: validatedCount,
            deferredCount: deferredCount,
            waivedCount: waivedCount,
            blockedCount: blockingReasons.count,
            canClose: blockingReasons.isEmpty,
            blockingReasons: blockingReasons
        )
    }

    private static func markdownCell(_ text: String) -> String {
        text.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "|", with: "\\|")
    }
}

protocol AICockpitRefreshNotifying {
    func postRefresh()
}

private struct AirframeDistributedRefreshNotifier: AICockpitRefreshNotifying {
    func postRefresh() {
        AirframeRefreshNotification.postRefresh()
    }
}

private enum AICockpitOutputFormat: String {
    case markdown
    case json
}

private enum AICockpitRequirementInterchangeFormat: String {
    case csv
    case json
}

private enum AICockpitCommandError: Error, Equatable {
    case invalidArguments(String)
    case denied(AirframeAuthorityDecision, AirframeOperation)
}

private struct AICockpitArguments {
    let positionals: [String]
    private let options: [String: [String]]

    init(_ arguments: [String]) {
        var positionals: [String] = []
        var options: [String: [String]] = [:]
        var index = 0
        while index < arguments.count {
            let argument = arguments[index]
            if argument.hasPrefix("--") {
                if index + 1 < arguments.count && !arguments[index + 1].hasPrefix("--") {
                    options[argument, default: []].append(arguments[index + 1])
                    index += 2
                } else {
                    options[argument, default: []].append("true")
                    index += 1
                }
            } else {
                positionals.append(argument)
                index += 1
            }
        }

        self.positionals = positionals
        self.options = options
    }

    var runtimeResolver: AirframeRuntimeConfigurationResolver {
        AirframeRuntimeConfigurationResolver()
    }

    var storeURL: URL {
        runtimeResolver.storeURL(explicitPath: value(for: "--store"))
    }

    func workspaceRootURL(projectContext: AirframeProjectContext) throws -> URL {
        if let explicit = value(for: "--root"), !explicit.isEmpty {
            return URL(filePath: explicit).standardizedFileURL
        }
        guard let configurationURL = runtimeResolver.configurationURL(explicitPath: value(for: "--config")) else {
            throw AICockpitCommandError.invalidArguments("canonical state commands require a workspace configuration")
        }
        let configuredRootPath = projectContext.configuration.workspace.rootPath
        if configuredRootPath.hasPrefix("/") {
            return URL(filePath: configuredRootPath).standardizedFileURL
        }
        let configurationDirectory = configurationURL.deletingLastPathComponent()
        let workspaceBaseURL = configurationDirectory.lastPathComponent == ".airframe"
            ? configurationDirectory.deletingLastPathComponent()
            : configurationDirectory
        return workspaceBaseURL.appending(path: configuredRootPath).standardizedFileURL
    }

    func backend(
        projectContext: AirframeProjectContext,
        controlledMutationsEnabled: Bool = false
    ) throws -> any AirframeBackend {
        let requestedKind = value(for: "--backend")
            ?? value(for: "--provider")
            ?? projectContext.configuration.backend.kind
        let rootURL = try? workspaceRootURL(projectContext: projectContext)
        if value(for: "--backend") == nil,
           let rootURL,
           FileManager.default.fileExists(atPath: rootURL.appending(path: ".airframe/state").path) {
            return AirframeCanonicalStoreBackend(rootURL: rootURL)
        }
        if requestedKind == "canonical" {
            guard let rootURL else {
                throw AICockpitCommandError.invalidArguments("canonical backend requires a workspace configuration")
            }
            return AirframeCanonicalStoreBackend(rootURL: rootURL)
        }
        switch AirframeBackendKind(rawValue: requestedKind) {
        case .localFixture:
            return AirframeLocalFilesystemBackend(storeURL: storeURL)
        case .githubFixture:
            return AirframeGitHubFixtureBackend(
                storeURL: storeURL,
                configuration: AirframeGitHubBackendConfiguration(repositorySlug: projectContext.project.repository)
            )
        case .githubIssues:
            return AirframeGitHubIssuesBackend(
                configuration: AirframeGitHubBackendConfiguration(repositorySlug: projectContext.project.repository),
                controlledMutationsEnabled: controlledMutationsEnabled
            )
        case nil:
            throw AICockpitCommandError.invalidArguments("unsupported backend \(requestedKind)")
        }
    }

    func canonicalProjectContextIfAvailable(_ projectContext: AirframeProjectContext) throws -> AirframeProjectContext? {
        guard let rootURL = try? workspaceRootURL(projectContext: projectContext),
              FileManager.default.fileExists(atPath: rootURL.appending(path: ".airframe/state").path) else {
            return nil
        }
        let snapshot = try AirframeCanonicalStoreRepository(rootURL: rootURL)
            .snapshot(project: projectContext.project)
        let canonicalProject = AirframeProject(
            id: snapshot.project.id,
            name: snapshot.project.name,
            repository: snapshot.project.repository,
            activeSprintID: snapshot.project.activeSprintID,
            activeEpicID: snapshot.project.activeEpicID
        )
        return AirframeProjectContext(
            configuration: projectContext.configuration,
            project: canonicalProject
        )
    }

    func canonicalAwareProjectContext() throws -> AirframeProjectContext {
        let projectContext = try runtimeResolver.loadContext(explicitPath: value(for: "--config"))
        return try canonicalProjectContextIfAvailable(projectContext) ?? projectContext
    }

    func value(for option: String) -> String? {
        options[option]?.last
    }

    func repeatedValues(for option: String) -> [String] {
        options[option] ?? []
    }

    var priorityValue: AirframeWorkPriority {
        priorityValue(defaultingTo: .medium)
    }

    func priorityValue(defaultingTo defaultValue: AirframeWorkPriority) -> AirframeWorkPriority {
        value(for: "--priority")
            .or(value(for: "--severity"))
            .flatMap(AirframeWorkPriority.init(rawValue:)) ?? defaultValue
    }

    func requiredValue(for option: String) throws -> String {
        guard let value = value(for: option), !value.isEmpty else {
            throw AICockpitCommandError.invalidArguments("missing required option \(option)")
        }
        return value
    }

    func githubMutationApproval() throws -> AirframeGitHubMutationApproval {
        guard value(for: "--approve") == "true" else {
            throw AirframeBackendError.requiresConfirmation(.requiresConfirmation)
        }
        let approvedBy = value(for: "--approved-by") ?? "human"
        return AirframeGitHubMutationApproval(
            isApproved: true,
            approvedBy: approvedBy,
            reason: value(for: "--approval-reason") ?? "Explicit CLI approval"
        )
    }

    func requiredStatus(for option: String) throws -> AirframeWorkStatus {
        switch try requiredValue(for: option) {
        case "backlog":
            return .backlog
        case "active":
            return .active
        case "unverified", "implemented-not-verified":
            return .implementedNotVerified
        case "verified", "implemented-verified":
            return .implementedVerified
        case "closed":
            return .closed
        case let value:
            throw AICockpitCommandError.invalidArguments("unsupported status \(value)")
        }
    }

    func optionalCommandStatus(
        for option: String,
        kind: AirframeWorkItemKind,
        defaultStatus: AirframeWorkStatus
    ) throws -> AirframeWorkStatus {
        guard value(for: option) != nil else { return defaultStatus }
        return try requiredCommandStatus(for: option, kind: kind)
    }

    func requiredCommandStatus(for option: String, kind: AirframeWorkItemKind) throws -> AirframeWorkStatus {
        let value = try requiredValue(for: option)
        switch (kind, value) {
        case (.task, "backlog"), (.issue, "backlog"), (.sprint, "backlog"), (.epic, "backlog"):
            return .backlog
        case (.task, "active"), (.issue, "active"), (.sprint, "active"), (.epic, "active"):
            return .active
        case (.task, "implemented"), (.task, "unverified"), (.task, "implemented-not-verified"):
            return .implementedNotVerified
        case (.issue, "resolved"), (.issue, "unverified"), (.issue, "resolved-not-verified"):
            return .implementedNotVerified
        case (.sprint, "planning"):
            return .planning
        case (.sprint, "review"):
            return .review
        case (.epic, "proposed"):
            return .proposed
        case (.epic, "draft"):
            return .draft
        case (.epic, "complete"):
            return .complete
        case (_, "verified"), (_, "implemented-verified"), (_, "resolved-verified"):
            throw AICockpitCommandError.invalidArguments("\(kind.rawValue) verification is human-only")
        case (_, "closed"):
            throw AICockpitCommandError.invalidArguments("\(kind.rawValue) closure is human-only")
        case let (_, unsupported):
            throw AICockpitCommandError.invalidArguments("unsupported \(kind.rawValue) status \(unsupported)")
        }
    }

    func requiredRepairAction() throws -> AirframeCanonicalRepairAction {
        let value = try requiredValue(for: "--action")
        guard let action = AirframeCanonicalRepairAction(rawValue: value),
              action != .moveOpenWorkToAnotherEpic,
              action != .carryForwardOpenWork else {
            throw AICockpitCommandError.invalidArguments("unsupported repair action \(value)")
        }
        return action
    }

    func optionalTestStatus(default defaultValue: AirframeCanonicalTestStatus) throws -> AirframeCanonicalTestStatus {
        guard let value = value(for: "--status") else { return defaultValue }
        guard let status = AirframeCanonicalTestStatus(rawValue: value) else {
            throw AICockpitCommandError.invalidArguments("unsupported test status \(value)")
        }
        return status
    }

    func requiredRequirementInterchangeFormat() throws -> AICockpitRequirementInterchangeFormat {
        let value = try requiredValue(for: "--format")
        guard let format = AICockpitRequirementInterchangeFormat(rawValue: value) else {
            throw AICockpitCommandError.invalidArguments("unsupported requirements format \(value)")
        }
        return format
    }
}

private extension Optional {
    func or(_ fallback: Wrapped?) -> Wrapped? {
        self ?? fallback
    }
}

private extension String {
    func ifEmpty(_ fallback: String) -> String {
        isEmpty ? fallback : self
    }
}

private struct AICockpitCommandEnvelope: Codable, Equatable {
    let status: String
    let kind: String
    let message: String
    let backendCapabilities: AirframeBackendCapabilities?
    let workItem: AirframeWorkItem?
    let taskPacket: AirframeTaskPacket?
    let dashboardSummary: AirframeDashboardSummary?
    var configurationDiagnostics: AirframeConfigurationDiagnostics? = nil
    var canonicalDiagnostics: AirframeCanonicalDiagnostics? = nil
    let evidence: [AirframeEvidence]
    var mutationResult: AirframeGitHubMutationResult? = nil

    var markdown: String {
        var lines = [
            "# Airframe Command",
            "",
            "- status: \(status)",
            "- kind: \(kind)",
            "- message: \(message)"
        ]

        if let backendCapabilities {
            lines.append(contentsOf: [
                "- backend: \(backendCapabilities.backendKind)",
                "- githubIssues: \(backendCapabilities.supportsGitHubIssues ? "supported" : "unsupported")"
            ])
        }

        if let workItem {
            lines.append(contentsOf: [
                "",
                "## Work Item",
                "- id: \(workItem.id.rawValue)",
                "- kind: \(workItem.kind.rawValue)",
                "- title: \(workItem.title)",
                "- status: \(workItem.status.description)"
            ])
        }

        if let dashboardSummary {
            lines.append(contentsOf: [
                "",
                "## Project Summary",
                "- totalWorkItems: \(dashboardSummary.totalWorkItemCount)",
                "- activeTasks: \(dashboardSummary.activeTaskCount)",
                "- unverifiedTasks: \(dashboardSummary.unverifiedTaskCount)",
                "- verifiedTasks: \(dashboardSummary.verifiedTaskCount)",
                "- issues: \(dashboardSummary.issueCount)",
                "- evidence: \(dashboardSummary.recentEvidenceCount)",
                "- nextTask: \(dashboardSummary.nextTask?.id.rawValue ?? "None")"
            ])
        }

        if let configurationDiagnostics {
            lines.append(contentsOf: [
                "",
                "## Configuration Diagnostics",
                "- status: \(configurationDiagnostics.status.rawValue)",
                "- workspace: \(configurationDiagnostics.workspaceID.rawValue)",
                "- defaultProject: \(configurationDiagnostics.defaultProjectID.rawValue)",
                "- projects: \(configurationDiagnostics.projectCount)",
                "- backend: \(configurationDiagnostics.backendKind) at \(configurationDiagnostics.backendLocation)"
            ])
            if configurationDiagnostics.issues.isEmpty {
                lines.append("- issues: None")
            } else {
                lines.append("### Issues")
                lines.append(
                    contentsOf: configurationDiagnostics.issues.map {
                        "- \($0.severity.rawValue) \($0.code): \($0.message)"
                    }
                )
            }
        }

        if let canonicalDiagnostics {
            lines.append(contentsOf: [
                "",
                "## Canonical State Diagnostics",
                "- status: \(canonicalDiagnostics.status.rawValue)"
            ])
            if canonicalDiagnostics.diagnostics.isEmpty {
                lines.append("- issues: None")
            } else {
                lines.append("### Issues")
                lines.append(
                    contentsOf: canonicalDiagnostics.diagnostics.map {
                        "- \($0.severity.rawValue) \($0.reasonCode.rawValue): \($0.message)"
                    }
                )
            }
        }

        if let taskPacket {
            lines.append(contentsOf: [
                "",
                "## Task Packet",
                "- objective: \(taskPacket.objective)",
                "",
                "### Scope"
            ])
            lines.append(contentsOf: taskPacket.scope.map { "- \($0)" })
            lines.append("")
            lines.append("### Acceptance Criteria")
            lines.append(contentsOf: taskPacket.acceptanceCriteria.map { "- \($0)" })
            lines.append("")
            lines.append("### Constraints")
            lines.append(contentsOf: taskPacket.constraints.map { "- \($0)" })
            lines.append("")
            lines.append("### Evidence Requirements")
            lines.append(contentsOf: taskPacket.evidenceRequirements.map { "- \($0)" })
            lines.append("")
            lines.append("### Protected Paths")
            lines.append(contentsOf: taskPacket.protectedPaths.isEmpty ? ["- None"] : taskPacket.protectedPaths.map { "- \($0)" })
            lines.append("")
            lines.append("### Report Format")
            lines.append(taskPacket.reportFormat)
            if !taskPacket.diagnostics.isEmpty {
                lines.append("")
                lines.append("### Diagnostics")
                lines.append(
                    contentsOf: taskPacket.diagnostics.map {
                        "- \($0.severity.rawValue) \($0.reasonCode.rawValue): \($0.message)"
                    }
                )
            }
        }

        if !evidence.isEmpty {
            lines.append(contentsOf: ["", "## Evidence"])
            lines.append(contentsOf: evidence.map { "- \($0.id.rawValue): \($0.summary) (\($0.artifact))" })
        }

        if let mutationResult {
            lines.append(contentsOf: [
                "",
                "## GitHub Mutation",
                "- mutation: \(mutationResult.mutation)",
                "- issue: #\(mutationResult.githubIssue)",
                "- audit: \(mutationResult.auditEvent.id.rawValue)",
                "- action: \(mutationResult.auditEvent.action)"
            ])
        }

        return lines.joined(separator: "\n")
    }
}

private struct AICockpitArtifactLinks: Codable, Equatable {
    let workItem: AirframeWorkItem
    let epicID: AirframeID?
    let sprintID: AirframeID?
    let requirementIDs: [AirframeID]
    let acceptanceCriterionIDs: [AirframeID]
    let testIDs: [AirframeID]
}

private struct AICockpitArtifactCommandEnvelope: Codable, Equatable {
    let status: String
    let kind: String
    let message: String
    var workItem: AirframeWorkItem? = nil
    var workItems: [AirframeWorkItem] = []
    var links: AICockpitArtifactLinks? = nil
    var gaps: [String] = []

    var markdown: String {
        var lines = [
            "# Airframe Artifact Command",
            "",
            "- status: \(status)",
            "- kind: \(kind)",
            "- message: \(message)"
        ]
        if let workItem {
            lines.append(contentsOf: [
                "",
                "## Work Item",
                "- id: \(workItem.id.rawValue)",
                "- kind: \(workItem.kind.rawValue)",
                "- title: \(workItem.title)",
                "- status: \(workItem.status.description)"
            ])
        }
        if !workItems.isEmpty {
            lines.append(contentsOf: ["", "## Work Items"])
            lines.append(contentsOf: workItems.map {
                "- \($0.id.rawValue): \($0.title) (\($0.status.description))"
            })
        }
        if let links {
            lines.append(contentsOf: [
                "",
                "## Links",
                "- epic: \(links.epicID?.rawValue ?? "None")",
                "- sprint: \(links.sprintID?.rawValue ?? "None")",
                "- requirements: \(links.requirementIDs.map(\.rawValue).joined(separator: ", ").ifEmpty("None"))",
                "- acceptanceCriteria: \(links.acceptanceCriterionIDs.map(\.rawValue).joined(separator: ", ").ifEmpty("None"))",
                "- tests: \(links.testIDs.map(\.rawValue).joined(separator: ", ").ifEmpty("None"))"
            ])
        }
        if !gaps.isEmpty {
            lines.append(contentsOf: ["", "## Gaps"])
            lines.append(contentsOf: gaps.map { "- \($0)" })
        }
        return lines.joined(separator: "\n")
    }
}

private struct AICockpitAcceptanceCriterionSummary: Codable, Equatable {
    let id: AirframeID
    let ownerID: AirframeID
    let text: String
    let isVerified: Bool
    let evidenceIDs: [AirframeID]

    init(_ record: AirframeCanonicalAcceptanceCriterionRecord) {
        self.id = record.id
        self.ownerID = record.ownerID
        self.text = record.text
        self.isVerified = record.isVerified
        self.evidenceIDs = record.evidenceIDs
    }
}

private struct AICockpitEpicCriterionCoverage: Codable, Equatable {
    let id: AirframeID
    let text: String
    let isVerified: Bool
    let testIDs: [AirframeID]
}

private struct AICockpitEpicCoverage: Codable, Equatable {
    let epicID: AirframeID
    let status: AirframeWorkStatus
    let acceptanceCriteria: [AICockpitEpicCriterionCoverage]
    let blockerMessages: [String]
    let isReady: Bool
}

private struct AICockpitPlanSummary: Codable, Equatable {
    let id: AirframeID
    let title: String
    let decisionState: AirframeCanonicalPlanDecisionState
    let targetEpicID: AirframeID?
    let targetSprintID: AirframeID?
    let targetTaskIDs: [AirframeID]

    init(_ record: AirframeCanonicalImplementationPlanRecord) {
        self.id = record.id
        self.title = record.title
        self.decisionState = record.decisionState
        self.targetEpicID = record.targetEpicID
        self.targetSprintID = record.targetSprintID
        self.targetTaskIDs = record.targetTaskIDs
    }
}

private struct AICockpitPlanCommandEnvelope: Codable, Equatable {
    let status: String
    let kind: String
    let message: String
    let backendCapabilities: AirframeBackendCapabilities?
    let plan: AirframeCanonicalImplementationPlanRecord?
    let plans: [AICockpitPlanSummary]

    var markdown: String {
        func list(_ values: [String]) -> [String] {
            values.isEmpty ? ["- None"] : values.map { "- \($0)" }
        }

        var lines = [
            "# Airframe Command",
            "",
            "- status: \(status)",
            "- kind: \(kind)",
            "- message: \(message)"
        ]

        if let backendCapabilities {
            lines.append("- backend: \(backendCapabilities.backendKind)")
        }

        if !plans.isEmpty {
            lines.append("")
            lines.append("## Plans")
            lines.append("")
            lines.append("| Plan | State | Epic | Sprint | Tasks | Title |")
            lines.append("| ---- | ----- | ---- | ------ | ----- | ----- |")
            for plan in plans {
                lines.append("| \(plan.id.rawValue) | \(plan.decisionState.description) | \(plan.targetEpicID?.rawValue ?? "None") | \(plan.targetSprintID?.rawValue ?? "None") | \(plan.targetTaskIDs.map(\.rawValue).joined(separator: ", ").ifEmpty("None")) | \(plan.title) |")
            }
        }

        if let plan {
            lines.append("")
            lines.append("## Plan")
            lines.append("")
            lines.append("- ID: \(plan.id.rawValue)")
            lines.append("- Title: \(plan.title)")
            lines.append("- State: \(plan.decisionState.description)")
            lines.append("- Epic: \(plan.targetEpicID?.rawValue ?? "None")")
            lines.append("- Sprint: \(plan.targetSprintID?.rawValue ?? "None")")
            lines.append("- Tasks: \(plan.targetTaskIDs.map(\.rawValue).joined(separator: ", ").ifEmpty("None"))")
            lines.append("- Proposed By: \(plan.proposedByActorID.rawValue)")
            lines.append("")
            lines.append("### Summary")
            lines.append(plan.summary)
            lines.append("")
            lines.append("### Scope")
            lines.append(contentsOf: list(plan.scope))
            lines.append("")
            lines.append("### File Changes")
            lines.append(contentsOf: list(plan.fileChanges))
            lines.append("")
            lines.append("### Commands")
            lines.append(contentsOf: list(plan.commands))
            lines.append("")
            lines.append("### External Effects")
            lines.append(contentsOf: list(plan.externalEffects))
            lines.append("")
            lines.append("### Verification")
            lines.append(contentsOf: list(plan.verificationCriteria))
        }

        return lines.joined(separator: "\n")
    }
}

private struct AICockpitAcceptanceCriteriaCommandEnvelope: Codable, Equatable {
    let status: String
    let kind: String
    let message: String
    let backendCapabilities: AirframeBackendCapabilities?
    let criterion: AirframeCanonicalAcceptanceCriterionRecord?
    let criteria: [AICockpitAcceptanceCriterionSummary]
    let epicCoverage: AICockpitEpicCoverage?

    var markdown: String {
        func cell(_ text: String) -> String {
            text.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "|", with: "\\|")
        }

        var lines = [
            "# Airframe Command",
            "",
            "- status: \(status)",
            "- kind: \(kind)",
            "- message: \(message)"
        ]

        if let backendCapabilities {
            lines.append("- backend: \(backendCapabilities.backendKind)")
        }

        if !criteria.isEmpty {
            lines.append("")
            lines.append("## Acceptance Criteria")
            lines.append("")
            lines.append("| Criterion | Owner | Verified | Evidence | Text |")
            lines.append("| --------- | ----- | -------- | -------- | ---- |")
            for criterion in criteria {
                lines.append("| \(cell(criterion.id.rawValue)) | \(cell(criterion.ownerID.rawValue)) | \(criterion.isVerified ? "yes" : "no") | \(cell(criterion.evidenceIDs.map(\.rawValue).joined(separator: ", "))) | \(cell(criterion.text)) |")
            }
        }

        if let criterion {
            lines.append("")
            lines.append("## Acceptance Criterion")
            lines.append("")
            lines.append("- ID: \(criterion.id.rawValue)")
            lines.append("- Owner: \(criterion.ownerID.rawValue)")
            lines.append("- Verified: \(criterion.isVerified ? "yes" : "no")")
            lines.append("- Evidence: \(criterion.evidenceIDs.map(\.rawValue).joined(separator: ", "))")
            lines.append("- Text: \(criterion.text)")
        }

        if let epicCoverage {
            lines.append("")
            lines.append("## Epic Coverage")
            lines.append("")
            lines.append("- Epic: \(epicCoverage.epicID.rawValue)")
            lines.append("- Status: \(epicCoverage.status.description)")
            lines.append("- Ready: \(epicCoverage.isReady ? "yes" : "no")")
            lines.append("- Blockers: \(epicCoverage.blockerMessages.count)")
            if !epicCoverage.blockerMessages.isEmpty {
                lines.append("")
                lines.append("### Blockers")
                lines.append(contentsOf: epicCoverage.blockerMessages.map { "- \($0)" })
            }
            lines.append("")
            lines.append("### Acceptance Criteria")
            lines.append("")
            lines.append("| Criterion | Verified | Tests | Text |")
            lines.append("| --------- | -------- | ----- | ---- |")
            for criterion in epicCoverage.acceptanceCriteria {
                lines.append("| \(cell(criterion.id.rawValue)) | \(criterion.isVerified ? "yes" : "no") | \(cell(criterion.testIDs.map(\.rawValue).joined(separator: ", "))) | \(cell(criterion.text)) |")
            }
        }

        return lines.joined(separator: "\n")
    }
}

private struct AICockpitTestSuiteSummary: Codable, Equatable {
    let id: AirframeID
    let title: String
    let objective: String
    let status: AirframeCanonicalTestStatus
    let testIDs: [AirframeID]
    let requirementIDs: [AirframeID]
    let acceptanceCriterionIDs: [AirframeID]

    init(_ record: AirframeCanonicalTestSuiteRecord) {
        self.id = record.id
        self.title = record.title
        self.objective = record.objective
        self.status = record.status
        self.testIDs = record.testIDs
        self.requirementIDs = record.requirementIDs
        self.acceptanceCriterionIDs = record.acceptanceCriterionIDs
    }
}

private struct AICockpitTestSuiteCommandEnvelope: Codable, Equatable {
    let status: String
    let kind: String
    let message: String
    let backendCapabilities: AirframeBackendCapabilities?
    let suite: AirframeCanonicalTestSuiteRecord?
    let suites: [AICockpitTestSuiteSummary]

    var markdown: String {
        func cell(_ text: String) -> String {
            text.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "|", with: "\\|")
        }

        var lines = [
            "# Airframe Command",
            "",
            "- status: \(status)",
            "- kind: \(kind)",
            "- message: \(message)"
        ]

        if let backendCapabilities {
            lines.append("- backend: \(backendCapabilities.backendKind)")
        }

        if !suites.isEmpty {
            lines.append("")
            lines.append("## Test Suites")
            lines.append("")
            lines.append("| Suite | Title | Status | Tests | Requirements | Acceptance Criteria |")
            lines.append("| ----- | ----- | ------ | ----- | ------------ | ------------------- |")
            for suite in suites {
                lines.append("| \(cell(suite.id.rawValue)) | \(cell(suite.title)) | \(cell(suite.status.rawValue)) | \(cell(suite.testIDs.map(\.rawValue).joined(separator: ", "))) | \(cell(suite.requirementIDs.map(\.rawValue).joined(separator: ", "))) | \(cell(suite.acceptanceCriterionIDs.map(\.rawValue).joined(separator: ", "))) |")
            }
        }

        if let suite {
            lines.append("")
            lines.append("## Test Suite")
            lines.append("")
            lines.append("- ID: \(suite.id.rawValue)")
            lines.append("- Title: \(suite.title)")
            lines.append("- Objective: \(suite.objective)")
            lines.append("- Status: \(suite.status.rawValue)")
            lines.append("- Tests: \(suite.testIDs.map(\.rawValue).joined(separator: ", "))")
            lines.append("- Requirements: \(suite.requirementIDs.map(\.rawValue).joined(separator: ", "))")
            lines.append("- Acceptance Criteria: \(suite.acceptanceCriterionIDs.map(\.rawValue).joined(separator: ", "))")
            lines.append("- Notes: \(suite.notes.joined(separator: " | "))")
        }

        return lines.joined(separator: "\n")
    }
}

private struct AICockpitTestSummary: Codable, Equatable {
    let id: AirframeID
    let title: String
    let objective: String
    let kind: AirframeCanonicalTestKind
    let status: AirframeCanonicalTestStatus
    let requirementIDs: [AirframeID]
    let acceptanceCriterionIDs: [AirframeID]
    let workItemIDs: [AirframeID]

    init(_ record: AirframeCanonicalTestRecord) {
        self.id = record.id
        self.title = record.title
        self.objective = record.objective
        self.kind = record.kind
        self.status = record.status
        self.requirementIDs = record.requirementIDs
        self.acceptanceCriterionIDs = record.acceptanceCriterionIDs
        self.workItemIDs = record.workItemIDs
    }
}

private struct AICockpitTestCommandEnvelope: Codable, Equatable {
    let status: String
    let kind: String
    let message: String
    let backendCapabilities: AirframeBackendCapabilities?
    let test: AirframeCanonicalTestRecord?
    let tests: [AICockpitTestSummary]
    let validationDiagnostics: AirframeCanonicalDiagnostics?

    var markdown: String {
        func cell(_ text: String) -> String {
            text.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "|", with: "\\|")
        }

        var lines = [
            "# Airframe Command",
            "",
            "- status: \(status)",
            "- kind: \(kind)",
            "- message: \(message)"
        ]

        if let backendCapabilities {
            lines.append(contentsOf: [
                "- backend: \(backendCapabilities.backendKind)",
                "- create: \(backendCapabilities.supportsCreateWorkItem ? "supported" : "unsupported")",
                "- update: \(backendCapabilities.supportsUpdateWorkItem ? "supported" : "unsupported")",
                "- evidence: \(backendCapabilities.supportsEvidenceAttachment ? "supported" : "unsupported")",
                "- taskPacket: \(backendCapabilities.supportsTaskPacket ? "supported" : "unsupported")",
                "- dashboardSummary: \(backendCapabilities.supportsDashboardSummary ? "supported" : "unsupported")",
                "- githubIssues: \(backendCapabilities.supportsGitHubIssues ? "supported" : "unsupported")"
            ])
        }

        if !tests.isEmpty {
            lines.append("")
            lines.append("## Tests")
            lines.append("")
            lines.append("| Test | Title | Kind | Status | Requirements | Acceptance Criteria | Work Items |")
            lines.append("| ---- | ----- | ---- | ------ | ------------ | ------------------- | ---------- |")
            for test in tests {
                lines.append(
                    "| \(cell(test.id.rawValue)) | \(cell(test.title)) | \(cell(test.kind.rawValue)) | \(cell(test.status.rawValue)) | \(cell(test.requirementIDs.map(\.rawValue).joined(separator: ", "))) | \(cell(test.acceptanceCriterionIDs.map(\.rawValue).joined(separator: ", "))) | \(cell(test.workItemIDs.map(\.rawValue).joined(separator: ", "))) |"
                )
            }
        }

        if let test {
            lines.append("")
            lines.append("## Test Definition")
            lines.append("")
            lines.append("- ID: \(test.id.rawValue)")
            lines.append("- Title: \(test.title)")
            lines.append("- Objective: \(test.objective)")
            lines.append("- Kind: \(test.kind.rawValue)")
            lines.append("- Status: \(test.status.rawValue)")
            lines.append("- Requirements: \(test.requirementIDs.map(\.rawValue).joined(separator: ", "))")
            lines.append("- Acceptance Criteria: \(test.acceptanceCriterionIDs.map(\.rawValue).joined(separator: ", "))")
            lines.append("- Work Items: \(test.workItemIDs.map(\.rawValue).joined(separator: ", "))")
            lines.append("- Evidence: \(test.evidenceIDs.map(\.rawValue).joined(separator: ", "))")
            lines.append("- Steps: \(test.steps.joined(separator: " | "))")
            lines.append("- Expected Results: \(test.expectedResults.joined(separator: " | "))")
            lines.append("- Automation Command: \(test.automationCommand ?? "None")")
            lines.append("- Artifact References: \(test.artifactReferences.joined(separator: ", "))")
            lines.append("- Notes: \(test.notes.joined(separator: " | "))")
        }

        if let validationDiagnostics {
            lines.append("")
            lines.append("## Validation Diagnostics")
            lines.append("")
            lines.append("- status: \(validationDiagnostics.status.rawValue)")
            lines.append("- valid: \(validationDiagnostics.isValid ? "yes" : "no")")
            lines.append("- issueCount: \(validationDiagnostics.diagnostics.count)")
            if !validationDiagnostics.diagnostics.isEmpty {
                lines.append(contentsOf: validationDiagnostics.diagnostics.map {
                    "- \($0.reasonCode.rawValue): \($0.message)"
                })
            }
        }

        return lines.joined(separator: "\n")
    }
}

private struct AICockpitRequirementImportPreviewResponse: Codable, Equatable {
    let status: String
    let kind: String
    let message: String
    let format: String
    let applied: Bool
    let createdCount: Int
    let updatedCount: Int
    let unchangedCount: Int
    let removedCount: Int
    let conflictedCount: Int
    let requirements: [AirframeRequirementImportPreviewItem]
    let revisions: [AirframeRequirementImportPreviewItem]

    var markdown: String {
        var lines = [
            "# Airframe Command",
            "",
            "- status: \(status)",
            "- kind: \(kind)",
            "- message: \(message)",
            "- format: \(format)",
            "- applied: \(applied)",
            "- created: \(createdCount)",
            "- updated: \(updatedCount)",
            "- unchanged: \(unchangedCount)",
            "- removed: \(removedCount)",
            "- conflicted: \(conflictedCount)"
        ]
        let items = requirements + revisions
        if !items.isEmpty {
            lines.append("")
            lines.append("## Preview")
            lines.append("| Kind | Change | ID | Details |")
            lines.append("| ---- | ------ | -- | ------- |")
            for item in items {
                lines.append("| \(item.recordKind.rawValue) | \(item.changeKind.rawValue) | \(item.id.rawValue) | \(item.details) |")
            }
        }
        return lines.joined(separator: "\n")
    }
}

private struct AICockpitErrorEnvelope: Codable, Equatable {
    let status: String
    let code: String
    let message: String
}
