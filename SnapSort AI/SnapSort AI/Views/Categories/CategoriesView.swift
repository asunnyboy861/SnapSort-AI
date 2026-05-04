import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<ScreenshotItem> { !$0.isDeleted }) private var screenshots: [ScreenshotItem]
    @State private var selectedCategory: ScreenshotCategory?

    var body: some View {
        NavigationStack {
            List {
                ForEach(ScreenshotCategory.allCases, id: \.self) { category in
                    let count = screenshots.filter { $0.category == category.rawValue }.count
                    if count > 0 {
                        NavigationLink {
                            CategoryDetailView(category: category, screenshots: screenshots.filter { $0.category == category.rawValue })
                        } label: {
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundStyle(Color(hex: category.colorHex))
                                    .frame(width: 32)
                                Text(category.rawValue)
                                Spacer()
                                Text("\(count)")
                                    .foregroundStyle(.secondary)
                                if category.isTemporary {
                                    Image(systemName: "clock")
                                        .foregroundStyle(.orange)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Categories")
        }
    }
}

struct CategoryDetailView: View {
    let category: ScreenshotCategory
    let screenshots: [ScreenshotItem]
    @State private var selectedItems: Set<UUID> = []
    @State private var isEditing = false

    var body: some View {
        List {
            ForEach(screenshots) { item in
                NavigationLink {
                    ScreenshotDetailView(item: item)
                } label: {
                    HStack {
                        if isEditing {
                            Image(systemName: selectedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(.blue)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            if let ocr = item.ocrText {
                                Text(ocr.prefix(80))
                                    .font(.subheadline)
                                    .lineLimit(2)
                            }
                            HStack {
                                Text(item.createdAt, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if item.isFavorite {
                                    Image(systemName: "heart.fill")
                                        .foregroundStyle(.pink)
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(category.rawValue)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Done" : "Select") {
                    isEditing.toggle()
                    selectedItems.removeAll()
                }
            }
        }
    }
}
