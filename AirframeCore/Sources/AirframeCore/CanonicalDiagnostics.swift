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
    case closedEpicOwnsOpenWork
    case epicSprintRelationshipDrift
    case epicTaskRelationshipDrift
    case sprintTaskRelationshipDrift
}

public enum AirframeCanonicalRepairAction: String, Codable, Equatable, Sendable {
    case clearActiveEpicID
    case clearActiveSprintID
    case restoreEpicToActive
    case restoreSprintToActive
    case moveOpenWorkToAnotherEpic
    case carryForwardOpenWork
    case reconcileEpicSprintLinks
    case reconcileEpicTaskLinks
    case reconcileSprintTaskLinks
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

    public init(
        project: AirframeCanonicalProjectRecord,
        epics: [AirframeCanonicalEpicRecord] = [],
        sprints: [AirframeCanonicalSprintRecord] = [],
        tasks: [AirframeCanonicalTaskRecord] = [],
        issues: [AirframeCanonicalIssueRecord] = []
    ) {
        self.project = project
        self.epics = epics
        self.sprints = sprints
        self.tasks = tasks
        self.issues = issues
    }
}

public struct AirframeCanonicalStateValidator: Sendable {
    public init() {}

    public func diagnostics(for snapshot: AirframeCanonicalStateSnapshot) -> AirframeCanonicalDiagnostics {
        let epicsByID = Dictionary(uniqueKeysWithValues: snapshot.epics.map { ($0.workItem.id, $0) })
        let sprintsByID = Dictionary(uniqueKeysWithValues: snapshot.sprints.map { ($0.workItem.id, $0) })
        let tasksByID = Dictionary(uniqueKeysWithValues: snapshot.tasks.map { ($0.workItem.id, $0) })
        let issuesByID = Dictionary(uniqueKeysWithValues: snapshot.issues.map { ($0.workItem.id, $0) })

        var diagnostics: [AirframeCanonicalDiagnostic] = []
        diagnostics.append(contentsOf: activeEpicDiagnostics(project: snapshot.project, epicsByID: epicsByID))
        diagnostics.append(contentsOf: activeSprintDiagnostics(project: snapshot.project, sprintsByID: sprintsByID))
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
                sprintsByID: sprintsByID,
                tasksByID: tasksByID
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
        epicsByID: [AirframeID: AirframeCanonicalEpicRecord]
    ) -> [AirframeCanonicalDiagnostic] {
        guard let activeEpicID = project.activeEpicID else {
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

    private func activeSprintDiagnostics(
        project: AirframeCanonicalProjectRecord,
        sprintsByID: [AirframeID: AirframeCanonicalSprintRecord]
    ) -> [AirframeCanonicalDiagnostic] {
        guard let activeSprintID = project.activeSprintID else {
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
        guard activeSprint.workItem.status == .active else {
            return [
                AirframeCanonicalDiagnostic(
                    severity: .blocking,
                    reasonCode: .activeSprintNotActive,
                    affectedIDs: [project.id, activeSprintID],
                    message: "Configured active Sprint \(activeSprintID.rawValue) is \(activeSprint.workItem.status.description), not Active.",
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
        return []
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

    private func isTerminal(_ status: AirframeWorkStatus) -> Bool {
        status == .implementedVerified || status == .closed
    }
}

