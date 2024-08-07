//
//  HomeView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/5/24.
//

import SwiftUI

// FIXME: - Update query to load names into memory instead of pulling from SwiftData every time. Pull from SwiftData only once and monitor for changes. Else, use a new variable.

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    
    
    // MARK: - Controls and Constants
    
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    private let headerTitle = "Baby Affinity"
    
    
    // MARK: - View
    
    var body: some View {
        
        NavigationStack {
            
            List {
                TopNamesView(show: self.selectedSex)
                    .modelContext(self.modelContext)
                
                FavoriteNamesView(show: self.selectedSex)
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
