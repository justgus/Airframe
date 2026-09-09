import Foundation

/// Git-aware preflight for human-facing canonical-state mutations.  It never
/// changes the working tree or switches branches; routing is deliberately a
/// separate, explicit user action.
public struct AirframeWorkspaceMutationGuard: Sendable {
    public enum Decision: Equatable, Sendable {
        case allowed(branch: String)
        case requiresReviewBranch(currentBranch: String, isDirty: Bool)
        case unavailable(String)

        public var message: String {
            switch self {
            case .allowed(let branch):
                return "Workspace branch \(branch) is eligible for the requested mutation."
            case .requiresReviewBranch(let currentBranch, let isDirty):
                let dirtyDetail = isDirty ? " The working tree has uncommitted changes and was left untouched." : ""
                return "Canonical mutations are blocked on protected branch \(currentBranch). Select or create a review branch first.\(dirtyDetail)"
            case .unavailable(let detail):
                return "Cannot confirm a safe Git branch for this canonical mutation: \(detail)"
            }
        }

        public var isAllowed: Bool {
            if case .allowed = self { return true }
            return false
        }
    }

    public typealias CommandRunner = @Sendable (_ arguments: [String], _ rootURL: URL) throws -> String

    private let run: CommandRunner
    private let protectedBranches: Set<String>

    public init(protectedBranches: Set<String> = ["main", "master"]) {
        self.init(protectedBranches: protectedBranches, run: Self.runGit)
    }

    public init(
        protectedBranches: Set<String>,
        run: @escaping CommandRunner
    ) {
        self.protectedBranches = protectedBranches
        self.run = run
    }

    /// Git branch names cannot contain whitespace. Keep operator-entered
    /// labels readable while normalizing whitespace runs to a single hyphen.
    public static func normalizedBranchName(_ branch: String) -> String {
        branch
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
    }

    public func evaluate(rootURL: URL?) -> Decision {
        guard let rootURL else {
            return .unavailable("workspace root is not configured")
        }
        do {
            let branch = try run(["branch", "--show-current"], rootURL)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !branch.isEmpty else {
                return .unavailable("repository is in detached HEAD state")
            }
            let status = try run(["status", "--porcelain"], rootURL)
            if protectedBranches.contains(branch) {
                return .requiresReviewBranch(
                    currentBranch: branch,
                    isDirty: !status.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )
            }
            return .allowed(branch: branch)
        } catch {
            // Fixture and exported-only workspaces have no Git metadata to
            // protect. The guard applies when a repository is actually
            // present; it must not turn those read/write test fixtures into a
            // false protected-branch failure.
            if error.localizedDescription.localizedCaseInsensitiveContains("not a git repository") {
                return .allowed(branch: "non-git-workspace")
            }
            return .unavailable(error.localizedDescription)
        }
    }

    /// Routes only after the operator has supplied a destination. Uncommitted
    /// work is preserved; Git rejects a switch if the destination would make
    /// that preservation unsafe.
    public func route(
        rootURL: URL?,
        to branch: String,
        createIfMissing: Bool
    ) -> Decision {
        let destination = Self.normalizedBranchName(branch)
        guard !destination.isEmpty else {
            return .unavailable("a review branch name is required")
        }
        guard let rootURL else {
            return .unavailable("workspace root is not configured")
        }
        do {
            let listed = try run(["branch", "--list", destination], rootURL)
            if listed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                guard createIfMissing else {
                    return .unavailable("review branch \(destination) does not exist; enable branch creation or enter an existing branch")
                }
                _ = try run(["switch", "-c", destination], rootURL)
            } else {
                _ = try run(["switch", destination], rootURL)
            }
            return .allowed(branch: destination)
        } catch {
            return .unavailable(error.localizedDescription)
        }
    }

    private static func runGit(arguments: [String], rootURL: URL) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["-C", rootURL.path] + arguments
        let output = Pipe()
        let error = Pipe()
        process.standardOutput = output
        process.standardError = error
        try process.run()
        process.waitUntilExit()
        let outputData = output.fileHandleForReading.readDataToEndOfFile()
        guard process.terminationStatus == 0 else {
            let errorData = error.fileHandleForReading.readDataToEndOfFile()
            throw AirframeBackendError.githubAccessFailed(
                String(data: errorData, encoding: .utf8) ?? "git command failed"
            )
        }
        return String(data: outputData, encoding: .utf8) ?? ""
    }
}
