//
//  ProductsView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/3/24.
//

import SwiftUI
import SwiftData
import StoreKit


struct ProductsView: View, NamePersistenceController {
    
    // MARK: - Properties
    
    @Environment(\.modelContext) var modelContext
    
    @EnvironmentObject private var store: Store
    
    @AppStorage("selectedSex") private var selectedSex: Sex = .male
    
    
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
    
    
    
    // MARK: - Name Scroll
    
    @Query private var names: [Name] = []
    @State private var scrollOffset: CGFloat = 0
    @State private var scrollContentWidth: CGFloat = 0
    @State private var timer: Timer? = nil
    
    // Scroll speed control
    let scrollSpeed: CGFloat = 50 // Points per second
    
    // MARK: - Auto Scroll Logic
    func startAutoScroll() {
        stopAutoScroll() // Stop any existing timer before starting a new one
        
        // Start a new timer to increment the scroll offset
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            scrollOffset += scrollSpeed * 0.01
            if scrollOffset >= scrollContentWidth {
                scrollOffset = 0 // Loop back to the start
            }
        }
    }
    
    func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    
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
                            scrollContentWidth = geo.size.width
                            startAutoScroll()
                        }
                    }
            })
            .offset(x: -scrollOffset)
        }
        .disabled(true)             // Disable user input to scroll
    }
    
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            gradiantSlide
            
            VStack(spacing: 16) {
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
            .frame(maxHeight: .infinity)
            .offset(y: -108 - 16)
            .multilineTextAlignment(.center)
            .padding()
            
            // FIXME: Add features list.
            
            
            
            VStack {
                Spacer()
                Button {
                    
                    for p in store.products {
                        if p.displayName == "Premium Account" {
                            Task {
                                await store.purchase(p)
                            }
                        }
                    }
                    
                } label: {
                    Text("Purchase Premium Account")
                        .fontWeight(.semibold)
                        .padding(8)
                }
                .buttonStyle(BorderedProminentButtonStyle())
            }
            .padding(.bottom)
        }
        // MARK: - Task
        .task {
            await store.fetchProducts()
        }
    }
    
    
    // MARK: - View Components
    
    private var gradiantSlide: some View {
        VStack {
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
            .frame(height: 400)
            
            Spacer()
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    
    
    
    // MARK: - Methods
    
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
