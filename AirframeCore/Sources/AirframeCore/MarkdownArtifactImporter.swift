import Foundation

public enum AirframeMarkdownImportDiagnosticCode: String, Codable, Equatable, Sendable {
    case unsupportedArtifact
    case missingRequiredField
    case ambiguousField
}

public struct AirframeMarkdownImportDiagnostic: Codable, Equatable, Sendable {
    public let severity: AirframeCanonicalDiagnosticSeverity
    public let code: AirframeMarkdownImportDiagnosticCode
    public let sourcePath: String?
    public let recordID: AirframeID?
    public let message: String

    public init(
        severity: AirframeCanonicalDiagnosticSeverity,
        code: AirframeMarkdownImportDiagnosticCode,
        sourcePath: String?,
        recordID: AirframeID?,
        message: String
    ) {
        self.severity = severity
        self.code = code
        self.sourcePath = sourcePath
        self.recordID = recordID
        self.message = message
    }
}

public struct AirframeMarkdownImportResult: Codable, Equatable, Sendable {
    public let epics: [AirframeCanonicalEpicRecord]
    public let sprints: [AirframeCanonicalSprintRecord]
    public let tasks: [AirframeCanonicalTaskRecord]
    public let issues: [AirframeCanonicalIssueRecord]
    public let diagnostics: [AirframeMarkdownImportDiagnostic]

    public init(
        epics: [AirframeCanonicalEpicRecord] = [],
        sprints: [AirframeCanonicalSprintRecord] = [],
        tasks: [AirframeCanonicalTaskRecord] = [],
        issues: [AirframeCanonicalIssueRecord] = [],
        diagnostics: [AirframeMarkdownImportDiagnostic] = []
    ) {
        self.epics = epics
        self.sprints = sprints
        self.tasks = tasks
        self.issues = issues
        self.diagnostics = diagnostics
    }

    public var isClean: Bool {
        !diagnostics.contains { $0.severity == .error || $0.severity == .blocking }
    }

    public func merged(with other: AirframeMarkdownImportResult) -> AirframeMarkdownImportResult {
        AirframeMarkdownImportResult(
            epics: epics + other.epics,
            sprints: sprints + other.sprints,
            tasks: tasks + other.tasks,
            issues: issues + other.issues,
            diagnostics: diagnostics + other.diagnostics
        )
    }
}

public struct AirframeMarkdownArtifactImporter: Sendable {
    public init() {}

    public func importDocuments(_ documents: [AirframeMarkdownDocument]) -> AirframeMarkdownImportResult {
        documents.reduce(AirframeMarkdownImportResult()) { result, document in
            result.merged(
                with: importDocument(document.markdown, sourcePath: document.sourcePath)
            )
        }
    }

    public func importDocument(_ markdown: String, sourcePath: String? = nil) -> AirframeMarkdownImportResult {
        let sections = AirframeMarkdownRecordSection.sections(in: markdown)
        guard !sections.isEmpty else {
            return AirframeMarkdownImportResult(
                diagnostics: [
                    AirframeMarkdownImportDiagnostic(
                        severity: .warning,
                        code: .unsupportedArtifact,
                        sourcePath: sourcePath,
                        recordID: nil,
                        message: "No Airframe artifact record heading was found."
                    )
                ]
            )
        }

        var epics: [AirframeCanonicalEpicRecord] = []
        var sprints: [AirframeCanonicalSprintRecord] = []
        var tasks: [AirframeCanonicalTaskRecord] = []
        var issues: [AirframeCanonicalIssueRecord] = []
        var diagnostics: [AirframeMarkdownImportDiagnostic] = []

        for section in sections {
            switch section.kind {
            case .epic:
                let imported = importEpic(section, sourcePath: sourcePath)
                imported.record.map { epics.append($0) }
                diagnostics.append(contentsOf: imported.diagnostics)
            case .sprint:
                let imported = importSprint(section, sourcePath: sourcePath)
                imported.record.map { sprints.append($0) }
                diagnostics.append(contentsOf: imported.diagnostics)
            case .task:
                let imported = importTask(section, sourcePath: sourcePath)
                imported.record.map { tasks.append($0) }
                diagnostics.append(contentsOf: imported.diagnostics)
            case .issue:
                let imported = importIssue(section, sourcePath: sourcePath)
                imported.record.map { issues.append($0) }
                diagnostics.append(contentsOf: imported.diagnostics)
            }
        }

        return AirframeMarkdownImportResult(
            epics: epics.sorted { $0.workItem.id.rawValue < $1.workItem.id.rawValue },
            sprints: sprints.sorted { $0.workItem.id.rawValue < $1.workItem.id.rawValue },
            tasks: tasks.sorted { $0.workItem.id.rawValue < $1.workItem.id.rawValue },
            issues: issues.sorted { $0.workItem.id.rawValue < $1.workItem.id.rawValue },
            diagnostics: diagnostics
        )
    }

    private func importEpic(
        _ section: AirframeMarkdownRecordSection,
        sourcePath: String?
    ) -> (record: AirframeCanonicalEpicRecord?, diagnostics: [AirframeMarkdownImportDiagnostic]) {
        let status = statusValue(section.field("Status"))
        var diagnostics = requiredDiagnostics(for: section, status: status, sourcePath: sourcePath)
        let record = AirframeCanonicalEpicRecord(
            workItem: AirframeWorkItem(
                id: section.id,
                kind: .epic,
                title: section.title,
                status: status ?? .backlog
            ),
            owner: section.field("Owner") ?? "",
            goal: section.block("Goal") ?? "",
            rationale: section.block("Rationale") ?? "",
            startDate: normalizedOptional(section.field("Start Date")),
            targetCloseDate: normalizedOptional(section.field("Target Close Date")),
            closeDate: normalizedOptional(section.field("Close Date")),
            scope: section.listBlock("Scope"),
            outOfScope: section.listBlock("Out of Scope"),
            acceptanceCriterionIDs: section.relatedIDs(withPrefix: "AC"),
            sprintIDs: section.relatedIDs(withPrefix: "SP"),
            taskIDs: section.relatedIDs(withPrefix: "T"),
            issueIDs: section.relatedIDs(withPrefix: "I"),
            planningDocumentPaths: section.linkTargets(),
            notes: section.notes(excluding: ["Goal", "Rationale", "Scope", "Out of Scope"]),
            metadata: metadata(sourcePath)
        )
        diagnostics.append(contentsOf: ambiguityDiagnostics(for: section, sourcePath: sourcePath))
        return (record, diagnostics)
    }

    private func importSprint(
        _ section: AirframeMarkdownRecordSection,
        sourcePath: String?
    ) -> (record: AirframeCanonicalSprintRecord?, diagnostics: [AirframeMarkdownImportDiagnostic]) {
        let status = statusValue(section.field("Status"))
        var diagnostics = requiredDiagnostics(for: section, status: status, sourcePath: sourcePath)
        let record = AirframeCanonicalSprintRecord(
            workItem: AirframeWorkItem(
                id: section.id,
                kind: .sprint,
                title: section.title,
                status: status ?? .backlog
            ),
            epicID: section.relatedID(fromField: "Epic", prefix: "EP"),
            goal: section.field("Goal") ?? section.block("Goal") ?? "",
            startDate: normalizedOptional(section.field("Start Date")),
            endDate: normalizedOptional(section.field("End Date")),
            capacity: normalizedOptional(section.field("Capacity")),
            taskIDs: section.relatedIDs(withPrefix: "T"),
            issueIDs: section.relatedIDs(withPrefix: "I"),
            notes: section.notes(excluding: ["Sprint Notes", "Planning Notes"]),
            metadata: metadata(sourcePath)
        )
        diagnostics.append(contentsOf: ambiguityDiagnostics(for: section, sourcePath: sourcePath))
        return (record, diagnostics)
    }

    private func importTask(
        _ section: AirframeMarkdownRecordSection,
        sourcePath: String?
    ) -> (record: AirframeCanonicalTaskRecord?, diagnostics: [AirframeMarkdownImportDiagnostic]) {
        let status = statusValue(section.field("Status"))
        var diagnostics = requiredDiagnostics(for: section, status: status, sourcePath: sourcePath)
        let record = AirframeCanonicalTaskRecord(
            workItem: AirframeWorkItem(
                id: section.id,
                kind: .task,
                title: section.title,
                status: status ?? .backlog,
                githubIssue: githubIssue(section.field("GitHub Issue"))
            ),
            component: section.field("Component") ?? "",
            priority: priorityValue(section.field("Priority")),
            rationale: section.block("Rationale") ?? "",
            epicID: section.relatedID(fromField: "Epic", prefix: "EP"),
            sprintID: section.relatedID(fromField: "Sprint Assigned", prefix: "SP"),
            dateRequested: normalizedOptional(section.field("Date Requested")),
            dateImplemented: normalizedOptional(section.field("Date Implemented")),
            dateVerified: normalizedOptional(section.field("Date Verified")),
            acceptanceCriteria: section.numberedBlock("Acceptance Criteria"),
            implementationDetails: section.bulletTextBlock("Implementation Notes"),
            evidenceIDs: section.relatedIDs(inBlock: "Evidence", withPrefix: "EV"),
            notes: section.notes(excluding: ["Rationale", "Acceptance Criteria", "Implementation Notes", "Evidence"]),
            metadata: metadata(sourcePath)
        )
        diagnostics.append(contentsOf: ambiguityDiagnostics(for: section, sourcePath: sourcePath))
        return (record, diagnostics)
    }

    private func importIssue(
        _ section: AirframeMarkdownRecordSection,
        sourcePath: String?
    ) -> (record: AirframeCanonicalIssueRecord?, diagnostics: [AirframeMarkdownImportDiagnostic]) {
        let status = statusValue(section.field("Status"))
        var diagnostics = requiredDiagnostics(for: section, status: status, sourcePath: sourcePath)
        let record = AirframeCanonicalIssueRecord(
            workItem: AirframeWorkItem(
                id: section.id,
                kind: .issue,
                title: section.title,
                status: status ?? .backlog,
                githubIssue: githubIssue(section.field("GitHub Issue"))
            ),
            severity: priorityValue(section.field("Severity")),
            observedBehavior: section.block("Observed Behavior") ?? section.block("Current Behavior") ?? "",
            expectedBehavior: section.block("Expected Behavior") ?? section.block("Desired Behavior") ?? "",
            epicID: section.relatedID(fromField: "Epic", prefix: "EP"),
            sprintID: section.relatedID(fromField: "Sprint Assigned", prefix: "SP"),
            dateReported: normalizedOptional(section.field("Date Reported") ?? section.field("Date Requested")),
            dateResolved: normalizedOptional(section.field("Date Resolved") ?? section.field("Date Implemented")),
            dateVerified: normalizedOptional(section.field("Date Verified")),
            reproductionSteps: section.numberedBlock("Reproduction Steps"),
            affectedComponents: section.csvField("Affected Components"),
            evidenceIDs: section.relatedIDs(inBlock: "Evidence", withPrefix: "EV"),
            notes: section.notes(excluding: ["Observed Behavior", "Expected Behavior", "Reproduction Steps", "Evidence"]),
            metadata: metadata(sourcePath)
        )
        diagnostics.append(contentsOf: ambiguityDiagnostics(for: section, sourcePath: sourcePath))
        return (record, diagnostics)
    }

    private func requiredDiagnostics(
        for section: AirframeMarkdownRecordSection,
        status: AirframeWorkStatus?,
        sourcePath: String?
    ) -> [AirframeMarkdownImportDiagnostic] {
        var diagnostics: [AirframeMarkdownImportDiagnostic] = []
        if section.title.isEmpty {
            diagnostics.append(missingDiagnostic("title", section: section, sourcePath: sourcePath))
        }
        if status == nil {
            diagnostics.append(missingDiagnostic("Status", section: section, sourcePath: sourcePath))
        }
        return diagnostics
    }

    private func ambiguityDiagnostics(
        for section: AirframeMarkdownRecordSection,
        sourcePath: String?
    ) -> [AirframeMarkdownImportDiagnostic] {
        section.ambiguousFields.map {
            AirframeMarkdownImportDiagnostic(
                severity: .warning,
                code: .ambiguousField,
                sourcePath: sourcePath,
                recordID: section.id,
                message: "Field \($0) is TBD or otherwise ambiguous."
            )
        }
    }

    private func missingDiagnostic(
        _ field: String,
        section: AirframeMarkdownRecordSection,
        sourcePath: String?
    ) -> AirframeMarkdownImportDiagnostic {
        AirframeMarkdownImportDiagnostic(
            severity: .error,
            code: .missingRequiredField,
            sourcePath: sourcePath,
            recordID: section.id,
            message: "Required field \(field) is missing."
        )
    }

    private func metadata(_ sourcePath: String?) -> AirframeCanonicalRecordMetadata {
        AirframeCanonicalRecordMetadata(source: sourcePath)
    }

    private func statusValue(_ rawValue: String?) -> AirframeWorkStatus? {
        guard let rawValue = normalizedOptional(rawValue)?.lowercased() else {
            return nil
        }
        switch rawValue {
        case "proposed": return .proposed
        case "draft": return .draft
        case "backlog": return .backlog
        case "planning": return .planning
        case "active", "in progress": return .active
        case "review": return .review
        case "implemented", "implemented - not verified", "resolved", "resolved - not verified":
            return .implementedNotVerified
        case "verified", "implemented - verified", "resolved - verified":
            return .implementedVerified
        case "complete": return .complete
        case "closed": return .closed
        default: return nil
        }
    }

    private func priorityValue(_ rawValue: String?) -> AirframeWorkPriority {
        switch normalizedOptional(rawValue)?.lowercased() {
        case "high": .high
        case "low": .low
        default: .medium
        }
    }

    private func githubIssue(_ rawValue: String?) -> Int? {
        guard let rawValue else { return nil }
        return firstID(in: rawValue, prefix: "#").flatMap { Int($0.rawValue.dropFirst()) }
    }

    private func normalizedOptional(_ rawValue: String?) -> String? {
        guard let value = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty,
              value.uppercased() != "TBD",
              value != "-" else {
            return nil
        }
        return value
    }
}

public struct AirframeMarkdownDocument: Codable, Equatable, Sendable {
    public let sourcePath: String?
    public let markdown: String

    public init(sourcePath: String? = nil, markdown: String) {
        self.sourcePath = sourcePath
        self.markdown = markdown
    }
}

private struct AirframeMarkdownRecordSection {
    let id: AirframeID
    let kind: AirframeWorkItemKind
    let title: String
    let lines: [String]

    var ambiguousFields: [String] {
        lines.compactMap { line in
            guard let field = Self.fieldNameAndValue(from: line),
                  field.value.uppercased() == "TBD" else {
                return nil
            }
            return field.name
        }
    }

    func field(_ name: String) -> String? {
        lines.lazy.compactMap(Self.fieldNameAndValue(from:)).first {
            $0.name == name
        }?.value
    }

    func csvField(_ name: String) -> [String] {
        field(name)?
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty } ?? []
    }

    func block(_ name: String) -> String? {
        let blockLines = blockLines(name)
        guard !blockLines.isEmpty else { return nil }
        return blockLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func bulletTextBlock(_ name: String) -> String? {
        let values = listBlock(name)
        guard !values.isEmpty else { return block(name) }
        return values.joined(separator: "\n")
    }

    func listBlock(_ name: String) -> [String] {
        blockLines(name).compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("- ") else { return nil }
            return String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces)
        }
    }

    func numberedBlock(_ name: String) -> [String] {
        blockLines(name).compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard let dotIndex = trimmed.firstIndex(of: "."),
                  trimmed[..<dotIndex].allSatisfy(\.isNumber) else {
                return nil
            }
            return String(trimmed[trimmed.index(after: dotIndex)...])
                .trimmingCharacters(in: .whitespaces)
        }
    }

    func notes(excluding names: [String]) -> [String] {
        var notes: [String] = []
        var index = 0
        while index < lines.count {
            let line = lines[index]
            if let field = Self.boldHeading(from: line), !names.contains(field) {
                let values = collectBlockLines(after: index)
                if !values.isEmpty {
                    notes.append("\(field): \(values.joined(separator: " "))")
                }
            }
            index += 1
        }
        return notes
    }

    func relatedID(fromField fieldName: String, prefix: String) -> AirframeID? {
        field(fieldName).flatMap { firstID(in: $0, prefix: prefix) }
    }

    func relatedIDs(withPrefix prefix: String) -> [AirframeID] {
        var ids: [AirframeID] = []
        for line in lines {
            ids.append(contentsOf: idsIn(line, prefix: prefix))
        }
        return stableUnique(ids)
    }

    func relatedIDs(inBlock blockName: String, withPrefix prefix: String) -> [AirframeID] {
        stableUnique(blockLines(blockName).flatMap { idsIn($0, prefix: prefix) })
    }

    func linkTargets() -> [String] {
        var targets: [String] = []
        for line in lines {
            var remainder = line[...]
            while let open = remainder.firstIndex(of: "("),
                  let close = remainder[open...].firstIndex(of: ")") {
                let target = String(remainder[remainder.index(after: open)..<close])
                if target.hasPrefix("../") || target.hasPrefix("docs/") {
                    targets.append(target)
                }
                remainder = remainder[remainder.index(after: close)...]
            }
        }
        return stableUnique(targets)
    }

    private func blockLines(_ name: String) -> [String] {
        guard let index = lines.firstIndex(where: { Self.boldHeading(from: $0) == name }) else {
            return []
        }
        return collectBlockLines(after: index)
    }

    private func collectBlockLines(after index: Int) -> [String] {
        var values: [String] = []
        for line in lines.dropFirst(index + 1) {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                if values.isEmpty {
                    continue
                }
                break
            }
            if trimmed.hasPrefix("#") || Self.fieldNameAndValue(from: trimmed) != nil || Self.boldHeading(from: trimmed) != nil {
                break
            }
            values.append(trimmed)
        }
        return values
    }

    static func sections(in markdown: String) -> [AirframeMarkdownRecordSection] {
        let lines = markdown.components(separatedBy: .newlines)
        var headings: [(index: Int, id: AirframeID, kind: AirframeWorkItemKind, title: String)] = []
        for (index, line) in lines.enumerated() {
            guard let heading = recordHeading(from: line) else {
                continue
            }
            headings.append((index, heading.id, heading.kind, heading.title))
        }
        return headings.enumerated().map { offset, heading in
            let end = offset + 1 < headings.count ? headings[offset + 1].index : lines.count
            return AirframeMarkdownRecordSection(
                id: heading.id,
                kind: heading.kind,
                title: heading.title,
                lines: Array(lines[(heading.index + 1)..<end])
            )
        }
    }

    static func fieldNameAndValue(from line: String) -> (name: String, value: String)? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix("**"),
              let close = trimmed.dropFirst(2).range(of: ":**") else {
            return nil
        }
        let name = String(trimmed[trimmed.index(trimmed.startIndex, offsetBy: 2)..<close.lowerBound])
        let value = String(trimmed[close.upperBound...]).trimmingCharacters(in: .whitespaces)
        return (name, value)
    }

    static func boldHeading(from line: String) -> String? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix("**"),
              trimmed.hasSuffix(":**"),
              !trimmed.contains(" ") || trimmed.contains(":**") else {
            return nil
        }
        return String(trimmed.dropFirst(2).dropLast(3))
    }

    private static func recordHeading(from line: String) -> (id: AirframeID, kind: AirframeWorkItemKind, title: String)? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix("#") else {
            return nil
        }
        let withoutMarks = trimmed.drop(while: { $0 == "#" }).trimmingCharacters(in: .whitespaces)
        guard let colonIndex = withoutMarks.firstIndex(of: ":") else {
            return nil
        }
        let idValue = String(withoutMarks[..<colonIndex])
        guard let kind = kind(for: idValue) else {
            return nil
        }
        let title = String(withoutMarks[withoutMarks.index(after: colonIndex)...])
            .trimmingCharacters(in: .whitespaces)
        return (AirframeID(idValue), kind, title)
    }

    private static func kind(for idValue: String) -> AirframeWorkItemKind? {
        if idValue.hasPrefix("EP-") { return .epic }
        if idValue.hasPrefix("SP-") { return .sprint }
        if idValue.hasPrefix("T-") { return .task }
        if idValue.hasPrefix("I-") { return .issue }
        return nil
    }
}

private func firstID(in value: String, prefix: String) -> AirframeID? {
    idsIn(value, prefix: prefix).first
}

private func idsIn(_ value: String, prefix: String) -> [AirframeID] {
    let pattern: String
    if prefix == "#" {
        pattern = #"#[0-9]+"#
    } else if prefix == "AC" {
        pattern = #"EP-[0-9]{3}-AC-[0-9]{2}"#
    } else {
        pattern = #"\#(prefix)-[0-9]{4}|\#(prefix)-[0-9]{3}"#
    }
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
        return []
    }
    let range = NSRange(value.startIndex..<value.endIndex, in: value)
    return regex.matches(in: value, range: range).compactMap { match in
        guard let range = Range(match.range, in: value) else { return nil }
        return AirframeID(String(value[range]))
    }
}

private func stableUnique<Value: Hashable>(_ values: [Value]) -> [Value] {
    var seen = Set<Value>()
    var result: [Value] = []
    for value in values where !seen.contains(value) {
        seen.insert(value)
        result.append(value)
    }
    return result
}
