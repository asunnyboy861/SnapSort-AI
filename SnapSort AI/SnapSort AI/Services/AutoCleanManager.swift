import Foundation
import Photos
import SwiftData

class AutoCleanManager {
    static let shared = AutoCleanManager()

    func fetchExpiredScreenshots(context: ModelContext) -> [ScreenshotItem] {
        let now = Date()
        let descriptor = FetchDescriptor<ScreenshotItem>(
            predicate: #Predicate { $0.isTemporary && $0.autoDeleteDate != nil && $0.autoDeleteDate! < now && !$0.isDeleted }
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func fetchCleanupSuggestions(context: ModelContext) -> [ScreenshotItem] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let descriptor = FetchDescriptor<ScreenshotItem>(
            predicate: #Predicate { $0.isTemporary && $0.createdAt < sevenDaysAgo && !$0.isDeleted }
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func deleteScreenshot(assetIdentifier: String) async -> Bool {
        let fetchResult = PHAsset.fetchAssets(
            withLocalIdentifiers: [assetIdentifier],
            options: nil
        )
        guard let asset = fetchResult.firstObject else { return false }

        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([asset] as NSFastEnumeration)
            }) { success, _ in
                continuation.resume(returning: success)
            }
        }
    }

    func markAsDeleted(_ item: ScreenshotItem, context: ModelContext) {
        item.isDeleted = true
        try? context.save()
    }

    func totalStorageUsed(context: ModelContext) -> Int64 {
        let descriptor = FetchDescriptor<ScreenshotItem>(
            predicate: #Predicate { !$0.isDeleted }
        )
        let items = (try? context.fetch(descriptor)) ?? []
        return items.reduce(0) { $0 + $1.fileSize }
    }

    func categoryCount(context: ModelContext, category: ScreenshotCategory) -> Int {
        let rawValue = category.rawValue
        let descriptor = FetchDescriptor<ScreenshotItem>(
            predicate: #Predicate { $0.category == rawValue && !$0.isDeleted }
        )
        return (try? context.fetchCount(descriptor)) ?? 0
    }

    func totalScreenshotCount(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<ScreenshotItem>(
            predicate: #Predicate { !$0.isDeleted }
        )
        return (try? context.fetchCount(descriptor)) ?? 0
    }
}
