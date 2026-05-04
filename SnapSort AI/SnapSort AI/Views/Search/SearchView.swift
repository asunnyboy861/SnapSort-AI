import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<ScreenshotItem> { !$0.isDeleted }) private var screenshots: [ScreenshotItem]
    @State private var searchText = ""
    @State private var selectedFilter: SearchFilter = .all

    enum SearchFilter: String, CaseIterable {
        case all = "All"
        case text = "OCR Text"
        case tags = "Tags"
        case category = "Category"
    }

    var filteredResults: [ScreenshotItem] {
        guard !searchText.isEmpty else { return [] }
        return screenshots.filter { item in
            switch selectedFilter {
            case .all:
                return (item.ocrText?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                       item.tags.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
                       item.category.localizedCaseInsensitiveContains(searchText)
            case .text:
                return item.ocrText?.localizedCaseInsensitiveContains(searchText) ?? false
            case .tags:
                return item.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            case .category:
                return item.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                filterPicker

                if searchText.isEmpty {
                    ContentUnavailableView(
                        "Search Screenshots",
                        systemImage: "magnifyingglass",
                        description: Text("Find screenshots by text content, tags, or category")
                    )
                } else if filteredResults.isEmpty {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "magnifyingglass",
                        description: Text("No screenshots matching \"\(searchText)\"")
                    )
                } else {
                    List(filteredResults) { item in
                        NavigationLink {
                            ScreenshotDetailView(item: item)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: item.categoryEnum.icon)
                                        .foregroundStyle(Color(hex: item.categoryEnum.colorHex))
                                    Text(item.categoryEnum.rawValue)
                                        .font(.subheadline.bold())
                                    Spacer()
                                    Text(item.createdAt, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                if let ocr = item.ocrText {
                                    Text(highlightedText(ocr, query: searchText))
                                        .font(.caption)
                                        .lineLimit(2)
                                }
                                if !item.tags.isEmpty {
                                    HStack {
                                        ForEach(item.tags.prefix(3), id: \.self) { tag in
                                            Text("#\(tag)")
                                                .font(.caption2)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(.blue.opacity(0.1))
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search screenshots...")
        }
    }

    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SearchFilter.allCases, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter.rawValue)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedFilter == filter ? Color.blue : Color(.systemGray5))
                            .foregroundStyle(selectedFilter == filter ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func highlightedText(_ text: String, query: String) -> String {
        guard let range = text.range(of: query, options: .caseInsensitive) else {
            return String(text.prefix(100))
        }
        let start = text.index(range.lowerBound, offsetBy: -20, limitedBy: text.startIndex) ?? text.startIndex
        let end = text.index(range.upperBound, offsetBy: 20, limitedBy: text.endIndex) ?? text.endIndex
        return "..." + text[start...end] + "..."
    }
}
