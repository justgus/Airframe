import AirframeCore
import SwiftUI

@main
struct AgileCockpitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                model: (try? AgileCockpitContextModel.sample()) ?? AgileCockpitContextModel(
                    context: AirframeProjectContext(
                        configuration: AirframeWorkspaceConfiguration(
                            schemaVersion: 1,
                            workspace: AirframeWorkspace(
                                id: AirframeID("WS-UNAVAILABLE"),
                                name: "Unavailable Workspace",
                                rootPath: "."
                            ),
                            projects: [
                                AirframeProject(
                                    id: AirframeID("PRJ-UNAVAILABLE"),
                                    name: "Unavailable Project",
                                    repository: "unknown",
                                    activeSprintID: nil,
                                    activeEpicID: nil
                                )
                            ],
                            defaultProjectID: AirframeID("PRJ-UNAVAILABLE"),
                            backend: AirframeBackendReference(
                                kind: "unavailable",
                                location: "unavailable"
                            )
                        ),
                        project: AirframeProject(
                            id: AirframeID("PRJ-UNAVAILABLE"),
                            name: "Unavailable Project",
                            repository: "unknown",
                            activeSprintID: nil,
                            activeEpicID: nil
                        )
                    )
                )
            )
        }
    }
}
