import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<ScreenshotItem> { !$0.isDeleted },
           sort: \ScreenshotItem.createdAt,
           order: .reverse) private var screenshots: [ScreenshotItem]
    @State private var monitor = ScreenshotMonitor()
    @State private var searchText = ""
    @State private var selectedCategory: ScreenshotCategory?
    @State private var showCleanAlert = false

    var filteredScreenshots: [ScreenshotItem] {
        var result = screenshots
        if let category = selectedCategory {
            result = result.filter { $0.category == category.rawValue }
        }
        if !searchText.isEmpty {
            result = result.filter {
                ($0.ocrText?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        return result
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statsSection
                    categoryGrid
                    recentScreenshotsSection
                }
                .padding()
            }
            .navigationTitle("SnapSort AI")
            .searchable(text: $searchText, prompt: "Search by text, tags...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCleanAlert = true
                    } label: {
                        Image(systemName: "trash.circle")
                    }
                }
            }
            .alert("Clean Temporary Screenshots", isPresented: $showCleanAlert) {
                Button("Clean", role: .destructive) { cleanTemporary() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Remove expired OTP codes and QR codes?")
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(title: "Total", value: "\(screenshots.count)", icon: "photo.stack", color: .blue)
            StatCard(title: "Temporary", value: "\(screenshots.filter { $0.isTemporary }.count)", icon: "clock", color: .orange)
            StatCard(title: "Favorites", value: "\(screenshots.filter { $0.isFavorite }.count)", icon: "heart.fill", color: .pink)
        }
    }

    private var categoryGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(ScreenshotCategory.allCases, id: \.self) { category in
                    CategoryPill(
                        category: category,
                        count: screenshots.filter { $0.category == category.rawValue }.count,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }
            }
        }
    }

    private var recentScreenshotsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Screenshots")
                .font(.headline)

            if filteredScreenshots.isEmpty {
                ContentUnavailableView(
                    "No Screenshots",
                    systemImage: "photo.on.rectangle.angled",
                    description: Text("Take a screenshot and it will appear here automatically")
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredScreenshots.prefix(20)) { item in
                        NavigationLink {
                            ScreenshotDetailView(item: item)
                        } label: {
                            ScreenshotRow(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func cleanTemporary() {
        let expired = AutoCleanManager.shared.fetchExpiredScreenshots(context: modelContext)
        for item in expired {
            Task {
                let success = await AutoCleanManager.shared.deleteScreenshot(assetIdentifier: item.assetIdentifier)
                if success {
                    AutoCleanManager.shared.markAsDeleted(item, context: modelContext)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct CategoryPill: View {
    let category: ScreenshotCategory
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.title3)
                Text(category.rawValue)
                    .font(.caption2)
                    .lineLimit(1)
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: category.colorHex))
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Color(hex: category.colorHex).opacity(0.2) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: category.colorHex) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ScreenshotRow: View {
    let item: ScreenshotItem

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: item.categoryEnum.icon)
                        .foregroundStyle(Color(hex: item.categoryEnum.colorHex))
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.categoryEnum.rawValue)
                    .font(.subheadline.bold())
                if let ocr = item.ocrText {
                    Text(ocr.prefix(60))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            if item.isTemporary {
                Image(systemName: "clock")
                    .foregroundStyle(.orange)
                    .font(.caption)
            }
            if item.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
                    .font(.caption)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
