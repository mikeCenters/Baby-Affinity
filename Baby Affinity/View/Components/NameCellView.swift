//
//  NameCellView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/7/24.
//

import SwiftUI
import Store

// MARK: - Name Cell View

/// A view that displays a `Name` object with its rank, rating, and favorite status.
struct NameCellView: View, NamePersistenceController {
    
    // MARK: - Properties
    
    /// The environment model context.
    @Environment(\.modelContext) var modelContext
    
    /// The object used to inferface with the App Store.
    @EnvironmentObject private var store: Store
    
    /// The selected sex stored in user defaults.
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    /// The `Name` object to be displayed in the cell.
    var name: Name
    
    /// The rank of the `Name` object.
    var rank: Int
    
    
    // MARK: - Controls and Constants
    
    @ProductStatus(ProductID.premiumAccount.rawValue) private var isPremium
    
    /// Used to provide the maxWidth of the rank and favorites icon. This is used to place the name perfectly center within the cell.
    private let rankAndIconMaxWidth: CGFloat = 60
    
    /// The value that represents the scale of the favorite icon.
    @State private var imageScale: CGFloat = 1
    
    // THe control used to show the purchase premium account sheet.
    @State private var showPurchaseScreen = false
    
    
    // MARK: - Body
    
    
    var body: some View {
        /// The `.frame` modifier is used to place components perfectly in their position. Use of `Spacer()` will create offsets for the center component.
        HStack {
            rankView
            
            nameAndRatingView
            
            favoriteButtonView
        }
        
        
        // MARK: - On Change
        
        .onChange(of: name.isFavorite) {
            withAnimation(.bouncy) {
                imageScale = name.isFavorite ? 1.5 : 1
                
            } completion: {
                withAnimation(.bouncy) {
                    imageScale = 1
                }
            }
        }
        
        
        // MARK: - Sheet - Products View
        .sheet(isPresented: $showPurchaseScreen) {
            ProductsView()
        }
    }
}


// MARK: - View Components

extension NameCellView {
    
    // MARK: - Rank View
    
    var rankView: some View {
        switch isPremium {
        case true:          // Premium Account
            
            /// Display the rank of the `Name` object.
            Text("\(rank)")
                .font(.headline)
                .frame(maxWidth: rankAndIconMaxWidth, alignment: .leading)
            
        case false:         // Non-Premium Account
            
            /// Obfuscate the rank of the `Name` object.
            Text("??")
                .font(.headline)
                .frame(maxWidth: rankAndIconMaxWidth, alignment: .leading)
        }
    }
    
    
    // MARK: - Name and Rating View
    
    var nameAndRatingView: some View {
        VStack(alignment: .center) {
            /// Displays the text of the `Name` object.
            Text(name.text)
                .font(.title3)
            
            switch isPremium {
            case true:          // Premium Account
                
                /// Displays the rating of the `Name` object.
                Text("Rating: \(name.affinityRating)")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                
            case false:         // Non-Premium Account
                
                /// Obfuscate the rating of the `Name` object.
                Text("Rating: ????")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    
    // MARK: - Favorite Button View
    
    var favoriteButtonView: some View {
        Button {
            switch isPremium {
            case true:          // Premium Account
                toggleFavorite()
                
            case false:         // Non-Premium Account
                handleNonPremiumFavorite()
            }
            
        } label: {
            /// Displays a filled star if the `Name` is a favorite, otherwise an empty star.
            Image(systemName: name.isFavorite ? "star.fill" : "star")
                .font(.headline)
                .foregroundColor(name.isFavorite ? .yellow : .gray)
            /// Scale effect will upscale when tapped and is a favorite; otherwise, no scaling is perfomed.
                .scaleEffect(imageScale)
        }
        .frame(maxWidth: rankAndIconMaxWidth, alignment: .trailing)
        .buttonStyle(.borderless)   /// Disable List cell tapping.
    }
    
    private func toggleFavorite() {
        /// Toggles the favorite status of the `Name` object.
        withAnimation(.bouncy) {
            name.toggleFavorite()
        }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    private func handleNonPremiumFavorite() {
        let favoriteNames = try? fetchFavoriteNames(sex: selectedSex)
        let maxFavorites = 3
        /// Only allow three favorites for non-premium users.
        if let count = favoriteNames?.count, count < maxFavorites {
            toggleFavorite()
            
        } else {
            
            if name.isFavorite {                // Set the name to non-favorite
                toggleFavorite()
                
            } else {                            // Show the purchase screen
                showPurchaseScreen.toggle()
            }
        }
    }
}


#if DEBUG

// MARK: - Previews

#Preview("Name Cell View in List - Non-Premium Account") {
    let names = (1...10).map { _ in
        try! Name("Name", sex: .male)
    }
    
    return List {
        Section {
            ForEach(Array(names.enumerated()), id: \.offset) { (index, name) in
                NameCellView(name: name, rank: index + 1)
            }
        }
    }
    .modelContainer(previewModelContainer_WithFavorites)
    .environmentObject(Store.main)
}

#Preview("Name Cell View in List - Premium Account") {
    let names = (1...10).map { _ in
        try! Name("Name", sex: .male)
    }
    
    return List {
        Section {
            ForEach(Array(names.enumerated()), id: \.offset) { (index, name) in
                NameCellView(name: name, rank: index + 1)
            }
        }
    }
    .modelContainer(previewModelContainer_WithFavorites)
    .environmentObject(Store.premium)
}

#endif
