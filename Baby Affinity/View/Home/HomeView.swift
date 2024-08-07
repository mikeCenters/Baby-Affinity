//
//  HomeView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/5/24.
//

import SwiftUI
import SwiftData

// FIXME: - Update query to load names into memory instead of pulling from SwiftData every time. Pull from SwiftData only once and monitor for changes. Else, use a new variable.


struct HomeView: View {
    
    // MARK: - Properties
    
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    /// Query for fetching `Name` objects.
    @Query private var names: [Name]
    
    
//    @Query(sort: \Name.affinityRating,
//           order: .reverse)
//    private var topNames: [Name]
    
    
    @Query(filter: #Predicate<Name> { $0.isFavorite },
           sort: \Name.affinityRating,
           order: .reverse)
    private var favoriteNames: [Name]
    
    
    
    // MARK: - Controls and Constants
    
    private let headerTitle = "Baby Affinity"
    
    
    // MARK: - Body
    
    var body: some View {
        
        NavigationStack {
            
            List {
                TopNamesView(show: self.selectedSex)
                    .modelContext(self.modelContext)
                
                FavoriteNamesView(names: favoriteNames.filter { $0.sex == selectedSex })
                    .modelContext(self.modelContext)
                
                // FIXME: Create Shared List
                Section("Shared List") {
                    ForEach(0..<5) { i in
                        Text("Name \(i+1)")
                    }
                }
                
                // FIXME: Add precurated top names as a banner to add names to your favorites. These could be pulled from the global list as rising names or top 10 global names.
                
                // FIXME: Add most viewed names.
            }
            .navigationTitle(self.headerTitle)
            .toolbar {
                SexSelectionIconView()
            }
        }
    }
}


#if DEBUG

// MARK: - Preview

#Preview {
    HomeView()
        .modelContainer(previewModelContainer_WithFavorites)
}

#endif
