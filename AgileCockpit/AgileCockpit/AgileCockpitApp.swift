import AirframeCore
import SwiftUI

@main
struct AgileCockpitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(coreInfo: .current)
        }
    }
}
