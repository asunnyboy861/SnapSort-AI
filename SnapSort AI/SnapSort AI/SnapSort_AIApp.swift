import SwiftUI
import SwiftData

@main
struct SnapSort_AIApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [ScreenshotItem.self, CategoryFolder.self])
    }
}
