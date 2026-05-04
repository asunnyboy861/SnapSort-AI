import SwiftData
import Foundation

@Model
class ScreenshotItem {
    var id: UUID = UUID()
    var assetIdentifier: String = ""
    var category: String = ScreenshotCategory.other.rawValue
    var ocrText: String? = nil
    var tags: [String] = []
    var createdAt: Date = Date()
    var isTemporary: Bool = false
    var isFavorite: Bool = false
    var isDeleted: Bool = false
    var fileSize: Int64 = 0
    var autoDeleteDate: Date? = nil

    init(assetIdentifier: String, category: ScreenshotCategory, ocrText: String? = nil) {
        self.id = UUID()
        self.assetIdentifier = assetIdentifier
        self.category = category.rawValue
        self.ocrText = ocrText
        self.tags = []
        self.createdAt = Date()
        self.isTemporary = category.isTemporary
        self.isFavorite = false
        self.isDeleted = false
        self.fileSize = 0
        self.autoDeleteDate = category.isTemporary ? Calendar.current.date(byAdding: .hour, value: 24, to: Date()) : nil
    }

    var categoryEnum: ScreenshotCategory {
        get { ScreenshotCategory(rawValue: category) ?? .other }
        set { category = newValue.rawValue }
    }
}
