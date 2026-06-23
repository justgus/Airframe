public struct AirframeCanonicalProjectSummary: Sendable {
    public init() {}

    public func dashboardSummary(
        epics: [AirframeCanonicalEpicRecord] = [],
        sprints: [AirframeCanonicalSprintRecord] = [],
        tasks: [AirframeCanonicalTaskRecord],
        issues: [AirframeCanonicalIssueRecord],
        evidence: [AirframeCanonicalEvidenceSummaryRecord] = []
    ) -> AirframeDashboardSummary {
        let sortedActiveTasks = tasks
            .map(\.workItem)
            .filter { $0.status == .active }
            .sorted { $0.id.rawValue < $1.id.rawValue }

        return AirframeDashboardSummary(
            totalWorkItemCount: epics.count + sprints.count + tasks.count + issues.count,
            activeTaskCount: tasks.filter { $0.workItem.status == .active }.count,
            unverifiedTaskCount: tasks.filter { $0.workItem.status == .implementedNotVerified }.count,
            verifiedTaskCount: tasks.filter { $0.workItem.status == .implementedVerified }.count,
            issueCount: issues.count,
            nextTask: sortedActiveTasks.first,
            recentEvidenceCount: evidence.count
        )
    }

    public func dashboardSummary(
        records: [AirframeLocalWorkRecord],
        evidence: [AirframeEvidence] = []
    ) -> AirframeDashboardSummary {
        dashboardSummary(
            epics: records.compactMap(canonicalEpicRecord),
            sprints: records.compactMap(canonicalSprintRecord),
            tasks: records.compactMap(canonicalTaskRecord),
            issues: records.compactMap(canonicalIssueRecord),
            evidence: evidence.map(canonicalEvidenceRecord)
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
            acceptanceCriteria: record.acceptanceCriteria
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

    private func canonicalEvidenceRecord(_ evidence: AirframeEvidence) -> AirframeCanonicalEvidenceSummaryRecord {
        AirframeCanonicalEvidenceSummaryRecord(
            id: evidence.id,
            workItemIDs: [],
            summary: evidence.summary,
            result: .informational,
            artifactReferences: [evidence.artifact]
        )
    }
}
