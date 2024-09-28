//
//  SharedNamesView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/13/24.
//

import SwiftUI


// MARK: - Shared Names View

/// A SwiftUI view that displays two lists of shared names: one for male names and one for female names.
/// The names are grouped into two categories: top names and favorite names.
/// - `maleNames`: An array of ranked male names to be displayed.
/// - `femaleNames`: An array of ranked female names to be displayed.
struct SharedNamesView: View {
    
    // MARK: - Properties
    
    /// The ranked male names that are passed to the view.
    var maleNames: [(Rank, Name)]
    
    /// The ranked female names that are passed to the view.
    var femaleNames: [(Rank, Name)]
    
    /// The top-ranked male names that will be displayed in the view.
    @State private var topMaleNames: [(Rank, Name)] = []
    
    /// The favorite male names that will be displayed in the view.
    @State private var favoriteMaleNames: [(Rank, Name)] = []
    
    /// The top-ranked female names that will be displayed in the view.
    @State private var topFemaleNames: [(Rank, Name)] = []
    
    /// The favorite female names that will be displayed in the view.
    @State private var favoriteFemaleNames: [(Rank, Name)] = []
    
    
    // MARK: - Controls and Constants
    
    /// The maximum number of top names to display.
    private let topNamesLimit = 10
    
    /// The maximum number of favorite names to display.
    private let favoriteNamesLimit = 5
    
    
    // MARK: - Body
    
    /// The body of the `SharedNamesView`. It contains expandable views that display top and favorite names for both male and female categories.
    var body: some View {
        NavigationStack {
            List {
                // Displays the top shared male names in an expandable view.
                ExpandableNamesView(names: topMaleNames, title: "Top Shared Male Names")
                
                // Displays the favorite shared male names in a refreshable view.
                RefreshableNamesView(names: favoriteMaleNames, title: "Shared Favorite Male Names")
                
                // Displays the top shared female names in an expandable view.
                ExpandableNamesView(names: topFemaleNames, title: "Top Shared Female Names")
                
                // Displays the favorite shared female names in a refreshable view.
                RefreshableNamesView(names: favoriteFemaleNames, title: "Shared Favorite Female Names")
            }
            .navigationTitle("Shared Names")
        }
        
        // MARK: - On Appear
        
        // When the view appears, the top and favorite names are set if they are not already loaded.
        .onAppear {
            if topMaleNames.isEmpty || topFemaleNames.isEmpty {
                setProperties()
            }
        }
    }
}


// MARK: - Methods

extension SharedNamesView {
    
    /// Sets the properties for the top and favorite male and female names by filtering and sorting the passed arrays.
    private func setProperties() {
        // Get the top male names and assign them to `topMaleNames`.
        topMaleNames = getTopNames(from: maleNames)
        
        // Get the favorite male names and assign them to `favoriteMaleNames`.
        favoriteMaleNames = getFavoriteNames(from: maleNames)
        
        // Get the top female names and assign them to `topFemaleNames`.
        topFemaleNames = getTopNames(from: femaleNames)
        
        // Get the favorite female names and assign them to `favoriteFemaleNames`.
        favoriteFemaleNames = getFavoriteNames(from: femaleNames)
    }
    
    /// Returns the top names from a given list of ranked names, sorted by their rank.
    /// - Parameter names: The list of ranked names to filter.
    /// - Returns: An array of the top names limited by `topNamesLimit`.
    private func getTopNames(from names: [(Rank, Name)]) -> [(Rank, Name)] {
        Array(names.sorted { $0.0 < $1.0 }.prefix(topNamesLimit))
    }
    
    /// Returns the favorite names from a given list of ranked names, filtered by their favorite status.
    /// - Parameter names: The list of ranked names to filter.
    /// - Returns: An array of favorite names.
    private func getFavoriteNames(from names: [(Rank, Name)]) -> [(Rank, Name)] {
        names.filter { $0.1.isFavorite }
    }
}


#if DEBUG

import Store

// MARK: - Previews

/// A preview for `SharedNamesView` that displays sample data.
#Preview {
    SharedNamesView(maleNames: PreviewData.rankedMaleNames(count: 100),
                    femaleNames: PreviewData.rankedFemaleNames(count: 100))
    .modelContainer(previewModelContainer)
    .environmentObject(Store.premium)
}

#endif
