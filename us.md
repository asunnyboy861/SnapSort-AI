# SnapSort AI - iOS Development Guide

## Executive Summary

SnapSort AI is an intelligent screenshot management app for iPhone that automatically detects, categorizes, and organizes screenshots using 100% on-device AI. Targeting the US market where the average iPhone user amasses 7,500 to 50,000+ screenshots, SnapSort AI solves the "screenshot black hole" problem where useful information is captured but never found again.

**Key Differentiators:**
- 100% on-device processing (Vision Framework) — zero cloud uploads, zero privacy risk
- 13 AI-powered categories (OTP, Receipt, Recipe, Shopping, Travel, Social, Work, Finance, Health, Meme, QR Code, Reminder, Other)
- Auto-clean expired temporary screenshots (OTP/QR codes after 24h)
- Full-text OCR search across all screenshots
- One-time $2.99 purchase — no subscription, ever
- Lightweight (<50MB) vs competitors that bloat to 1.6GB

**Target Audience:** US iPhone users aged 18-45 who take 5+ screenshots daily and struggle to find them later.

**App Store Subtitle:** Your Screenshots, Sorted

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| **Captr** | 5.0 rating, clean UI | Cloud upload (privacy risk), requires network | 100% local processing, works offline |
| **Screenshot PRO** | Established, 94 reviews | OCR inaccurate, 1.6GB bloat, deletes files before backup | Accurate OCR, <50MB, safe deletion |
| **Screenshots Pro** | Developer-focused, device frames | Not for everyday screenshot management | Built for regular users, AI categorization |
| **TempSnap** | Temporary/permanent split, free | No AI categorization, no OCR search, ads | AI auto-categorize + OCR search + no ads |
| **SnapStash AI** | AI features | Free tier only 30/month, $4.99-9.99/month | Generous free tier + $2.99 one-time |
| **Apple Photos (built-in)** | Free, integrated | No AI categorization, no auto-clean, limited Live Text | All features Apple Photos lacks |

## Apple Design Guidelines Compliance

- **Privacy**: 100% on-device processing aligns with Apple's privacy-first philosophy. No data leaves the device.
- **PhotoKit**: Proper use of PHPhotoLibrary with clear permission descriptions per App Store Review Guidelines 5.1.1
- **Vision Framework**: Using Apple's native VNRecognizeTextRequest for OCR (supports 109 languages)
- **SwiftData**: Using Apple's latest data persistence framework for iOS 17+
- **HIG Layout**: Tab-based navigation (Home/Categories/Search/Settings) following iOS 26 tab patterns
- **Dark Mode**: Full support with OLED-optimized pure black background
- **Accessibility**: VoiceOver labels on all interactive elements, Dynamic Type support
- **Haptics**: UIImpactFeedbackGenerator for category selection and deletion actions

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), PhotoKit (screenshot access), Vision (OCR/classification)
- **Data**: SwiftData (ScreenshotItem, CategoryFolder models)
- **OCR**: Vision Framework (VNRecognizeTextRequest) — 100% on-device
- **Classification**: Vision Framework (VNClassifyImageRequest) + keyword matching
- **Barcode**: Vision Framework (VNDetectBarcodesRequest)
- **Photos**: PhotoKit (PHAsset, PHPhotoLibrary)
- **Notifications**: UserNotifications (cleanup reminders)
- **Encryption**: CryptoKit (sensitive screenshot encryption — Phase 2)
- **Widget**: WidgetKit (home screen quick search — Phase 2)
- **Purchase**: StoreKit 2 (one-time $2.99 purchase)
- **Sync**: CloudKit (iCloud sync — Phase 2)

## Module Structure

```
SnapSortAI/
├── App/
│   ├── SnapSort_AIApp.swift
│   └── ContentView.swift
├── Models/
│   ├── ScreenshotItem.swift
│   ├── CategoryFolder.swift
│   └── ScreenshotCategory.swift
├── Services/
│   ├── ScreenshotMonitor.swift
│   ├── OCREngine.swift
│   ├── ScreenshotClassifier.swift
│   ├── ScreenshotProcessor.swift
│   ├── AutoCleanManager.swift
│   └── PurchaseManager.swift
├── Views/
│   ├── Onboarding/
│   │   └── OnboardingView.swift
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── StorageStatView.swift
│   ├── Categories/
│   │   ├── CategoryGridView.swift
│   │   └── ScreenshotListView.swift
│   ├── Search/
│   │   └── SearchView.swift
│   ├── Detail/
│   │   └── ScreenshotDetailView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── ContactSupportView.swift
│   │   └── PaywallView.swift
│   └── Components/
│       ├── CategoryCard.swift
│       ├── ScreenshotThumbnail.swift
│       └── CleanupBanner.swift
├── Extensions/
│   ├── Color+Hex.swift
│   └── PHAsset+Extensions.swift
└── Resources/
    └── Assets.xcassets/
```

## Implementation Flow

1. Configure Xcode project: Bundle ID, deployment target, Info.plist permissions
2. Define SwiftData models (ScreenshotItem, CategoryFolder)
3. Implement ScreenshotMonitor (PHPhotoLibraryChangeObserver)
4. Implement OCREngine (VNRecognizeTextRequest wrapper)
5. Implement ScreenshotClassifier (13 categories with keyword + Vision)
6. Implement ScreenshotProcessor (monitor → OCR → classify pipeline)
7. Build OnboardingView (photo permission + notification permission)
8. Build HomeView (recent screenshots + category cards + storage stats + cleanup banner)
9. Build CategoryGridView (13 category grid with counts)
10. Build ScreenshotListView (category detail with swipe actions)
11. Build SearchView (full-text OCR search with debounce)
12. Build ScreenshotDetailView (full image + OCR text + actions)
13. Build SettingsView (permissions, cleanup, privacy, about, support)
14. Implement AutoCleanManager (expired temporary screenshot cleanup)
15. Implement PurchaseManager (StoreKit 2 one-time $2.99)
16. Build PaywallView (Pro upgrade screen)
17. Build ContactSupportView (feedback form)
18. Test on iPhone and iPad simulators

## UI/UX Design Specifications

- **Color Scheme**:
  - Primary: #0A84FF (dark mode) / #007AFF (light mode)
  - Background: #000000 (dark, OLED) / #F2F2F7 (light, system gray)
  - Card: #1C1C1E (dark) / #FFFFFF (light)
  - Category colors: OTP #FF6B6B, Receipt #4ECDC4, Recipe #FFE66D, Shopping #A8E6CF, Travel #6C5CE7, Social #FD79A8, Work #0984E3, Finance #00B894, Health #E17055, Meme #FDCB6E, QR Code #636E72, Reminder #E84393, Other #B2BEC3

- **Typography**: SF Pro system font, .title for headers, .body for content, .caption for metadata

- **Layout**:
  - TabView with 4 tabs: Home, Categories, Search, Settings
  - Main content max width 720pt for iPad
  - 2-column LazyVGrid for category cards
  - Horizontal scroll for recent screenshots

- **Animations**:
  - Swipe-to-delete: red button slides in from right
  - Swipe-to-favorite: yellow star slides in from left
  - Card tap: spring(duration: 0.3) expand transition
  - Category switch: .transition(.opacity)
  - Search: 300ms debounce with live results

- **Gestures**: Swipe left to delete, swipe right to favorite, long press for batch select, pull to refresh

## Code Generation Rules

- Minimum iOS 17.0, Swift 5.9+
- Pure SwiftUI, no UIKit mixing (except PhotoKit requirements)
- SwiftData for persistence, no CoreData
- async/await + Actor, no Combine
- All image processing on background threads
- OCR on downsampled images (800px width max)
- 100% on-device processing, zero network requests
- Error handling: try? + default values, never crash
- Single image processing with immediate memory release
- No code comments unless explicitly requested
- All attributes in SwiftData models must be optional or have default values
- iPad layout: .frame(maxWidth: 720).frame(maxWidth: .infinity) for main ScrollView content

## Build & Deployment Checklist

- [ ] Bundle ID: com.zzoutuo.SnapSortAI
- [ ] Deployment Target: iOS 17.0
- [ ] Info.plist: NSPhotoLibraryUsageDescription
- [ ] Info.plist: NSUserNotificationsUsageDescription (optional)
- [ ] App Icon generated and configured
- [ ] StoreKit 2 configured with product ID: com.zzoutuo.SnapSortAI.pro
- [ ] Privacy Policy page deployed
- [ ] Support page deployed
- [ ] No Terms of Use needed (one-time purchase, not subscription)
- [ ] Tested on iPhone XS Max simulator
- [ ] Tested on iPad Pro 13-inch (M4) simulator
- [ ] No API keys or secrets in source code
- [ ] Pushed to GitHub
