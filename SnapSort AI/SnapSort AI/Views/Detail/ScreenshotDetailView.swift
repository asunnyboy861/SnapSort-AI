import SwiftUI
import SwiftData
import Photos

struct ScreenshotDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let item: ScreenshotItem
    @State private var thumbnail: UIImage?
    @State private var showTagSheet = false
    @State private var newTag = ""
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                imageSection
                categorySection
                ocrSection
                tagsSection
                infoSection
                actionsSection
            }
            .padding()
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .task { loadThumbnail() }
        .alert("Delete Screenshot", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) { deleteScreenshot() }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var imageSection: some View {
        Group {
            if let image = thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 4)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .aspectRatio(9/16, contentMode: .fit)
                    .overlay {
                        ProgressView()
                    }
            }
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.headline)
            HStack {
                Image(systemName: item.categoryEnum.icon)
                    .foregroundStyle(Color(hex: item.categoryEnum.colorHex))
                Text(item.categoryEnum.rawValue)
                    .font(.subheadline.bold())
                Spacer()
                if item.isTemporary {
                    Label("Auto-delete", systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            .padding()
            .background(Color(hex: item.categoryEnum.colorHex).opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var ocrSection: some View {
        Group {
            if let ocr = item.ocrText, !ocr.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recognized Text")
                        .font(.headline)
                    Text(ocr)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Tags")
                    .font(.headline)
                Spacer()
                Button {
                    showTagSheet = true
                } label: {
                    Image(systemName: "plus.circle")
                }
            }

            if item.tags.isEmpty {
                Text("No tags yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(item.tags, id: \.self) { tag in
                        HStack(spacing: 4) {
                            Text("#\(tag)")
                                .font(.caption)
                            Button {
                                removeTag(tag)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption2)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .sheet(isPresented: $showTagSheet) {
            NavigationStack {
                VStack {
                    HStack {
                        TextField("Add tag...", text: $newTag)
                            .textFieldStyle(.roundedBorder)
                        Button("Add") {
                            addTag()
                        }
                        .disabled(newTag.isEmpty)
                    }
                    .padding()
                    Spacer()
                }
                .navigationTitle("Add Tag")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { showTagSheet = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Info")
                .font(.headline)
            HStack {
                Label(item.createdAt.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                Spacer()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            if item.fileSize > 0 {
                HStack {
                    Label(ByteCountFormatter.string(fromByteCount: item.fileSize, countStyle: .file), systemImage: "doc")
                    Spacer()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                item.isFavorite.toggle()
                try? modelContext.save()
            } label: {
                Label(
                    item.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                    systemImage: item.isFavorite ? "heart.slash" : "heart"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete Screenshot", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private func loadThumbnail() {
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [item.assetIdentifier], options: nil)
        guard let asset = fetchResult.firstObject else { return }
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: 600, height: 1200),
            contentMode: .aspectFit,
            options: options
        ) { image, _ in
            if let image = image {
                DispatchQueue.main.async { thumbnail = image }
            }
        }
    }

    private func addTag() {
        guard !newTag.isEmpty else { return }
        if !item.tags.contains(newTag) {
            item.tags.append(newTag)
            try? modelContext.save()
        }
        newTag = ""
    }

    private func removeTag(_ tag: String) {
        item.tags.removeAll { $0 == tag }
        try? modelContext.save()
    }

    private func deleteScreenshot() {
        Task {
            let success = await AutoCleanManager.shared.deleteScreenshot(assetIdentifier: item.assetIdentifier)
            if success {
                AutoCleanManager.shared.markAsDeleted(item, context: modelContext)
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }

        return (CGSize(width: maxX, height: currentY + rowHeight), positions)
    }
}
