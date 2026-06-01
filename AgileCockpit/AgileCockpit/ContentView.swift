import AirframeCore
import SwiftUI

struct AgileCockpitContextModel {
    let coreInfo: AirframeCoreInfo
    let context: AirframeProjectContext

    init(
        coreInfo: AirframeCoreInfo = .current,
        context: AirframeProjectContext
    ) {
        self.coreInfo = coreInfo
        self.context = context
    }

    static func sample() throws -> AgileCockpitContextModel {
        try AgileCockpitContextModel(
            context: AirframeConfigurationLoader().loadSampleContext()
        )
    }
}

struct ContentView: View {
    let model: AgileCockpitContextModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Agile Cockpit")
                .font(.title)
                .accessibilityIdentifier("agile-cockpit-title")
            Text(model.context.workspaceName)
                .font(.headline)
                .accessibilityIdentifier("agile-cockpit-workspace")
            Text(model.context.projectName)
                .font(.subheadline)
                .accessibilityIdentifier("agile-cockpit-project")
            Text("Active Sprint: \(model.context.project.activeSprintID?.rawValue ?? "None")")
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("agile-cockpit-active-sprint")
            Text(model.coreInfo.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("agile-cockpit-core-summary")
        }
        .padding(24)
        .frame(minWidth: 420, minHeight: 240)
    }
}

#Preview {
    ContentView(
        model: try! AgileCockpitContextModel.sample()
    )
}
