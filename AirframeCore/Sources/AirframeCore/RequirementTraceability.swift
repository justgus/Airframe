import Foundation

public enum AirframeRequirementTraceTargetKind: String, Codable, Equatable, Sendable {
    case requirement
    case acceptanceCriterion
    case task
    case issue
    case epic
    case sprint
    case evidence
    case test
    case design
    case source
    case commit
    case revision
}

public enum AirframeRequirementGapKind: String, Codable, Equatable, Sendable {
    case missingImplementationTrace
    case missingVerificationEvidence
    case missingValidationEvidence
    case missingReleaseScope
}

public struct AirframeRequirementTraceSummary: Codable, Equatable, Sendable {
    public let requirementID: AirframeID
    public let revisionIDs: [AirframeID]
    public let acceptanceCriterionIDs: [AirframeID]
    public let targetKinds: [String]
    public let workItemIDs: [AirframeID]
    public let evidenceIDs: [AirframeID]
    public let traceCount: Int

    public var hasWorkItemTrace: Bool { !workItemIDs.isEmpty }
    public var hasAcceptanceCriterionTrace: Bool { !acceptanceCriterionIDs.isEmpty }
    public var hasEvidenceTrace: Bool { !evidenceIDs.isEmpty }

    public init(
        requirementID: AirframeID,
        revisionIDs: [AirframeID],
        acceptanceCriterionIDs: [AirframeID] = [],
        targetKinds: [String],
        workItemIDs: [AirframeID],
        evidenceIDs: [AirframeID],
        traceCount: Int
    ) {
        self.requirementID = requirementID
        self.revisionIDs = revisionIDs
        self.acceptanceCriterionIDs = acceptanceCriterionIDs
        self.targetKinds = targetKinds
        self.workItemIDs = workItemIDs
        self.evidenceIDs = evidenceIDs
        self.traceCount = traceCount
    }
}

public struct AirframeRequirementCoverageSummary: Codable, Equatable, Sendable {
    public let totalRequirementCount: Int
    public let assignedRequirementCount: Int
    public let implementedRequirementCount: Int
    public let verifiedRequirementCount: Int
    public let unassignedRequirementCount: Int
}

public struct AirframeRequirementTraceGap: Codable, Equatable, Sendable {
    public let requirementID: AirframeID
    public let kind: AirframeRequirementGapKind
    public let message: String
    public let isBlocking: Bool

    public init(
        requirementID: AirframeID,
        kind: AirframeRequirementGapKind,
        message: String,
        isBlocking: Bool = true
    ) {
        self.requirementID = requirementID
        self.kind = kind
        self.message = message
        self.isBlocking = isBlocking
    }
}

public struct AirframeRequirementReleaseGateSummary: Codable, Equatable, Sendable {
    public let releaseScope: String?
    public let inScopeRequirementIDs: [AirframeID]
    public let implementedCount: Int
    public let verifiedCount: Int
    public let validatedCount: Int
    public let deferredCount: Int
    public let waivedCount: Int
    public let blockedRequirementIDs: [AirframeID]
    public let blockingReasons: [String]

    public var canClose: Bool { blockedRequirementIDs.isEmpty }
    public var blockedCount: Int { blockedRequirementIDs.count }

    public init(
        releaseScope: String?,
        inScopeRequirementIDs: [AirframeID],
        implementedCount: Int,
        verifiedCount: Int,
        validatedCount: Int,
        deferredCount: Int,
        waivedCount: Int,
        blockedRequirementIDs: [AirframeID],
        blockingReasons: [String]
    ) {
        self.releaseScope = releaseScope
        self.inScopeRequirementIDs = inScopeRequirementIDs
        self.implementedCount = implementedCount
        self.verifiedCount = verifiedCount
        self.validatedCount = validatedCount
        self.deferredCount = deferredCount
        self.waivedCount = waivedCount
        self.blockedRequirementIDs = blockedRequirementIDs
        self.blockingReasons = blockingReasons
    }
}

public struct AirframeRequirementTraceabilityIndex: Sendable {
    public let requirements: [AirframeCanonicalRequirementRecord]
    public let revisions: [AirframeCanonicalRequirementRevisionRecord]
    public let evidence: [AirframeCanonicalEvidenceSummaryRecord]
    public let acceptanceCriteria: [AirframeCanonicalAcceptanceCriterionRecord]
    public let epics: [AirframeCanonicalEpicRecord]
    public let sprints: [AirframeCanonicalSprintRecord]
    public let tasks: [AirframeCanonicalTaskRecord]
    public let issues: [AirframeCanonicalIssueRecord]

    private let requirementsByID: [AirframeID: AirframeCanonicalRequirementRecord]
    private let revisionsByRequirementID: [AirframeID: [AirframeCanonicalRequirementRevisionRecord]]
    private let evidenceByID: [AirframeID: AirframeCanonicalEvidenceSummaryRecord]
    private let acceptanceCriteriaByID: [AirframeID: AirframeCanonicalAcceptanceCriterionRecord]

    public init(
        requirements: [AirframeCanonicalRequirementRecord] = [],
        revisions: [AirframeCanonicalRequirementRevisionRecord] = [],
        evidence: [AirframeCanonicalEvidenceSummaryRecord] = [],
        acceptanceCriteria: [AirframeCanonicalAcceptanceCriterionRecord] = [],
        epics: [AirframeCanonicalEpicRecord] = [],
        sprints: [AirframeCanonicalSprintRecord] = [],
        tasks: [AirframeCanonicalTaskRecord] = [],
        issues: [AirframeCanonicalIssueRecord] = []
    ) {
        self.requirements = requirements.sorted { $0.id.rawValue < $1.id.rawValue }
        self.revisions = revisions.sorted {
            $0.requirementID.rawValue == $1.requirementID.rawValue
                ? $0.revisionNumber == $1.revisionNumber
                    ? $0.id.rawValue < $1.id.rawValue
                    : $0.revisionNumber < $1.revisionNumber
                : $0.requirementID.rawValue < $1.requirementID.rawValue
        }
        self.evidence = evidence.sorted { $0.id.rawValue < $1.id.rawValue }
        self.acceptanceCriteria = acceptanceCriteria.sorted { $0.id.rawValue < $1.id.rawValue }
        self.epics = epics.sorted { $0.workItem.id.rawValue < $1.workItem.id.rawValue }
        self.sprints = sprints.sorted { $0.workItem.id.rawValue < $1.workItem.id.rawValue }
        self.tasks = tasks.sorted { $0.workItem.id.rawValue < $1.workItem.id.rawValue }
        self.issues = issues.sorted { $0.workItem.id.rawValue < $1.workItem.id.rawValue }
        self.requirementsByID = Dictionary(uniqueKeysWithValues: self.requirements.map { ($0.id, $0) })
        self.revisionsByRequirementID = Dictionary(grouping: self.revisions, by: \.requirementID)
        self.evidenceByID = Dictionary(uniqueKeysWithValues: self.evidence.map { ($0.id, $0) })
        self.acceptanceCriteriaByID = Dictionary(uniqueKeysWithValues: self.acceptanceCriteria.map { ($0.id, $0) })
    }

    public func revisionHistory(for requirementID: AirframeID) -> [AirframeCanonicalRequirementRevisionRecord] {
        revisionsByRequirementID[requirementID, default: []]
    }

    public func requirements(for workItemID: AirframeID) -> [AirframeCanonicalRequirementRecord] {
        requirementIDs(for: workItemID)
            .compactMap { requirementsByID[$0] }
            .sorted { $0.id.rawValue < $1.id.rawValue }
    }

    public func requirementIDs(for workItemID: AirframeID) -> [AirframeID] {
        var ids = Set<AirframeID>()

        for task in tasks where task.workItem.id == workItemID {
            ids.formUnion(task.requirementIDs)
        }
        for criterion in acceptanceCriteria where criterion.id == workItemID || criterion.ownerID == workItemID {
            ids.formUnion(requirements(matching: criterion))
        }
        for issue in issues where issue.workItem.id == workItemID {
            _ = issue
        }
        for evidenceRecord in evidence where evidenceRecord.id == workItemID {
            ids.formUnion(evidenceRecord.requirementIDs)
        }
        for requirement in requirements {
            for link in requirement.traceLinks where link.targetID == workItemID.rawValue {
                ids.insert(requirement.id)
            }
        }
        for requirement in requirements where inferredTraceSummary(for: requirement.id).acceptanceCriterionIDs.contains(workItemID) {
            ids.insert(requirement.id)
        }

        return ids.sorted { $0.rawValue < $1.rawValue }
    }

    public func traceSummary(for requirementID: AirframeID) -> AirframeRequirementTraceSummary {
        let requirement = requirementsByID[requirementID]
        let revisionIDs = revisionHistory(for: requirementID).map(\.id)
        var workItemIDs = Set<AirframeID>()
        var evidenceIDs = Set<AirframeID>()
        var acceptanceCriterionIDs = Set<AirframeID>()
        var targetKinds = Set<String>()

        if let requirement {
            for link in requirement.traceLinks {
                targetKinds.insert(link.targetKind)
                if let targetKind = AirframeRequirementTraceTargetKind(rawValue: link.targetKind) {
                    switch targetKind {
                    case .acceptanceCriterion:
                        acceptanceCriterionIDs.insert(AirframeID(link.targetID))
                    case .task, .issue, .epic, .sprint:
                        workItemIDs.insert(AirframeID(link.targetID))
                    case .evidence:
                        evidenceIDs.insert(AirframeID(link.targetID))
                    case .revision:
                        _ = link
                    case .requirement, .test, .design, .source, .commit:
                        break
                    }
                }
            }
        }

        for task in tasks where task.requirementIDs.contains(requirementID) {
            workItemIDs.insert(task.workItem.id)
        }
        for issue in issues where issue.evidenceIDs.contains(where: { evidenceByID[$0]?.requirementIDs.contains(requirementID) == true }) {
            workItemIDs.insert(issue.workItem.id)
        }
        for evidenceRecord in evidence where evidenceRecord.requirementIDs.contains(requirementID) {
            evidenceIDs.insert(evidenceRecord.id)
        }

        let inferred = inferredTraceMatches(for: requirement)
        workItemIDs.formUnion(inferred.workItemIDs)
        evidenceIDs.formUnion(inferred.evidenceIDs)
        acceptanceCriterionIDs.formUnion(inferred.acceptanceCriterionIDs)
        targetKinds.formUnion(inferred.targetKinds)

        return AirframeRequirementTraceSummary(
            requirementID: requirementID,
            revisionIDs: revisionIDs,
            acceptanceCriterionIDs: acceptanceCriterionIDs.sorted { $0.rawValue < $1.rawValue },
            targetKinds: targetKinds.sorted(),
            workItemIDs: workItemIDs.sorted { $0.rawValue < $1.rawValue },
            evidenceIDs: evidenceIDs.sorted { $0.rawValue < $1.rawValue },
            traceCount: workItemIDs.count + evidenceIDs.count + revisionIDs.count
                + acceptanceCriterionIDs.count
        )
    }

    public func gapDiagnostics(releaseScope: String? = nil) -> [AirframeRequirementTraceGap] {
        scopedRequirements(releaseScope: releaseScope).flatMap { requirement in
            gapDiagnostics(for: requirement, releaseScope: releaseScope)
        }
        .sorted {
            $0.requirementID.rawValue == $1.requirementID.rawValue
                ? $0.kind.rawValue < $1.kind.rawValue
                : $0.requirementID.rawValue < $1.requirementID.rawValue
        }
    }

    public func releaseGateSummary(releaseScope: String? = nil) -> AirframeRequirementReleaseGateSummary {
        let scoped = scopedRequirements(releaseScope: releaseScope)
        let gaps = gapDiagnostics(releaseScope: releaseScope)
        let blockingRequirementIDs = Array(Set(gaps.filter(\.isBlocking).map(\.requirementID)))
            .sorted { $0.rawValue < $1.rawValue }
        let blockingReasons = gaps.filter(\.isBlocking).map(\.message)
        let implementedCount = scoped.filter { $0.status == .implemented }.count
        let verifiedCount = scoped.filter { $0.status == .verified }.count
        let validatedCount = scoped.filter { $0.status == .validated }.count
        let deferredCount = scoped.filter { $0.status == .deferred }.count
        let waivedCount = scoped.filter { $0.status == .waived }.count

        let openStatuses = scoped.filter { !allowedClosingStatuses.contains($0.status) }
        let openBlockingReasons = openStatuses.map { "Requirement \($0.id.rawValue) is \($0.status.description)." }

        return AirframeRequirementReleaseGateSummary(
            releaseScope: releaseScope,
            inScopeRequirementIDs: scoped.map(\.id),
            implementedCount: implementedCount,
            verifiedCount: verifiedCount,
            validatedCount: validatedCount,
            deferredCount: deferredCount,
            waivedCount: waivedCount,
            blockedRequirementIDs: blockingRequirementIDs,
            blockingReasons: blockingReasons + openBlockingReasons
        )
    }

    public func requirementListMarkdown() -> String {
        var lines: [String] = [
            "# Requirements",
            "",
            "Currently: **\(requirements.count) requirements**",
            "",
            "| Requirement | Title | Status | Source | Statement | Release Scope |",
            "| ----------- | ----- | ------ | ------ | --------- | ------------- |"
        ]
        for requirement in requirements {
            lines.append(
                "| \(markdownCell(requirement.id.rawValue)) | \(markdownCell(requirement.title)) | \(markdownCell(requirement.status.description)) | \(markdownCell(requirement.sourceKind.rawValue)) | \(markdownCell(requirement.statement)) | \(markdownCell(requirement.releaseScope.isEmpty ? "None" : requirement.releaseScope.joined(separator: ", "))) |"
            )
        }
        return lines.joined(separator: "\n") + "\n"
    }

    public func requirementSpecificationMarkdown() -> String {
        let coverage = coverageSummary()
        var lines: [String] = [
            "# Requirements Specification",
            "",
            "Currently: **\(coverage.totalRequirementCount) requirements**",
            "",
            "| Requirement | Title | Statement | Verification Method | Compliance | Work Items | Acceptance Criteria | Evidence |",
            "| ----------- | ----- | --------- | ------------------- | ---------- | ---------- | ------------------- | -------- |"
        ]
        for requirement in requirements {
            let summary = traceSummary(for: requirement.id)
            lines.append(
                "| \(markdownCell(requirement.id.rawValue)) | \(markdownCell(requirement.title)) | \(markdownCell(requirement.statement)) | \(markdownCell(requirement.verificationMethod.description)) | \(markdownCell(complianceLabel(for: requirement, summary: summary))) | \(markdownCell(summary.workItemIDs.map(\.rawValue).joined(separator: ", "))) | \(markdownCell(summary.acceptanceCriterionIDs.map(\.rawValue).joined(separator: ", "))) | \(markdownCell(summary.evidenceIDs.map(\.rawValue).joined(separator: ", "))) |"
            )
        }
        return lines.joined(separator: "\n") + "\n"
    }

    public func traceabilityMatrixMarkdown() -> String {
        var lines: [String] = [
            "# Requirements Traceability Matrix",
            "",
            "| Requirement | Title | Status | Work Items | Acceptance Criteria | Evidence | Revisions | Trace Targets |",
            "| ----------- | ----- | ------ | ---------- | ------------------- | -------- | --------- | ------------- |"
        ]
        for requirement in requirements {
            let summary = traceSummary(for: requirement.id)
            lines.append(
                "| \(markdownCell(requirement.id.rawValue)) | \(markdownCell(requirement.title)) | \(markdownCell(requirement.status.description)) | \(markdownCell(summary.workItemIDs.map(\.rawValue).joined(separator: ", "))) | \(markdownCell(summary.acceptanceCriterionIDs.map(\.rawValue).joined(separator: ", "))) | \(markdownCell(summary.evidenceIDs.map(\.rawValue).joined(separator: ", "))) | \(markdownCell(summary.revisionIDs.map(\.rawValue).joined(separator: ", "))) | \(markdownCell(summary.targetKinds.joined(separator: ", "))) |"
            )
        }
        return lines.joined(separator: "\n") + "\n"
    }

    public func bidirectionalTraceabilityMarkdown() -> String {
        var lines: [String] = [
            "# Bidirectional Requirements Traceability Matrix",
            "",
            "| Work Item or Evidence | Requirements |",
            "| --------------------- | ------------ |"
        ]
        let identifiers = (epics.map(\.workItem.id) + sprints.map(\.workItem.id) + tasks.map(\.workItem.id) + issues.map(\.workItem.id) + evidence.map(\.id))
        for identifier in identifiers {
            let requirementIDs = requirementIDs(for: identifier)
            guard !requirementIDs.isEmpty else { continue }
            lines.append("| \(identifier.rawValue) | \(requirementIDs.map(\.rawValue).joined(separator: ", ")) |")
        }
        return lines.joined(separator: "\n") + "\n"
    }

    public func releaseGateMarkdown(releaseScope: String? = nil) -> String {
        let gate = releaseGateSummary(releaseScope: releaseScope)
        var lines: [String] = [
            "# Release Gate",
            "",
            "**Release Scope:** \(gate.releaseScope ?? "All requirements")",
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

    public func coverageSummary(releaseScope: String? = nil) -> AirframeRequirementCoverageSummary {
        let scoped = scopedRequirements(releaseScope: releaseScope)
        let assignedRequirementCount = scoped.filter { requirement in
            let summary = traceSummary(for: requirement.id)
            return summary.hasWorkItemTrace || summary.hasAcceptanceCriterionTrace || summary.hasEvidenceTrace
        }.count
        let implementedRequirementCount = scoped.filter { requirement in
            let summary = traceSummary(for: requirement.id)
            return summary.hasWorkItemTrace && requirement.status == .implemented
        }.count
        let verifiedRequirementCount = scoped.filter { requirement in
            let summary = traceSummary(for: requirement.id)
            return (summary.hasAcceptanceCriterionTrace || summary.hasEvidenceTrace) && requirement.status == .verified
        }.count
        return AirframeRequirementCoverageSummary(
            totalRequirementCount: scoped.count,
            assignedRequirementCount: assignedRequirementCount,
            implementedRequirementCount: implementedRequirementCount,
            verifiedRequirementCount: verifiedRequirementCount,
            unassignedRequirementCount: scoped.count - assignedRequirementCount
        )
    }

    private var allowedClosingStatuses: Set<AirframeRequirementLifecycleStatus> {
        [.implemented, .verified, .validated, .deferred, .waived, .superseded, .removed]
    }

    private func scopedRequirements(releaseScope: String?) -> [AirframeCanonicalRequirementRecord] {
        guard let releaseScope else { return requirements }
        return requirements.filter { $0.releaseScope.contains(releaseScope) }
    }

    private func inferredTraceSummary(for requirementID: AirframeID) -> AirframeRequirementTraceSummary {
        let requirement = requirementsByID[requirementID]
        let revisionIDs = revisionHistory(for: requirementID).map(\.id)
        let inferred = inferredTraceMatches(for: requirement)
        return AirframeRequirementTraceSummary(
            requirementID: requirementID,
            revisionIDs: revisionIDs,
            acceptanceCriterionIDs: inferred.acceptanceCriterionIDs.sorted { $0.rawValue < $1.rawValue },
            targetKinds: inferred.targetKinds.sorted(),
            workItemIDs: inferred.workItemIDs.sorted { $0.rawValue < $1.rawValue },
            evidenceIDs: inferred.evidenceIDs.sorted { $0.rawValue < $1.rawValue },
            traceCount: inferred.workItemIDs.count + inferred.evidenceIDs.count + revisionIDs.count + inferred.acceptanceCriterionIDs.count
        )
    }

    private func inferredTraceMatches(for requirement: AirframeCanonicalRequirementRecord?) -> (
        workItemIDs: Set<AirframeID>,
        evidenceIDs: Set<AirframeID>,
        acceptanceCriterionIDs: Set<AirframeID>,
        targetKinds: Set<String>
    ) {
        guard let requirement else {
            return ([], [], [], [])
        }

        let requirementText = "\(requirement.title)\n\(requirement.statement)\n\(requirement.rationale)"
        let requirementTokens = normalizedTokens(requirementText)
        var workItemIDs = Set<AirframeID>()
        var evidenceIDs = Set<AirframeID>()
        var acceptanceCriterionIDs = Set<AirframeID>()
        var targetKinds = Set<String>()

        for criterion in acceptanceCriteria {
            let searchable = "\(criterion.text)\n\(criterion.ownerID.rawValue)"
            if matchScore(queryTokens: requirementTokens, candidate: searchable) >= 3 {
                acceptanceCriterionIDs.insert(criterion.id)
                workItemIDs.insert(criterion.ownerID)
                targetKinds.insert(AirframeRequirementTraceTargetKind.acceptanceCriterion.rawValue)
                targetKinds.insert(AirframeRequirementTraceTargetKind.epic.rawValue)
            }
        }

        for epic in epics {
            if matchScore(queryTokens: requirementTokens, candidate: searchableText(for: epic)) >= 3 {
                workItemIDs.insert(epic.workItem.id)
                targetKinds.insert(AirframeRequirementTraceTargetKind.epic.rawValue)
            }
        }

        for sprint in sprints {
            if matchScore(queryTokens: requirementTokens, candidate: searchableText(for: sprint)) >= 3 {
                workItemIDs.insert(sprint.workItem.id)
                targetKinds.insert(AirframeRequirementTraceTargetKind.sprint.rawValue)
            }
        }

        for task in tasks {
            if matchScore(queryTokens: requirementTokens, candidate: searchableText(for: task)) >= 3 {
                workItemIDs.insert(task.workItem.id)
                targetKinds.insert(AirframeRequirementTraceTargetKind.task.rawValue)
            }
        }

        for issue in issues {
            if matchScore(queryTokens: requirementTokens, candidate: searchableText(for: issue)) >= 3 {
                workItemIDs.insert(issue.workItem.id)
                targetKinds.insert(AirframeRequirementTraceTargetKind.issue.rawValue)
            }
        }

        for evidenceRecord in evidence {
            if matchScore(queryTokens: requirementTokens, candidate: searchableText(for: evidenceRecord)) >= 3 {
                evidenceIDs.insert(evidenceRecord.id)
                targetKinds.insert(AirframeRequirementTraceTargetKind.evidence.rawValue)
            }
        }

        return (workItemIDs, evidenceIDs, acceptanceCriterionIDs, targetKinds)
    }

    private func requirements(matching criterion: AirframeCanonicalAcceptanceCriterionRecord) -> [AirframeID] {
        let requirementTokens = normalizedTokens(criterion.text)
        return requirements.compactMap { requirement in
            let score = matchScore(queryTokens: requirementTokens, candidate: "\(requirement.title) \(requirement.statement)")
            if requirement.id == criterion.ownerID || score >= 3 {
                return requirement.id
            }
            return nil
        }
    }

    private func searchableText(for epic: AirframeCanonicalEpicRecord) -> String {
        [
            epic.workItem.id.rawValue,
            epic.workItem.title,
            epic.workItem.status.description,
            epic.goal,
            epic.rationale,
            epic.scope.joined(separator: " "),
            epic.outOfScope.joined(separator: " "),
            epic.notes.joined(separator: " "),
            epic.planningDocumentPaths.joined(separator: " ")
        ]
        .joined(separator: "\n")
    }

    private func searchableText(for sprint: AirframeCanonicalSprintRecord) -> String {
        [
            sprint.workItem.id.rawValue,
            sprint.workItem.title,
            sprint.workItem.status.description,
            sprint.goal,
            sprint.notes.joined(separator: " ")
        ]
        .joined(separator: "\n")
    }

    private func searchableText(for task: AirframeCanonicalTaskRecord) -> String {
        [
            task.workItem.id.rawValue,
            task.workItem.title,
            task.workItem.status.description,
            task.component,
            task.rationale,
            task.currentBehavior ?? "",
            task.desiredBehavior ?? "",
            task.acceptanceCriteria.joined(separator: " "),
            task.designApproach ?? "",
            task.componentsAffected.joined(separator: " "),
            task.implementationDetails ?? "",
            task.testSteps.joined(separator: " "),
            task.notes.joined(separator: " ")
        ]
        .joined(separator: "\n")
    }

    private func searchableText(for issue: AirframeCanonicalIssueRecord) -> String {
        [
            issue.workItem.id.rawValue,
            issue.workItem.title,
            issue.workItem.status.description,
            issue.observedBehavior,
            issue.expectedBehavior,
            issue.reproductionSteps.joined(separator: " "),
            issue.affectedComponents.joined(separator: " "),
            issue.notes.joined(separator: " ")
        ]
        .joined(separator: "\n")
    }

    private func searchableText(for evidence: AirframeCanonicalEvidenceSummaryRecord) -> String {
        [
            evidence.id.rawValue,
            evidence.summary,
            evidence.command ?? "",
            evidence.artifactReferences.joined(separator: " "),
            evidence.ciReferences.joined(separator: " "),
            evidence.environment ?? ""
        ]
        .joined(separator: "\n")
    }

    private func normalizedTokens(_ text: String) -> Set<String> {
        let stopWords: Set<String> = [
            "a", "an", "and", "are", "as", "at", "be", "by", "for", "from", "has", "have", "in", "is", "it", "of", "on", "or", "shall", "the", "to", "with", "will"
        ]
        return text
            .lowercased()
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
            .filter { $0.count > 2 && !stopWords.contains($0) }
            .reduce(into: Set<String>()) { $0.insert($1) }
    }

    private func matchScore(queryTokens: Set<String>, candidate: String) -> Int {
        let candidateTokens = normalizedTokens(candidate)
        let shared = queryTokens.intersection(candidateTokens)
        return shared.count
    }

    fileprivate func complianceLabel(for requirement: AirframeCanonicalRequirementRecord, summary: AirframeRequirementTraceSummary) -> String {
        switch requirement.status {
        case .implemented, .verified, .validated:
            if summary.hasWorkItemTrace || summary.hasAcceptanceCriterionTrace || summary.hasEvidenceTrace {
                return "Complies"
            }
            return "Not demonstrated"
        case .deferred:
            return "Deferred"
        case .waived:
            return "Waived"
        case .superseded:
            return "Superseded"
        case .removed:
            return "Removed"
        case .active:
            return summary.hasWorkItemTrace ? "In progress" : "Not yet assigned"
        case .draft, .proposed:
            return summary.hasWorkItemTrace || summary.hasAcceptanceCriterionTrace ? "In progress" : "Not yet assigned"
        }
    }

    fileprivate func markdownCell(_ text: String) -> String {
        text.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "|", with: "\\|")
    }

    private static func missingImplementationMessage(_ requirementID: AirframeID) -> String {
        "Requirement \(requirementID.rawValue) has no linked implementation work."
    }

    private static func missingVerificationMessage(_ requirementID: AirframeID) -> String {
        "Requirement \(requirementID.rawValue) requires verification evidence but has none."
    }

    private static func missingScopeMessage(_ requirementID: AirframeID, releaseScope: String) -> String {
        "Requirement \(requirementID.rawValue) is not assigned to release scope \(releaseScope)."
    }

    private func gapDiagnostics(
        for requirement: AirframeCanonicalRequirementRecord,
        releaseScope: String?
    ) -> [AirframeRequirementTraceGap] {
        let summary = traceSummary(for: requirement.id)
        var gaps: [AirframeRequirementTraceGap] = []

        if !summary.hasWorkItemTrace {
            gaps.append(
                AirframeRequirementTraceGap(
                    requirementID: requirement.id,
                    kind: .missingImplementationTrace,
                    message: Self.missingImplementationMessage(requirement.id)
                )
            )
        }

        if requirement.validationRequired && !summary.hasEvidenceTrace {
            gaps.append(
                AirframeRequirementTraceGap(
                    requirementID: requirement.id,
                    kind: .missingVerificationEvidence,
                    message: Self.missingVerificationMessage(requirement.id)
                )
            )
        }

        if requirement.releaseScope.isEmpty, let releaseScope {
            gaps.append(
                AirframeRequirementTraceGap(
                    requirementID: requirement.id,
                    kind: .missingReleaseScope,
                    message: Self.missingScopeMessage(requirement.id, releaseScope: releaseScope),
                    isBlocking: false
                )
            )
        }

        return gaps
    }
}

public struct AirframeRequirementDocumentationProjector: Sendable {
    public init() {}

    public func projectRequirementsIndex(_ index: AirframeRequirementTraceabilityIndex) -> String {
        index.requirementListMarkdown()
    }

    public func projectRequirementsSpecification(_ index: AirframeRequirementTraceabilityIndex) -> String {
        index.requirementSpecificationMarkdown()
    }

    public func projectTraceabilityMatrix(_ index: AirframeRequirementTraceabilityIndex) -> String {
        index.traceabilityMatrixMarkdown()
    }

    public func projectBidirectionalTraceabilityMatrix(_ index: AirframeRequirementTraceabilityIndex) -> String {
        index.bidirectionalTraceabilityMarkdown()
    }

    public func projectReleaseGate(_ index: AirframeRequirementTraceabilityIndex, releaseScope: String? = nil) -> String {
        index.releaseGateMarkdown(releaseScope: releaseScope)
    }

    public func projectComplianceVerificationMatrix(_ index: AirframeRequirementTraceabilityIndex) -> String {
        let gate = index.releaseGateSummary()
        var lines: [String] = [
            "# Compliance Verification Matrix",
            "",
            "| Count | Value |",
            "| ----- | ----- |",
            "| Requirements | \(index.requirements.count) |",
            "| Implemented | \(gate.implementedCount) |",
            "| Verified | \(gate.verifiedCount) |",
            "| Validated | \(gate.validatedCount) |",
            "| Deferred | \(gate.deferredCount) |",
            "| Waived | \(gate.waivedCount) |",
            "| Blocked | \(gate.blockedCount) |",
            "",
            "| Requirement | Text | Verification Method | Compliance | Work Items | Acceptance Criteria | Evidence |",
            "| ----------- | ---- | ------------------- | ---------- | ---------- | ------------------- | -------- |"
        ]
        for requirement in index.requirements {
            let summary = index.traceSummary(for: requirement.id)
            lines.append(
                "| \(index.markdownCell(requirement.id.rawValue)) | \(index.markdownCell(requirement.statement)) | \(index.markdownCell(requirement.verificationMethod.description)) | \(index.markdownCell(index.complianceLabel(for: requirement, summary: summary))) | \(index.markdownCell(summary.workItemIDs.map(\.rawValue).joined(separator: ", "))) | \(index.markdownCell(summary.acceptanceCriterionIDs.map(\.rawValue).joined(separator: ", "))) | \(index.markdownCell(summary.evidenceIDs.map(\.rawValue).joined(separator: ", "))) |"
            )
        }
        if !gate.blockingReasons.isEmpty {
            lines.append("")
            lines.append("## Blocking Reasons")
            lines.append(contentsOf: gate.blockingReasons.map { "- \($0)" })
        }
        return lines.joined(separator: "\n") + "\n"
    }

    public func projectRequirementReport(_ index: AirframeRequirementTraceabilityIndex, releaseScope: String? = nil) -> [String: String] {
        [
            "Requirements/Requirements-Specification.md": projectRequirementsSpecification(index),
            "Requirements/index.md": projectRequirementsIndex(index),
            "Requirements/Requirements-Traceability-Matrix.md": projectTraceabilityMatrix(index),
            "Requirements/Bidirectional-Requirements-Traceability-Matrix.md": projectBidirectionalTraceabilityMatrix(index),
            "Requirements/Release-Gate.md": projectReleaseGate(index, releaseScope: releaseScope),
            "Requirements/Compliance-Verification-Matrix.md": projectComplianceVerificationMatrix(index)
        ]
    }
}
