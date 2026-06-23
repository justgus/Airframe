public struct AirframeCanonicalStateSnapshotBuilder: Sendable {
    public init() {}

    public func snapshot(
        project: AirframeProject,
        records: [AirframeLocalWorkRecord]
    ) -> AirframeCanonicalStateSnapshot {
        AirframeCanonicalStateSnapshot(
            project: AirframeCanonicalProjectRecord(
                id: project.id,
                name: project.name,
                repository: project.repository,
                activeEpicID: project.activeEpicID,
                activeSprintID: project.activeSprintID,
                epicIDs: records.filter { $0.workItem.kind == .epic }.map(\.workItem.id),
                sprintIDs: records.filter { $0.workItem.kind == .sprint }.map(\.workItem.id),
                taskIDs: records.filter { $0.workItem.kind == .task }.map(\.workItem.id),
                issueIDs: records.filter { $0.workItem.kind == .issue }.map(\.workItem.id)
            ),
            epics: records.compactMap(canonicalEpicRecord),
            sprints: records.compactMap(canonicalSprintRecord),
            tasks: records.compactMap(canonicalTaskRecord),
            issues: records.compactMap(canonicalIssueRecord)
        )
    }

    private func canonicalEpicRecord(_ record: AirframeLocalWorkRecord) -> AirframeCanonicalEpicRecord? {
        guard record.workItem.kind == .epic else { return nil }
        return AirframeCanonicalEpicRecord(
            workItem: record.workItem,
            owner: "",
            goal: "",
            rationale: "",
            sprintIDs: record.sprintID.map { [$0] } ?? []
        )
    }

    private func canonicalSprintRecord(_ record: AirframeLocalWorkRecord) -> AirframeCanonicalSprintRecord? {
        guard record.workItem.kind == .sprint else { return nil }
        return AirframeCanonicalSprintRecord(
            workItem: record.workItem,
            epicID: record.epicID,
            goal: ""
        )
    }

    private func canonicalTaskRecord(_ record: AirframeLocalWorkRecord) -> AirframeCanonicalTaskRecord? {
        guard record.workItem.kind == .task else { return nil }
        return AirframeCanonicalTaskRecord(
            workItem: record.workItem,
            component: "",
            priority: record.priority,
            rationale: "",
            epicID: record.epicID,
            sprintID: record.sprintID,
            acceptanceCriteria: record.acceptanceCriteria,
            componentsAffected: record.scope,
            testSteps: record.evidenceRequirements,
            notes: record.constraints
        )
    }

    private func canonicalIssueRecord(_ record: AirframeLocalWorkRecord) -> AirframeCanonicalIssueRecord? {
        guard record.workItem.kind == .issue else { return nil }
        return AirframeCanonicalIssueRecord(
            workItem: record.workItem,
            severity: record.priority,
            observedBehavior: "",
            expectedBehavior: "",
            epicID: record.epicID,
            sprintID: record.sprintID
        )
    }
}
