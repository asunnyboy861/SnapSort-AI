import Foundation
import SwiftData

enum ScreenshotCategory: String, CaseIterable, Codable {
    case otp = "OTP Code"
    case receipt = "Receipt"
    case recipe = "Recipe"
    case shopping = "Shopping"
    case travel = "Travel"
    case social = "Social Media"
    case work = "Work"
    case finance = "Finance"
    case health = "Health"
    case meme = "Meme"
    case qrCode = "QR Code"
    case reminder = "Reminder"
    case other = "Other"

    var icon: String {
        switch self {
        case .otp: return "lock.shield"
        case .receipt: return "receipt"
        case .recipe: return "fork.knife"
        case .shopping: return "bag"
        case .travel: return "airplane"
        case .social: return "message"
        case .work: return "briefcase"
        case .finance: return "dollarsign.circle"
        case .health: return "heart"
        case .meme: return "face.smiling"
        case .qrCode: return "qrcode"
        case .reminder: return "bell"
        case .other: return "square.grid.2x2"
        }
    }

    var colorHex: String {
        switch self {
        case .otp: return "FF6B6B"
        case .receipt: return "4ECDC4"
        case .recipe: return "FFE66D"
        case .shopping: return "A8E6CF"
        case .travel: return "6C5CE7"
        case .social: return "FD79A8"
        case .work: return "0984E3"
        case .finance: return "00B894"
        case .health: return "E17055"
        case .meme: return "FDCB6E"
        case .qrCode: return "636E72"
        case .reminder: return "E84393"
        case .other: return "B2BEC3"
        }
    }

    var isTemporary: Bool {
        self == .otp || self == .qrCode
    }
}
