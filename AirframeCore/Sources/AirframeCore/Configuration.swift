import Foundation

public struct AirframeWorkspaceConfiguration: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let workspace: AirframeWorkspace
    public let projects: [AirframeProject]
    public let defaultProjectID: AirframeID
    public let backend: AirframeBackendReference

    public init(
        schemaVersion: Int,
        workspace: AirframeWorkspace,
        projects: [AirframeProject],
        defaultProjectID: AirframeID,
        backend: AirframeBackendReference
    ) {
        self.schemaVersion = schemaVersion
        self.workspace = workspace
        self.projects = projects
        self.defaultProjectID = defaultProjectID
        self.backend = backend
    }

    public var defaultProject: AirframeProject? {
        projects.first { $0.id == defaultProjectID }
    }
}

public struct AirframeWorkspace: Codable, Equatable, Sendable {
    public let id: AirframeID
    public let name: String
    public let rootPath: String

    public init(id: AirframeID, name: String, rootPath: String) {
        self.id = id
        self.name = name
        self.rootPath = rootPath
    }
}

public struct AirframeProject: Codable, Equatable, Sendable {
    public let id: AirframeID
    public let name: String
    public let repository: String
    public let activeSprintID: AirframeID?
    public let activeEpicID: AirframeID?

    public init(
        id: AirframeID,
        name: String,
        repository: String,
        activeSprintID: AirframeID?,
        activeEpicID: AirframeID?
    ) {
        self.id = id
        self.name = name
        self.repository = repository
        self.activeSprintID = activeSprintID
        self.activeEpicID = activeEpicID
    }
}

public struct AirframeProjectContext: Equatable, Sendable {
    public let configuration: AirframeWorkspaceConfiguration
    public let project: AirframeProject

    public init(configuration: AirframeWorkspaceConfiguration, project: AirframeProject) {
        self.configuration = configuration
        self.project = project
    }

    public var workspaceName: String {
        configuration.workspace.name
    }

    public var projectName: String {
        project.name
    }

    public var summaryLines: [String] {
        [
            "Workspace: \(workspaceName) (\(configuration.workspace.id.rawValue))",
            "Project: \(projectName) (\(project.id.rawValue))",
            "Repository: \(project.repository)",
            "Backend: \(configuration.backend.kind) at \(configuration.backend.location)",
            "Active Epic: \(project.activeEpicID?.rawValue ?? "None")",
            "Active Sprint: \(project.activeSprintID?.rawValue ?? "None")"
        ]
    }
}

public enum AirframeConfigurationError: Error, Equatable, CustomStringConvertible, Sendable {
    case missingFile(String)
    case unreadableData(String)
    case decodingFailed(String)
    case invalidConfiguration(String)

    public var description: String {
        switch self {
        case .missingFile(let path):
            "Missing configuration file: \(path)"
        case .unreadableData(let path):
            "Configuration file could not be read: \(path)"
        case .decodingFailed(let message):
            "Configuration decoding failed: \(message)"
        case .invalidConfiguration(let message):
            "Invalid configuration: \(message)"
        }
    }
}

public struct AirframeConfigurationLoader: Sendable {
    public let decoder: JSONDecoder

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    public func load(from url: URL) throws(AirframeConfigurationError) -> AirframeWorkspaceConfiguration {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw .missingFile(url.path)
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw .unreadableData(url.path)
        }

        return try load(data: data)
    }

    public func load(data: Data) throws(AirframeConfigurationError) -> AirframeWorkspaceConfiguration {
        let configuration: AirframeWorkspaceConfiguration
        do {
            configuration = try decoder.decode(AirframeWorkspaceConfiguration.self, from: data)
        } catch {
            throw .decodingFailed(error.localizedDescription)
        }

        try validate(configuration)
        return configuration
    }

    public func loadSampleConfiguration() throws(AirframeConfigurationError) -> AirframeWorkspaceConfiguration {
        guard let url = Bundle.module.url(
            forResource: "sample-airframe-workspace",
            withExtension: "json"
        ) else {
            throw .missingFile("sample-airframe-workspace.json")
        }

        return try load(from: url)
    }

    public func loadSampleContext() throws(AirframeConfigurationError) -> AirframeProjectContext {
        let configuration = try loadSampleConfiguration()
        guard let project = configuration.defaultProject else {
            throw .invalidConfiguration("Default project \(configuration.defaultProjectID.rawValue) is not defined.")
        }
        return AirframeProjectContext(configuration: configuration, project: project)
    }

    private func validate(_ configuration: AirframeWorkspaceConfiguration) throws(AirframeConfigurationError) {
        guard configuration.schemaVersion == 1 else {
            throw .invalidConfiguration("Unsupported schema version \(configuration.schemaVersion).")
        }

        guard !configuration.workspace.id.rawValue.isEmpty else {
            throw .invalidConfiguration("Workspace ID is required.")
        }

        guard !configuration.projects.isEmpty else {
            throw .invalidConfiguration("At least one project is required.")
        }

        let projectIDs = Set(configuration.projects.map(\.id))
        guard projectIDs.count == configuration.projects.count else {
            throw .invalidConfiguration("Project IDs must be unique.")
        }

        guard projectIDs.contains(configuration.defaultProjectID) else {
            throw .invalidConfiguration("Default project \(configuration.defaultProjectID.rawValue) is not defined.")
        }
    }
}
