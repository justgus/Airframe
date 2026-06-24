import Foundation

public struct AirframeRequirementInterchangeDocument: Codable, Equatable, Sendable {
    public let metadata: AirframeCanonicalRecordMetadata
    public let requirements: [AirframeCanonicalRequirementRecord]
    public let revisions: [AirframeCanonicalRequirementRevisionRecord]

    public init(
        requirements: [AirframeCanonicalRequirementRecord] = [],
        revisions: [AirframeCanonicalRequirementRevisionRecord] = [],
        metadata: AirframeCanonicalRecordMetadata = AirframeCanonicalRecordMetadata()
    ) {
        self.metadata = metadata
        self.requirements = requirements
        self.revisions = revisions
    }
}

public enum AirframeRequirementImportRecordKind: String, Codable, Equatable, Sendable {
    case requirement
    case revision
}

public enum AirframeRequirementImportChangeKind: String, Codable, Equatable, Sendable {
    case created
    case updated
    case unchanged
    case removed
    case conflicted
}

public struct AirframeRequirementImportPreviewItem: Codable, Equatable, Sendable {
    public let recordKind: AirframeRequirementImportRecordKind
    public let changeKind: AirframeRequirementImportChangeKind
    public let id: AirframeID
    public let details: String
    public let conflicts: [String]

    public init(
        recordKind: AirframeRequirementImportRecordKind,
        changeKind: AirframeRequirementImportChangeKind,
        id: AirframeID,
        details: String,
        conflicts: [String] = []
    ) {
        self.recordKind = recordKind
        self.changeKind = changeKind
        self.id = id
        self.details = details
        self.conflicts = conflicts
    }
}

public struct AirframeRequirementImportPreview: Codable, Equatable, Sendable {
    public let requirements: [AirframeRequirementImportPreviewItem]
    public let revisions: [AirframeRequirementImportPreviewItem]

    public init(
        requirements: [AirframeRequirementImportPreviewItem] = [],
        revisions: [AirframeRequirementImportPreviewItem] = []
    ) {
        self.requirements = requirements
        self.revisions = revisions
    }

    public var createdCount: Int {
        requirements.filter { $0.changeKind == .created }.count + revisions.filter { $0.changeKind == .created }.count
    }

    public var updatedCount: Int {
        requirements.filter { $0.changeKind == .updated }.count + revisions.filter { $0.changeKind == .updated }.count
    }

    public var unchangedCount: Int {
        requirements.filter { $0.changeKind == .unchanged }.count + revisions.filter { $0.changeKind == .unchanged }.count
    }

    public var removedCount: Int {
        requirements.filter { $0.changeKind == .removed }.count + revisions.filter { $0.changeKind == .removed }.count
    }

    public var conflictedCount: Int {
        requirements.filter { $0.changeKind == .conflicted }.count + revisions.filter { $0.changeKind == .conflicted }.count
    }
}

public enum AirframeRequirementInterchangeError: Error, Equatable, Sendable {
    case unsupportedSchemaVersion(Int)
    case invalidCSV(String)
    case invalidRecordKind(String)
}

public struct AirframeRequirementInterchange: Sendable {
    public init() {}

    public func exportJSON(
        requirements: [AirframeCanonicalRequirementRecord],
        revisions: [AirframeCanonicalRequirementRevisionRecord] = []
    ) throws -> String {
        let document = AirframeRequirementInterchangeDocument(requirements: requirements, revisions: revisions)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(document)
        return String(decoding: data, as: UTF8.self)
    }

    public func importJSON(_ json: String) throws -> AirframeRequirementInterchangeDocument {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let data = Data(json.utf8)
        let document = try decoder.decode(AirframeRequirementInterchangeDocument.self, from: data)
        guard document.metadata.schemaVersion == .current else {
            throw AirframeRequirementInterchangeError.unsupportedSchemaVersion(document.metadata.schemaVersion.major)
        }
        return document
    }

    public func previewImportJSON(
        _ json: String,
        existingRequirements: [AirframeCanonicalRequirementRecord] = [],
        existingRevisions: [AirframeCanonicalRequirementRevisionRecord] = []
    ) throws -> AirframeRequirementImportPreview {
        let document = try importJSON(json)
        return previewImport(
            requirements: document.requirements,
            revisions: document.revisions,
            existingRequirements: existingRequirements,
            existingRevisions: existingRevisions
        )
    }

    public func exportCSV(
        requirements: [AirframeCanonicalRequirementRecord],
        revisions: [AirframeCanonicalRequirementRevisionRecord] = []
    ) throws -> String {
        let rows = requirements.map(requirementRow) + revisions.map(revisionRow)
        let headers = Self.csvHeaders
        var lines = [Self.csvEncodeRow(headers)]
        lines.append(contentsOf: rows.map(Self.csvEncodeRow))
        return lines.joined(separator: "\n") + "\n"
    }

    public func importCSV(_ csv: String) throws -> AirframeRequirementInterchangeDocument {
        var rows = try Self.csvDecode(csv)
        guard !rows.isEmpty else {
            return AirframeRequirementInterchangeDocument()
        }

        let header = rows.removeFirst()
        let mapping: [String: Int] = Dictionary(uniqueKeysWithValues: header.enumerated().map { ($0.element.lowercased(), $0.offset) })

        func value(_ row: [String], _ key: String) -> String? {
            guard let index = mapping[key], index < row.count else { return nil }
            let trimmed = row[index].trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }

        var requirements: [AirframeCanonicalRequirementRecord] = []
        var revisions: [AirframeCanonicalRequirementRevisionRecord] = []

        for row in rows {
            guard let kindRaw = value(row, "record_kind") else {
                throw AirframeRequirementInterchangeError.invalidCSV("Missing record_kind column.")
            }
            switch kindRaw {
            case "requirement":
                requirements.append(
                    AirframeCanonicalRequirementRecord(
                        id: AirframeID(value(row, "id") ?? ""),
                        title: value(row, "title") ?? "",
                        statement: value(row, "statement") ?? "",
                        status: try Self.requirementStatus(value(row, "status")),
                        rationale: value(row, "rationale") ?? "",
                        sourceKind: Self.requirementSourceKind(value(row, "source_kind")),
                        sourceURI: value(row, "source_uri"),
                        externalID: value(row, "external_id"),
                        priority: Self.priority(value(row, "priority")),
                        verificationMethod: Self.verificationMethod(value(row, "verification_method")),
                        validationRequired: Self.bool(value(row, "validation_required")),
                        releaseScope: Self.list(value(row, "release_scope")),
                        parentIDs: Self.ids(value(row, "parent_ids")),
                        derivedFromIDs: Self.ids(value(row, "derived_from_ids")),
                        supersedesIDs: Self.ids(value(row, "supersedes_ids")),
                        traceLinks: Self.traceLinks(value(row, "trace_links")),
                        deviationIDs: Self.ids(value(row, "deviation_ids")),
                        currentRevisionID: value(row, "current_revision_id").map(AirframeID.init),
                        changeRationale: value(row, "change_rationale")
                    )
                )
            case "revision":
                guard let revisionNumber = Int(value(row, "revision_number") ?? "") else {
                    throw AirframeRequirementInterchangeError.invalidCSV("Revision rows require revision_number.")
                }
                revisions.append(
                    AirframeCanonicalRequirementRevisionRecord(
                        id: AirframeID(value(row, "id") ?? ""),
                        requirementID: AirframeID(value(row, "requirement_id") ?? ""),
                        revisionNumber: revisionNumber,
                        title: value(row, "title") ?? "",
                        statement: value(row, "statement") ?? "",
                        status: try Self.requirementStatus(value(row, "status")),
                        rationale: value(row, "rationale") ?? "",
                        sourceKind: Self.requirementSourceKind(value(row, "source_kind")),
                        sourceURI: value(row, "source_uri"),
                        priority: Self.priority(value(row, "priority")),
                        verificationMethod: Self.verificationMethod(value(row, "verification_method")),
                        validationRequired: Self.bool(value(row, "validation_required")),
                        releaseScope: Self.list(value(row, "release_scope")),
                        parentIDs: Self.ids(value(row, "parent_ids")),
                        derivedFromIDs: Self.ids(value(row, "derived_from_ids")),
                        supersedesIDs: Self.ids(value(row, "supersedes_ids")),
                        traceLinks: Self.traceLinks(value(row, "trace_links")),
                        deviationIDs: Self.ids(value(row, "deviation_ids")),
                        changeRationale: value(row, "change_rationale")
                    )
                )
            default:
                throw AirframeRequirementInterchangeError.invalidRecordKind(kindRaw)
            }
        }

        return AirframeRequirementInterchangeDocument(requirements: requirements, revisions: revisions)
    }

    public func previewImportCSV(
        _ csv: String,
        existingRequirements: [AirframeCanonicalRequirementRecord] = [],
        existingRevisions: [AirframeCanonicalRequirementRevisionRecord] = []
    ) throws -> AirframeRequirementImportPreview {
        let document = try importCSV(csv)
        return previewImport(
            requirements: document.requirements,
            revisions: document.revisions,
            existingRequirements: existingRequirements,
            existingRevisions: existingRevisions
        )
    }

    private func requirementRow(_ requirement: AirframeCanonicalRequirementRecord) -> [String] {
        [
            "requirement",
            requirement.id.rawValue,
            "",
            "",
            requirement.externalID ?? "",
            requirement.title,
            requirement.statement,
            requirement.status.rawValue,
            requirement.rationale,
            requirement.sourceKind.rawValue,
            requirement.sourceURI ?? "",
            requirement.priority.rawValue,
            requirement.verificationMethod.rawValue,
            requirement.validationRequired ? "true" : "false",
            Self.join(requirement.releaseScope),
            Self.join(requirement.parentIDs.map(\.rawValue)),
            Self.join(requirement.derivedFromIDs.map(\.rawValue)),
            Self.join(requirement.supersedesIDs.map(\.rawValue)),
            Self.join(requirement.traceLinks.map(Self.traceLinkValue)),
            Self.join(requirement.deviationIDs.map(\.rawValue)),
            requirement.currentRevisionID?.rawValue ?? "",
            requirement.changeRationale ?? ""
        ]
    }

    private func revisionRow(_ revision: AirframeCanonicalRequirementRevisionRecord) -> [String] {
        [
            "revision",
            revision.id.rawValue,
            revision.requirementID.rawValue,
            String(revision.revisionNumber),
            "",
            revision.title,
            revision.statement,
            revision.status.rawValue,
            revision.rationale,
            revision.sourceKind.rawValue,
            revision.sourceURI ?? "",
            revision.priority.rawValue,
            revision.verificationMethod.rawValue,
            revision.validationRequired ? "true" : "false",
            Self.join(revision.releaseScope),
            Self.join(revision.parentIDs.map(\.rawValue)),
            Self.join(revision.derivedFromIDs.map(\.rawValue)),
            Self.join(revision.supersedesIDs.map(\.rawValue)),
            Self.join(revision.traceLinks.map(Self.traceLinkValue)),
            Self.join(revision.deviationIDs.map(\.rawValue)),
            "",
            revision.changeRationale ?? ""
        ]
    }

    private static let csvHeaders: [String] = [
        "record_kind",
        "id",
        "requirement_id",
        "revision_number",
        "external_id",
        "title",
        "statement",
        "status",
        "rationale",
        "source_kind",
        "source_uri",
        "priority",
        "verification_method",
        "validation_required",
        "release_scope",
        "parent_ids",
        "derived_from_ids",
        "supersedes_ids",
        "trace_links",
        "deviation_ids",
        "current_revision_id",
        "change_rationale"
    ]

    private static func csvEncodeRow(_ fields: [String]) -> String {
        fields.map(csvEscape).joined(separator: ",")
    }

    private static func csvEscape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") || value.contains("\r") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }

    private static func csvDecode(_ csv: String) throws -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentField = ""
        var isQuoted = false
        var iterator = csv.makeIterator()
        while let character = iterator.next() {
            switch character {
            case "\"":
                if isQuoted {
                    if let next = iterator.next() {
                        if next == "\"" {
                            currentField.append("\"")
                        } else {
                            isQuoted = false
                            if next == "," {
                                currentRow.append(currentField)
                                currentField = ""
                            } else if next == "\n" {
                                currentRow.append(currentField)
                                rows.append(currentRow)
                                currentRow = []
                                currentField = ""
                            } else if next == "\r" {
                                continue
                            } else {
                                currentField.append(next)
                            }
                        }
                    } else {
                        isQuoted = false
                    }
                } else if currentField.isEmpty {
                    isQuoted = true
                } else {
                    currentField.append(character)
                }
            case "," where !isQuoted:
                currentRow.append(currentField)
                currentField = ""
            case "\n" where !isQuoted:
                currentRow.append(currentField)
                rows.append(currentRow)
                currentRow = []
                currentField = ""
            case "\r" where !isQuoted:
                continue
            default:
                currentField.append(character)
            }
        }
        if !currentField.isEmpty || !currentRow.isEmpty {
            currentRow.append(currentField)
            rows.append(currentRow)
        }
        return rows
    }

    private static func join(_ values: [String]) -> String {
        values.joined(separator: "|")
    }

    private static func ids(_ value: String?) -> [AirframeID] {
        Self.list(value).map(AirframeID.init)
    }

    private static func list(_ value: String?) -> [String] {
        guard let value, !value.isEmpty else { return [] }
        return value.split(separator: "|", omittingEmptySubsequences: true).map(String.init)
    }

    private static func bool(_ value: String?) -> Bool {
        guard let value else { return false }
        return value.lowercased() == "true" || value == "1" || value.lowercased() == "yes"
    }

    private static func priority(_ value: String?) -> AirframeWorkPriority {
        AirframeWorkPriority(rawValue: value ?? "") ?? .medium
    }

    private static func requirementStatus(_ value: String?) throws -> AirframeRequirementLifecycleStatus {
        guard let value, let status = AirframeRequirementLifecycleStatus(rawValue: value) else {
            throw AirframeRequirementInterchangeError.invalidCSV("Missing or invalid requirement status.")
        }
        return status
    }

    private static func requirementSourceKind(_ value: String?) -> AirframeRequirementSourceKind {
        AirframeRequirementSourceKind(rawValue: value ?? "") ?? .airframe
    }

    private static func verificationMethod(_ value: String?) -> AirframeRequirementVerificationMethod {
        AirframeRequirementVerificationMethod(rawValue: value ?? "") ?? .test
    }

    private static func traceLinks(_ value: String?) -> [AirframeRequirementLink] {
        guard let value, !value.isEmpty else { return [] }
        return value.split(separator: "|", omittingEmptySubsequences: true).map { entry in
            let parts = entry.split(separator: ">", omittingEmptySubsequences: false).map { String($0) }
            if parts.count >= 3 {
                return AirframeRequirementLink(
                    id: AirframeID(parts[0]),
                    targetKind: parts[1],
                    targetID: parts[2],
                    title: parts.count > 3 ? parts[3] : nil
                )
            }
            return AirframeRequirementLink(id: AirframeID(String(entry)), targetKind: "unknown", targetID: String(entry))
        }
    }

    private static func traceLinkValue(_ link: AirframeRequirementLink) -> String {
        [link.id.rawValue, link.targetKind, link.targetID, link.title ?? ""].joined(separator: ">")
    }

    private func previewImport(
        requirements incomingRequirements: [AirframeCanonicalRequirementRecord],
        revisions incomingRevisions: [AirframeCanonicalRequirementRevisionRecord],
        existingRequirements: [AirframeCanonicalRequirementRecord],
        existingRevisions: [AirframeCanonicalRequirementRevisionRecord]
    ) -> AirframeRequirementImportPreview {
        let requirementItems = Self.previewRequirementItems(
            incomingRequirements: incomingRequirements,
            existingRequirements: existingRequirements
        )
        let revisionItems = Self.previewRevisionItems(
            incomingRevisions: incomingRevisions,
            existingRevisions: existingRevisions
        )
        return AirframeRequirementImportPreview(requirements: requirementItems, revisions: revisionItems)
    }

    private static func previewRequirementItems(
        incomingRequirements: [AirframeCanonicalRequirementRecord],
        existingRequirements: [AirframeCanonicalRequirementRecord]
    ) -> [AirframeRequirementImportPreviewItem] {
        var existingByID = Dictionary(uniqueKeysWithValues: existingRequirements.map { ($0.id, $0) })
        var seenIDs = Set<AirframeID>()
        var items: [AirframeRequirementImportPreviewItem] = []

        for requirement in incomingRequirements {
            if !seenIDs.insert(requirement.id).inserted {
                items.append(
                    AirframeRequirementImportPreviewItem(
                        recordKind: .requirement,
                        changeKind: .conflicted,
                        id: requirement.id,
                        details: "Duplicate requirement identifier in import payload.",
                        conflicts: ["duplicate-import-id"]
                    )
                )
                continue
            }

            guard let current = existingByID.removeValue(forKey: requirement.id) else {
                items.append(
                    AirframeRequirementImportPreviewItem(
                        recordKind: .requirement,
                        changeKind: .created,
                        id: requirement.id,
                        details: "New requirement will be created."
                    )
                )
                continue
            }

            let changeKind: AirframeRequirementImportChangeKind = current == requirement ? .unchanged : .updated
            items.append(
                AirframeRequirementImportPreviewItem(
                    recordKind: .requirement,
                    changeKind: changeKind,
                    id: requirement.id,
                    details: changeKind == .unchanged ? "Imported requirement matches canonical state." : "Imported requirement differs from canonical state."
                )
            )
        }

        for requirement in existingByID.values {
            items.append(
                AirframeRequirementImportPreviewItem(
                    recordKind: .requirement,
                    changeKind: .removed,
                    id: requirement.id,
                    details: "Canonical requirement is absent from the import payload."
                )
            )
        }

        return items.sorted { $0.id.rawValue < $1.id.rawValue }
    }

    private static func previewRevisionItems(
        incomingRevisions: [AirframeCanonicalRequirementRevisionRecord],
        existingRevisions: [AirframeCanonicalRequirementRevisionRecord]
    ) -> [AirframeRequirementImportPreviewItem] {
        var existingByID = Dictionary(uniqueKeysWithValues: existingRevisions.map { ($0.id, $0) })
        var seenIDs = Set<AirframeID>()
        var items: [AirframeRequirementImportPreviewItem] = []

        for revision in incomingRevisions {
            if !seenIDs.insert(revision.id).inserted {
                items.append(
                    AirframeRequirementImportPreviewItem(
                        recordKind: .revision,
                        changeKind: .conflicted,
                        id: revision.id,
                        details: "Duplicate revision identifier in import payload.",
                        conflicts: ["duplicate-import-id"]
                    )
                )
                continue
            }

            guard let current = existingByID.removeValue(forKey: revision.id) else {
                items.append(
                    AirframeRequirementImportPreviewItem(
                        recordKind: .revision,
                        changeKind: .created,
                        id: revision.id,
                        details: "New revision will be created."
                    )
                )
                continue
            }

            let changeKind: AirframeRequirementImportChangeKind = current == revision ? .unchanged : .updated
            items.append(
                AirframeRequirementImportPreviewItem(
                    recordKind: .revision,
                    changeKind: changeKind,
                    id: revision.id,
                    details: changeKind == .unchanged ? "Imported revision matches canonical state." : "Imported revision differs from canonical state."
                )
            )
        }

        for revision in existingByID.values {
            items.append(
                AirframeRequirementImportPreviewItem(
                    recordKind: .revision,
                    changeKind: .removed,
                    id: revision.id,
                    details: "Canonical revision is absent from the import payload."
                )
            )
        }

        return items.sorted { $0.id.rawValue < $1.id.rawValue }
    }
}
