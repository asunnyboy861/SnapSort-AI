import SwiftData
import Foundation

@Model
class CategoryFolder {
    var id: UUID = UUID()
    var name: String = ""
    var icon: String = "folder"
    var colorHex: String = "B2BEC3"
    var screenshotIds: [String] = []
    var createdAt: Date = Date()

    init(name: String, icon: String, colorHex: String) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.screenshotIds = []
        self.createdAt = Date()
    }
}
