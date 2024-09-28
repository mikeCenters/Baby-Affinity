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
    
    var body: some View { NavigationStack {
        List {
            /// Displays a first name and the stored last name for liking and disliking.
            NamePreviewCard()
            
            /// Displays the top names based on affinity rating.
            TopNamesView()
            
            /// Displays the favorite names.
            FavoriteNamesView()
            
            Section {
                NavigationLink {
                    
                    NameSharingView()
                    
                    
                } label: {
                    Text("Name Sharing")
                }

            }
            
            
            /// Displays the sheet with all names of the selected sex.
            showAllNamesButton
        }
        .navigationTitle(headerTitle)
        
        
        // MARK: - ToolBar
        
        .toolbar {
            /// Toolbar item to select the sex for filtering names.
            SexSelectionIconView()
        }
        
        
        // MARK: - Sheet
        
        .sheet(isPresented: $showAllNames) {
            NamesView(isShown: $showAllNames)
        }
    }
    }
}


// MARK: - View Components

extension HomeView {
    
    // MARK: - Show All Names Button
    
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

import Store

// MARK: - Preview

#Preview("Home View - Non-Premium Account") {
    HomeView()
        .modelContainer(previewModelContainer_WithFavorites)
        .environmentObject(Store.main)
}

#Preview("Home View - Premium Account") {
    HomeView()
        .modelContainer(previewModelContainer_WithFavorites)
        .environmentObject(Store.premium)
}

#endif
