//
//  ProductsView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/3/24.
//

import SwiftUI
import SwiftData
import StoreKit


struct PresentationLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        // We assume two subviews (top and bottom)
        guard subviews.count == 2 else { return .zero }
        
        // Use the proposed width and height, or fallback to a default if unavailable
        let width = proposal.width ?? 0
        let height = proposal.height ?? 0
        
        return CGSize(width: width, height: height)
    }
    
    // This method places the subviews in the calculated layout bounds
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        guard subviews.count == 2 else { return }

        let totalHeight = bounds.height
        let availableWidth = bounds.width

        // Calculate the heights for each section (2/5 for top, 3/5 for bottom)
        let topHeight = totalHeight * 2 / 5
        let bottomHeight = totalHeight * 3 / 5

        // Get subview sizes
        let topSubview = subviews[0]
        let bottomSubview = subviews[1]
        let topSubviewSize = topSubview.sizeThatFits(ProposedViewSize(width: availableWidth, height: topHeight))
        let bottomSubviewSize = bottomSubview.sizeThatFits(ProposedViewSize(width: availableWidth, height: bottomHeight))

        // Calculate the x and y coordinates to center each subview
        let topXOffset = (availableWidth - topSubviewSize.width) / 2
        let topYOffset = (topHeight - topSubviewSize.height) / 2
        let bottomXOffset = (availableWidth - bottomSubviewSize.width) / 2
        let bottomYOffset = (bottomHeight - bottomSubviewSize.height) / 2

        // Place the top view centered within its section
        topSubview.place(
            at: CGPoint(x: bounds.minX + topXOffset, y: bounds.minY + topYOffset),
            proposal: ProposedViewSize(width: availableWidth, height: topHeight)
        )
        
        // Place the bottom view centered within its section
        bottomSubview.place(
            at: CGPoint(x: bounds.minX + bottomXOffset, y: bounds.minY + topHeight + bottomYOffset),
            proposal: ProposedViewSize(width: availableWidth, height: bottomHeight)
        )
    }
}


struct ProductsView: View, NamePersistenceController {
    
    // MARK: - Properties
    
    @Environment(\.modelContext) var modelContext
    
    @EnvironmentObject private var store: Store
    
    @AppStorage("selectedSex") private var selectedSex: Sex = .male
    
    @Query private var names: [Name] = []
    
    private var product: Product? {
        store.products.first { $0.id == "com.mikeCenters.BabyAffinity.premium"}
    }
    
    
    // MARK: - Controls and Constants
    
    private let maleColorSet = [Color.blue.opacity(1), Color.blue.opacity(0.8)]
    
    private let femaleColorSet = [Color.pink.opacity(1), Color.pink.opacity(0.8)]
    
    private func getGradientStart(_ index: Int) -> Color {
        switch selectedSex {
        case .female:
            femaleColorSet[index % femaleColorSet.count]
        case .male:
            maleColorSet[index % maleColorSet.count]
        }
    }
    
    // Name Scroll Animation
    private let nameScrollSpeed: CGFloat = 50           // Points per second
    @State private var nameScrollOffset: CGFloat = 0
    @State private var nameScrollContentWidth: CGFloat = 0
    @State private var nameScrollAnimationTimer: Timer? = nil
    
    
    // MARK: - Body
    
    var body: some View {
        PresentationLayout {
            
            // Top Section
            
            ZStack(alignment: .bottom) {
                VStack(spacing: 16) {
                    Spacer()
                    Image(uiImage: UIImage(named: "AppIcon")!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 100/5.8))
                    
                    Text("Baby Affinity")
                        .font(.largeTitle).bold()
                    
                    Text("The first important decision, should be the easiest.")
                        .fontWeight(.semibold)
                    
                    nameScroll
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            }
            .background(gradientSlide)
            
            
            // Bottom Section
            
            VStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 12) {
                    Spacer()
                    
                    getFeatureItemView(
                        title: "See Your Top Names",
                        description: "Easily view and manage your top-rated names in one place."
                    )
                    
                    getFeatureItemView(
                        title: "Access Affinity Ratings",
                        description: "Unlock advanced Affinity Ratings to discover your ideal baby name match."
                    )
                    
                    getFeatureItemView(
                        title: "Add More Favorites",
                        description: "Save and manage additional favorite names without any limits."
                    )
                    
//                    getFeatureItemView(
//                        title: "Share with a Partner",
//                        description: "Collaborate with your partner by sharing your favorite names directly."
//                    )
                    
                    Spacer()
                    
                        
                }
                .padding(.horizontal)

                purchaseButtonAndDisclaimer
            }
        }
        // MARK: - Task
        .task {
            await store.fetchProducts()
        }
    }
    
    
    // MARK: - View Components
    
    private func getFeatureItemView(title: String, description: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    
    // MARK: - Purchase Button and Disclaimer
    
    private var purchaseButtonAndDisclaimer: some View {
        VStack(spacing: 8) {
            Text("Unlock an enhanced experience for just \(product?.displayPrice ?? "<Unable to locate the product in the App Store.>").")
            
            Button {
                if let p = product {
                    Task {
                        await store.purchase(p)
                    }
                }
                
            } label: {
                Text("Purchase Premium Account")
                    .fontWeight(.semibold)
                    .padding(8)
            }
            .buttonStyle(BorderedProminentButtonStyle())
            
            disclaimerTextAndLinks
        }
    }
    
    private var disclaimerTextAndLinks: some View {
        VStack {
            Text("By placing an in-app purchase, you agree to the Privacy Policy and Terms of Service.")
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            LegalInfoView(showAppVersion: false)
        }
        .padding(.horizontal, 32)
    }
    
    
    // MARK: - Name Scroll
    
    var nameScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 20) {
                ForEach(names) { name in
                    Text(name.text)
                        .font(.body)
                }
                
            }
            .frame(height: UIFont.preferredFont(forTextStyle: .body).lineHeight)
            .background(GeometryReader { geo in
                Color.clear
                    .onAppear {
                        /// Delay to allow content to render
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            nameScrollContentWidth = geo.size.width
                            startAutoScroll()
                        }
                    }
            })
            .offset(x: -nameScrollOffset)
        }
        .disabled(true)                     // Disable user input to scroll
    }
    
    func startAutoScroll() {
        stopAutoScroll()    // Stop any existing timer before starting a new one
        
        // Start a new timer to increment the scroll offset
        nameScrollAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            nameScrollOffset += nameScrollSpeed * 0.01
            if nameScrollOffset >= nameScrollContentWidth {
                nameScrollOffset = 0            // Loop back to the start
            }
        }
    }
    
    func stopAutoScroll() {
        nameScrollAnimationTimer?.invalidate()
        nameScrollAnimationTimer = nil
    }
    
    
    // MARK: - Gradient Slide
    
    private var gradientSlide: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(0...100, id: \.self) { num in
                    LinearGradient(colors: [getGradientStart(num),
                                            Color(.systemBackground)],
                                   startPoint: .top,
                                   endPoint: .bottom)
                    .frame(width: 80)
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    func gradientBackground(for index: Int) -> LinearGradient {
        let (startColor, endColor) = colorPair(for: selectedSex, index: index)
        
        return LinearGradient(
            gradient: Gradient(colors: [startColor, endColor]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    func colorPair(for sex: Sex, index: Int) -> (Color, Color) {
        let colors: [Color]
        
        switch sex {
        case .male:
            colors = [Color.blue.opacity(1), Color.blue.opacity(0.8)]
        case .female:
            colors = [Color.pink.opacity(1), Color.pink.opacity(0.8)]
        }
        
        // Alternate the color pair based on the index
        let startColor = colors[index % colors.count]
        let endColor = Color(.systemBackground)
        
        return (startColor, endColor)
    }
}

#if DEBUG

// MARK: - Previews

#Preview("Products View") {
    @StateObject var store = Store.shared
    
    return ProductsView()
        .modelContainer(previewModelContainer)
        .environmentObject(store)
}

#endif
