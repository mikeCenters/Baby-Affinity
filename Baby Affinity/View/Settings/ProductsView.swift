//
//  ProductsView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/3/24.
//

import SwiftUI
import SwiftData
import StoreKit


// MARK: - Products View

struct ProductsView: View, NamePersistenceController {
    
    // MARK: - Properties
    
    @Environment(\.modelContext) var modelContext
    @AppStorage("selectedSex") private var selectedSex: Sex = .male
    @EnvironmentObject private var store: Store
    @PremiumAccount private var isPremium
    
    private var product: Product? {
        store.products.first { $0.id == "com.mikeCenters.BabyAffinity.premium"}
    }
    
    @Query private var names: [Name] = []
    
    
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
    
    
    // MARK: - Body
    
    var body: some View {
        PresentationLayout {
            
            // Top Section
            
            ZStack(alignment: .bottom) {
                VStack(spacing: 8) {
                    Spacer()
                    Image(uiImage: UIImage(named: "AppIcon")!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 84, height: 84)
                        .clipShape(RoundedRectangle(cornerRadius: 84/5.8))
                    
                    Text("Baby Affinity")
                        .font(.title).bold()
                    
                    Text("The first important decision, should be the easiest.")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            }
            .background(gradientSlide)
            
            
            // Bottom Section
            
            VStack(spacing: 8) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
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
                        
                        getFeatureItemView(
                            title: "Share with a Partner",
                            description: "Collaborate with your partner by sharing your favorite names and generating a shared list."
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.top)

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
            if !isPremium {
                Text("Unlock an enhanced experience for just \(product?.displayPrice ?? "<Unable to locate the product in the App Store.>").")
                    .multilineTextAlignment(.center)
            }
            
            Button {
                if !isPremium {
                    if let p = product {
                        Task {
                            await store.purchase(p)
                        }
                    }
                }
                
            } label: {
                Text(isPremium ? "Premium Account Active" : "Purchase Premium Account")
                    .fontWeight(.semibold)
                    .padding(8)
            }
            .buttonStyle(BorderedProminentButtonStyle())
            .tint(isPremium ? .green : .blue)
            
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
    
    private func gradientBackground(for index: Int) -> LinearGradient {
        let (startColor, endColor) = colorPair(for: selectedSex, index: index)
        
        return LinearGradient(
            gradient: Gradient(colors: [startColor, endColor]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private func colorPair(for sex: Sex, index: Int) -> (Color, Color) {
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

#Preview("With a Tab View and Navigation Stack - Non-Premium Account") {
    TabView {
        NavigationStack {
            ProductsView()
        }
        .tabItem {
            Label("Products", systemImage: "cart")
        }
        .modelContainer(previewModelContainer)
        .environmentObject(Store.shared)
    }
}

#Preview("With a Tab View and Navigation Stack - Premium Account") {
    TabView {
        NavigationStack {
            ProductsView()
        }
        .tabItem {
            Label("Products", systemImage: "cart")
        }
        .modelContainer(previewModelContainer)
        .environmentObject(Store.premium)
    }
}

#endif
