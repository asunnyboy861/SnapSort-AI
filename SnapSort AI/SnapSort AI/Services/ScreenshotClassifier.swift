import Vision
import UIKit

class ScreenshotClassifier {
    static let shared = ScreenshotClassifier()

    func classify(image: UIImage, ocrText: String?) -> ScreenshotCategory {
        if isOTPCode(ocrText) { return .otp }
        if isQRCode(image) { return .qrCode }
        if isReceipt(ocrText) { return .receipt }
        if isRecipe(ocrText) { return .recipe }
        if isShopping(ocrText) { return .shopping }
        if isTravel(ocrText) { return .travel }
        if isFinance(ocrText) { return .finance }
        if isHealth(ocrText) { return .health }
        if isWork(ocrText) { return .work }
        if isSocial(ocrText) { return .social }
        if isReminder(ocrText) { return .reminder }
        return classifyByVision(image: image)
    }

    private func isOTPCode(_ text: String?) -> Bool {
        guard let text = text?.lowercased() else { return false }
        let patterns = [
            "verification code", "verify", "otp", "pin code",
            "authentication code", "security code", "confirm",
            "your code is", "code:"
        ]
        return patterns.contains { text.contains($0) }
    }

    private func isQRCode(_ image: UIImage) -> Bool {
        guard let cgImage = image.cgImage else { return false }
        let request = VNDetectBarcodesRequest()
        request.symbologies = [.qr, .aztec, .pdf417]
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
        return !(request.results?.isEmpty ?? true)
    }

    private func isReceipt(_ text: String?) -> Bool {
        guard let text = text?.lowercased() else { return false }
        let patterns = [
            "total", "subtotal", "tax", "change", "payment",
            "visa", "mastercard", "amex", "card ending",
            "order #", "transaction", "purchase", "receipt"
        ]
        return patterns.filter { text.contains($0) }.count >= 2
    }

    private func isRecipe(_ text: String?) -> Bool {
        guard let text = text?.lowercased() else { return false }
        let patterns = [
            "ingredients", "directions", "preheat", "tablespoon",
            "teaspoon", "cups", "bake at", "minutes", "servings",
            "recipe", "cook", "stir", "mix"
        ]
        return patterns.filter { text.contains($0) }.count >= 3
    }

    private func isShopping(_ text: String?) -> Bool {
        guard let text = text?.lowercased() else { return false }
        let patterns = [
            "add to cart", "checkout", "price", "discount",
            "sale", "order", "shipping", "delivery"
        ]
        return patterns.filter { text.contains($0) }.count >= 2
    }

    private func isTravel(_ text: String?) -> Bool {
        guard let text = text?.lowercased() else { return false }
        let patterns = [
            "flight", "boarding pass", "reservation", "hotel",
            "check-in", "departure", "arrival", "gate", "seat"
        ]
        return patterns.filter { text.contains($0) }.count >= 2
    }

    private func isFinance(_ text: String?) -> Bool {
        guard let text = text?.lowercased() else { return false }
        let patterns = [
            "balance", "account", "deposit", "withdrawal",
            "interest", "credit score", "mortgage", "loan",
            "investment", "portfolio", "dividend"
        ]
        return patterns.filter { text.contains($0) }.count >= 2
    }

    private func isHealth(_ text: String?) -> Bool {
        guard let text = text?.lowercased() else { return false }
        let patterns = [
            "doctor", "appointment", "prescription", "medication",
            "blood pressure", "heart rate", "calories", "workout",
            "steps", "sleep", "bmi"
        ]
        return patterns.filter { text.contains($0) }.count >= 2
    }

    private func isWork(_ text: String?) -> Bool {
        guard let text = text?.lowercased() else { return false }
        let patterns = [
            "meeting", "deadline", "project", "sprint",
            "standup", "jira", "slack", "confluence",
            "pull request", "deploy", "review"
        ]
        return patterns.filter { text.contains($0) }.count >= 2
    }

    private func isSocial(_ text: String?) -> Bool {
        guard let text = text?.lowercased() else { return false }
        let patterns = [
            "liked your", "followed you", "mentioned you",
            "dm", "retweet", "repost", "story", "followers",
            "instagram", "twitter", "tiktok", "snapchat"
        ]
        return patterns.filter { text.contains($0) }.count >= 1
    }

    private func isReminder(_ text: String?) -> Bool {
        guard let text = text?.lowercased() else { return false }
        let patterns = [
            "remind", "don't forget", "todo", "to-do",
            "deadline", "due date", "upcoming", "scheduled"
        ]
        return patterns.filter { text.contains($0) }.count >= 1
    }

    private func classifyByVision(image: UIImage) -> ScreenshotCategory {
        guard let cgImage = image.cgImage else { return .other }
        let request = VNClassifyImageRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])

        guard let results = request.results else {
            return .other
        }

        for result in results where result.confidence > 0.3 {
            let identifier = result.identifier.lowercased()
            if identifier.contains("food") || identifier.contains("menu") { return .recipe }
            if identifier.contains("text") || identifier.contains("document") { return .work }
        }

        return .other
    }
}
