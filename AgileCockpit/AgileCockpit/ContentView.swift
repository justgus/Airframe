import AirframeCore
import SwiftUI

struct ContentView: View {
    let coreInfo: AirframeCoreInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Agile Cockpit")
                .font(.title)
            Text("Workspace skeleton is ready.")
                .foregroundStyle(.secondary)
            Text(coreInfo.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(minWidth: 420, minHeight: 240)
    }
}

#Preview {
    ContentView(coreInfo: .current)
}
