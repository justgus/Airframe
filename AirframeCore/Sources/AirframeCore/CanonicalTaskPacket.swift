public struct AirframeCanonicalTaskPacketAssembler: Sendable {
    public init() {}

    public func taskPacket(
        for task: AirframeCanonicalTaskRecord,
        epics: [AirframeCanonicalEpicRecord] = [],
        sprints: [AirframeCanonicalSprintRecord] = [],
        issues: [AirframeCanonicalIssueRecord] = [],
        evidence: [AirframeCanonicalEvidenceSummaryRecord] = [],
        reportFormat: String = "Summarize changes, verification commands, and residual risks."
    ) -> AirframeTaskPacket {
        let relatedEvidence = evidence
            .filter { $0.workItemIDs.contains(task.workItem.id) }
            .sorted { $0.id.rawValue < $1.id.rawValue }
            .map(airframeEvidence)

        return AirframeTaskPacket(
            workItem: task.workItem,
            objective: task.workItem.title,
            scope: task.componentsAffected,
            acceptanceCriteria: task.acceptanceCriteria,
            constraints: task.notes,
            evidenceRequirements: task.testSteps,
            protectedPaths: [],
            reportFormat: reportFormat,
            existingEvidence: relatedEvidence,
            diagnostics: relationshipDiagnostics(for: task, epics: epics, sprints: sprints, issues: issues)
        )
    }

    public func taskPacket(
        for record: AirframeLocalWorkRecord,
        records: [AirframeLocalWorkRecord],
        evidence: [AirframeEvidence] = []
    ) -> AirframeTaskPacket {
        let canonicalTask = canonicalTaskRecord(record)
        let canonicalEvidence = evidence.map { canonicalEvidenceRecord($0, ownerID: record.workItem.id) }
        let packet = taskPacket(
            for: canonicalTask,
            epics: records.compactMap(canonicalEpicRecord),
            sprints: records.compactMap(canonicalSprintRecord),
            issues: records.compactMap(canonicalIssueRecord),
            evidence: canonicalEvidence,
            reportFormat: record.reportFormat
        )

        return AirframeTaskPacket(
            workItem: packet.workItem,
            objective: packet.objective,
            scope: record.scope,
            acceptanceCriteria: record.acceptanceCriteria,
            constraints: record.constraints,
            evidenceRequirements: record.evidenceRequirements,
            protectedPaths: record.protectedPaths,
            reportFormat: record.reportFormat,
            existingEvidence: evidence.sorted { $0.id.rawValue < $1.id.rawValue },
            diagnostics: packet.diagnostics
        )
    }

    private func relationshipDiagnostics(
        for task: AirframeCanonicalTaskRecord,
        epics: [AirframeCanonicalEpicRecord],
        sprints: [AirframeCanonicalSprintRecord],
        issues: [AirframeCanonicalIssueRecord]
    ) -> [AirframeCanonicalDiagnostic] {
        let epicsByID = Dictionary(uniqueKeysWithValues: epics.map { ($0.workItem.id, $0) })
        let sprintsByID = Dictionary(uniqueKeysWithValues: sprints.map { ($0.workItem.id, $0) })
        _ = issues
        var diagnostics: [AirframeCanonicalDiagnostic] = []

        if let epicID = task.epicID {
            if let epic = epicsByID[epicID] {
                if !epic.taskIDs.isEmpty, !epic.taskIDs.contains(task.workItem.id) {
                    diagnostics.append(
                        AirframeCanonicalDiagnostic(
                            severity: .warning,
                            reasonCode: .epicTaskRelationshipDrift,
                            affectedIDs: [epicID, task.workItem.id],
                            message: "Task \(task.workItem.id.rawValue) references Epic \(epicID.rawValue), but the Epic does not reference the Task."
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
                            message: "Task \(task.workItem.id.rawValue) references Sprint \(sprintID.rawValue), but the Sprint does not reference the Task."
                        )
                    )
                }
                if let sprintEpicID = sprint.epicID, let taskEpicID = task.epicID, sprintEpicID != taskEpicID {
                    diagnostics.append(
                        AirframeCanonicalDiagnostic(
                            severity: .warning,
                            reasonCode: .epicSprintRelationshipDrift,
                            affectedIDs: [taskEpicID, sprintID],
                            message: "Task \(task.workItem.id.rawValue) references Epic \(taskEpicID.rawValue), but Sprint \(sprintID.rawValue) references Epic \(sprintEpicID.rawValue)."
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

        return diagnostics.sorted {
            $0.reasonCode.rawValue == $1.reasonCode.rawValue
                ? $0.affectedIDs.map(\.rawValue).joined() < $1.affectedIDs.map(\.rawValue).joined()
                : $0.reasonCode.rawValue < $1.reasonCode.rawValue
        }
    }

    private func canonicalTaskRecord(_ record: AirframeLocalWorkRecord) -> AirframeCanonicalTaskRecord {
        AirframeCanonicalTaskRecord(
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

    private func canonicalEvidenceRecord(
        _ evidence: AirframeEvidence,
        ownerID: AirframeID
    ) -> AirframeCanonicalEvidenceSummaryRecord {
        AirframeCanonicalEvidenceSummaryRecord(
            id: evidence.id,
            workItemIDs: [ownerID],
            summary: evidence.summary,
            result: .informational,
            artifactReferences: [evidence.artifact]
        )
    }

    private func airframeEvidence(_ evidence: AirframeCanonicalEvidenceSummaryRecord) -> AirframeEvidence {
        AirframeEvidence(
            id: evidence.id,
            summary: evidence.summary,
            artifact: evidence.artifactReferences.first ?? evidence.command ?? "canonical-evidence"
        )
    }
}
