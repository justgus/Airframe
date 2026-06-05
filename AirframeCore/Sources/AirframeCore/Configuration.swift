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

public struct AirframeRuntimeConfigurationResolver {
    public let environment: [String: String]
    public let currentDirectoryURL: URL
    public let fileManager: FileManager
    public let loader: AirframeConfigurationLoader

    public init(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        currentDirectoryURL: URL = URL(filePath: FileManager.default.currentDirectoryPath),
        fileManager: FileManager = .default,
        loader: AirframeConfigurationLoader = AirframeConfigurationLoader()
    ) {
        self.environment = environment
        self.currentDirectoryURL = currentDirectoryURL
        self.fileManager = fileManager
        self.loader = loader
    }

    public func configurationURL(explicitPath: String? = nil) -> URL? {
        if let explicitPath, !explicitPath.isEmpty {
            return URL(filePath: explicitPath)
        }
        if let environmentPath = environment["AIRFRAME_CONFIG_PATH"], !environmentPath.isEmpty {
            return URL(filePath: environmentPath)
        }

        let localURL = currentDirectoryURL
            .appending(path: ".airframe")
            .appending(path: "airframe-workspace.json")
        guard fileManager.fileExists(atPath: localURL.path) else {
            return nil
        }
        return localURL
    }

    public func storeURL(explicitPath: String? = nil) -> URL {
        if let explicitPath, !explicitPath.isEmpty {
            return URL(filePath: explicitPath)
        }
        if let environmentPath = environment["AIRFRAME_STORE_PATH"], !environmentPath.isEmpty {
            return URL(filePath: environmentPath)
        }

        return currentDirectoryURL
            .appending(path: ".airframe")
            .appending(path: "airframe-local-backend.json")
    }

    public func loadConfiguration(explicitPath: String? = nil) throws(AirframeConfigurationError) -> AirframeWorkspaceConfiguration {
        guard let configurationURL = configurationURL(explicitPath: explicitPath) else {
            return try loader.loadSampleConfiguration()
        }
        return try loader.load(from: configurationURL)
    }

    public func loadContext(explicitPath: String? = nil) throws(AirframeConfigurationError) -> AirframeProjectContext {
        let configuration = try loadConfiguration(explicitPath: explicitPath)
        return try loader.context(for: configuration)
    }
}

public enum AirframeConfigurationDiagnosticSeverity: String, Codable, Equatable, Sendable {
    case ok
    case warning
    case error
}

public struct AirframeConfigurationDiagnosticIssue: Codable, Equatable, Sendable {
    public let severity: AirframeConfigurationDiagnosticSeverity
    public let code: String
    public let message: String

    public init(
        severity: AirframeConfigurationDiagnosticSeverity,
        code: String,
        message: String
    ) {
        self.severity = severity
        self.code = code
        self.message = message
    }
}

public struct AirframeConfigurationDiagnostics: Codable, Equatable, Sendable {
    public let status: AirframeConfigurationDiagnosticSeverity
    public let workspaceID: AirframeID
    public let defaultProjectID: AirframeID
    public let projectCount: Int
    public let backendKind: String
    public let backendLocation: String
    public let issues: [AirframeConfigurationDiagnosticIssue]

    public init(
        status: AirframeConfigurationDiagnosticSeverity,
        workspaceID: AirframeID,
        defaultProjectID: AirframeID,
        projectCount: Int,
        backendKind: String,
        backendLocation: String,
        issues: [AirframeConfigurationDiagnosticIssue]
    ) {
        self.status = status
        self.workspaceID = workspaceID
        self.defaultProjectID = defaultProjectID
        self.projectCount = projectCount
        self.backendKind = backendKind
        self.backendLocation = backendLocation
        self.issues = issues
    }

    public var isValid: Bool {
        status != .error
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

    public func diagnostics(data: Data) throws(AirframeConfigurationError) -> AirframeConfigurationDiagnostics {
        let configuration: AirframeWorkspaceConfiguration
        do {
            configuration = try decoder.decode(AirframeWorkspaceConfiguration.self, from: data)
        } catch {
            throw .decodingFailed(error.localizedDescription)
        }

        return diagnostics(for: configuration)
    }

    public func diagnostics(for configuration: AirframeWorkspaceConfiguration) -> AirframeConfigurationDiagnostics {
        var issues: [AirframeConfigurationDiagnosticIssue] = []

        func issue(_ code: String, _ message: String) {
            issues.append(
                AirframeConfigurationDiagnosticIssue(
                    severity: .error,
                    code: code,
                    message: message
                )
            )
        }

        if configuration.schemaVersion != 1 {
            issue("unsupportedSchemaVersion", "Unsupported schema version \(configuration.schemaVersion).")
        }

        if configuration.workspace.id.rawValue.isEmpty {
            issue("missingWorkspaceID", "Workspace ID is required.")
        }

        if configuration.workspace.name.isEmpty {
            issue("missingWorkspaceName", "Workspace name is required.")
        }

        if configuration.workspace.rootPath.isEmpty {
            issue("missingWorkspaceRootPath", "Workspace root path is required.")
        }

        if configuration.projects.isEmpty {
            issue("missingProjects", "At least one project is required.")
        }

        let projectIDs = Set(configuration.projects.map(\.id))
        if projectIDs.count != configuration.projects.count {
            issue("duplicateProjectID", "Project IDs must be unique.")
        }

        if !projectIDs.contains(configuration.defaultProjectID) {
            issue(
                "missingDefaultProject",
                "Default project \(configuration.defaultProjectID.rawValue) is not defined."
            )
        }

        for project in configuration.projects {
            if project.id.rawValue.isEmpty {
                issue("missingProjectID", "Project ID is required.")
            }
            if project.name.isEmpty {
                issue("missingProjectName", "Project \(project.id.rawValue) name is required.")
            }
            if project.repository.isEmpty {
                issue("missingProjectRepository", "Project \(project.id.rawValue) repository is required.")
            }
            if let activeSprintID = project.activeSprintID, activeSprintID.rawValue.isEmpty {
                issue("missingActiveSprintID", "Project \(project.id.rawValue) active sprint ID is empty.")
            }
            if let activeEpicID = project.activeEpicID, activeEpicID.rawValue.isEmpty {
                issue("missingActiveEpicID", "Project \(project.id.rawValue) active epic ID is empty.")
            }
        }

        if configuration.backend.kind.isEmpty {
            issue("missingBackendKind", "Backend kind is required.")
        } else if AirframeBackendKind(rawValue: configuration.backend.kind) == nil {
            issue("unsupportedBackendKind", "Backend kind \(configuration.backend.kind) is not supported.")
        }

        if configuration.backend.location.isEmpty {
            issue("missingBackendLocation", "Backend location is required.")
        }

        if configuration.backend.kind.hasPrefix("github"),
           !configuration.backend.location.contains("/") {
            issue("invalidGitHubRepository", "GitHub backend location must be an owner/repository slug.")
        }

        return AirframeConfigurationDiagnostics(
            status: issues.contains { $0.severity == .error } ? .error : .ok,
            workspaceID: configuration.workspace.id,
            defaultProjectID: configuration.defaultProjectID,
            projectCount: configuration.projects.count,
            backendKind: configuration.backend.kind,
            backendLocation: configuration.backend.location,
            issues: issues
        )
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
        return try context(for: configuration)
    }

    public func context(for configuration: AirframeWorkspaceConfiguration) throws(AirframeConfigurationError) -> AirframeProjectContext {
        guard let project = configuration.defaultProject else {
            throw .invalidConfiguration("Default project \(configuration.defaultProjectID.rawValue) is not defined.")
        }
        return AirframeProjectContext(configuration: configuration, project: project)
    }

    private func validate(_ configuration: AirframeWorkspaceConfiguration) throws(AirframeConfigurationError) {
        let diagnostics = diagnostics(for: configuration)
        guard diagnostics.isValid else {
            let message = diagnostics.issues.first?.message ?? "Configuration failed validation."
            throw .invalidConfiguration(message)
        }
    }
}
