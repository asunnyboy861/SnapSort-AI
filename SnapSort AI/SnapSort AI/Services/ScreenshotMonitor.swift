import Photos
import SwiftUI

@Observable
class ScreenshotMonitor: NSObject, PHPhotoLibraryChangeObserver {
    var newScreenshots: [ScreenshotItem] = []
    var isMonitoring: Bool = false
    var permissionGranted: Bool = false

    private var fetchResult: PHFetchResult<PHAsset>?
    private var lastScreenshotCount: Int = 0

    func startMonitoring() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                guard let self else { return }
                self.permissionGranted = (status == .authorized || status == .limited)
                guard self.permissionGranted else { return }
                self.setupFetchResult()
                PHPhotoLibrary.shared().register(self)
                self.isMonitoring = true
            }
        }
    }

    private func setupFetchResult() {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(
            format: "mediaType == %d AND isScreenshot == YES",
            PHAssetMediaType.image.rawValue
        )
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: options)
        lastScreenshotCount = fetchResult?.count ?? 0
    }

    func fetchAllScreenshotAssets() -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(
            format: "mediaType == %d AND isScreenshot == YES",
            PHAssetMediaType.image.rawValue
        )
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return PHAsset.fetchAssets(with: options)
    }

    nonisolated func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { @MainActor in
            guard let fetchResult = fetchResult,
                  let details = changeInstance.changeDetails(for: fetchResult) else { return }

            let newCount = details.fetchResultAfterChanges.count
            if newCount > lastScreenshotCount {
                let inserted = details.insertedObjects
                for asset in inserted {
                    let item = await ScreenshotProcessor.shared.analyze(asset: asset)
                    self.newScreenshots.append(item)
                }
                self.lastScreenshotCount = newCount
            }
        }
    }
}
