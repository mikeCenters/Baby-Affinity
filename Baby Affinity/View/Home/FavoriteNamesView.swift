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
    
    /// The `FetchDescriptor` used to return the favorite names of the user.
    static private func fetchDescriptor(for sex: Sex) -> FetchDescriptor<Name> {
        return FetchDescriptor<Name>(
            predicate: #Predicate {
                $0.sexRawValue == sex.rawValue && $0.isFavorite
            }
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
    
    
    // MARK: - Controls and Constants
    
    private let maxPresentedNames = 5
    
    /// Timestamp for last refresh.
    @State private var lastRefresh: Date = .distantPast
    /// The time between data refreshes.
    private let refreshCooldown: TimeInterval = 1 // 1 second cooldown
        
    
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
                
                if presentedNames.isEmpty {   // No favorite names are available
                    self.noFavoritesFound
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    
                } else {                      // Favorites are available
                    ForEach(self.presentedNames, id: \.self) { name in
                        CellView(name, rank: name.getRank(from: modelContext) ?? 0)
                    }
                }
                
                
                // MARK: - Footer View
                
                HStack {
                    Spacer()
                    
                    // Reload names
                    Button {
                        withAnimation {
                            self.loadNames()
                        }
                        
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline)
                    }
                    .buttonStyle(.borderless)
                    .sensoryFeedback(.impact, trigger: self.presentedNames)
                }
            }
            .onAppear {
                // MARK: - On Appear
                
                withAnimation {
                    self.loadNames()
                }
            }
            .onChange(of: self.names) { oldValue, newValue in
                // MARK: - On Change
                
                guard self.presentedNames.count < self.maxPresentedNames
                else { return }
                
                if self.presentedNames.count == self.maxPresentedNames {
                    
                } else {
                    self.loadNames()
                }
            }
    }
}


// MARK: - View Components

extension FavoriteNamesView {
    
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
            .buttonStyle(.borderless)   /// Disable List cell tapping.
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


// MARK: - Methods

extension FavoriteNamesView {
    
    /// Load names to be presented in the view.
    private func loadNames() {
        /// Check if the cooldown period has passed
        let currentTime = Date()
        guard currentTime.timeIntervalSince(self.lastRefresh) >= self.refreshCooldown 
        else { return }
        
        let maxCount = min(self.maxPresentedNames, self.names.count)
        
        guard maxCount > 0 else {
            self.presentedNames = []
            return
        }
        
        self.presentedNames = self.names.randomElements(count: self.maxPresentedNames)
    }
}


#if DEBUG

// MARK: - Preview

#Preview {
    List {
        FavoriteNamesView()
            .modelContainer(previewModelContainer_WithFavorites)
    }
}

#endif
