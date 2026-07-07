import Foundation

public enum AirframeCanonicalDiagnosticSeverity: String, Codable, Equatable, Sendable {
    case info
    case warning
    case error
    case blocking
}

public enum AirframeCanonicalDiagnosticReasonCode: String, Codable, Equatable, Sendable {
    case activeEpicMissing
    case activeSprintMissing
    case activeEpicNotActive
    case activeSprintNotActive
    case activeEpicPointerMismatch
    case activeSprintPointerMismatch
    case backendRelationshipDrift
    case backendStatusDrift
    case closedEpicOwnsOpenWork
    case epicSprintRelationshipDrift
    case multipleActiveSprints
    case epicTaskRelationshipDrift
    case sprintTaskRelationshipDrift
    case taskEpicMissing
    case taskSprintMissing
    case testRequirementMissing
    case testAcceptanceCriterionMissing
    case testWorkItemMissing
    case testSuiteTestMissing
    case testRunTestMissing
    case testRunSuiteMissing
}

public enum AirframeCanonicalRepairAction: String, Codable, Equatable, Sendable {
    case applyBackendStatusLabels
    case applyBackendRelationshipLabels
    case clearActiveEpicID
    case clearActiveSprintID
    case restoreEpicToActive
    case restoreSprintToActive
    case setActiveEpicID
    case setActiveSprintID
    case moveOpenWorkToAnotherEpic
    case carryForwardOpenWork
    case reconcileEpicSprintLinks
    case reconcileEpicTaskLinks
    case reconcileSprintTaskLinks
}

public struct AirframeCanonicalBackendReconciler: Sendable {
    public init() {}

    public func diagnostics(
        canonicalRecords: [AirframeLocalWorkRecord],
        backendRecords: [AirframeLocalWorkRecord],
        workflowPolicy: AirframeCanonicalWorkflowPolicyCatalog = .airframeDefault
    ) -> [AirframeCanonicalDiagnostic] {
        let backendByID = Dictionary(uniqueKeysWithValues: backendRecords.map { ($0.workItem.id, $0) })
        return canonicalRecords.compactMap { canonicalRecord in
            guard let backendRecord = backendByID[canonicalRecord.workItem.id] else {
                return nil
            }
            if backendRecord.workItem.status != canonicalRecord.workItem.status {
                return statusDriftDiagnostic(
                    canonicalRecord: canonicalRecord,
                    backendRecord: backendRecord,
                    workflowPolicy: workflowPolicy
                )
            }
            if backendRecord.epicID != canonicalRecord.epicID || backendRecord.sprintID != canonicalRecord.sprintID {
                return relationshipDriftDiagnostic(
                    canonicalRecord: canonicalRecord,
                    backendRecord: backendRecord
                )
            }
            return nil
        }.sorted {
            $0.reasonCode.rawValue == $1.reasonCode.rawValue
                ? $0.affectedIDs.map(\.rawValue).joined() < $1.affectedIDs.map(\.rawValue).joined()
                : $0.reasonCode.rawValue < $1.reasonCode.rawValue
        }
    }

    private func statusDriftDiagnostic(
        canonicalRecord: AirframeLocalWorkRecord,
        backendRecord: AirframeLocalWorkRecord,
        workflowPolicy: AirframeCanonicalWorkflowPolicyCatalog
    ) -> AirframeCanonicalDiagnostic {
        let requiresHumanApproval = workflowPolicy.transition(
            for: canonicalRecord.workItem.kind,
            from: backendRecord.workItem.status,
            to: canonicalRecord.workItem.status
        ).map {
            $0.operation.category == .humanAcceptance ||
                $0.operation.category == .sprintControl ||
                $0.operation.category == .epicControl ||
                $0.operation.requiresConfirmation
        } ?? true

        return AirframeCanonicalDiagnostic(
            severity: .warning,
            reasonCode: .backendStatusDrift,
            affectedIDs: [canonicalRecord.workItem.id],
            message: "Backend status for \(canonicalRecord.workItem.id.rawValue) is \(backendRecord.workItem.status.description), but canonical status is \(canonicalRecord.workItem.status.description).",
            repairOptions: [
                AirframeCanonicalRepairOption(
                    action: .applyBackendStatusLabels,
                    title: "Update backend status labels from canonical state.",
                    affectedIDs: [canonicalRecord.workItem.id],
                    requiresHumanApproval: requiresHumanApproval
                )
            ]
        )
    }

    private func relationshipDriftDiagnostic(
        canonicalRecord: AirframeLocalWorkRecord,
        backendRecord: AirframeLocalWorkRecord
    ) -> AirframeCanonicalDiagnostic {
        AirframeCanonicalDiagnostic(
            severity: .warning,
            reasonCode: .backendRelationshipDrift,
            affectedIDs: [canonicalRecord.workItem.id],
            message: "Backend relationships for \(canonicalRecord.workItem.id.rawValue) do not match canonical Epic/Sprint labels.",
            repairOptions: [
                AirframeCanonicalRepairOption(
                    action: .applyBackendRelationshipLabels,
                    title: "Update backend Epic/Sprint labels from canonical state.",
                    affectedIDs: [canonicalRecord.workItem.id],
                    requiresHumanApproval: false
                )
            ]
        )
    }
}

public struct AirframeCanonicalBackendRepairApplication: Codable, Equatable, Sendable {
    public let workItemID: AirframeID
    public let action: AirframeCanonicalRepairAction
    public let applied: Bool
    public let message: String

    public init(
        workItemID: AirframeID,
        action: AirframeCanonicalRepairAction,
        applied: Bool,
        message: String
    ) {
        self.workItemID = workItemID
        self.action = action
        self.applied = applied
        self.message = message
    }
}

public struct AirframeCanonicalBackendRepairResult: Codable, Equatable, Sendable {
    public let applications: [AirframeCanonicalBackendRepairApplication]

    public init(applications: [AirframeCanonicalBackendRepairApplication]) {
        self.applications = applications
    }

    public var appliedCount: Int {
        applications.filter(\.applied).count
    }
}

public struct AirframeCanonicalBackendRepairer: Sendable {
    public init() {}

    public func apply(
        repairOption: AirframeCanonicalRepairOption,
        canonicalRecords: [AirframeLocalWorkRecord],
        backend: any AirframeBackend,
        approval: AirframeGitHubMutationApproval? = nil,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws -> AirframeCanonicalBackendRepairResult {
        guard repairOption.action == .applyBackendStatusLabels
            || repairOption.action == .applyBackendRelationshipLabels else {
            throw AirframeBackendError.readOnlyBackend("canonical repair action \(repairOption.action.rawValue)")
        }
        guard !repairOption.requiresHumanApproval else {
            throw AirframeBackendError.requiresConfirmation(.requiresConfirmation)
        }

        let canonicalByID = Dictionary(uniqueKeysWithValues: canonicalRecords.map { ($0.workItem.id, $0) })
        let applications = try repairOption.affectedIDs.map { id in
            guard let canonicalRecord = canonicalByID[id] else {
                throw AirframeBackendError.missingWorkItem(id)
            }
            if let githubBackend = backend as? AirframeGitHubIssuesBackend {
                _ = try githubBackend.updateGitHubWorkRecord(
                    canonicalRecord,
                    approval: approval,
                    context: context,
                    targetProjectID: targetProjectID
                )
            } else {
                try backend.updateWorkRecord(canonicalRecord)
            }
            return AirframeCanonicalBackendRepairApplication(
                workItemID: id,
                action: repairOption.action,
                applied: true,
                message: "Applied \(repairOption.action.rawValue) to \(id.rawValue)."
            )
        }
        return AirframeCanonicalBackendRepairResult(applications: applications)
    }
}

public struct AirframeCanonicalStateRepairer: Sendable {
    public init() {}

    public func apply(
        repairOption: AirframeCanonicalRepairOption,
        repository: AirframeCanonicalStoreRepository
    ) throws -> AirframeCanonicalBackendRepairResult {
        guard !repairOption.requiresHumanApproval else {
            throw AirframeBackendError.requiresConfirmation(.requiresConfirmation)
        }
        let applications: [AirframeCanonicalBackendRepairApplication]
        switch repairOption.action {
        case .clearActiveEpicID:
            applications = try applyClearActiveEpicID(repairOption, repository: repository)
        case .clearActiveSprintID:
            applications = try applyClearActiveSprintID(repairOption, repository: repository)
        case .restoreEpicToActive:
            applications = try applyRestoreEpicToActive(repairOption, repository: repository)
        case .restoreSprintToActive:
            applications = try applyRestoreSprintToActive(repairOption, repository: repository)
        case .setActiveEpicID:
            applications = try applySetActiveEpicID(repairOption, repository: repository)
        case .setActiveSprintID:
            applications = try applySetActiveSprintID(repairOption, repository: repository)
        case .reconcileEpicSprintLinks:
            applications = try applyPairwiseRepair(repairOption, expectedPrefix: "EP", relatedPrefix: "SP") { epicID, sprintID in
                try repository.reconcileEpicSprintLinks(epicID: epicID, sprintID: sprintID)
            }
        case .reconcileEpicTaskLinks:
            applications = try applyPairwiseRepair(repairOption, expectedPrefix: "EP", relatedPrefix: "T") { epicID, taskID in
                try repository.reconcileEpicTaskLinks(epicID: epicID, taskID: taskID)
            }
        case .reconcileSprintTaskLinks:
            applications = try applyPairwiseRepair(repairOption, expectedPrefix: "SP", relatedPrefix: "T") { sprintID, taskID in
                try repository.reconcileSprintTaskLinks(sprintID: sprintID, taskID: taskID)
            }
        case .applyBackendStatusLabels,
             .applyBackendRelationshipLabels,
             .moveOpenWorkToAnotherEpic,
             .carryForwardOpenWork:
            throw AirframeBackendError.readOnlyBackend("canonical repair action \(repairOption.action.rawValue)")
        }
        return AirframeCanonicalBackendRepairResult(applications: applications)
    }

    private func applyClearActiveEpicID(
        _ repairOption: AirframeCanonicalRepairOption,
        repository: AirframeCanonicalStoreRepository
    ) throws -> [AirframeCanonicalBackendRepairApplication] {
        let projectID = try projectID(from: repairOption.affectedIDs)
        try repository.clearActiveEpicID(projectID: projectID)
        return [application(projectID, action: repairOption.action)]
    }

    private func applyClearActiveSprintID(
        _ repairOption: AirframeCanonicalRepairOption,
        repository: AirframeCanonicalStoreRepository
    ) throws -> [AirframeCanonicalBackendRepairApplication] {
        let projectID = try projectID(from: repairOption.affectedIDs)
        try repository.clearActiveSprintID(projectID: projectID)
        return [application(projectID, action: repairOption.action)]
    }

    private func applyRestoreEpicToActive(
        _ repairOption: AirframeCanonicalRepairOption,
        repository: AirframeCanonicalStoreRepository
    ) throws -> [AirframeCanonicalBackendRepairApplication] {
        let epicIDs = repairOption.affectedIDs.filter { $0.rawValue.hasPrefix("EP-") }
        guard !epicIDs.isEmpty else {
            throw AirframeBackendError.missingWorkItem(repairOption.affectedIDs.first ?? AirframeID("EP-UNKNOWN"))
        }
        return try epicIDs.map { epicID in
            try repository.restoreEpicToActive(epicID: epicID)
            return application(epicID, action: repairOption.action)
        }
    }

    private func applyRestoreSprintToActive(
        _ repairOption: AirframeCanonicalRepairOption,
        repository: AirframeCanonicalStoreRepository
    ) throws -> [AirframeCanonicalBackendRepairApplication] {
        let sprintIDs = repairOption.affectedIDs.filter { $0.rawValue.hasPrefix("SP-") }
        guard !sprintIDs.isEmpty else {
            throw AirframeBackendError.missingWorkItem(repairOption.affectedIDs.first ?? AirframeID("SP-UNKNOWN"))
        }
        return try sprintIDs.map { sprintID in
            try repository.restoreSprintToActive(sprintID: sprintID)
            return application(sprintID, action: repairOption.action)
        }
    }

    private func applySetActiveSprintID(
        _ repairOption: AirframeCanonicalRepairOption,
        repository: AirframeCanonicalStoreRepository
    ) throws -> [AirframeCanonicalBackendRepairApplication] {
        let projectID = try projectID(from: repairOption.affectedIDs)
        let sprintIDs = repairOption.affectedIDs.filter { $0.rawValue.hasPrefix("SP-") }
        guard sprintIDs.count == 1, let sprintID = sprintIDs.first else {
            throw AirframeBackendError.requiresConfirmation(.requiresConfirmation)
        }
        try repository.setActiveSprintID(sprintID, projectID: projectID)
        return [application(projectID, action: repairOption.action)]
    }

    private func applySetActiveEpicID(
        _ repairOption: AirframeCanonicalRepairOption,
        repository: AirframeCanonicalStoreRepository
    ) throws -> [AirframeCanonicalBackendRepairApplication] {
        let projectID = try projectID(from: repairOption.affectedIDs)
        let epicIDs = repairOption.affectedIDs.filter { $0.rawValue.hasPrefix("EP-") }
        guard epicIDs.count == 1, let epicID = epicIDs.first else {
            throw AirframeBackendError.requiresConfirmation(.requiresConfirmation)
        }
        try repository.setActiveEpicID(epicID, projectID: projectID)
        return [application(projectID, action: repairOption.action)]
    }

    private func applyPairwiseRepair(
        _ repairOption: AirframeCanonicalRepairOption,
        expectedPrefix: String,
        relatedPrefix: String,
        repair: (AirframeID, AirframeID) throws -> Void
    ) throws -> [AirframeCanonicalBackendRepairApplication] {
        guard let ownerID = repairOption.affectedIDs.first(where: { $0.rawValue.hasPrefix("\(expectedPrefix)-") }) else {
            throw AirframeBackendError.missingWorkItem(repairOption.affectedIDs.first ?? AirframeID("\(expectedPrefix)-UNKNOWN"))
        }
        let relatedIDs = repairOption.affectedIDs.filter { $0.rawValue.hasPrefix("\(relatedPrefix)-") }
        guard !relatedIDs.isEmpty else {
            throw AirframeBackendError.missingWorkItem(ownerID)
        }
        return try relatedIDs.map { relatedID in
            try repair(ownerID, relatedID)
            return application(relatedID, action: repairOption.action)
        }
    }

    private func projectID(from ids: [AirframeID]) throws -> AirframeID {
        guard let projectID = ids.first(where: { $0.rawValue.hasPrefix("PRJ-") }) else {
            throw AirframeBackendError.missingWorkItem(ids.first ?? AirframeID("PRJ-UNKNOWN"))
        }
        return projectID
    }

    private func application(
        _ id: AirframeID,
        action: AirframeCanonicalRepairAction
    ) -> AirframeCanonicalBackendRepairApplication {
        AirframeCanonicalBackendRepairApplication(
            workItemID: id,
            action: action,
            applied: true,
            message: "Applied \(action.rawValue) to \(id.rawValue)."
        )
    }
}

public struct AirframeCanonicalRepairOption: Codable, Equatable, Sendable {
    public let action: AirframeCanonicalRepairAction
    public let title: String
    public let affectedIDs: [AirframeID]
    public let requiresHumanApproval: Bool

    public init(
        action: AirframeCanonicalRepairAction,
        title: String,
        affectedIDs: [AirframeID],
        requiresHumanApproval: Bool = true
    ) {
        self.action = action
        self.title = title
        self.affectedIDs = affectedIDs
        self.requiresHumanApproval = requiresHumanApproval
    }
}

public struct AirframeCanonicalDiagnostic: Codable, Equatable, Sendable {
    public let severity: AirframeCanonicalDiagnosticSeverity
    public let reasonCode: AirframeCanonicalDiagnosticReasonCode
    public let affectedIDs: [AirframeID]
    public let message: String
    public let repairOptions: [AirframeCanonicalRepairOption]

    public init(
        severity: AirframeCanonicalDiagnosticSeverity,
        reasonCode: AirframeCanonicalDiagnosticReasonCode,
        affectedIDs: [AirframeID],
        message: String,
        repairOptions: [AirframeCanonicalRepairOption] = []
    ) {
        self.severity = severity
        self.reasonCode = reasonCode
        self.affectedIDs = affectedIDs
        self.message = message
        self.repairOptions = repairOptions
    }
}

public struct AirframeCanonicalDiagnostics: Codable, Equatable, Sendable {
    public let diagnostics: [AirframeCanonicalDiagnostic]

    public init(diagnostics: [AirframeCanonicalDiagnostic]) {
        self.diagnostics = diagnostics
    }

    public var status: AirframeCanonicalDiagnosticSeverity {
        if diagnostics.contains(where: { $0.severity == .blocking }) {
            return .blocking
        }
        if diagnostics.contains(where: { $0.severity == .error }) {
            return .error
        }
        if diagnostics.contains(where: { $0.severity == .warning }) {
            return .warning
        }
        return .info
    }

    public var isValid: Bool {
        !diagnostics.contains { $0.severity == .error || $0.severity == .blocking }
    }
}

public struct AirframeCanonicalStateSnapshot: Sendable {
    public let project: AirframeCanonicalProjectRecord
    public let epics: [AirframeCanonicalEpicRecord]
    public let sprints: [AirframeCanonicalSprintRecord]
    public let tasks: [AirframeCanonicalTaskRecord]
    public let issues: [AirframeCanonicalIssueRecord]
    public let requirements: [AirframeCanonicalRequirementRecord]
    public let acceptanceCriteria: [AirframeCanonicalAcceptanceCriterionRecord]
    public let tests: [AirframeCanonicalTestRecord]
    public let testSuites: [AirframeCanonicalTestSuiteRecord]
    public let testRuns: [AirframeCanonicalTestRunRecord]

    public init(
        project: AirframeCanonicalProjectRecord,
        epics: [AirframeCanonicalEpicRecord] = [],
        sprints: [AirframeCanonicalSprintRecord] = [],
        tasks: [AirframeCanonicalTaskRecord] = [],
        issues: [AirframeCanonicalIssueRecord] = [],
        requirements: [AirframeCanonicalRequirementRecord] = [],
        acceptanceCriteria: [AirframeCanonicalAcceptanceCriterionRecord] = [],
        tests: [AirframeCanonicalTestRecord] = [],
        testSuites: [AirframeCanonicalTestSuiteRecord] = [],
        testRuns: [AirframeCanonicalTestRunRecord] = []
    ) {
        self.project = project
        self.epics = epics
        self.sprints = sprints
        self.tasks = tasks
        self.issues = issues
        self.requirements = requirements
        self.acceptanceCriteria = acceptanceCriteria
        self.tests = tests
        self.testSuites = testSuites
        self.testRuns = testRuns
    }
}

public struct AirframeCanonicalStateValidator: Sendable {
    public init() {}

    public func diagnostics(for snapshot: AirframeCanonicalStateSnapshot) -> AirframeCanonicalDiagnostics {
        let epicsByID = Dictionary(uniqueKeysWithValues: snapshot.epics.map { ($0.workItem.id, $0) })
        let sprintsByID = Dictionary(uniqueKeysWithValues: snapshot.sprints.map { ($0.workItem.id, $0) })
        let tasksByID = Dictionary(uniqueKeysWithValues: snapshot.tasks.map { ($0.workItem.id, $0) })
        let issuesByID = Dictionary(uniqueKeysWithValues: snapshot.issues.map { ($0.workItem.id, $0) })
        let requirementsByID = Dictionary(uniqueKeysWithValues: snapshot.requirements.map { ($0.id, $0) })
        let criteriaByID = Dictionary(uniqueKeysWithValues: snapshot.acceptanceCriteria.map { ($0.id, $0) })
        let testsByID = Dictionary(uniqueKeysWithValues: snapshot.tests.map { ($0.id, $0) })
        let suitesByID = Dictionary(uniqueKeysWithValues: snapshot.testSuites.map { ($0.id, $0) })

        var diagnostics: [AirframeCanonicalDiagnostic] = []
        diagnostics.append(contentsOf: activeEpicDiagnostics(project: snapshot.project, epics: snapshot.epics, epicsByID: epicsByID))
        diagnostics.append(contentsOf: activeSprintDiagnostics(project: snapshot.project, sprints: snapshot.sprints, sprintsByID: sprintsByID))
        diagnostics.append(
            contentsOf: closedEpicDiagnostics(
                epics: snapshot.epics,
                sprintsByID: sprintsByID,
                tasksByID: tasksByID,
                issuesByID: issuesByID
            )
        )
        diagnostics.append(
            contentsOf: relationshipDiagnostics(
                epics: snapshot.epics,
                tasks: snapshot.tasks,
                epicsByID: epicsByID,
                sprintsByID: sprintsByID,
                tasksByID: tasksByID
            )
        )
        diagnostics.append(
            contentsOf: testDiagnostics(
                tests: snapshot.tests,
                testSuites: snapshot.testSuites,
                testRuns: snapshot.testRuns,
                requirementsByID: requirementsByID,
                criteriaByID: criteriaByID,
                testsByID: testsByID,
                suitesByID: suitesByID,
                tasksByID: tasksByID,
                issuesByID: issuesByID,
                epicsByID: epicsByID,
                sprintsByID: sprintsByID
            )
        )

        return AirframeCanonicalDiagnostics(
            diagnostics: diagnostics.sorted {
                $0.reasonCode.rawValue == $1.reasonCode.rawValue
                    ? $0.affectedIDs.map(\.rawValue).joined() < $1.affectedIDs.map(\.rawValue).joined()
                    : $0.reasonCode.rawValue < $1.reasonCode.rawValue
            }
        )
    }

    private func activeEpicDiagnostics(
        project: AirframeCanonicalProjectRecord,
        epics: [AirframeCanonicalEpicRecord],
        epicsByID: [AirframeID: AirframeCanonicalEpicRecord]
    ) -> [AirframeCanonicalDiagnostic] {
        let activeEpicIDs = epics
            .filter { $0.workItem.status == .active }
            .map(\.workItem.id)
            .sorted { $0.rawValue < $1.rawValue }
        guard let activeEpicID = project.activeEpicID else {
            if activeEpicIDs.count == 1, let soleActiveEpicID = activeEpicIDs.first {
                return [
                    activeEpicPointerMismatchDiagnostic(
                        project: project,
                        soleActiveEpicID: soleActiveEpicID
                    )
                ]
            }
            return []
        }
        guard let activeEpic = epicsByID[activeEpicID] else {
            return [
                AirframeCanonicalDiagnostic(
                    severity: .blocking,
                    reasonCode: .activeEpicMissing,
                    affectedIDs: [project.id, activeEpicID],
                    message: "Configured active Epic \(activeEpicID.rawValue) does not exist.",
                    repairOptions: [
                        AirframeCanonicalRepairOption(
                            action: .clearActiveEpicID,
                            title: "Clear the configured active Epic.",
                            affectedIDs: [project.id, activeEpicID]
                        )
                    ]
                )
            ]
        }
        if activeEpicIDs.count == 1,
           let soleActiveEpicID = activeEpicIDs.first,
           activeEpicID != soleActiveEpicID {
            return [
                activeEpicPointerMismatchDiagnostic(
                    project: project,
                    soleActiveEpicID: soleActiveEpicID
                )
            ]
        }
        guard activeEpic.workItem.status == .active else {
            return [
                AirframeCanonicalDiagnostic(
                    severity: .blocking,
                    reasonCode: .activeEpicNotActive,
                    affectedIDs: [project.id, activeEpicID],
                    message: "Configured active Epic \(activeEpicID.rawValue) is \(activeEpic.workItem.status.description), not Active.",
                    repairOptions: [
                        AirframeCanonicalRepairOption(
                            action: .restoreEpicToActive,
                            title: "Restore the Epic status to Active.",
                            affectedIDs: [activeEpicID]
                        ),
                        AirframeCanonicalRepairOption(
                            action: .clearActiveEpicID,
                            title: "Clear the configured active Epic.",
                            affectedIDs: [project.id, activeEpicID]
                        )
                    ]
                )
            ]
        }
        return []
    }

    private func activeEpicPointerMismatchDiagnostic(
        project: AirframeCanonicalProjectRecord,
        soleActiveEpicID: AirframeID
    ) -> AirframeCanonicalDiagnostic {
        let configuredIDs = project.activeEpicID.map { [$0] } ?? []
        return AirframeCanonicalDiagnostic(
            severity: .blocking,
            reasonCode: .activeEpicPointerMismatch,
            affectedIDs: [project.id, soleActiveEpicID] + configuredIDs,
            message: "The sole Active Epic is \(soleActiveEpicID.rawValue), but project.activeEpicID is \(project.activeEpicID?.rawValue ?? "None").",
            repairOptions: [
                AirframeCanonicalRepairOption(
                    action: .setActiveEpicID,
                    title: "Set the project active Epic to \(soleActiveEpicID.rawValue).",
                    affectedIDs: [project.id, soleActiveEpicID],
                    requiresHumanApproval: false
                )
            ]
        )
    }

    private func activeSprintDiagnostics(
        project: AirframeCanonicalProjectRecord,
        sprints: [AirframeCanonicalSprintRecord],
        sprintsByID: [AirframeID: AirframeCanonicalSprintRecord]
    ) -> [AirframeCanonicalDiagnostic] {
        let activeSprintIDs = sprints
            .filter { $0.workItem.status == .active }
            .map(\.workItem.id)
            .sorted { $0.rawValue < $1.rawValue }
        if activeSprintIDs.count > 1 {
            return [
                AirframeCanonicalDiagnostic(
                    severity: .blocking,
                    reasonCode: .multipleActiveSprints,
                    affectedIDs: [project.id] + activeSprintIDs,
                    message: "Multiple Sprints are Active: \(activeSprintIDs.map(\.rawValue).joined(separator: ", ")). Only one Sprint may be Active in the single-development-path Airframe workflow."
                )
            ]
        }
        guard let activeSprintID = project.activeSprintID else {
            if activeSprintIDs.count == 1, let soleActiveSprintID = activeSprintIDs.first {
                return [
                    activeSprintPointerMismatchDiagnostic(
                        project: project,
                        soleActiveSprintID: soleActiveSprintID
                    )
                ]
            }
            return []
        }
        guard let activeSprint = sprintsByID[activeSprintID] else {
            return [
                AirframeCanonicalDiagnostic(
                    severity: .blocking,
                    reasonCode: .activeSprintMissing,
                    affectedIDs: [project.id, activeSprintID],
                    message: "Configured active Sprint \(activeSprintID.rawValue) does not exist.",
                    repairOptions: [
                        AirframeCanonicalRepairOption(
                            action: .clearActiveSprintID,
                            title: "Clear the configured active Sprint.",
                            affectedIDs: [project.id, activeSprintID]
                        )
                    ]
                )
            ]
        }
        guard activeSprint.workItem.status == .active || activeSprint.workItem.status == .review else {
            return [
                AirframeCanonicalDiagnostic(
                    severity: .blocking,
                    reasonCode: .activeSprintNotActive,
                    affectedIDs: [project.id, activeSprintID],
                    message: "Configured active Sprint \(activeSprintID.rawValue) is \(activeSprint.workItem.status.description), not Active or Review.",
                    repairOptions: [
                        AirframeCanonicalRepairOption(
                            action: .restoreSprintToActive,
                            title: "Restore the Sprint status to Active.",
                            affectedIDs: [activeSprintID]
                        ),
                        AirframeCanonicalRepairOption(
                            action: .clearActiveSprintID,
                            title: "Clear the configured active Sprint.",
                            affectedIDs: [project.id, activeSprintID]
                        )
                    ]
                )
            ]
        }
        if activeSprintIDs.count == 1,
           let soleActiveSprintID = activeSprintIDs.first,
           activeSprintID != soleActiveSprintID {
            return [
                activeSprintPointerMismatchDiagnostic(
                    project: project,
                    soleActiveSprintID: soleActiveSprintID
                )
            ]
        }
        return []
    }

    private func activeSprintPointerMismatchDiagnostic(
        project: AirframeCanonicalProjectRecord,
        soleActiveSprintID: AirframeID
    ) -> AirframeCanonicalDiagnostic {
        let configuredIDs = project.activeSprintID.map { [$0] } ?? []
        return AirframeCanonicalDiagnostic(
            severity: .blocking,
            reasonCode: .activeSprintPointerMismatch,
            affectedIDs: [project.id, soleActiveSprintID] + configuredIDs,
            message: "The sole Active Sprint is \(soleActiveSprintID.rawValue), but project.activeSprintID is \(project.activeSprintID?.rawValue ?? "None").",
            repairOptions: [
                AirframeCanonicalRepairOption(
                    action: .setActiveSprintID,
                    title: "Set the project active Sprint to \(soleActiveSprintID.rawValue).",
                    affectedIDs: [project.id, soleActiveSprintID],
                    requiresHumanApproval: false
                )
            ]
        )
    }

    private func closedEpicDiagnostics(
        epics: [AirframeCanonicalEpicRecord],
        sprintsByID: [AirframeID: AirframeCanonicalSprintRecord],
        tasksByID: [AirframeID: AirframeCanonicalTaskRecord],
        issuesByID: [AirframeID: AirframeCanonicalIssueRecord]
    ) -> [AirframeCanonicalDiagnostic] {
        epics.flatMap { epic in
            guard epic.workItem.status == .closed else {
                return [] as [AirframeCanonicalDiagnostic]
            }
            let openSprintIDs = epic.sprintIDs.filter {
                sprintsByID[$0].map { !isTerminal($0.workItem.status) } ?? false
            }
            let openTaskIDs = epic.taskIDs.filter {
                tasksByID[$0].map { !isTerminal($0.workItem.status) } ?? false
            }
            let openIssueIDs = epic.issueIDs.filter {
                issuesByID[$0].map { !isTerminal($0.workItem.status) } ?? false
            }
            let openIDs = openSprintIDs + openTaskIDs + openIssueIDs
            guard !openIDs.isEmpty else {
                return [] as [AirframeCanonicalDiagnostic]
            }
            return [
                AirframeCanonicalDiagnostic(
                    severity: .blocking,
                    reasonCode: .closedEpicOwnsOpenWork,
                    affectedIDs: [epic.workItem.id] + openIDs,
                    message: "Closed Epic \(epic.workItem.id.rawValue) still owns open work: \(openIDs.map(\.rawValue).joined(separator: ", ")).",
                    repairOptions: [
                        AirframeCanonicalRepairOption(
                            action: .restoreEpicToActive,
                            title: "Restore the Epic status to Active.",
                            affectedIDs: [epic.workItem.id]
                        ),
                        AirframeCanonicalRepairOption(
                            action: .moveOpenWorkToAnotherEpic,
                            title: "Move open work to another Epic.",
                            affectedIDs: openIDs
                        ),
                        AirframeCanonicalRepairOption(
                            action: .carryForwardOpenWork,
                            title: "Carry forward or explicitly descope the open work.",
                            affectedIDs: openIDs
                        )
                    ]
                )
            ]
        }
    }

    private func relationshipDiagnostics(
        epics: [AirframeCanonicalEpicRecord],
        tasks: [AirframeCanonicalTaskRecord],
        epicsByID: [AirframeID: AirframeCanonicalEpicRecord],
        sprintsByID: [AirframeID: AirframeCanonicalSprintRecord],
        tasksByID: [AirframeID: AirframeCanonicalTaskRecord]
    ) -> [AirframeCanonicalDiagnostic] {
        var diagnostics: [AirframeCanonicalDiagnostic] = []
        for epic in epics {
            for sprintID in epic.sprintIDs {
                if let sprint = sprintsByID[sprintID], sprint.epicID != epic.workItem.id {
                    diagnostics.append(
                        AirframeCanonicalDiagnostic(
                            severity: .error,
                            reasonCode: .epicSprintRelationshipDrift,
                            affectedIDs: [epic.workItem.id, sprintID],
                            message: "Epic \(epic.workItem.id.rawValue) references Sprint \(sprintID.rawValue), but the Sprint references \(sprint.epicID?.rawValue ?? "no Epic").",
                            repairOptions: [
                                AirframeCanonicalRepairOption(
                                    action: .reconcileEpicSprintLinks,
                                    title: "Reconcile Epic and Sprint links.",
                                    affectedIDs: [epic.workItem.id, sprintID]
                                )
                            ]
                        )
                    )
                }
            }
            for taskID in epic.taskIDs {
                if let task = tasksByID[taskID], task.epicID != epic.workItem.id {
                    diagnostics.append(
                        AirframeCanonicalDiagnostic(
                            severity: .error,
                            reasonCode: .epicTaskRelationshipDrift,
                            affectedIDs: [epic.workItem.id, taskID],
                            message: "Epic \(epic.workItem.id.rawValue) references Task \(taskID.rawValue), but the Task references \(task.epicID?.rawValue ?? "no Epic").",
                            repairOptions: [
                                AirframeCanonicalRepairOption(
                                    action: .reconcileEpicTaskLinks,
                                    title: "Reconcile Epic and Task links.",
                                    affectedIDs: [epic.workItem.id, taskID]
                                )
                            ]
                        )
                    )
                }
            }
        }
        for task in tasks {
            if let epicID = task.epicID {
                if let epic = epicsByID[epicID] {
                    if !epic.taskIDs.isEmpty, !epic.taskIDs.contains(task.workItem.id) {
                        diagnostics.append(
                            AirframeCanonicalDiagnostic(
                                severity: .warning,
                                reasonCode: .epicTaskRelationshipDrift,
                                affectedIDs: [epicID, task.workItem.id],
                                message: "Task \(task.workItem.id.rawValue) references Epic \(epicID.rawValue), but the Epic does not reference the Task.",
                                repairOptions: [
                                    AirframeCanonicalRepairOption(
                                        action: .reconcileEpicTaskLinks,
                                        title: "Reconcile Epic and Task links.",
                                        affectedIDs: [epicID, task.workItem.id]
                                    )
                                ]
                            )
                        )
                    }
                } else {
                    diagnostics.append(
                        AirframeCanonicalDiagnostic(
                            severity: .warning,
                            reasonCode: .taskEpicMissing,
                            affectedIDs: [task.workItem.id, epicID],
                            message: "Task \(task.workItem.id.rawValue) references missing Epic \(epicID.rawValue)."
                        )
                    )
                }
            }
            if let sprintID = task.sprintID {
                if let sprint = sprintsByID[sprintID] {
                    if !sprint.taskIDs.isEmpty, !sprint.taskIDs.contains(task.workItem.id) {
                        diagnostics.append(
                            AirframeCanonicalDiagnostic(
                                severity: .warning,
                                reasonCode: .sprintTaskRelationshipDrift,
                                affectedIDs: [sprintID, task.workItem.id],
                                message: "Task \(task.workItem.id.rawValue) references Sprint \(sprintID.rawValue), but the Sprint does not reference the Task.",
                                repairOptions: [
                                    AirframeCanonicalRepairOption(
                                        action: .reconcileSprintTaskLinks,
                                        title: "Reconcile Sprint and Task links.",
                                        affectedIDs: [sprintID, task.workItem.id]
                                    )
                                ]
                            )
                        )
                    }
                } else {
                    diagnostics.append(
                        AirframeCanonicalDiagnostic(
                            severity: .warning,
                            reasonCode: .taskSprintMissing,
                            affectedIDs: [task.workItem.id, sprintID],
                            message: "Task \(task.workItem.id.rawValue) references missing Sprint \(sprintID.rawValue)."
                        )
                    )
                }
            }
        }
        for sprint in sprintsByID.values {
            for taskID in sprint.taskIDs {
                if let task = tasksByID[taskID], task.sprintID != sprint.workItem.id {
                    diagnostics.append(
                        AirframeCanonicalDiagnostic(
                            severity: .error,
                            reasonCode: .sprintTaskRelationshipDrift,
                            affectedIDs: [sprint.workItem.id, taskID],
                            message: "Sprint \(sprint.workItem.id.rawValue) references Task \(taskID.rawValue), but the Task references \(task.sprintID?.rawValue ?? "no Sprint").",
                            repairOptions: [
                                AirframeCanonicalRepairOption(
                                    action: .reconcileSprintTaskLinks,
                                    title: "Reconcile Sprint and Task links.",
                                    affectedIDs: [sprint.workItem.id, taskID]
                                )
                            ]
                        )
                    )
                }
            }
        }
        return diagnostics
    }

    private func testDiagnostics(
        tests: [AirframeCanonicalTestRecord],
        testSuites: [AirframeCanonicalTestSuiteRecord],
        testRuns: [AirframeCanonicalTestRunRecord],
        requirementsByID: [AirframeID: AirframeCanonicalRequirementRecord],
        criteriaByID: [AirframeID: AirframeCanonicalAcceptanceCriterionRecord],
        testsByID: [AirframeID: AirframeCanonicalTestRecord],
        suitesByID: [AirframeID: AirframeCanonicalTestSuiteRecord],
        tasksByID: [AirframeID: AirframeCanonicalTaskRecord],
        issuesByID: [AirframeID: AirframeCanonicalIssueRecord],
        epicsByID: [AirframeID: AirframeCanonicalEpicRecord],
        sprintsByID: [AirframeID: AirframeCanonicalSprintRecord]
    ) -> [AirframeCanonicalDiagnostic] {
        var diagnostics: [AirframeCanonicalDiagnostic] = []
        for test in tests {
            for requirementID in test.requirementIDs where requirementsByID[requirementID] == nil {
                diagnostics.append(
                    AirframeCanonicalDiagnostic(
                        severity: .warning,
                        reasonCode: .testRequirementMissing,
                        affectedIDs: [test.id, requirementID],
                        message: "Test \(test.id.rawValue) references missing Requirement \(requirementID.rawValue)."
                    )
                )
            }
            for criterionID in test.acceptanceCriterionIDs where criteriaByID[criterionID] == nil {
                diagnostics.append(
                    AirframeCanonicalDiagnostic(
                        severity: .warning,
                        reasonCode: .testAcceptanceCriterionMissing,
                        affectedIDs: [test.id, criterionID],
                        message: "Test \(test.id.rawValue) references missing Acceptance Criterion \(criterionID.rawValue)."
                    )
                )
            }
            for workItemID in test.workItemIDs where !workItemExists(
                workItemID,
                tasksByID: tasksByID,
                issuesByID: issuesByID,
                epicsByID: epicsByID,
                sprintsByID: sprintsByID
            ) {
                diagnostics.append(
                    AirframeCanonicalDiagnostic(
                        severity: .warning,
                        reasonCode: .testWorkItemMissing,
                        affectedIDs: [test.id, workItemID],
                        message: "Test \(test.id.rawValue) references missing work item \(workItemID.rawValue)."
                    )
                )
            }
        }
        for suite in testSuites {
            for testID in suite.testIDs where testsByID[testID] == nil {
                diagnostics.append(
                    AirframeCanonicalDiagnostic(
                        severity: .warning,
                        reasonCode: .testSuiteTestMissing,
                        affectedIDs: [suite.id, testID],
                        message: "Test Suite \(suite.id.rawValue) references missing Test \(testID.rawValue)."
                    )
                )
            }
            for requirementID in suite.requirementIDs where requirementsByID[requirementID] == nil {
                diagnostics.append(
                    AirframeCanonicalDiagnostic(
                        severity: .warning,
                        reasonCode: .testRequirementMissing,
                        affectedIDs: [suite.id, requirementID],
                        message: "Test Suite \(suite.id.rawValue) references missing Requirement \(requirementID.rawValue)."
                    )
                )
            }
            for criterionID in suite.acceptanceCriterionIDs where criteriaByID[criterionID] == nil {
                diagnostics.append(
                    AirframeCanonicalDiagnostic(
                        severity: .warning,
                        reasonCode: .testAcceptanceCriterionMissing,
                        affectedIDs: [suite.id, criterionID],
                        message: "Test Suite \(suite.id.rawValue) references missing Acceptance Criterion \(criterionID.rawValue)."
                    )
                )
            }
        }
        for run in testRuns {
            if testsByID[run.testID] == nil {
                diagnostics.append(
                    AirframeCanonicalDiagnostic(
                        severity: .warning,
                        reasonCode: .testRunTestMissing,
                        affectedIDs: [run.id, run.testID],
                        message: "Test Run \(run.id.rawValue) references missing Test \(run.testID.rawValue)."
                    )
                )
            }
            if let suiteID = run.suiteID, suitesByID[suiteID] == nil {
                diagnostics.append(
                    AirframeCanonicalDiagnostic(
                        severity: .warning,
                        reasonCode: .testRunSuiteMissing,
                        affectedIDs: [run.id, suiteID],
                        message: "Test Run \(run.id.rawValue) references missing Test Suite \(suiteID.rawValue)."
                    )
                )
            }
        }
        return diagnostics
    }

    private func workItemExists(
        _ id: AirframeID,
        tasksByID: [AirframeID: AirframeCanonicalTaskRecord],
        issuesByID: [AirframeID: AirframeCanonicalIssueRecord],
        epicsByID: [AirframeID: AirframeCanonicalEpicRecord],
        sprintsByID: [AirframeID: AirframeCanonicalSprintRecord]
    ) -> Bool {
        tasksByID[id] != nil || issuesByID[id] != nil || epicsByID[id] != nil || sprintsByID[id] != nil
    }

    private func isTerminal(_ status: AirframeWorkStatus) -> Bool {
        status == .implementedVerified || status == .closed
    }
}
