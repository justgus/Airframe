import Foundation

public enum AirframeBackendKind: String, Codable, Equatable, Sendable {
    case localFixture = "local-fixture"
    case githubFixture = "github-fixture"
    case githubIssues = "github-issues"
}

public struct AirframeGitHubBackendConfiguration: Codable, Equatable, Sendable {
    public let owner: String
    public let repository: String
    public let issueLabelPrefix: String
    public let taskLabel: String
    public let issueLabel: String

    public init(
        owner: String,
        repository: String,
        issueLabelPrefix: String = "airframe",
        taskLabel: String = "airframe-task",
        issueLabel: String = "airframe-issue"
    ) {
        self.owner = owner
        self.repository = repository
        self.issueLabelPrefix = issueLabelPrefix
        self.taskLabel = taskLabel
        self.issueLabel = issueLabel
    }

    public init(repositorySlug: String) {
        let parts = repositorySlug.split(separator: "/", maxSplits: 1).map(String.init)
        self.init(
            owner: parts.first ?? "",
            repository: parts.count > 1 ? parts[1] : repositorySlug
        )
    }

    public var slug: String {
        owner.isEmpty ? repository : "\(owner)/\(repository)"
    }
}

public struct AirframeGitHubIssueRecord: Codable, Equatable, Sendable {
    public let number: Int
    public let title: String
    public let state: String
    public let labels: [String]
    public let body: String

    public init(
        number: Int,
        title: String,
        state: String = "open",
        labels: [String],
        body: String
    ) {
        self.number = number
        self.title = title
        self.state = state
        self.labels = labels
        self.body = body
    }
}

public struct AirframeGitHubIssueMapper: Sendable {
    public let configuration: AirframeGitHubBackendConfiguration

    public init(configuration: AirframeGitHubBackendConfiguration) {
        self.configuration = configuration
    }

    public func issue(from record: AirframeLocalWorkRecord, evidence: [AirframeEvidence] = []) -> AirframeGitHubIssueRecord {
        let issueNumber = record.workItem.githubIssue ?? numericSuffix(from: record.workItem.id)
        return AirframeGitHubIssueRecord(
            number: issueNumber,
            title: record.workItem.title,
            state: record.workItem.status == .closed ? "closed" : "open",
            labels: labels(for: record),
            body: body(for: record, evidence: evidence)
        )
    }

    public func record(from issue: AirframeGitHubIssueRecord) -> AirframeLocalWorkRecord {
        let labels = Set(issue.labels)
        let kind: AirframeWorkItemKind = labels.contains(configuration.issueLabel) ? .issue : .task
        let idPrefix = kind == .issue ? "I" : "T"
        let status = status(from: labels, state: issue.state)
        return AirframeLocalWorkRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("\(idPrefix)-\(String(format: "%04d", issue.number))"),
                kind: kind,
                title: issue.title,
                status: status,
                githubIssue: issue.number
            ),
            epicID: firstIDLabel(prefix: "epic-", labels: labels).map(AirframeID.init),
            sprintID: firstIDLabel(prefix: "sprint-", labels: labels).map(AirframeID.init),
            priority: priority(from: labels),
            acceptanceCriteria: section("Acceptance Criteria", in: issue.body),
            scope: section("Scope", in: issue.body),
            constraints: section("Constraints", in: issue.body),
            evidenceRequirements: section("Evidence Requirements", in: issue.body),
            protectedPaths: section("Protected Paths", in: issue.body),
            reportFormat: section("Report Format", in: issue.body).first ?? "Summarize changes, verification commands, and residual risks."
        )
    }

    public func evidence(from issue: AirframeGitHubIssueRecord) -> [AirframeEvidence] {
        section("Evidence", in: issue.body).compactMap { line in
            let parts = line.split(separator: "|", maxSplits: 2).map { $0.trimmingCharacters(in: .whitespaces) }
            guard parts.count == 3 else { return nil }
            return AirframeEvidence(id: AirframeID(parts[0]), summary: parts[1], artifact: parts[2])
        }
    }

    private func labels(for record: AirframeLocalWorkRecord) -> [String] {
        var labels = [
            record.workItem.kind == .issue ? configuration.issueLabel : configuration.taskLabel,
            "status-\(statusLabel(record.workItem.status))",
            "priority-\(record.priority.rawValue)"
        ]
        if let sprintID = record.sprintID {
            labels.append("sprint-\(sprintID.rawValue)")
        }
        if let epicID = record.epicID {
            labels.append("epic-\(epicID.rawValue)")
        }
        return labels.sorted()
    }

    private func body(for record: AirframeLocalWorkRecord, evidence: [AirframeEvidence]) -> String {
        var lines: [String] = [
            "## Airframe",
            "- id: \(record.workItem.id.rawValue)",
            "- kind: \(record.workItem.kind.rawValue)",
            "- status: \(record.workItem.status.description)",
            "- sprint: \(record.sprintID?.rawValue ?? "None")",
            "- epic: \(record.epicID?.rawValue ?? "None")",
            "",
            "## Scope"
        ]
        appendBullets(record.scope, to: &lines)
        lines.append(contentsOf: ["", "## Acceptance Criteria"])
        appendBullets(record.acceptanceCriteria, to: &lines)
        lines.append(contentsOf: ["", "## Constraints"])
        appendBullets(record.constraints, to: &lines)
        lines.append(contentsOf: ["", "## Evidence Requirements"])
        appendBullets(record.evidenceRequirements, to: &lines)
        lines.append(contentsOf: ["", "## Protected Paths"])
        appendBullets(record.protectedPaths, to: &lines)
        lines.append(contentsOf: ["", "## Evidence"])
        appendBullets(evidence.map { "\($0.id.rawValue) | \($0.summary) | \($0.artifact)" }, to: &lines)
        lines.append(contentsOf: ["", "## Report Format", record.reportFormat])
        return lines.joined(separator: "\n")
    }

    private func appendBullets(_ values: [String], to lines: inout [String]) {
        lines.append(contentsOf: values.isEmpty ? ["- None"] : values.map { "- \($0)" })
    }

    private func statusLabel(_ status: AirframeWorkStatus) -> String {
        switch status {
        case .backlog:
            "backlog"
        case .active:
            "active"
        case .implementedNotVerified:
            "unverified"
        case .implementedVerified:
            "verified"
        case .closed:
            "closed"
        }
    }

    private func status(from labels: Set<String>, state: String) -> AirframeWorkStatus {
        if state == "closed" || labels.contains("status-closed") {
            return .closed
        }
        if labels.contains("status-verified") {
            return .implementedVerified
        }
        if labels.contains("status-unverified") {
            return .implementedNotVerified
        }
        if labels.contains("status-active") {
            return .active
        }
        return .backlog
    }

    private func priority(from labels: Set<String>) -> AirframeWorkPriority {
        if labels.contains("priority-high") {
            return .high
        }
        if labels.contains("priority-low") {
            return .low
        }
        return .medium
    }

    private func firstIDLabel(prefix: String, labels: Set<String>) -> String? {
        labels.first { $0.hasPrefix(prefix) }.map { String($0.dropFirst(prefix.count)) }
    }

    private func numericSuffix(from id: AirframeID) -> Int {
        Int(id.rawValue.split(separator: "-").last ?? "0") ?? 0
    }

    private func section(_ title: String, in body: String) -> [String] {
        let lines = body.components(separatedBy: .newlines)
        guard let start = lines.firstIndex(of: "## \(title)") else { return [] }
        var values: [String] = []
        for line in lines.dropFirst(start + 1) {
            if line.hasPrefix("## ") {
                break
            }
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("- ") {
                let value = String(trimmed.dropFirst(2))
                if value != "None" {
                    values.append(value)
                }
            } else if !trimmed.isEmpty, title == "Report Format" {
                values.append(trimmed)
            }
        }
        return values
    }
}

public final class AirframeGitHubFixtureBackend: @unchecked Sendable, AirframeBackend {
    public let capabilities: AirframeBackendCapabilities = .githubFixture
    public let configuration: AirframeGitHubBackendConfiguration

    private let localBackend: AirframeLocalFilesystemBackend

    public init(
        storeURL: URL,
        configuration: AirframeGitHubBackendConfiguration
    ) {
        self.localBackend = AirframeLocalFilesystemBackend(storeURL: storeURL)
        self.configuration = configuration
    }

    public func listWorkRecords() throws -> [AirframeLocalWorkRecord] {
        try localBackend.listWorkRecords()
    }

    public func workRecord(id: AirframeID) throws -> AirframeLocalWorkRecord? {
        try localBackend.workRecord(id: id)
    }

    public func createWorkRecord(_ record: AirframeLocalWorkRecord) throws {
        try localBackend.createWorkRecord(record)
    }

    public func updateWorkItem(_ workItem: AirframeWorkItem) throws {
        try localBackend.updateWorkItem(workItem)
    }

    public func transitionWorkItem(
        id: AirframeID,
        to status: AirframeWorkStatus,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws {
        try localBackend.transitionWorkItem(id: id, to: status, context: context, targetProjectID: targetProjectID)
    }

    public func attachEvidence(_ evidence: AirframeEvidence, to workItemID: AirframeID) throws {
        try localBackend.attachEvidence(evidence, to: workItemID)
    }

    public func evidence(for workItemID: AirframeID) throws -> [AirframeEvidence] {
        try localBackend.evidence(for: workItemID)
    }

    public func taskPacket(for workItemID: AirframeID) throws -> AirframeTaskPacket {
        try localBackend.taskPacket(for: workItemID)
    }

    public func applyHumanVerification(
        action: AirframeHumanVerificationAction,
        to workItemID: AirframeID,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws -> AirframeHumanVerificationResult {
        try localBackend.applyHumanVerification(
            action: action,
            to: workItemID,
            context: context,
            targetProjectID: targetProjectID
        )
    }

    public func dashboardSummary() throws -> AirframeDashboardSummary {
        try localBackend.dashboardSummary()
    }

    public func githubIssues() throws -> [AirframeGitHubIssueRecord] {
        let mapper = AirframeGitHubIssueMapper(configuration: configuration)
        return try listWorkRecords().map { record in
            let evidence = try self.evidence(for: record.workItem.id)
            return mapper.issue(from: record, evidence: evidence)
        }
    }
}

public extension AirframeBackendReference {
    var backendKind: AirframeBackendKind? {
        AirframeBackendKind(rawValue: kind)
    }

    var githubConfiguration: AirframeGitHubBackendConfiguration {
        AirframeGitHubBackendConfiguration(repositorySlug: location)
    }
}
