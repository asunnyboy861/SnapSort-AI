import Photos
import UIKit

class ScreenshotProcessor {
    static let shared = ScreenshotProcessor()

    func analyze(asset: PHAsset) async -> ScreenshotItem {
        let image = await loadImage(from: asset)
        let ocrText = await OCREngine.shared.recognizeText(in: image)
        let category = ScreenshotClassifier.shared.classify(image: image, ocrText: ocrText)

        let item = ScreenshotItem(
            assetIdentifier: asset.localIdentifier,
            category: category,
            ocrText: ocrText
        )
        item.fileSize = estimateFileSize(image: image)
        return item
    }

    func loadImage(from asset: PHAsset) async -> UIImage {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = false

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 800, height: 1600),
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image ?? UIImage())
            }
        }
    }

    func loadFullSizeImage(from asset: PHAsset) async -> UIImage {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = false

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image ?? UIImage())
            }
        }
    }

    private func estimateFileSize(image: UIImage) -> Int64 {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return 0 }
        return Int64(data.count)
    }
}
