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
    
    // MARK: - Properties
    
    /// The environment's model context.
    @Environment(\.modelContext) private var modelContext
    
    /// The selected sex for which the names are filtered, stored in `AppStorage`.
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    /// The list of favorite names to be queried from the data context.
    @Query private var names: [Name] = []
    
    /// The list of favorite names presented in the view.
    @State private var presentedNames: [Name] = []
    
    
    // MARK: - Controls and Constants
    
    /// The maximum number of names to be presented.
    static private let nameLimit = 5
    
    
    // MARK: - Init
    
    /**
     Initializes a `FavoriteNamesView` with a specific sex filter.

     - Parameter sex: The `Sex` to filter the names by. This parameter determines which favorite names are displayed based on their associated sex.

     This initializer creates a `FetchDescriptor` configured with a predicate to filter names based on the provided sex and their favorite status, and a sort descriptor to order the names by their `affinityRating` in descending order.

     Example usage:
     ```
     FavoriteNamesView(sex: .female)
     ```
     */
    init(sex: Sex) {
        let descriptor = FetchDescriptor<Name>(
            predicate: #Predicate {
                $0.sexRawValue == sex.rawValue &&
                $0.isFavorite
            },
            sortBy: [.init(\.affinityRating, order: .reverse)]
        )
        
        _names = Query(descriptor)
    }
    
    
    // MARK: - Body
    
    var body: some View {
        Section(
            header: Text("Favorite \(selectedSex.alternateName) Names")) {
                
                // MARK: - Cell View
                
                if presentedNames.isEmpty {   // No favorite names are available
                    noFavoritesFound
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    
                } else {                      // Favorites are available
                    ForEach(presentedNames.randomElements(count: Self.nameLimit), id: \.self) { name in
                        NameCellView(name: name, rank: name.getRank(from: modelContext) ?? 0)
                    }
                }
                
                
                // MARK: - Footer View
                
                HStack {
                    Spacer()
                    
                    // Reload names
                    Button {
                        withAnimation {
                            loadNames()
                        }
                        
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline)
                    }
                    .buttonStyle(.borderless)
                    .sensoryFeedback(.impact, trigger: names)
                }
            }
            .onAppear {
                // MARK: - On Appear
                
                withAnimation {
                    loadNames()
                }
            }
            .onChange(of: selectedSex) {
                withAnimation {
                    loadNames()
                }
            }
    }
}


// MARK: - View Components

extension FavoriteNamesView {
    
    // MARK: - Empty Favorites View
    
    /// The text to be displayed when no favorite `Name`s are found.
    private var noFavoritesText: String {
        "No favorite \(selectedSex.alternateName.lowercased()) names are found! Try adding them to your favorites to keep them available here."
    }
    
    /// A view to display when no favorite `Name`s are found.
    private var noFavoritesFound: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundColor(.yellow)
            
            Text(noFavoritesText)
                .multilineTextAlignment(.center)
        }
    }
}


// MARK: - Methods

extension FavoriteNamesView {
    
    /**
     Loads the favorite names to be presented in the view.
     
     This method randomly selects a subset of the favorite names from the `names` array, up to a maximum of `nameLimit`. The selected names are then assigned to `presentedNames` for display in the view.
     
     The selection is done each time the method is called, which can be triggered by user actions such as pressing a reload button.
     
     Example usage:
     ```
     loadNames()
     ```
     */
    private func loadNames() {
        presentedNames = names.randomElements(count: Self.nameLimit)
    }
}


#if DEBUG

// MARK: - Preview

#Preview {
    List {
        FavoriteNamesView(sex: .male)
    }
    .modelContainer(previewModelContainer_WithFavorites)
//    .modelContainer(previewModelContainer)
}

#endif
