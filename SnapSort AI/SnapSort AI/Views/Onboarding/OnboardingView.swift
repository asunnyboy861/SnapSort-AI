import SwiftUI
import Photos

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var permissionGranted = false

    private let pages = [
        OnboardingPage(
            icon: "photo.on.rectangle.angled",
            title: "Smart Screenshot Detection",
            description: "Automatically detects new screenshots and starts organizing them instantly."
        ),
        OnboardingPage(
            icon: "brain.head.profile",
            title: "AI-Powered Classification",
            description: "13 smart categories — OTP codes, receipts, recipes, travel, and more."
        ),
        OnboardingPage(
            icon: "doc.text.magnifyingglass",
            title: "Full-Text OCR Search",
            description: "Find any screenshot by the text inside it. Never lose a screenshot again."
        ),
        OnboardingPage(
            icon: "trash.circle",
            title: "Auto-Clean Temporary Screenshots",
            description: "OTP codes and QR codes auto-delete after 24 hours. Keep your library clean."
        )
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                Spacer()

                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 24) {
                            Image(systemName: pages[index].icon)
                                .font(.system(size: 72))
                                .foregroundStyle(.white)

                            Text(pages[index].title)
                                .font(.title.bold())
                                .foregroundStyle(.white)

                            Text(pages[index].description)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                Spacer()

                if currentPage == pages.count - 1 {
                    Button {
                        requestPermission()
                    } label: {
                        Text(permissionGranted ? "Get Started" : "Allow Photo Access")
                            .font(.headline)
                            .foregroundStyle(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)
                } else {
                    Button {
                        withAnimation { currentPage += 1 }
                    } label: {
                        Text("Next")
                            .font(.headline)
                            .foregroundStyle(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)
                }
            }
        }
    }

    private func requestPermission() {
        if permissionGranted {
            hasCompletedOnboarding = true
            return
        }
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                if status == .authorized || status == .limited {
                    permissionGranted = true
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}
