//
//  FavoriteNamesView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/3/24.
//

import SwiftUI
import SwiftData


/// A list view of the favorite `Name`s.
struct FavoriteNamesView: View {
    
    // MARK: - Fetch Descriptor
    
    /// The `FetchDescriptor` used to return the top 10 names of the user.
    static private func fetchDescriptor(for sex: Sex) -> FetchDescriptor<Name> {
        return FetchDescriptor<Name>(
            predicate: #Predicate { $0.sexRawValue == sex.rawValue && $0.isFavorite },
            sortBy: [
                .init(\.affinityRating, order: .reverse)
            ]
        )
    }
    
    
    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    
    /// The names of the selected `Sex` that are labeled as a favorite.
    @Query private var names: [Name]
    
    /// The list of names to be presented within the view.
    @State private var presentedNames: [Name] = []
    
    /// The sex of the names provided.
    private let selectedSex: Sex
    
    /// The title text used for the section header.
//    private let headerTitle: String = "Your Top \(self.selectedSex)Names"
//
    
    // MARK: - Controls
    
    
    // MARK: - Init
    
    init(show sex: Sex = .male) {
        self.selectedSex = sex
        _names = Query(Self.fetchDescriptor(for: sex))
    }
    
    
    // MARK: - Body
    
    var body: some View {
        Section(
            header: Text("Favorite \(self.selectedSex.alternateName) Names")) {
            
            // MARK: - Cell View
            
            
            if presentedNames.isEmpty {     // No favorite names are available
                
                self.noFavoritesFound
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                
                
            } else {                        // Favorites are available
                
                // List of favorite names
                ForEach(Array(presentedNames.enumerated()), id: \.element) { (index, name) in
                    CellView(name, rank: index + 1)
                }
            }
            
            
            
            // MARK: - Footer View
            HStack {
                Spacer()
                
                Button {
                    withAnimation {
                        // Reload names
                        self.loadNames()
                    }
                    
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.headline)
                }
            }
        }
    }
    
    private func loadNames() {
        self.presentedNames = self.names
    }
    
    
    
    
    // MARK: - View Components
    
    /// The view that displays the rank, name, rating, and favorite status of a `Name` object.
    private func CellView(_ name: Name, rank: Int) -> some View {
        
        /// The `.frame` modifier is used to place components perfectly in their position. Use of `Spacer()` will create offsets for the center component.
        HStack {
            
            // Rank
            Text("\(rank)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            // Name and Rating
            VStack(alignment: .center) {
                Text(name.text)
                    .font(.title3)
                
                Text("Rating: \(name.affinityRating)")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            
            // Favorite Indicator
            Button {
                // Toggle Favorite.
                withAnimation {
                    name.toggleFavorite()
                }
                
            } label: {
                Image(systemName: name.isFavorite ? "star.fill" : "star")
                    .foregroundColor(name.isFavorite ? .yellow : .gray)
                    .font(.headline)
            }
            .sensoryFeedback(.impact, trigger: name.isFavorite)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    
    // MARK: - Empty Favorites View
    
    /// A view to display when no favorites are found.
    private var noFavoritesFound: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundColor(.yellow)
            
            Text("No favorite \(self.selectedSex.alternateName.lowercased()) names are found! Try adding them to your favorites to keep them available here.")
                .multilineTextAlignment(.center)
        }
    }
    
    
}


#if DEBUG

// MARK: - Preview

#Preview {
    List {
        FavoriteNamesView()
            .modelContainer(previewModelContainer)
    }
}

#endif

