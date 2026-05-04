# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- Photo Library access (NSPhotoLibraryUsageDescription) — required for screenshot detection and management
- User Notifications (NSUserNotificationsUsageDescription) — optional for cleanup reminders
- Face ID / Local Authentication — Pro feature for privacy lock
- StoreKit 2 — one-time in-app purchase
- No iCloud/CloudKit needed for Phase 1
- No HealthKit needed
- No Location Services needed
- No Camera needed (reads existing screenshots only)
- No Siri needed for Phase 1
- No Background Modes needed for Phase 1

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| Photo Library Access | ✅ Configured | Info.plist NSPhotoLibraryUsageDescription |
| User Notifications | ✅ Configured | Info.plist NSUserNotificationsUsageDescription |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| StoreKit 2 (In-App Purchase) | ⏳ Pending | Configure in App Store Connect: Product ID com.zzoutuo.SnapSort-AI.pro, Non-Consumable, $2.99 |
| Face ID (Local Authentication) | ⏳ Pending | Add NSFaceIDUsageDescription to Info.plist when implementing Pro privacy lock |

## No Configuration Needed
- iCloud / CloudKit — Phase 2 only
- HealthKit — Not applicable
- Location Services — Not applicable
- Camera — Not applicable (reads existing screenshots only)
- Siri — Phase 2 only
- Background Modes — Not needed
- Apple Watch — Not applicable
- Push Notifications — Using local notifications only

## Verification
- Build succeeded after configuration: ⏳ Pending
- All entitlements correct: ✅
