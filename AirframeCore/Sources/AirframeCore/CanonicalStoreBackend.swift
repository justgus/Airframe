import Foundation

public struct AirframeCanonicalStoreState: Sendable {
    public let workspaces: [AirframeCanonicalWorkspaceRecord]
    public let projects: [AirframeCanonicalProjectRecord]
    public let epics: [AirframeCanonicalEpicRecord]
    public let sprints: [AirframeCanonicalSprintRecord]
    public let tasks: [AirframeCanonicalTaskRecord]
    public let issues: [AirframeCanonicalIssueRecord]
    public let requirements: [AirframeCanonicalRequirementRecord]
    public let requirementRevisions: [AirframeCanonicalRequirementRevisionRecord]
    public let acceptanceCriteria: [AirframeCanonicalAcceptanceCriterionRecord]
    public let evidence: [AirframeCanonicalEvidenceSummaryRecord]

    public init(
        workspaces: [AirframeCanonicalWorkspaceRecord] = [],
        projects: [AirframeCanonicalProjectRecord] = [],
        epics: [AirframeCanonicalEpicRecord] = [],
        sprints: [AirframeCanonicalSprintRecord] = [],
        tasks: [AirframeCanonicalTaskRecord] = [],
        issues: [AirframeCanonicalIssueRecord] = [],
        requirements: [AirframeCanonicalRequirementRecord] = [],
        requirementRevisions: [AirframeCanonicalRequirementRevisionRecord] = [],
        acceptanceCriteria: [AirframeCanonicalAcceptanceCriterionRecord] = [],
        evidence: [AirframeCanonicalEvidenceSummaryRecord] = []
    ) {
        self.workspaces = workspaces
        self.projects = projects
        self.epics = epics
        self.sprints = sprints
        self.tasks = tasks
        self.issues = issues
        self.requirements = requirements
        self.requirementRevisions = requirementRevisions
        self.acceptanceCriteria = acceptanceCriteria
        self.evidence = evidence
    }
}

public final class AirframeCanonicalStoreRepository: @unchecked Sendable {
    public let store: AirframeCanonicalJSONStore

    public init(store: AirframeCanonicalJSONStore) {
        self.store = store
    }

    public convenience init(rootURL: URL) {
        self.init(store: AirframeCanonicalJSONStore(rootURL: rootURL))
    }

    public func loadState() throws -> AirframeCanonicalStoreState {
        try AirframeCanonicalStoreState(
            workspaces: store.list(AirframeCanonicalWorkspaceRecord.self),
            projects: store.list(AirframeCanonicalProjectRecord.self),
            epics: store.list(AirframeCanonicalEpicRecord.self),
            sprints: store.list(AirframeCanonicalSprintRecord.self),
            tasks: store.list(AirframeCanonicalTaskRecord.self),
            issues: store.list(AirframeCanonicalIssueRecord.self),
            requirements: store.list(AirframeCanonicalRequirementRecord.self),
            requirementRevisions: store.list(AirframeCanonicalRequirementRevisionRecord.self),
            acceptanceCriteria: store.list(AirframeCanonicalAcceptanceCriterionRecord.self),
            evidence: store.list(AirframeCanonicalEvidenceSummaryRecord.self)
        )
    }

    public func saveImportedState(
        _ importResult: AirframeMarkdownImportResult,
        context: AirframeProjectContext
    ) throws {
        try replaceManagedRecords()
        let project = AirframeCanonicalProjectRecord(
            id: context.project.id,
            name: context.project.name,
            repository: context.project.repository,
            activeEpicID: context.project.activeEpicID,
            activeSprintID: context.project.activeSprintID,
            epicIDs: importResult.epics.map(\.workItem.id),
            sprintIDs: importResult.sprints.map(\.workItem.id),
            taskIDs: importResult.tasks.map(\.workItem.id),
            issueIDs: importResult.issues.map(\.workItem.id)
        )
        let workspace = AirframeCanonicalWorkspaceRecord(
            id: context.configuration.workspace.id,
            name: context.configuration.workspace.name,
            rootPath: context.configuration.workspace.rootPath,
            projectIDs: [context.project.id],
            defaultProjectID: context.configuration.defaultProjectID
        )

        try store.save(workspace)
        try store.save(project)
        try importResult.epics.forEach(store.save)
        try importResult.sprints.forEach(store.save)
        try importResult.tasks.forEach(store.save)
        try importResult.issues.forEach(store.save)
        try importResult.requirements.forEach(store.save)
        try importResult.requirementRevisions.forEach(store.save)
        try importResult.acceptanceCriteria.forEach(store.save)
    }

    private func replaceManagedRecords() throws {
        try store.list(AirframeCanonicalWorkspaceRecord.self).forEach {
            try store.delete(AirframeCanonicalWorkspaceRecord.self, id: $0.id)
        }
        try store.list(AirframeCanonicalProjectRecord.self).forEach {
            try store.delete(AirframeCanonicalProjectRecord.self, id: $0.id)
        }
        try store.list(AirframeCanonicalEpicRecord.self).forEach {
            try store.delete(AirframeCanonicalEpicRecord.self, id: $0.workItem.id)
        }
        try store.list(AirframeCanonicalSprintRecord.self).forEach {
            try store.delete(AirframeCanonicalSprintRecord.self, id: $0.workItem.id)
        }
        try store.list(AirframeCanonicalTaskRecord.self).forEach {
            try store.delete(AirframeCanonicalTaskRecord.self, id: $0.workItem.id)
        }
        try store.list(AirframeCanonicalIssueRecord.self).forEach {
            try store.delete(AirframeCanonicalIssueRecord.self, id: $0.workItem.id)
        }
        try store.list(AirframeCanonicalRequirementRecord.self).forEach {
            try store.delete(AirframeCanonicalRequirementRecord.self, id: $0.id)
        }
        try store.list(AirframeCanonicalRequirementRevisionRecord.self).forEach {
            try store.delete(AirframeCanonicalRequirementRevisionRecord.self, id: $0.id)
        }
        try store.list(AirframeCanonicalAcceptanceCriterionRecord.self).forEach {
            try store.delete(AirframeCanonicalAcceptanceCriterionRecord.self, id: $0.id)
        }
    }

    public func workRecords() throws -> [AirframeLocalWorkRecord] {
        try workRecords(from: loadState())
    }

    public func workRecords(from state: AirframeCanonicalStoreState) -> [AirframeLocalWorkRecord] {
        let epics = state.epics.map { epic in
            AirframeLocalWorkRecord(
                workItem: epic.workItem,
                priority: .medium,
                acceptanceCriteria: state.acceptanceCriteria
                    .filter { $0.ownerID == epic.workItem.id }
                    .sorted { $0.id.rawValue < $1.id.rawValue }
                    .map { ($0.isVerified ? "[x] " : "[ ] ") + $0.text },
                scope: epic.scope,
                constraints: epic.outOfScope
            )
        }
        let sprints = state.sprints.map { sprint in
            AirframeLocalWorkRecord(
                workItem: sprint.workItem,
                epicID: sprint.epicID,
                priority: .medium,
                scope: sprint.notes
            )
        }
        let tasks = state.tasks.map { task in
            AirframeLocalWorkRecord(
                workItem: task.workItem,
                epicID: task.epicID,
                sprintID: task.sprintID,
                priority: task.priority,
                acceptanceCriteria: task.acceptanceCriteria,
                scope: task.componentsAffected,
                constraints: task.notes,
                evidenceRequirements: task.testSteps
            )
        }
        let issues = state.issues.map { issue in
            AirframeLocalWorkRecord(
                workItem: issue.workItem,
                epicID: issue.epicID,
                sprintID: issue.sprintID,
                priority: issue.severity
            )
        }
        return (epics + sprints + tasks + issues).sorted {
            $0.workItem.id.rawValue < $1.workItem.id.rawValue
        }
    }

    public func epicCriteriaSummary(epicID: AirframeID) throws -> AirframeEpicAcceptanceCriteriaSummary {
        let criteria = try store.list(AirframeCanonicalAcceptanceCriterionRecord.self)
            .filter { $0.ownerID == epicID }
            .sorted { $0.id.rawValue < $1.id.rawValue }
            .map {
                AirframeEpicAcceptanceCriterion(
                    id: $0.id,
                    text: $0.text,
                    isVerified: $0.isVerified
                )
            }
        return AirframeEpicAcceptanceCriteriaSummary(epicID: epicID, criteria: criteria)
    }

    public func verifyEpicCriterion(id: AirframeID) throws {
        guard let criterion = try store.load(AirframeCanonicalAcceptanceCriterionRecord.self, id: id) else {
            throw AirframeBackendError.missingWorkItem(id)
        }
        try store.save(
            AirframeCanonicalAcceptanceCriterionRecord(
                id: criterion.id,
                ownerID: criterion.ownerID,
                text: criterion.text,
                isVerified: true,
                evidenceIDs: criterion.evidenceIDs,
                metadata: AirframeCanonicalRecordMetadata(
                    schemaVersion: criterion.metadata.schemaVersion,
                    createdAt: criterion.metadata.createdAt,
                    updatedAt: Date(),
                    source: criterion.metadata.source
                )
            )
        )
    }

    public func transitionWorkItem(id: AirframeID, to status: AirframeWorkStatus) throws {
        if let record = try store.load(AirframeCanonicalEpicRecord.self, id: id) {
            try store.save(record.updatingStatus(status))
            return
        }
        if let record = try store.load(AirframeCanonicalSprintRecord.self, id: id) {
            try store.save(record.updatingStatus(status))
            try applyActiveSprintPointerSideEffect(for: record, transitioningTo: status)
            return
        }
        if let record = try store.load(AirframeCanonicalTaskRecord.self, id: id) {
            try store.save(record.updatingStatus(status))
            return
        }
        if let record = try store.load(AirframeCanonicalIssueRecord.self, id: id) {
            try store.save(record.updatingStatus(status))
            return
        }
        throw AirframeBackendError.missingWorkItem(id)
    }

    public func updateWorkRecord(_ record: AirframeLocalWorkRecord) throws {
        switch record.workItem.kind {
        case .epic:
            guard let existing = try store.load(AirframeCanonicalEpicRecord.self, id: record.workItem.id) else {
                throw AirframeBackendError.missingWorkItem(record.workItem.id)
            }
            try store.save(existing.updating(from: record))
        case .sprint:
            guard let existing = try store.load(AirframeCanonicalSprintRecord.self, id: record.workItem.id) else {
                throw AirframeBackendError.missingWorkItem(record.workItem.id)
            }
            try store.save(existing.updating(from: record))
        case .task:
            guard let existing = try store.load(AirframeCanonicalTaskRecord.self, id: record.workItem.id) else {
                throw AirframeBackendError.missingWorkItem(record.workItem.id)
            }
            try store.save(existing.updating(from: record))
            try reconcileEpicTaskLinks(epicID: record.epicID, taskID: record.workItem.id)
            try reconcileSprintTaskLinks(sprintID: record.sprintID, taskID: record.workItem.id)
        case .issue:
            guard let existing = try store.load(AirframeCanonicalIssueRecord.self, id: record.workItem.id) else {
                throw AirframeBackendError.missingWorkItem(record.workItem.id)
            }
            try store.save(existing.updating(from: record))
            try reconcileEpicIssueLinks(epicID: record.epicID, issueID: record.workItem.id)
            try reconcileSprintIssueLinks(sprintID: record.sprintID, issueID: record.workItem.id)
        }
    }

    public func createWorkRecord(_ record: AirframeLocalWorkRecord) throws {
        switch record.workItem.kind {
        case .epic:
            guard try store.load(AirframeCanonicalEpicRecord.self, id: record.workItem.id) == nil else {
                throw AirframeBackendError.duplicateWorkItem(record.workItem.id)
            }
            try store.save(
                AirframeCanonicalEpicRecord(
                    workItem: record.workItem,
                    owner: "",
                    goal: record.scope.first ?? "",
                    rationale: record.constraints.first ?? "",
                    startDate: nil,
                    targetCloseDate: nil,
                    closeDate: record.workItem.status == .closed ? isoDateString() : nil,
                    scope: record.scope,
                    outOfScope: record.constraints,
                    acceptanceCriterionIDs: [],
                    sprintIDs: [],
                    taskIDs: [],
                    issueIDs: [],
                    planningDocumentPaths: [],
                    notes: record.constraints
                )
            )
            try updateProjectRecord { project in
                var updated = project.addingEpicID(record.workItem.id)
                if record.workItem.status == .active {
                    updated = updated.settingActiveEpicID(record.workItem.id)
                }
                return updated
            }
        case .sprint:
            guard try store.load(AirframeCanonicalSprintRecord.self, id: record.workItem.id) == nil else {
                throw AirframeBackendError.duplicateWorkItem(record.workItem.id)
            }
            try store.save(
                AirframeCanonicalSprintRecord(
                    workItem: record.workItem,
                    epicID: record.epicID,
                    goal: record.scope.first ?? "",
                    startDate: nil,
                    endDate: record.workItem.status == .review || record.workItem.status == .closed ? isoDateString() : nil,
                    capacity: nil,
                    taskIDs: [],
                    issueIDs: [],
                    notes: record.constraints
                )
            )
            try updateProjectRecord { project in
                var updated = project.addingSprintID(record.workItem.id)
                if record.workItem.status == .active {
                    updated = updated.settingActiveSprintID(record.workItem.id)
                }
                return updated
            }
            if let epicID = record.epicID {
                try reconcileEpicSprintLinks(epicID: epicID, sprintID: record.workItem.id)
            }
        case .task:
            guard try store.load(AirframeCanonicalTaskRecord.self, id: record.workItem.id) == nil else {
                throw AirframeBackendError.duplicateWorkItem(record.workItem.id)
            }
            try store.save(
                AirframeCanonicalTaskRecord(
                    workItem: record.workItem,
                    component: record.scope.first ?? "",
                    priority: record.priority,
                    rationale: record.constraints.first ?? "",
                    epicID: record.epicID,
                    sprintID: record.sprintID,
                    dateRequested: nil,
                    dateImplemented: record.workItem.status == .implementedNotVerified ? isoDateString() : nil,
                    dateVerified: record.workItem.status == .implementedVerified ? isoDateString() : nil,
                    currentBehavior: nil,
                    desiredBehavior: nil,
                    requirementIDs: [],
                    acceptanceCriteria: record.acceptanceCriteria,
                    designApproach: nil,
                    componentsAffected: record.scope,
                    implementationDetails: nil,
                    evidenceIDs: [],
                    testSteps: record.evidenceRequirements,
                    notes: record.constraints
                )
            )
            try updateProjectRecord { $0.addingTaskID(record.workItem.id) }
            try reconcileEpicTaskLinks(epicID: record.epicID, taskID: record.workItem.id)
            try reconcileSprintTaskLinks(sprintID: record.sprintID, taskID: record.workItem.id)
        case .issue:
            guard try store.load(AirframeCanonicalIssueRecord.self, id: record.workItem.id) == nil else {
                throw AirframeBackendError.duplicateWorkItem(record.workItem.id)
            }
            try store.save(
                AirframeCanonicalIssueRecord(
                    workItem: record.workItem,
                    severity: record.priority,
                    observedBehavior: "",
                    expectedBehavior: "",
                    epicID: record.epicID,
                    sprintID: record.sprintID,
                    dateReported: nil,
                    dateResolved: record.workItem.status == .implementedNotVerified ? isoDateString() : nil,
                    dateVerified: record.workItem.status == .implementedVerified ? isoDateString() : nil,
                    reproductionSteps: record.evidenceRequirements,
                    affectedComponents: record.scope,
                    evidenceIDs: [],
                    notes: record.constraints
                )
            )
            try updateProjectRecord { $0.addingIssueID(record.workItem.id) }
            try reconcileEpicIssueLinks(epicID: record.epicID, issueID: record.workItem.id)
            try reconcileSprintIssueLinks(sprintID: record.sprintID, issueID: record.workItem.id)
        }
    }

    public func clearActiveSprintID(projectID: AirframeID) throws {
        guard let project = try store.load(AirframeCanonicalProjectRecord.self, id: projectID) else {
            throw AirframeBackendError.missingWorkItem(projectID)
        }
        try store.save(project.clearingActiveSprintID())
    }

    public func clearActiveEpicID(projectID: AirframeID) throws {
        guard let project = try store.load(AirframeCanonicalProjectRecord.self, id: projectID) else {
            throw AirframeBackendError.missingWorkItem(projectID)
        }
        try store.save(project.clearingActiveEpicID())
    }

    public func setActiveSprintID(_ sprintID: AirframeID, projectID: AirframeID) throws {
        guard let project = try store.load(AirframeCanonicalProjectRecord.self, id: projectID) else {
            throw AirframeBackendError.missingWorkItem(projectID)
        }
        try store.save(project.settingActiveSprintID(sprintID))
    }

    public func setActiveEpicID(_ epicID: AirframeID, projectID: AirframeID) throws {
        guard let project = try store.load(AirframeCanonicalProjectRecord.self, id: projectID) else {
            throw AirframeBackendError.missingWorkItem(projectID)
        }
        try store.save(project.settingActiveEpicID(epicID))
    }

    public func restoreEpicToActive(epicID: AirframeID) throws {
        try transitionWorkItem(id: epicID, to: .active)
    }

    public func restoreSprintToActive(sprintID: AirframeID) throws {
        try transitionWorkItem(id: sprintID, to: .active)
    }

    public func reconcileEpicSprintLinks(epicID: AirframeID, sprintID: AirframeID) throws {
        guard let epic = try store.load(AirframeCanonicalEpicRecord.self, id: epicID) else {
            throw AirframeBackendError.missingWorkItem(epicID)
        }
        guard let sprint = try store.load(AirframeCanonicalSprintRecord.self, id: sprintID) else {
            throw AirframeBackendError.missingWorkItem(sprintID)
        }
        try store.save(epic.addingSprintID(sprintID))
        try store.save(sprint.settingEpicID(epicID))
    }

    public func reconcileEpicTaskLinks(epicID: AirframeID?, taskID: AirframeID) throws {
        guard let task = try store.load(AirframeCanonicalTaskRecord.self, id: taskID) else {
            throw AirframeBackendError.missingWorkItem(taskID)
        }
        try moveTask(taskID: taskID, toEpicID: epicID, toSprintID: task.sprintID)
    }

    public func reconcileEpicTaskLinks(epicID: AirframeID, taskID: AirframeID) throws {
        try reconcileEpicTaskLinks(epicID: Optional(epicID), taskID: taskID)
    }

    public func reconcileEpicIssueLinks(epicID: AirframeID?, issueID: AirframeID) throws {
        guard let issue = try store.load(AirframeCanonicalIssueRecord.self, id: issueID) else {
            throw AirframeBackendError.missingWorkItem(issueID)
        }
        try moveIssue(issueID: issueID, toEpicID: epicID, toSprintID: issue.sprintID)
    }

    public func reconcileEpicIssueLinks(epicID: AirframeID, issueID: AirframeID) throws {
        try reconcileEpicIssueLinks(epicID: Optional(epicID), issueID: issueID)
    }

    public func reconcileSprintTaskLinks(sprintID: AirframeID?, taskID: AirframeID) throws {
        guard let task = try store.load(AirframeCanonicalTaskRecord.self, id: taskID) else {
            throw AirframeBackendError.missingWorkItem(taskID)
        }
        try moveTask(taskID: taskID, toEpicID: task.epicID, toSprintID: sprintID)
    }

    public func reconcileSprintTaskLinks(sprintID: AirframeID, taskID: AirframeID) throws {
        try reconcileSprintTaskLinks(sprintID: Optional(sprintID), taskID: taskID)
    }

    public func reconcileSprintIssueLinks(sprintID: AirframeID?, issueID: AirframeID) throws {
        guard let issue = try store.load(AirframeCanonicalIssueRecord.self, id: issueID) else {
            throw AirframeBackendError.missingWorkItem(issueID)
        }
        try moveIssue(issueID: issueID, toEpicID: issue.epicID, toSprintID: sprintID)
    }

    public func reconcileSprintIssueLinks(sprintID: AirframeID, issueID: AirframeID) throws {
        try reconcileSprintIssueLinks(sprintID: Optional(sprintID), issueID: issueID)
    }

    public func moveTask(
        taskID: AirframeID,
        toEpicID epicID: AirframeID?,
        toSprintID sprintID: AirframeID?
    ) throws {
        guard let task = try store.load(AirframeCanonicalTaskRecord.self, id: taskID) else {
            throw AirframeBackendError.missingWorkItem(taskID)
        }
        if let epicID, try store.load(AirframeCanonicalEpicRecord.self, id: epicID) == nil {
            throw AirframeBackendError.missingWorkItem(epicID)
        }
        if let sprintID, try store.load(AirframeCanonicalSprintRecord.self, id: sprintID) == nil {
            throw AirframeBackendError.missingWorkItem(sprintID)
        }

        try removeTaskIDFromEpics(taskID)
        try removeTaskIDFromSprints(taskID)
        try store.save(task.settingEpicID(epicID).settingSprintID(sprintID))

        if let epicID {
            guard let epic = try store.load(AirframeCanonicalEpicRecord.self, id: epicID) else {
                throw AirframeBackendError.missingWorkItem(epicID)
            }
            try store.save(epic.addingTaskID(taskID))
        }
        if let sprintID {
            guard let sprint = try store.load(AirframeCanonicalSprintRecord.self, id: sprintID) else {
                throw AirframeBackendError.missingWorkItem(sprintID)
            }
            try store.save(sprint.addingTaskID(taskID))
        }
    }

    public func moveIssue(
        issueID: AirframeID,
        toEpicID epicID: AirframeID?,
        toSprintID sprintID: AirframeID?
    ) throws {
        guard let issue = try store.load(AirframeCanonicalIssueRecord.self, id: issueID) else {
            throw AirframeBackendError.missingWorkItem(issueID)
        }
        if let epicID, try store.load(AirframeCanonicalEpicRecord.self, id: epicID) == nil {
            throw AirframeBackendError.missingWorkItem(epicID)
        }
        if let sprintID, try store.load(AirframeCanonicalSprintRecord.self, id: sprintID) == nil {
            throw AirframeBackendError.missingWorkItem(sprintID)
        }

        try removeIssueIDFromEpics(issueID)
        try removeIssueIDFromSprints(issueID)
        try store.save(issue.settingEpicID(epicID).settingSprintID(sprintID))

        if let epicID {
            guard let epic = try store.load(AirframeCanonicalEpicRecord.self, id: epicID) else {
                throw AirframeBackendError.missingWorkItem(epicID)
            }
            try store.save(epic.addingIssueID(issueID))
        }
        if let sprintID {
            guard let sprint = try store.load(AirframeCanonicalSprintRecord.self, id: sprintID) else {
                throw AirframeBackendError.missingWorkItem(sprintID)
            }
            try store.save(sprint.addingIssueID(issueID))
        }
    }

    private func removeTaskIDFromEpics(_ taskID: AirframeID) throws {
        try store.list(AirframeCanonicalEpicRecord.self)
            .filter { $0.taskIDs.contains(taskID) }
            .forEach { try store.save($0.removingTaskID(taskID)) }
    }

    private func removeIssueIDFromEpics(_ issueID: AirframeID) throws {
        try store.list(AirframeCanonicalEpicRecord.self)
            .filter { $0.issueIDs.contains(issueID) }
            .forEach { try store.save($0.removingIssueID(issueID)) }
    }

    private func removeTaskIDFromSprints(_ taskID: AirframeID) throws {
        try store.list(AirframeCanonicalSprintRecord.self)
            .filter { $0.taskIDs.contains(taskID) }
            .forEach { try store.save($0.removingTaskID(taskID)) }
    }

    private func removeIssueIDFromSprints(_ issueID: AirframeID) throws {
        try store.list(AirframeCanonicalSprintRecord.self)
            .filter { $0.issueIDs.contains(issueID) }
            .forEach { try store.save($0.removingIssueID(issueID)) }
    }

    public func snapshot(project: AirframeProject) throws -> AirframeCanonicalStateSnapshot {
        let state = try loadState()
        let projectRecord = state.projects.first { $0.id == project.id } ?? AirframeCanonicalProjectRecord(
            id: project.id,
            name: project.name,
            repository: project.repository,
            activeEpicID: project.activeEpicID,
            activeSprintID: project.activeSprintID,
            epicIDs: state.epics.map(\.workItem.id),
            sprintIDs: state.sprints.map(\.workItem.id),
            taskIDs: state.tasks.map(\.workItem.id),
            issueIDs: state.issues.map(\.workItem.id)
        )
        return AirframeCanonicalStateSnapshot(
            project: projectRecord,
            epics: state.epics,
            sprints: state.sprints,
            tasks: state.tasks,
            issues: state.issues
        )
    }

    private func applyActiveSprintPointerSideEffect(
        for sprint: AirframeCanonicalSprintRecord,
        transitioningTo status: AirframeWorkStatus
    ) throws {
        let projects = try store.list(AirframeCanonicalProjectRecord.self)
        switch status {
        case .active:
            guard let project = projects.first(where: { $0.sprintIDs.contains(sprint.workItem.id) }) else {
                return
            }
            try store.save(project.settingActiveSprintID(sprint.workItem.id))
        case .closed:
            try projects
                .filter { $0.activeSprintID == sprint.workItem.id }
                .forEach { try store.save($0.clearingActiveSprintID()) }
        default:
            return
        }
    }

    private func updateProjectRecord(
        _ transform: (AirframeCanonicalProjectRecord) -> AirframeCanonicalProjectRecord
    ) throws {
        guard let project = try store.list(AirframeCanonicalProjectRecord.self).first else {
            throw AirframeBackendError.unwritableStore("canonical store is missing a project record")
        }
        try store.save(transform(project))
    }
}

public final class AirframeCanonicalStoreBackend: @unchecked Sendable, AirframeBackend {
    public let capabilities: AirframeBackendCapabilities = .canonicalStore

    private let repository: AirframeCanonicalStoreRepository

    public init(repository: AirframeCanonicalStoreRepository) {
        self.repository = repository
    }

    public convenience init(rootURL: URL) {
        self.init(repository: AirframeCanonicalStoreRepository(rootURL: rootURL))
    }

    public func listWorkRecords() throws -> [AirframeLocalWorkRecord] {
        try repository.workRecords()
    }

    public func workRecord(id: AirframeID) throws -> AirframeLocalWorkRecord? {
        try listWorkRecords().first { $0.workItem.id == id }
    }

    public func createWorkRecord(_ record: AirframeLocalWorkRecord) throws {
        try repository.createWorkRecord(record)
    }

    public func updateWorkRecord(_ record: AirframeLocalWorkRecord) throws {
        try repository.updateWorkRecord(record)
    }

    public func updateWorkItem(_ workItem: AirframeWorkItem) throws {
        try repository.transitionWorkItem(id: workItem.id, to: workItem.status)
    }

    public func transitionWorkItem(
        id: AirframeID,
        to status: AirframeWorkStatus,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws {
        guard let record = try workRecord(id: id) else {
            throw AirframeBackendError.missingWorkItem(id)
        }
        let transition = AirframeWorkflowTransition(
            workItemID: id,
            kind: record.workItem.kind,
            fromStatus: record.workItem.status,
            toStatus: status,
            operation: AirframeOperation(id: operationID(for: status), category: operationCategory(for: status))
        )
        let decision = AirframeWorkflowTransitionEvaluator().evaluate(
            context: context,
            transition: transition,
            targetProjectID: targetProjectID
        )
        switch decision {
        case .allowed:
            try repository.transitionWorkItem(id: id, to: status)
        case .requiresConfirmation(let reason):
            throw AirframeBackendError.requiresConfirmation(reason)
        case .denied(let reason, let authorityReason):
            if reason == .invalidTransition {
                throw AirframeBackendError.invalidTransition(from: record.workItem.status, to: status)
            }
            throw AirframeBackendError.authorityDenied(authorityReason)
        }
    }

    public func attachEvidence(_ evidence: AirframeEvidence, to workItemID: AirframeID) throws {
        throw AirframeBackendError.readOnlyBackend("direct evidence attachment")
    }

    public func evidence(for workItemID: AirframeID) throws -> [AirframeEvidence] {
        []
    }

    public func taskPacket(for workItemID: AirframeID) throws -> AirframeTaskPacket {
        let records = try listWorkRecords()
        guard let record = records.first(where: { $0.workItem.id == workItemID }) else {
            throw AirframeBackendError.missingWorkItem(workItemID)
        }
        return AirframeCanonicalTaskPacketAssembler().taskPacket(for: record, records: records)
    }

    public func applyHumanVerification(
        action: AirframeHumanVerificationAction,
        to workItemID: AirframeID,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws -> AirframeHumanVerificationResult {
        guard let record = try workRecord(id: workItemID) else {
            throw AirframeBackendError.missingWorkItem(workItemID)
        }
        guard record.workItem.status == .implementedNotVerified else {
            throw AirframeBackendError.invalidTransition(from: record.workItem.status, to: action.resultingStatus)
        }
        let operation = AirframeOperation(id: action.operationID, category: .humanAcceptance)
        let decision = AirframeAuthorityEvaluator().evaluate(
            context: context,
            operation: operation,
            targetProjectID: targetProjectID
        )
        switch decision {
        case .allowed:
            try repository.transitionWorkItem(id: workItemID, to: action.resultingStatus)
            let updated = AirframeWorkItem(
                id: record.workItem.id,
                kind: record.workItem.kind,
                title: record.workItem.title,
                status: action.resultingStatus,
                githubIssue: record.workItem.githubIssue
            )
            return AirframeHumanVerificationResult(action: action, workItem: updated, decision: decision)
        case .requiresConfirmation(let reason):
            throw AirframeBackendError.requiresConfirmation(reason)
        case .denied(let reason):
            throw AirframeBackendError.authorityDenied(reason)
        }
    }

    public func dashboardSummary() throws -> AirframeDashboardSummary {
        try AirframeCanonicalProjectSummary().dashboardSummary(records: listWorkRecords())
    }

    private func operationID(for status: AirframeWorkStatus) -> AirframeID {
        switch status {
        case .proposed: AirframeID("OP-PROPOSE-WORK")
        case .draft: AirframeID("OP-DRAFT-WORK")
        case .backlog: AirframeID("OP-RETURN-TO-BACKLOG")
        case .planning: AirframeID("OP-PLAN-WORK")
        case .active: AirframeID("OP-ACTIVATE-WORK")
        case .review: AirframeID("OP-REVIEW-WORK")
        case .implementedNotVerified: AirframeID("OP-READY-FOR-VERIFICATION")
        case .implementedVerified: AirframeID("OP-HUMAN-VERIFY")
        case .complete: AirframeID("OP-COMPLETE-WORK")
        case .closed: AirframeID("OP-CLOSE-WORK")
        }
    }

    private func operationCategory(for status: AirframeWorkStatus) -> AirframeOperationCategory {
        status == .implementedVerified ? .humanAcceptance : .workflowTransition
    }
}

private extension AirframeCanonicalEpicRecord {
    func updating(from record: AirframeLocalWorkRecord) -> AirframeCanonicalEpicRecord {
        AirframeCanonicalEpicRecord(
            workItem: record.workItem,
            owner: owner,
            goal: goal,
            rationale: rationale,
            startDate: startDate,
            targetCloseDate: targetCloseDate,
            closeDate: record.workItem.status == .closed ? (closeDate ?? isoDateString()) : closeDate,
            scope: record.scope.isEmpty ? scope : record.scope,
            outOfScope: record.constraints.isEmpty ? outOfScope : record.constraints,
            acceptanceCriterionIDs: acceptanceCriterionIDs,
            sprintIDs: sprintIDs,
            taskIDs: taskIDs,
            issueIDs: issueIDs,
            planningDocumentPaths: planningDocumentPaths,
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }

    func updatingStatus(_ status: AirframeWorkStatus) -> AirframeCanonicalEpicRecord {
        AirframeCanonicalEpicRecord(
            workItem: workItem.updatingStatus(status),
            owner: owner,
            goal: goal,
            rationale: rationale,
            startDate: startDate,
            targetCloseDate: targetCloseDate,
            closeDate: status == .closed ? (closeDate ?? isoDateString()) : closeDate,
            scope: scope,
            outOfScope: outOfScope,
            acceptanceCriterionIDs: acceptanceCriterionIDs,
            sprintIDs: sprintIDs,
            taskIDs: taskIDs,
            issueIDs: issueIDs,
            planningDocumentPaths: planningDocumentPaths,
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }

    func addingSprintID(_ sprintID: AirframeID) -> AirframeCanonicalEpicRecord {
        AirframeCanonicalEpicRecord(
            workItem: workItem,
            owner: owner,
            goal: goal,
            rationale: rationale,
            startDate: startDate,
            targetCloseDate: targetCloseDate,
            closeDate: closeDate,
            scope: scope,
            outOfScope: outOfScope,
            acceptanceCriterionIDs: acceptanceCriterionIDs,
            sprintIDs: appendUnique(sprintID, to: sprintIDs),
            taskIDs: taskIDs,
            issueIDs: issueIDs,
            planningDocumentPaths: planningDocumentPaths,
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }

    func addingTaskID(_ taskID: AirframeID) -> AirframeCanonicalEpicRecord {
        AirframeCanonicalEpicRecord(
            workItem: workItem,
            owner: owner,
            goal: goal,
            rationale: rationale,
            startDate: startDate,
            targetCloseDate: targetCloseDate,
            closeDate: closeDate,
            scope: scope,
            outOfScope: outOfScope,
            acceptanceCriterionIDs: acceptanceCriterionIDs,
            sprintIDs: sprintIDs,
            taskIDs: appendUnique(taskID, to: taskIDs),
            issueIDs: issueIDs,
            planningDocumentPaths: planningDocumentPaths,
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }

    func removingTaskID(_ taskID: AirframeID) -> AirframeCanonicalEpicRecord {
        AirframeCanonicalEpicRecord(
            workItem: workItem,
            owner: owner,
            goal: goal,
            rationale: rationale,
            startDate: startDate,
            targetCloseDate: targetCloseDate,
            closeDate: closeDate,
            scope: scope,
            outOfScope: outOfScope,
            acceptanceCriterionIDs: acceptanceCriterionIDs,
            sprintIDs: sprintIDs,
            taskIDs: taskIDs.filter { $0 != taskID },
            issueIDs: issueIDs,
            planningDocumentPaths: planningDocumentPaths,
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }

    func addingIssueID(_ issueID: AirframeID) -> AirframeCanonicalEpicRecord {
        AirframeCanonicalEpicRecord(
            workItem: workItem,
            owner: owner,
            goal: goal,
            rationale: rationale,
            startDate: startDate,
            targetCloseDate: targetCloseDate,
            closeDate: closeDate,
            scope: scope,
            outOfScope: outOfScope,
            acceptanceCriterionIDs: acceptanceCriterionIDs,
            sprintIDs: sprintIDs,
            taskIDs: taskIDs,
            issueIDs: appendUnique(issueID, to: issueIDs),
            planningDocumentPaths: planningDocumentPaths,
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }

    func removingIssueID(_ issueID: AirframeID) -> AirframeCanonicalEpicRecord {
        AirframeCanonicalEpicRecord(
            workItem: workItem,
            owner: owner,
            goal: goal,
            rationale: rationale,
            startDate: startDate,
            targetCloseDate: targetCloseDate,
            closeDate: closeDate,
            scope: scope,
            outOfScope: outOfScope,
            acceptanceCriterionIDs: acceptanceCriterionIDs,
            sprintIDs: sprintIDs,
            taskIDs: taskIDs,
            issueIDs: issueIDs.filter { $0 != issueID },
            planningDocumentPaths: planningDocumentPaths,
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }
}

private extension AirframeCanonicalProjectRecord {
    func settingActiveSprintID(_ sprintID: AirframeID) -> AirframeCanonicalProjectRecord {
        AirframeCanonicalProjectRecord(
            id: id,
            name: name,
            repository: repository,
            activeEpicID: activeEpicID,
            activeSprintID: sprintID,
            epicIDs: epicIDs,
            sprintIDs: sprintIDs,
            taskIDs: taskIDs,
            issueIDs: issueIDs,
            backendMappingIDs: backendMappingIDs,
            metadata: metadata.updatingTimestamp()
        )
    }

    func clearingActiveSprintID() -> AirframeCanonicalProjectRecord {
        AirframeCanonicalProjectRecord(
            id: id,
            name: name,
            repository: repository,
            activeEpicID: activeEpicID,
            activeSprintID: nil,
            epicIDs: epicIDs,
            sprintIDs: sprintIDs,
            taskIDs: taskIDs,
            issueIDs: issueIDs,
            backendMappingIDs: backendMappingIDs,
            metadata: metadata.updatingTimestamp()
        )
    }

    func clearingActiveEpicID() -> AirframeCanonicalProjectRecord {
        AirframeCanonicalProjectRecord(
            id: id,
            name: name,
            repository: repository,
            activeEpicID: nil,
            activeSprintID: activeSprintID,
            epicIDs: epicIDs,
            sprintIDs: sprintIDs,
            taskIDs: taskIDs,
            issueIDs: issueIDs,
            backendMappingIDs: backendMappingIDs,
            metadata: metadata.updatingTimestamp()
        )
    }

    func settingActiveEpicID(_ epicID: AirframeID) -> AirframeCanonicalProjectRecord {
        AirframeCanonicalProjectRecord(
            id: id,
            name: name,
            repository: repository,
            activeEpicID: epicID,
            activeSprintID: activeSprintID,
            epicIDs: epicIDs,
            sprintIDs: sprintIDs,
            taskIDs: taskIDs,
            issueIDs: issueIDs,
            backendMappingIDs: backendMappingIDs,
            metadata: metadata.updatingTimestamp()
        )
    }

    func addingEpicID(_ epicID: AirframeID) -> AirframeCanonicalProjectRecord {
        AirframeCanonicalProjectRecord(
            id: id,
            name: name,
            repository: repository,
            activeEpicID: activeEpicID,
            activeSprintID: activeSprintID,
            epicIDs: appendUnique(epicID, to: epicIDs),
            sprintIDs: sprintIDs,
            taskIDs: taskIDs,
            issueIDs: issueIDs,
            backendMappingIDs: backendMappingIDs,
            metadata: metadata.updatingTimestamp()
        )
    }

    func addingSprintID(_ sprintID: AirframeID) -> AirframeCanonicalProjectRecord {
        AirframeCanonicalProjectRecord(
            id: id,
            name: name,
            repository: repository,
            activeEpicID: activeEpicID,
            activeSprintID: activeSprintID,
            epicIDs: epicIDs,
            sprintIDs: appendUnique(sprintID, to: sprintIDs),
            taskIDs: taskIDs,
            issueIDs: issueIDs,
            backendMappingIDs: backendMappingIDs,
            metadata: metadata.updatingTimestamp()
        )
    }

    func addingTaskID(_ taskID: AirframeID) -> AirframeCanonicalProjectRecord {
        AirframeCanonicalProjectRecord(
            id: id,
            name: name,
            repository: repository,
            activeEpicID: activeEpicID,
            activeSprintID: activeSprintID,
            epicIDs: epicIDs,
            sprintIDs: sprintIDs,
            taskIDs: appendUnique(taskID, to: taskIDs),
            issueIDs: issueIDs,
            backendMappingIDs: backendMappingIDs,
            metadata: metadata.updatingTimestamp()
        )
    }

    func addingIssueID(_ issueID: AirframeID) -> AirframeCanonicalProjectRecord {
        AirframeCanonicalProjectRecord(
            id: id,
            name: name,
            repository: repository,
            activeEpicID: activeEpicID,
            activeSprintID: activeSprintID,
            epicIDs: epicIDs,
            sprintIDs: sprintIDs,
            taskIDs: taskIDs,
            issueIDs: appendUnique(issueID, to: issueIDs),
            backendMappingIDs: backendMappingIDs,
            metadata: metadata.updatingTimestamp()
        )
    }
}

private extension AirframeCanonicalSprintRecord {
    func updating(from record: AirframeLocalWorkRecord) -> AirframeCanonicalSprintRecord {
        AirframeCanonicalSprintRecord(
            workItem: record.workItem,
            epicID: record.epicID,
            goal: record.scope.first ?? goal,
            startDate: startDate,
            endDate: record.workItem.status == .review || record.workItem.status == .closed ? (endDate ?? isoDateString()) : endDate,
            capacity: capacity,
            taskIDs: taskIDs,
            issueIDs: issueIDs,
            notes: record.constraints.isEmpty ? notes : record.constraints,
            metadata: metadata.updatingTimestamp()
        )
    }

    func updatingStatus(_ status: AirframeWorkStatus) -> AirframeCanonicalSprintRecord {
        AirframeCanonicalSprintRecord(
            workItem: workItem.updatingStatus(status),
            epicID: epicID,
            goal: goal,
            startDate: startDate,
            endDate: status == .review || status == .closed ? (endDate ?? isoDateString()) : endDate,
            capacity: capacity,
            taskIDs: taskIDs,
            issueIDs: issueIDs,
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }

    func settingEpicID(_ epicID: AirframeID) -> AirframeCanonicalSprintRecord {
        AirframeCanonicalSprintRecord(
            workItem: workItem,
            epicID: epicID,
            goal: goal,
            startDate: startDate,
            endDate: endDate,
            capacity: capacity,
            taskIDs: taskIDs,
            issueIDs: issueIDs,
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }

    func addingTaskID(_ taskID: AirframeID) -> AirframeCanonicalSprintRecord {
        AirframeCanonicalSprintRecord(
            workItem: workItem,
            epicID: epicID,
            goal: goal,
            startDate: startDate,
            endDate: endDate,
            capacity: capacity,
            taskIDs: appendUnique(taskID, to: taskIDs),
            issueIDs: issueIDs,
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }

    func removingTaskID(_ taskID: AirframeID) -> AirframeCanonicalSprintRecord {
        AirframeCanonicalSprintRecord(
            workItem: workItem,
            epicID: epicID,
            goal: goal,
            startDate: startDate,
            endDate: endDate,
            capacity: capacity,
            taskIDs: taskIDs.filter { $0 != taskID },
            issueIDs: issueIDs,
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }

    func addingIssueID(_ issueID: AirframeID) -> AirframeCanonicalSprintRecord {
        AirframeCanonicalSprintRecord(
            workItem: workItem,
            epicID: epicID,
            goal: goal,
            startDate: startDate,
            endDate: endDate,
            capacity: capacity,
            taskIDs: taskIDs,
            issueIDs: appendUnique(issueID, to: issueIDs),
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }

    func removingIssueID(_ issueID: AirframeID) -> AirframeCanonicalSprintRecord {
        AirframeCanonicalSprintRecord(
            workItem: workItem,
            epicID: epicID,
            goal: goal,
            startDate: startDate,
            endDate: endDate,
            capacity: capacity,
            taskIDs: taskIDs,
            issueIDs: issueIDs.filter { $0 != issueID },
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }
}

private extension AirframeCanonicalTaskRecord {
    func updating(from record: AirframeLocalWorkRecord) -> AirframeCanonicalTaskRecord {
        AirframeCanonicalTaskRecord(
            workItem: record.workItem,
            component: component,
            priority: record.priority,
            rationale: rationale,
            epicID: record.epicID,
            sprintID: record.sprintID,
            dateRequested: dateRequested,
            dateImplemented: record.workItem.status == .implementedNotVerified ? (dateImplemented ?? isoDateString()) : dateImplemented,
            dateVerified: record.workItem.status == .implementedVerified ? (dateVerified ?? isoDateString()) : dateVerified,
            currentBehavior: currentBehavior,
            desiredBehavior: desiredBehavior,
            requirementIDs: requirementIDs,
            acceptanceCriteria: record.acceptanceCriteria.isEmpty ? acceptanceCriteria : record.acceptanceCriteria,
            designApproach: designApproach,
            componentsAffected: record.scope.isEmpty ? componentsAffected : record.scope,
            implementationDetails: implementationDetails,
            evidenceIDs: evidenceIDs,
            testSteps: record.evidenceRequirements.isEmpty ? testSteps : record.evidenceRequirements,
            notes: record.constraints.isEmpty ? notes : record.constraints,
            metadata: metadata.updatingTimestamp()
        )
    }

    func updatingStatus(_ status: AirframeWorkStatus) -> AirframeCanonicalTaskRecord {
        AirframeCanonicalTaskRecord(
            workItem: workItem.updatingStatus(status),
            component: component,
            priority: priority,
            rationale: rationale,
            epicID: epicID,
            sprintID: sprintID,
            dateRequested: dateRequested,
            dateImplemented: dateImplemented,
            dateVerified: status == .implementedVerified ? (dateVerified ?? isoDateString()) : dateVerified,
            currentBehavior: currentBehavior,
            desiredBehavior: desiredBehavior,
            requirementIDs: requirementIDs,
            acceptanceCriteria: acceptanceCriteria,
            designApproach: designApproach,
            componentsAffected: componentsAffected,
            implementationDetails: implementationDetails,
            evidenceIDs: evidenceIDs,
            testSteps: testSteps,
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }

    func settingEpicID(_ epicID: AirframeID?) -> AirframeCanonicalTaskRecord {
        AirframeCanonicalTaskRecord(
            workItem: workItem,
            component: component,
            priority: priority,
            rationale: rationale,
            epicID: epicID,
            sprintID: sprintID,
            dateRequested: dateRequested,
            dateImplemented: dateImplemented,
            dateVerified: dateVerified,
            currentBehavior: currentBehavior,
            desiredBehavior: desiredBehavior,
            requirementIDs: requirementIDs,
            acceptanceCriteria: acceptanceCriteria,
            designApproach: designApproach,
            componentsAffected: componentsAffected,
            implementationDetails: implementationDetails,
            evidenceIDs: evidenceIDs,
            testSteps: testSteps,
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }

    func settingSprintID(_ sprintID: AirframeID?) -> AirframeCanonicalTaskRecord {
        AirframeCanonicalTaskRecord(
            workItem: workItem,
            component: component,
            priority: priority,
            rationale: rationale,
            epicID: epicID,
            sprintID: sprintID,
            dateRequested: dateRequested,
            dateImplemented: dateImplemented,
            dateVerified: dateVerified,
            currentBehavior: currentBehavior,
            desiredBehavior: desiredBehavior,
            requirementIDs: requirementIDs,
            acceptanceCriteria: acceptanceCriteria,
            designApproach: designApproach,
            componentsAffected: componentsAffected,
            implementationDetails: implementationDetails,
            evidenceIDs: evidenceIDs,
            testSteps: testSteps,
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }
}

private extension AirframeCanonicalIssueRecord {
    func updating(from record: AirframeLocalWorkRecord) -> AirframeCanonicalIssueRecord {
        AirframeCanonicalIssueRecord(
            workItem: record.workItem,
            severity: record.priority,
            observedBehavior: observedBehavior,
            expectedBehavior: expectedBehavior,
            epicID: record.epicID,
            sprintID: record.sprintID,
            dateReported: dateReported,
            dateResolved: record.workItem.status == .implementedNotVerified ? (dateResolved ?? isoDateString()) : dateResolved,
            dateVerified: record.workItem.status == .implementedVerified ? (dateVerified ?? isoDateString()) : dateVerified,
            reproductionSteps: record.evidenceRequirements.isEmpty ? reproductionSteps : record.evidenceRequirements,
            affectedComponents: record.scope.isEmpty ? affectedComponents : record.scope,
            evidenceIDs: evidenceIDs,
            notes: record.constraints.isEmpty ? notes : record.constraints,
            metadata: metadata.updatingTimestamp()
        )
    }

    func updatingStatus(_ status: AirframeWorkStatus) -> AirframeCanonicalIssueRecord {
        AirframeCanonicalIssueRecord(
            workItem: workItem.updatingStatus(status),
            severity: severity,
            observedBehavior: observedBehavior,
            expectedBehavior: expectedBehavior,
            epicID: epicID,
            sprintID: sprintID,
            dateReported: dateReported,
            dateResolved: status == .implementedNotVerified ? (dateResolved ?? isoDateString()) : dateResolved,
            dateVerified: status == .implementedVerified ? (dateVerified ?? isoDateString()) : dateVerified,
            reproductionSteps: reproductionSteps,
            affectedComponents: affectedComponents,
            evidenceIDs: evidenceIDs,
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }

    func settingEpicID(_ epicID: AirframeID?) -> AirframeCanonicalIssueRecord {
        AirframeCanonicalIssueRecord(
            workItem: workItem,
            severity: severity,
            observedBehavior: observedBehavior,
            expectedBehavior: expectedBehavior,
            epicID: epicID,
            sprintID: sprintID,
            dateReported: dateReported,
            dateResolved: dateResolved,
            dateVerified: dateVerified,
            reproductionSteps: reproductionSteps,
            affectedComponents: affectedComponents,
            evidenceIDs: evidenceIDs,
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }

    func settingSprintID(_ sprintID: AirframeID?) -> AirframeCanonicalIssueRecord {
        AirframeCanonicalIssueRecord(
            workItem: workItem,
            severity: severity,
            observedBehavior: observedBehavior,
            expectedBehavior: expectedBehavior,
            epicID: epicID,
            sprintID: sprintID,
            dateReported: dateReported,
            dateResolved: dateResolved,
            dateVerified: dateVerified,
            reproductionSteps: reproductionSteps,
            affectedComponents: affectedComponents,
            evidenceIDs: evidenceIDs,
            notes: notes,
            metadata: metadata.updatingTimestamp()
        )
    }
}

private func appendUnique(_ id: AirframeID, to ids: [AirframeID]) -> [AirframeID] {
    ids.contains(id) ? ids : ids + [id]
}

private extension AirframeWorkItem {
    func updatingStatus(_ status: AirframeWorkStatus) -> AirframeWorkItem {
        AirframeWorkItem(id: id, kind: kind, title: title, status: status, githubIssue: githubIssue)
    }
}

private extension AirframeCanonicalRecordMetadata {
    func updatingTimestamp() -> AirframeCanonicalRecordMetadata {
        AirframeCanonicalRecordMetadata(
            schemaVersion: schemaVersion,
            createdAt: createdAt,
            updatedAt: Date(),
            source: source
        )
    }
}

private func isoDateString(_ date: Date = Date()) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withFullDate]
    return formatter.string(from: date)
}
