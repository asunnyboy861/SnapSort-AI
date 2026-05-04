import StoreKit
import SwiftUI

@MainActor
@Observable
class PurchaseManager {
    static let shared = PurchaseManager()

    var isPro: Bool = false
    var isLoading: Bool = false
    var product: Product?

    private let productId = "com.zzoutuo.SnapSort-AI.pro"

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [productId])
            product = products.first
        } catch {
            print("Failed to load product: \(error)")
        }
    }

    func purchase() async -> Bool {
        guard let product = product else { return false }
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified:
                    isPro = true
                    return true
                case .unverified:
                    return false
                }
            case .pending, .userCancelled:
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkPurchaseStatus()
        } catch {
            print("Restore failed: \(error)")
        }
    }

    func checkPurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == productId {
                    isPro = transaction.revocationDate == nil
                    return
                }
            }
        }
        isPro = false
    }

    var ocrMonthlyLimit: Int {
        isPro ? Int.max : 50
    }

    var classificationLimit: Int {
        isPro ? Int.max : 100
    }
}
