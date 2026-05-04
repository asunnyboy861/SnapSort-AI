import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var purchaseManager = PurchaseManager.shared
    @AppStorage("autoCleanEnabled") private var autoCleanEnabled = true
    @AppStorage("cleanReminderEnabled") private var cleanReminderEnabled = true
    @AppStorage("cleanReminderHour") private var cleanReminderHour = 22
    @State private var showProSheet = false

    var body: some View {
        NavigationStack {
            List {
                proSection
                screenshotSection
                cleanSection
                notificationSection
                aboutSection
            }
            .navigationTitle("Settings")
        }
    }

    private var proSection: some View {
        Section {
            if purchaseManager.isPro {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.yellow)
                    Text("SnapSort AI Pro")
                        .font(.headline)
                    Spacer()
                    Text("Active")
                        .foregroundStyle(.green)
                }
            } else {
                Button {
                    showProSheet = true
                } label: {
                    HStack {
                        Image(systemName: "crown")
                            .foregroundStyle(.yellow)
                        Text("Upgrade to Pro")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text("Pro Features")
        }
        .sheet(isPresented: $showProSheet) {
            ProPurchaseView()
        }
    }

    private var screenshotSection: some View {
        Section {
            let total = AutoCleanManager.shared.totalScreenshotCount(context: modelContext)
            let storage = AutoCleanManager.shared.totalStorageUsed(context: modelContext)
            HStack {
                Text("Total Screenshots")
                Spacer()
                Text("\(total)")
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Storage Used")
                Spacer()
                Text(ByteCountFormatter.string(fromByteCount: storage, countStyle: .file))
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Statistics")
        }
    }

    private var cleanSection: some View {
        Section {
            Toggle("Auto-Clean Temporary", isOn: $autoCleanEnabled)
            if autoCleanEnabled {
                Stepper("Clean after: \(cleanReminderHour) hours", value: $cleanReminderHour, in: 1...72)
            }
        } header: {
            Text("Auto-Clean")
        } footer: {
            Text("OTP codes and QR codes will be automatically removed after the specified time.")
        }
    }

    private var notificationSection: some View {
        Section {
            Toggle("Cleanup Reminders", isOn: $cleanReminderEnabled)
        } header: {
            Text("Notifications")
        } footer: {
            Text("Get reminded when temporary screenshots are ready to be cleaned up.")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
            Link(destination: URL(string: "https://zzoutuo.com/snapsort-ai/privacy")!) {
                HStack {
                    Text("Privacy Policy")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }
            Link(destination: URL(string: "https://zzoutuo.com/snapsort-ai/support")!) {
                HStack {
                    Text("Support")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }
            Button {
                Task {
                    await purchaseManager.restorePurchases()
                }
            } label: {
                Text("Restore Purchases")
            }
        } header: {
            Text("About")
        }
    }
}

struct ProPurchaseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var purchaseManager = PurchaseManager.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.yellow)

                    Text("SnapSort AI Pro")
                        .font(.largeTitle.bold())

                    Text("One-time purchase, use forever")
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 12) {
                        ProFeatureRow(icon: "tag", title: "Custom Tags", description: "Add personal tags to any screenshot")
                        ProFeatureRow(icon: "faceid", title: "Face ID Lock", description: "Protect sensitive screenshots")
                        ProFeatureRow(icon: "square.grid.2x2", title: "Home Screen Widget", description: "Quick search from your home screen")
                        ProFeatureRow(icon: "checklist", title: "Batch Operations", description: "Select and manage multiple screenshots")
                        ProFeatureRow(icon: "icloud", title: "iCloud Sync", description: "Sync across all your devices")
                        ProFeatureRow(icon: "mic", title: "Siri Shortcuts", description: "Voice control for quick actions")
                        ProFeatureRow(icon: "doc.on.doc", title: "Export OCR Text", description: "Copy and share recognized text")
                        ProFeatureRow(icon: "slider.horizontal.3", title: "Custom Rules", description: "Create your own classification rules")
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    if let product = purchaseManager.product {
                        Button {
                            Task {
                                let success = await purchaseManager.purchase()
                                if success { dismiss() }
                            }
                        } label: {
                            if purchaseManager.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Buy for \(product.displayPrice)")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal)
                    } else {
                        ProgressView("Loading price...")
                    }

                    Button("Restore Purchases") {
                        Task { await purchaseManager.restorePurchases() }
                    }
                    .font(.subheadline)
                }
                .padding()
            }
            .navigationTitle("Go Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            .task {
                await purchaseManager.loadProduct()
                await purchaseManager.checkPurchaseStatus()
            }
        }
    }
}

struct ProFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
