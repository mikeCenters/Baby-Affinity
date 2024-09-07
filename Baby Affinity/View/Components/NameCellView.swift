//
//  NameCellView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/7/24.
//

import SwiftUI

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
    
    /// Used to provide the maxWidth of the rank and favorites icon. This is used to place the name perfectly center within the cell.
    private let rankAndIconMaxWidth: CGFloat? = 60
    
    /// The value that represents the scale of the favorite icon.
    @State private var imageScale: CGFloat = 1
    
    @State private var showPurchaseScreen = false
    
    
    // MARK: - Body
    
    var body: some View {
        /// The `.frame` modifier is used to place components perfectly in their position. Use of `Spacer()` will create offsets for the center component.
        HStack {
            
            if store.purchasedProductIDs.contains(Store.premiumProductID) {
                /// Display the rank of the `Name` object.
                Text("\(rank)")
                    .font(.headline)
                    .frame(maxWidth: rankAndIconMaxWidth, alignment: .leading)
                
            } else {
                /// Obfuscate the rank of the `Name` object.
                Text("??")
                    .font(.headline)
                    .frame(maxWidth: rankAndIconMaxWidth, alignment: .leading)
            }
            
            VStack(alignment: .center) {
                /// Displays the text of the `Name` object.
                Text(name.text)
                    .font(.title3)
                
                
                if store.purchasedProductIDs.contains(Store.premiumProductID) {
                    /// Displays the rating of the `Name` object.
                    Text("Rating: \(name.affinityRating)")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    
                } else {
                    /// Obfuscate the rating of the `Name` object.
                    Text("Rating: ????")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            
            Button {
                let favoriteNames = try? fetchFavoriteNames(sex: selectedSex)
                
                /// Only allow three favorites for non-premium users.
                if let count = favoriteNames?.count, count < 3 {
                    /// Toggles the favorite status of the `Name` object.
                    withAnimation(.bouncy) {
                        name.toggleFavorite()
                    }
                    
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    
                } else {
                    showPurchaseScreen.toggle()
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
        .onChange(of: name.isFavorite) {
            withAnimation(.bouncy) {
                imageScale = name.isFavorite ? 1.5 : 1
                
            } completion: {
                withAnimation(.bouncy) {
                    imageScale = 1
                }
            }
        }
        .sheet(isPresented: $showPurchaseScreen) {
            ProductsView()
        }
    }
}


#if DEBUG

// MARK: - Previews

import SwiftData

#Preview {
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
}

#endif
