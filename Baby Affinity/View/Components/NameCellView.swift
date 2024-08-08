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
    var name: Name
    
    /// The rank of the `Name` object.
    var rank: Int
    
    
    // MARK: - Body
    
    var body: some View {
        
        /// The `.frame` modifier is used to place components perfectly in their position. Use of `Spacer()` will create offsets for the center component.
        HStack {
            
            /// Displays the rank of the `Name` object.
            Text("\(rank)")
                .font(.headline)
                .frame(maxWidth: 60, alignment: .leading)
            
            
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
                withAnimation {
                    name.toggleFavorite()
                }
                
            } label: {
                /// Displays a filled star if the `Name` is a favorite, otherwise an empty star.
                Image(systemName: name.isFavorite ? "star.fill" : "star")
                    .foregroundColor(name.isFavorite ? .yellow : .gray)
                    .font(.headline)
            }
            .buttonStyle(.borderless)   /// Disable List cell tapping.
            .sensoryFeedback(.impact, trigger: name.isFavorite)
            .frame(maxWidth: 60, alignment: .trailing)
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

