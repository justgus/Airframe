import AirframeCore
import Foundation
import SwiftUI

@main
struct AgileCockpitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                model: (try? AgileCockpitDashboardModel.configured())
                    ?? (try? AgileCockpitDashboardModel.sample())
                    ?? AgileCockpitApp.fallbackModel()
            )
        }
    }

    @MainActor
    private static func fallbackModel() -> AgileCockpitDashboardModel {
        let project = AirframeProject(
            id: AirframeID("PRJ-UNAVAILABLE"),
            name: "Unavailable Project",
            repository: "unknown",
            activeSprintID: nil,
            activeEpicID: nil
        )
        let configuration = AirframeWorkspaceConfiguration(
            schemaVersion: 1,
            workspace: AirframeWorkspace(
                id: AirframeID("WS-UNAVAILABLE"),
                name: "Unavailable Workspace",
                rootPath: "."
            ),
            projects: [project],
            defaultProjectID: project.id,
            backend: AirframeBackendReference(
                kind: "unavailable",
                location: "unavailable"
            )
        )
        let context = AirframeProjectContext(configuration: configuration, project: project)
        let backend = AirframeLocalFilesystemBackend(
            storeURL: FileManager.default.temporaryDirectory
                .appending(path: "AgileCockpitFallback")
                .appending(path: "airframe-local-backend.json")
        )
        let actor = AirframeActor(
            id: AirframeID("ACTOR-FALLBACK-REVIEWER"),
            displayName: "Fallback Reviewer",
            authorityClass: .humanReviewer,
            credentialSource: .xcodeSession
        )
        let credential = AirframeCredentialContext(
            credentialID: AirframeID("CRED-FALLBACK-REVIEWER"),
            actorID: actor.id,
            credentialSource: .xcodeSession,
            executionProjectID: project.id,
            allowedProjectIDs: [project.id]
        )
        let reviewer = try! AirframeCertifiedContext(
            actor: actor,
            credential: credential,
            targetProjectID: project.id
        )

        return try! AgileCockpitDashboardModel(
            context: context,
            backend: backend,
            reviewerContext: reviewer
        )
    }
}
