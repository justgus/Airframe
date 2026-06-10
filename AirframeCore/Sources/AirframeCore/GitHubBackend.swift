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

public protocol AirframeGitHubIssueTransport: Sendable {
    func listIssues(configuration: AirframeGitHubBackendConfiguration) throws -> [AirframeGitHubIssueRecord]
    func issue(number: Int, configuration: AirframeGitHubBackendConfiguration) throws -> AirframeGitHubIssueRecord
    func addComment(
        issueNumber: Int,
        body: String,
        configuration: AirframeGitHubBackendConfiguration
    ) throws
    func replaceStatusLabel(
        issueNumber: Int,
        removing oldStatusLabels: [String],
        adding newStatusLabel: String,
        configuration: AirframeGitHubBackendConfiguration
    ) throws
}

public extension AirframeGitHubIssueTransport {
    func addComment(
        issueNumber: Int,
        body: String,
        configuration: AirframeGitHubBackendConfiguration
    ) throws {
        throw AirframeBackendError.readOnlyBackend("GitHub issue comments")
    }

    func replaceStatusLabel(
        issueNumber: Int,
        removing oldStatusLabels: [String],
        adding newStatusLabel: String,
        configuration: AirframeGitHubBackendConfiguration
    ) throws {
        throw AirframeBackendError.readOnlyBackend("GitHub status label transitions")
    }
}

public struct AirframeGitHubCLITransport: AirframeGitHubIssueTransport {
    public init() {}

    public func listIssues(configuration: AirframeGitHubBackendConfiguration) throws -> [AirframeGitHubIssueRecord] {
        let data = try runGitHubCLI(arguments: [
            "issue", "list",
            "--repo", configuration.slug,
            "--state", "all",
            "--limit", "100",
            "--json", "number,title,state,labels,body"
        ])
        return try decodeIssues(from: data)
    }

    public func issue(number: Int, configuration: AirframeGitHubBackendConfiguration) throws -> AirframeGitHubIssueRecord {
        let data = try runGitHubCLI(arguments: [
            "issue", "view", "\(number)",
            "--repo", configuration.slug,
            "--json", "number,title,state,labels,body"
        ])
        return try decodeIssue(from: data)
    }

    public func addComment(
        issueNumber: Int,
        body: String,
        configuration: AirframeGitHubBackendConfiguration
    ) throws {
        _ = try runGitHubCLI(arguments: [
            "issue", "comment", "\(issueNumber)",
            "--repo", configuration.slug,
            "--body", body
        ])
    }

    public func replaceStatusLabel(
        issueNumber: Int,
        removing oldStatusLabels: [String],
        adding newStatusLabel: String,
        configuration: AirframeGitHubBackendConfiguration
    ) throws {
        for label in oldStatusLabels where label != newStatusLabel {
            _ = try runGitHubCLI(arguments: [
                "issue", "edit", "\(issueNumber)",
                "--repo", configuration.slug,
                "--remove-label", label
            ])
        }
        _ = try runGitHubCLI(arguments: [
            "issue", "edit", "\(issueNumber)",
            "--repo", configuration.slug,
            "--add-label", newStatusLabel
        ])
    }

    private func runGitHubCLI(arguments: [String]) throws -> Data {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["gh"] + arguments

        let fileManager = FileManager.default
        let temporaryDirectory = fileManager.temporaryDirectory
        let invocationID = UUID().uuidString
        let outputURL = temporaryDirectory.appendingPathComponent("airframe-gh-\(invocationID).stdout")
        let errorURL = temporaryDirectory.appendingPathComponent("airframe-gh-\(invocationID).stderr")

        _ = fileManager.createFile(atPath: outputURL.path, contents: nil)
        _ = fileManager.createFile(atPath: errorURL.path, contents: nil)

        let outputHandle: FileHandle
        let errorHandle: FileHandle
        do {
            outputHandle = try FileHandle(forWritingTo: outputURL)
            errorHandle = try FileHandle(forWritingTo: errorURL)
        } catch {
            throw AirframeBackendError.githubAccessFailed("Unable to prepare gh output capture: \(error.localizedDescription)")
        }

        process.standardOutput = outputHandle
        process.standardError = errorHandle

        defer {
            try? outputHandle.close()
            try? errorHandle.close()
            try? fileManager.removeItem(at: outputURL)
            try? fileManager.removeItem(at: errorURL)
        }

        do {
            try process.run()
        } catch {
            throw AirframeBackendError.githubAccessFailed("Unable to launch gh CLI: \(error.localizedDescription)")
        }

        process.waitUntilExit()
        try? outputHandle.close()
        try? errorHandle.close()

        let outputData = (try? Data(contentsOf: outputURL)) ?? Data()
        let errorData = (try? Data(contentsOf: errorURL)) ?? Data()

        guard process.terminationStatus == 0 else {
            let message = String(decoding: errorData, as: UTF8.self)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            throw AirframeBackendError.githubAccessFailed(message.isEmpty ? "gh exited with status \(process.terminationStatus)" : message)
        }

        return outputData
    }

    private func decodeIssues(from data: Data) throws -> [AirframeGitHubIssueRecord] {
        do {
            return try JSONDecoder().decode([GitHubIssueDTO].self, from: data).map(\.record)
        } catch {
            throw AirframeBackendError.githubAccessFailed("Could not decode gh issue list output: \(error.localizedDescription)")
        }
    }

    private func decodeIssue(from data: Data) throws -> AirframeGitHubIssueRecord {
        do {
            return try JSONDecoder().decode(GitHubIssueDTO.self, from: data).record
        } catch {
            throw AirframeBackendError.githubAccessFailed("Could not decode gh issue view output: \(error.localizedDescription)")
        }
    }
}

private struct GitHubIssueDTO: Decodable {
    let number: Int
    let title: String
    let state: String
    let labels: [GitHubLabelDTO]
    let body: String?

    var record: AirframeGitHubIssueRecord {
        AirframeGitHubIssueRecord(
            number: number,
            title: title,
            state: state.lowercased(),
            labels: labels.map(\.name),
            body: body ?? ""
        )
    }
}

private struct GitHubLabelDTO: Decodable {
    let name: String
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
        let kind = workItemKind(from: issue, labels: labels)
        let idPrefix = kind == .issue ? "I" : "T"
        let id = metadataValue("Airframe ID", in: issue.body)
            ?? airframeSectionValue("id", in: issue.body)
            ?? prefixedID(in: issue.title)
            ?? "\(idPrefix)-\(String(format: "%04d", issue.number))"
        let status = status(from: labels, state: issue.state)
        return AirframeLocalWorkRecord(
            workItem: AirframeWorkItem(
                id: AirframeID(id),
                kind: kind,
                title: normalizedTitle(issue.title),
                status: status,
                githubIssue: issue.number
            ),
            epicID: firstIDLabel(prefix: "epic-", labels: labels).map(AirframeID.init)
                ?? metadataValue("Epic", in: issue.body).map(AirframeID.init)
                ?? airframeSectionValue("epic", in: issue.body).flatMap(optionalAirframeID),
            sprintID: firstIDLabel(prefix: "sprint-", labels: labels).map(AirframeID.init)
                ?? metadataValue("Sprint", in: issue.body).map(AirframeID.init)
                ?? airframeSectionValue("sprint", in: issue.body).flatMap(optionalAirframeID),
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

    private func workItemKind(from issue: AirframeGitHubIssueRecord, labels: Set<String>) -> AirframeWorkItemKind {
        if let type = metadataValue("Airframe Type", in: issue.body)?.lowercased() {
            return type == "issue" ? .issue : .task
        }
        if let id = metadataValue("Airframe ID", in: issue.body) ?? airframeSectionValue("id", in: issue.body) {
            return id.hasPrefix("I-") ? .issue : .task
        }
        return labels.contains(configuration.issueLabel) ? .issue : .task
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
        if labels.contains("status-verified") {
            return .implementedVerified
        }
        if labels.contains("status-unverified") {
            return .implementedNotVerified
        }
        if labels.contains("status-active") {
            return .active
        }
        if state == "closed" || labels.contains("status-closed") {
            return .closed
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

    private func metadataValue(_ key: String, in body: String) -> String? {
        for line in body.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("\(key):") else { continue }
            let value = trimmed.dropFirst(key.count + 1).trimmingCharacters(in: .whitespaces)
            return value.isEmpty ? nil : value
        }
        return nil
    }

    private func airframeSectionValue(_ key: String, in body: String) -> String? {
        for line in section("Airframe", in: body) {
            let parts = line.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            guard parts.count == 2, parts[0].lowercased() == key.lowercased(), parts[1] != "None" else { continue }
            return parts[1]
        }
        return nil
    }

    private func prefixedID(in title: String) -> String? {
        guard title.hasPrefix("[") else { return nil }
        guard let end = title.firstIndex(of: "]") else { return nil }
        let candidate = String(title[title.index(after: title.startIndex)..<end])
        return candidate.range(of: #"^[TI]-[0-9]{4}$"#, options: .regularExpression) == nil ? nil : candidate
    }

    private func normalizedTitle(_ title: String) -> String {
        guard let id = prefixedID(in: title) else { return title }
        let prefix = "[\(id)]"
        return title.hasPrefix(prefix) ? title.dropFirst(prefix.count).trimmingCharacters(in: .whitespaces) : title
    }

    private func optionalAirframeID(_ value: String) -> AirframeID? {
        value == "None" ? nil : AirframeID(value)
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

public final class AirframeGitHubIssuesBackend: @unchecked Sendable, AirframeBackend {
    public let capabilities: AirframeBackendCapabilities
    public let configuration: AirframeGitHubBackendConfiguration

    private let transport: any AirframeGitHubIssueTransport
    private let mapper: AirframeGitHubIssueMapper

    public init(
        configuration: AirframeGitHubBackendConfiguration,
        transport: any AirframeGitHubIssueTransport = AirframeGitHubCLITransport(),
        controlledMutationsEnabled: Bool = false
    ) {
        self.configuration = configuration
        self.transport = transport
        self.mapper = AirframeGitHubIssueMapper(configuration: configuration)
        self.capabilities = controlledMutationsEnabled ? .githubIssuesControlledMutations : .githubIssuesReadOnly
    }

    public func listWorkRecords() throws -> [AirframeLocalWorkRecord] {
        try transport.listIssues(configuration: configuration)
            .filter(isAirframeWorkIssue)
            .map(mapper.record(from:))
            .sorted { $0.workItem.id.rawValue < $1.workItem.id.rawValue }
    }

    public func workRecord(id: AirframeID) throws -> AirframeLocalWorkRecord? {
        try listWorkRecords().first { $0.workItem.id == id }
    }

    public func createWorkRecord(_ record: AirframeLocalWorkRecord) throws {
        throw AirframeBackendError.readOnlyBackend("work item creation")
    }

    public func updateWorkItem(_ workItem: AirframeWorkItem) throws {
        throw AirframeBackendError.readOnlyBackend("work item updates")
    }

    public func transitionWorkItem(
        id: AirframeID,
        to status: AirframeWorkStatus,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws {
        throw AirframeBackendError.readOnlyBackend("workflow transitions")
    }

    public func attachEvidence(_ evidence: AirframeEvidence, to workItemID: AirframeID) throws {
        throw AirframeBackendError.readOnlyBackend("evidence attachment")
    }

    public func evidence(for workItemID: AirframeID) throws -> [AirframeEvidence] {
        guard let record = try workRecord(id: workItemID), let issueNumber = record.workItem.githubIssue else {
            throw AirframeBackendError.missingWorkItem(workItemID)
        }
        return try mapper.evidence(from: transport.issue(number: issueNumber, configuration: configuration))
    }

    public func taskPacket(for workItemID: AirframeID) throws -> AirframeTaskPacket {
        guard let record = try workRecord(id: workItemID), let issueNumber = record.workItem.githubIssue else {
            throw AirframeBackendError.missingWorkItem(workItemID)
        }
        let issue = try transport.issue(number: issueNumber, configuration: configuration)
        return AirframeTaskPacket(
            workItem: record.workItem,
            objective: record.workItem.title,
            scope: record.scope,
            acceptanceCriteria: record.acceptanceCriteria,
            constraints: record.constraints,
            evidenceRequirements: record.evidenceRequirements,
            protectedPaths: record.protectedPaths,
            reportFormat: record.reportFormat,
            existingEvidence: mapper.evidence(from: issue)
        )
    }

    public func applyHumanVerification(
        action: AirframeHumanVerificationAction,
        to workItemID: AirframeID,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws -> AirframeHumanVerificationResult {
        throw AirframeBackendError.readOnlyBackend("human verification")
    }

    public func addIssueComment(
        to workItemID: AirframeID,
        body: String,
        approval: AirframeGitHubMutationApproval?,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws -> AirframeGitHubMutationResult {
        let record = try approvedMutationRecord(
            workItemID: workItemID,
            approval: approval,
            context: context,
            targetProjectID: targetProjectID,
            operation: AirframeOperation(
                id: AirframeID("OP-GITHUB-ISSUE-COMMENT"),
                category: .evidence,
                requiresConfirmation: true
            )
        )
        let issueNumber = try githubIssueNumber(for: record)
        try transport.addComment(issueNumber: issueNumber, body: body, configuration: configuration)
        return mutationResult(
            record: record,
            issueNumber: issueNumber,
            mutation: "githubIssueComment",
            action: "OP-GITHUB-ISSUE-COMMENT",
            context: context,
            targetProjectID: targetProjectID
        )
    }

    public func attachEvidenceComment(
        _ evidence: AirframeEvidence,
        to workItemID: AirframeID,
        approval: AirframeGitHubMutationApproval?,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws -> AirframeGitHubMutationResult {
        let body = """
        Airframe Evidence
        Work Item: \(workItemID.rawValue)
        Evidence: \(evidence.id.rawValue)
        Summary: \(evidence.summary)
        Artifact: \(evidence.artifact)
        """
        let record = try approvedMutationRecord(
            workItemID: workItemID,
            approval: approval,
            context: context,
            targetProjectID: targetProjectID,
            operation: AirframeOperation(
                id: AirframeID("OP-GITHUB-EVIDENCE-COMMENT"),
                category: .evidence,
                requiresConfirmation: true
            )
        )
        let issueNumber = try githubIssueNumber(for: record)
        try transport.addComment(issueNumber: issueNumber, body: body, configuration: configuration)
        return mutationResult(
            record: record,
            issueNumber: issueNumber,
            mutation: "githubEvidenceComment",
            action: "OP-GITHUB-EVIDENCE-COMMENT",
            context: context,
            targetProjectID: targetProjectID
        )
    }

    public func transitionGitHubStatus(
        workItemID: AirframeID,
        to status: AirframeWorkStatus,
        approval: AirframeGitHubMutationApproval?,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws -> AirframeGitHubMutationResult {
        let record = try approvedMutationRecord(
            workItemID: workItemID,
            approval: approval,
            context: context,
            targetProjectID: targetProjectID,
            operation: AirframeOperation(
                id: operationID(for: status),
                category: operationCategory(for: status),
                requiresConfirmation: true
            )
        )
        let transition = AirframeWorkflowTransition(
            workItemID: workItemID,
            kind: record.workItem.kind,
            fromStatus: record.workItem.status,
            toStatus: status,
            operation: AirframeOperation(
                id: operationID(for: status),
                category: operationCategory(for: status),
                requiresConfirmation: false
            )
        )
        let workflowDecision = AirframeWorkflowTransitionEvaluator().evaluate(
            context: context,
            transition: transition,
            targetProjectID: targetProjectID
        )
        switch workflowDecision {
        case .allowed:
            break
        case .denied(let reason, _) where reason == .invalidTransition:
            throw AirframeBackendError.invalidTransition(from: record.workItem.status, to: status)
        case .denied(_, let authorityReason):
            throw AirframeBackendError.authorityDenied(authorityReason)
        case .requiresConfirmation(let reason):
            throw AirframeBackendError.requiresConfirmation(reason)
        }

        let issue = try transport.issue(number: try githubIssueNumber(for: record), configuration: configuration)
        let statusLabels = issue.labels.filter { $0.hasPrefix("status-") }
        let issueNumber = try githubIssueNumber(for: record)
        try transport.replaceStatusLabel(
            issueNumber: issueNumber,
            removing: statusLabels,
            adding: statusLabel(for: status),
            configuration: configuration
        )
        let updatedWorkItem = AirframeWorkItem(
            id: record.workItem.id,
            kind: record.workItem.kind,
            title: record.workItem.title,
            status: status,
            githubIssue: record.workItem.githubIssue
        )
        return mutationResult(
            record: record.updating(workItem: updatedWorkItem),
            issueNumber: issueNumber,
            mutation: "githubStatusLabelTransition",
            action: operationID(for: status).rawValue,
            context: context,
            targetProjectID: targetProjectID
        )
    }

    public func dashboardSummary() throws -> AirframeDashboardSummary {
        let records = try listWorkRecords()
        let workItems = records.map(\.workItem)
        let tasks = workItems.filter { $0.kind == .task }
        let nextTask = tasks
            .filter { $0.status == .active }
            .sorted { $0.id.rawValue < $1.id.rawValue }
            .first
        return AirframeDashboardSummary(
            totalWorkItemCount: workItems.count,
            activeTaskCount: tasks.filter { $0.status == .active }.count,
            unverifiedTaskCount: tasks.filter { $0.status == .implementedNotVerified }.count,
            verifiedTaskCount: tasks.filter { $0.status == .implementedVerified }.count,
            issueCount: workItems.filter { $0.kind == .issue }.count,
            nextTask: nextTask,
            recentEvidenceCount: 0
        )
    }

    private func isAirframeWorkIssue(_ issue: AirframeGitHubIssueRecord) -> Bool {
        let labels = Set(issue.labels)
        return labels.contains(configuration.taskLabel)
            || labels.contains(configuration.issueLabel)
            || issue.body.contains("Airframe ID:")
            || issue.body.contains("- id: T-")
            || issue.body.contains("- id: I-")
    }

    private func approvedMutationRecord(
        workItemID: AirframeID,
        approval: AirframeGitHubMutationApproval?,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID,
        operation: AirframeOperation
    ) throws -> AirframeLocalWorkRecord {
        guard capabilities.supportsGitHubIssueComments || capabilities.supportsGitHubStatusMutations else {
            throw AirframeBackendError.readOnlyBackend("controlled GitHub mutations")
        }
        guard approval?.isApproved == true else {
            throw AirframeBackendError.requiresConfirmation(.requiresConfirmation)
        }
        let decision = AirframeAuthorityEvaluator().evaluate(
            context: context,
            operation: AirframeOperation(
                id: operation.id,
                category: operation.category,
                requiresConfirmation: false
            ),
            targetProjectID: targetProjectID
        )
        guard decision.isAllowed else {
            throw AirframeBackendError.authorityDenied(decision.reason)
        }
        guard let record = try workRecord(id: workItemID) else {
            throw AirframeBackendError.missingWorkItem(workItemID)
        }
        return record
    }

    private func githubIssueNumber(for record: AirframeLocalWorkRecord) throws -> Int {
        guard let issueNumber = record.workItem.githubIssue else {
            throw AirframeBackendError.missingWorkItem(record.workItem.id)
        }
        return issueNumber
    }

    private func mutationResult(
        record: AirframeLocalWorkRecord,
        issueNumber: Int,
        mutation: String,
        action: String,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) -> AirframeGitHubMutationResult {
        AirframeGitHubMutationResult(
            workItem: record.workItem,
            githubIssue: issueNumber,
            mutation: mutation,
            auditEvent: AirframeAuditEventFactory().makeEvent(
                id: AirframeID("AUD-\(action)-\(record.workItem.id.rawValue)"),
                context: context,
                action: action,
                workItemID: record.workItem.id,
                decision: .allowed(),
                targetProjectID: targetProjectID
            )
        )
    }

    private func statusLabel(for status: AirframeWorkStatus) -> String {
        switch status {
        case .backlog:
            "status-backlog"
        case .active:
            "status-active"
        case .implementedNotVerified:
            "status-unverified"
        case .implementedVerified:
            "status-verified"
        case .closed:
            "status-closed"
        }
    }

    private func operationID(for status: AirframeWorkStatus) -> AirframeID {
        switch status {
        case .backlog:
            AirframeID("OP-GITHUB-MOVE-BACKLOG")
        case .active:
            AirframeID("OP-GITHUB-MOVE-ACTIVE")
        case .implementedNotVerified:
            AirframeID("OP-GITHUB-MARK-READY")
        case .implementedVerified:
            AirframeID("OP-HUMAN-VERIFY")
        case .closed:
            AirframeID("OP-GITHUB-CLOSE-WORK")
        }
    }

    private func operationCategory(for status: AirframeWorkStatus) -> AirframeOperationCategory {
        switch status {
        case .implementedVerified:
            .humanAcceptance
        case .closed:
            .destructive
        default:
            .workflowTransition
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
