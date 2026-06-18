import Foundation

public protocol AirframeCanonicalFileRecord: Codable, Sendable {
    static var canonicalDirectoryName: String { get }
    var canonicalRecordID: AirframeID { get }
}

extension AirframeCanonicalWorkspaceRecord: AirframeCanonicalFileRecord {
    public static let canonicalDirectoryName = "workspaces"
    public var canonicalRecordID: AirframeID { id }
}

extension AirframeCanonicalProjectRecord: AirframeCanonicalFileRecord {
    public static let canonicalDirectoryName = "projects"
    public var canonicalRecordID: AirframeID { id }
}

extension AirframeCanonicalEpicRecord: AirframeCanonicalFileRecord {
    public static let canonicalDirectoryName = "epics"
    public var canonicalRecordID: AirframeID { workItem.id }
}

extension AirframeCanonicalSprintRecord: AirframeCanonicalFileRecord {
    public static let canonicalDirectoryName = "sprints"
    public var canonicalRecordID: AirframeID { workItem.id }
}

extension AirframeCanonicalTaskRecord: AirframeCanonicalFileRecord {
    public static let canonicalDirectoryName = "tasks"
    public var canonicalRecordID: AirframeID { workItem.id }
}

extension AirframeCanonicalIssueRecord: AirframeCanonicalFileRecord {
    public static let canonicalDirectoryName = "issues"
    public var canonicalRecordID: AirframeID { workItem.id }
}

extension AirframeCanonicalAcceptanceCriterionRecord: AirframeCanonicalFileRecord {
    public static let canonicalDirectoryName = "acceptance-criteria"
    public var canonicalRecordID: AirframeID { id }
}

extension AirframeCanonicalEvidenceSummaryRecord: AirframeCanonicalFileRecord {
    public static let canonicalDirectoryName = "evidence"
    public var canonicalRecordID: AirframeID { id }
}

extension AirframeCanonicalAuditEventRecord: AirframeCanonicalFileRecord {
    public static let canonicalDirectoryName = "audit-events"
    public var canonicalRecordID: AirframeID { event.id }
}

extension AirframeCanonicalBackendMappingRecord: AirframeCanonicalFileRecord {
    public static let canonicalDirectoryName = "backend-mappings"
    public var canonicalRecordID: AirframeID { id }
}

extension AirframeCanonicalWorkflowDefinitionRecord: AirframeCanonicalFileRecord {
    public static let canonicalDirectoryName = "workflows"
    public var canonicalRecordID: AirframeID { id }
}

extension AirframeCanonicalWorkflowTransitionRecord: AirframeCanonicalFileRecord {
    public static let canonicalDirectoryName = "workflow-transitions"
    public var canonicalRecordID: AirframeID { id }
}

public final class AirframeCanonicalJSONStore: @unchecked Sendable {
    public let stateURL: URL

    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let lock = NSLock()

    public init(
        rootURL: URL,
        fileManager: FileManager = .default,
        encoder: JSONEncoder = AirframeCanonicalJSONStore.makeEncoder(),
        decoder: JSONDecoder = AirframeCanonicalJSONStore.makeDecoder()
    ) {
        self.stateURL = rootURL
            .appending(path: ".airframe")
            .appending(path: "state")
        self.fileManager = fileManager
        self.encoder = encoder
        self.decoder = decoder
    }

    public init(
        stateURL: URL,
        fileManager: FileManager = .default,
        encoder: JSONEncoder = AirframeCanonicalJSONStore.makeEncoder(),
        decoder: JSONDecoder = AirframeCanonicalJSONStore.makeDecoder()
    ) {
        self.stateURL = stateURL
        self.fileManager = fileManager
        self.encoder = encoder
        self.decoder = decoder
    }

    public func save<Record: AirframeCanonicalFileRecord>(_ record: Record) throws {
        try withLock {
            let directoryURL = directoryURL(for: Record.self)
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            } catch {
                throw AirframeBackendError.unwritableStore(directoryURL.path)
            }

            let data: Data
            do {
                data = try encoder.encode(record)
            } catch {
                throw AirframeBackendError.encodingFailed(error.localizedDescription)
            }

            do {
                try data.write(to: recordURL(for: record.canonicalRecordID, as: Record.self), options: .atomic)
            } catch {
                throw AirframeBackendError.unwritableStore(directoryURL.path)
            }
        }
    }

    public func load<Record: AirframeCanonicalFileRecord>(
        _ type: Record.Type,
        id: AirframeID
    ) throws -> Record? {
        try withLock {
            let url = recordURL(for: id, as: Record.self)
            guard fileManager.fileExists(atPath: url.path) else {
                return nil
            }

            return try readRecord(Record.self, from: url)
        }
    }

    public func list<Record: AirframeCanonicalFileRecord>(_ type: Record.Type) throws -> [Record] {
        try withLock {
            let directoryURL = directoryURL(for: Record.self)
            guard fileManager.fileExists(atPath: directoryURL.path) else {
                return []
            }

            let urls: [URL]
            do {
                urls = try fileManager.contentsOfDirectory(
                    at: directoryURL,
                    includingPropertiesForKeys: nil
                )
            } catch {
                throw AirframeBackendError.unreadableStore(directoryURL.path)
            }

            return try urls
                .filter { $0.pathExtension == "json" }
                .sorted { $0.lastPathComponent < $1.lastPathComponent }
                .map { try readRecord(Record.self, from: $0) }
        }
    }

    public func delete<Record: AirframeCanonicalFileRecord>(
        _ type: Record.Type,
        id: AirframeID
    ) throws {
        try withLock {
            let url = recordURL(for: id, as: Record.self)
            guard fileManager.fileExists(atPath: url.path) else {
                return
            }
            do {
                try fileManager.removeItem(at: url)
            } catch {
                throw AirframeBackendError.unwritableStore(url.path)
            }
        }
    }

    public func exists<Record: AirframeCanonicalFileRecord>(
        _ type: Record.Type,
        id: AirframeID
    ) -> Bool {
        withLock {
            fileManager.fileExists(atPath: recordURL(for: id, as: Record.self).path)
        }
    }

    public func recordURL<Record: AirframeCanonicalFileRecord>(
        for id: AirframeID,
        as type: Record.Type
    ) -> URL {
        directoryURL(for: Record.self).appending(path: "\(id.rawValue).json")
    }

    public func directoryURL<Record: AirframeCanonicalFileRecord>(
        for type: Record.Type
    ) -> URL {
        stateURL.appending(path: Record.canonicalDirectoryName)
    }

    public static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    public static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private func readRecord<Record: AirframeCanonicalFileRecord>(
        _ type: Record.Type,
        from url: URL
    ) throws -> Record {
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw AirframeBackendError.unreadableStore(url.path)
        }

        do {
            return try decoder.decode(Record.self, from: data)
        } catch {
            throw AirframeBackendError.decodingFailed(error.localizedDescription)
        }
    }

    private func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body()
    }
}

