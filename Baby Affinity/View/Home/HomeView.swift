//
//  HomeView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/5/24.
//
import SwiftUI
import SwiftData

/// The main home view of the Baby Affinity app.
struct HomeView: View {
    
    // MARK: - Properties
    
    /// The environment's model context.
    @Environment(\.modelContext) private var modelContext
    
    /// The selected sex for which the names are filtered, stored in `AppStorage`.
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    
    // MARK: - Controls and Constants
    
    /// The title of the navigation bar.
    private let headerTitle = "Baby Affinity"
    
    /// Show all names of the selected sex.
    @State private var showAllNames = false
    
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                
                // FIXME: Add Name Selection Card.
                /// A card view, with a full name option, due date, etc.
                
                /// Displays the top names based on affinity rating.
                TopNamesView()
                    
                /// Displays the favorite names.
                FavoriteNamesView()
                
                // FIXME: Create Shared List
                
                // FIXME: Add precurated top names as a banner to add names to your favorites. These could be pulled from the global list as rising names or top 10 global names.
                
                // FIXME: Add most viewed names.
                
                /// Displays the sheet with all names of the selected sex.
                showAllNamesButton
            }
            .navigationTitle(headerTitle)
            .toolbar {
                /// Toolbar item to select the sex for filtering names.
                SexSelectionIconView()
            }
            .sheet(isPresented: $showAllNames) {
                NamesView(isShown: $showAllNames)
            }
        }
    }
    
    
    // MARK: - View Components
    
    var showAllNamesButton: some View {
        HStack {
            Spacer()
            
            Button {
                withAnimation {
                    showAllNames.toggle()
                }
            } label: {
                Text("Show all names")
            }
            .font(.headline)
            
            Spacer()
        }
        .listRowBackground(Color.clear)
    }
}


#if DEBUG

// MARK: - Preview

#Preview {
    HomeView()
        .modelContainer(previewModelContainer_WithFavorites)
}

#endif
