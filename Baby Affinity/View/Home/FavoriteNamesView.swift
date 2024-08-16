//
//  FavoriteNamesView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/3/24.
//

import SwiftUI
import SwiftData

/// A list view of the favorite `Name` objects.
struct FavoriteNamesView: View, NamePersistenceController {
    
    // MARK: - View States
    
    enum States {
        case isLoading, noFavorites, showNames
    }
    
    
    // MARK: - Properties
    
    /// The environment's model context.
    @Environment(\.modelContext) private var modelContext
    
    /// The selected sex for which the names are filtered, stored in `AppStorage`.
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    /// The list of favorite names presented in the view.
    @State private var presentedNames: [Name] = []
    
    
    // MARK: - Controls and Constants
    
    /// The maximum number of names to be presented.
    static private let nameLimit = 5
    
    /// The state of the view.
    @State private var viewState: FavoriteNamesView.States = .isLoading
    
    
    // MARK: - Body
    
    var body: some View {
        Section(header: Text("Favorite \(selectedSex.childNaming) Names")) {
                
                // MARK: - Body
                
                switch viewState {
                case .isLoading:        /// View is loading names
                    LoadingIndicator()
                    
                case .noFavorites:      /// No favorite names are available
                    noFavoritesFound
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    
                case .showNames:        /// Favorites are available
                    ForEach(presentedNames.randomElements(count: Self.nameLimit), id: \.self) { name in
                        let rank = try? getRank(of: name, from: modelContext)
                        NameCellView(name: name, rank: rank ?? 0)
                    }
                }
                
                
                // MARK: - Footer View
                
                HStack {
                    Spacer()
                    
                    // Reload names
                    Button {
                        /// Only load names if the view state is not already loading names.
                        if viewState != .isLoading {
                            withAnimation {
                                loadNames()
                            }
                        }
                        
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline)
                    }
                    .buttonStyle(.borderless)
                    .sensoryFeedback(.impact, trigger: presentedNames)
                }
            }
        // MARK: - On Appear
            .onAppear {
                withAnimation {
                    loadNames()
                }
            }
        // MARK: - On Change
            .onChange(of: selectedSex) {
                withAnimation {
                    loadNames()
                }
            }
            .onChange(of: presentedNames) {
                withAnimation {
                    handleViewState()
                }
            }
    }
}


// MARK: - View Components

extension FavoriteNamesView {
    
    // MARK: - Empty Favorites View
    
    /// The text to be displayed when no favorite `Name`s are found.
    private var noFavoritesText: String {
        "No favorite \(selectedSex.childNaming.lowercased()) names are found! Try adding them to your favorites to keep them available here."
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
        viewState = .isLoading
        presentedNames = []
        
        do {
            let names = try fetchFavoriteNames(sex: selectedSex, context: modelContext)
            let namesToShow = names.randomElements(count: Self.nameLimit)
            presentedNames = namesToShow.sorted { $0.affinityRating > $1.affinityRating }
            
            handleViewState()
        } catch {
            logError("Could not fetch names for the Favorite Names View: \(error)")
        }
        
    }
    
    private func handleViewState() {
        viewState = presentedNames.isEmpty ? .noFavorites : .showNames
    }
}


#if DEBUG

// MARK: - Preview

#Preview("Favorites are available") {
    List {
        FavoriteNamesView()
    }
    .modelContainer(previewModelContainer_WithFavorites)
}

#Preview("Favorites are not available") {
    List {
        FavoriteNamesView()
    }
    .modelContainer(previewModelContainer)
}

#Preview("View is loading") {
    
    @State var selectedSex: Sex = .male

    return List {
        Section(header: Text("Favorite \(selectedSex.childNaming) Names")) {
            
            LoadingIndicator()
            
            // MARK: - Footer View
            
            HStack {
                Spacer()
                
                // Reload names
                Button {
                    
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.headline)
                }
                .buttonStyle(.borderless)
            }
        }
    }
    .modelContainer(previewModelContainer_EmptyStore)
}

#endif
