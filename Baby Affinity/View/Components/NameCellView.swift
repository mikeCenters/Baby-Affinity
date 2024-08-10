//
//  NameCellView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/7/24.
//

import SwiftUI

/// A view that displays a `Name` object with its rank, rating, and favorite status.
struct NameCellView: View {
    
    // MARK: - Properties
    
    /// The `Name` object to be displayed in the cell.
    @Bindable var name: Name
    
    /// The rank of the `Name` object.
    var rank: Int
    
    
    // MARK: - Controls and Constants
    
    /// A boolean that represents the state of the favorite button press.
    @State private var favIsTapped = false
    
    /// Used to provide the maxWidth of the rank and favorites icon. This is used to place the name perfectly center within the cell.
    private let rankAndIconMaxWidth: CGFloat? = 60
    
    
    // MARK: - Body
    
    var body: some View {
        /// The `.frame` modifier is used to place components perfectly in their position. Use of `Spacer()` will create offsets for the center component.
        HStack {
            
            /// Displays the rank of the `Name` object.
            Text("\(rank)")
                .font(.headline)
                .frame(maxWidth: rankAndIconMaxWidth, alignment: .leading)
            
            
            VStack(alignment: .center) {
                /// Displays the text of the `Name` object.
                Text(name.text)
                    .font(.title3)
                
                /// Displays the rating of the `Name` object.
                Text("Rating: \(name.affinityRating)")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            
            Button {
                /// Toggles the favorite status of the `Name` object.
                withAnimation(.bouncy.speed(1.5)) {
                    name.toggleFavorite()
                    favIsTapped.toggle()
                    
                } completion: {
                    withAnimation(.bouncy.speed(1.5)) {
                        favIsTapped.toggle()
                    }
                }
                
            } label: {
                /// Displays a filled star if the `Name` is a favorite, otherwise an empty star.
                Image(systemName: name.isFavorite ? "star.fill" : "star")
                    .font(.headline)
                    .foregroundColor(name.isFavorite ? .yellow : .gray)
                /// Scale effect will upscale when tapped and is a favorite; otherwise, no scaling is perfomed.
                    .scaleEffect(favIsTapped ? name.isFavorite ? 1.3 : 1 : 1)
            }
            .frame(maxWidth: rankAndIconMaxWidth, alignment: .trailing)
            .sensoryFeedback(.impact, trigger: name.isFavorite)
            .buttonStyle(.borderless)   /// Disable List cell tapping.
        }
    }
}


#if DEBUG

import SwiftData

#Preview {
    let names = (1...10).map {
        Name("Name \($0)", sex: .male, affinityRating: 1200)
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
