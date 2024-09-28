//
//  FavoriteNamesView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/3/24.
//

import SwiftUI
import SwiftData
import SystemLogger

/// A view that displays the user's favorite names based on the selected sex.
/// The names are fetched and displayed with their corresponding ranks. The view supports
/// different states such as loading, showing names, or indicating that no favorites are available.
struct FavoriteNamesView: View {
    
    // MARK: - View States
    
    /// Enum representing the different states the view can be in.
    enum ViewState {
        case isLoading, noFavorites, showNames
    }
    
    
    // MARK: - Properties
    
    /// The environment model context.
    @Environment(\.modelContext) internal var modelContext
    
    /// The selected sex for filtering the names, stored in `AppStorage`.
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    /// The names to be presented in the view, each paired with its rank.
    @State private var presentedNames: [(Rank, Name)] = []
    
    
    // MARK: - Controls and Constants
    
    /// The current state of the view, determining which content is displayed.
    @State private var viewState: FavoriteNamesView.ViewState = .isLoading
    
    /// The maximum number of names to display in the list.
    private let nameLimit = 5
    
    
    // MARK: - Body
    
    var body: some View {
        Group {
            switch viewState {
            case .isLoading:
                LoadingIndicator()
                
            case .noFavorites:
                Section {
                    noFavoritesFound
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    
                    Button {
                        withAnimation {
                            refreshNames()
                        }
                        
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline)
                    }
                    .buttonStyle(.borderless)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
            case .showNames:
                RefreshableNamesView(
                    names: presentedNames,
                    title: "Favorite \(selectedSex.childNaming) Names") {
                        withAnimation {
                            refreshNames()
                        }
                }
            }
        }
        
        
        // MARK: - On Appear
        
        .onAppear {
            if viewState == .isLoading {
                withAnimation {
                    presentNames()
                    handleViewState()
                }
            }
        }
        
        
        // MARK: - On Change
        
        .onChange(of: selectedSex) {
            withAnimation {
                presentNames()
                handleViewState()
            }
        }
    }
}


// MARK: - View Components

extension FavoriteNamesView {
    
    // MARK: - Empty Favorites
    
    /// A text describing that no favorite names were found for the selected sex.
    private var noFavoritesText: String {
        "No favorite \(selectedSex.childNaming.lowercased()) names are found! Try adding them to your favorites to keep them available here."
    }
    
    /// A view that displays a message indicating that no favorite names were found.
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
    
    /// Handles the view state based on the availability of names to present.
    private func handleViewState() {
        viewState = presentedNames.isEmpty ? .noFavorites : .showNames
    }
    
    private func refreshNames() {
        if viewState != .isLoading {
            presentNames()
            
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}

extension FavoriteNamesView: NamePersistenceController {
    
    private func presentNames() {
        presentedNames = getNamesToPresent(for: selectedSex)
        handleViewState()
    }
    
    private func getNamesToPresent(for sex: Sex) -> [(Rank, Name)] {
        let names = getRandomFavoriteNames(for: sex, count: nameLimit)
        return addRank(to: names)
    }
    
    private func addRank(to names: [Name]) -> [(Rank, Name)] {
        names.map { name in
            let rank = (try? getRank(of: name)) ?? 0
            
            if rank == 0 {
                SystemLogger.main.logError("Unable to get the rank of \(String(describing: name.sex?.sexNamingConvention.description)) name \(name.text) for Favorite Name View.")
            }
            
            return (rank, name)
        }
    }
    
    private func getRandomFavoriteNames(for sex: Sex, count: Int) -> [Name] {
        getFavoriteNames(for: sex).randomElements(count: count)
    }
    
    private func getFavoriteNames(for sex: Sex) -> [Name] {
        do {
            return try fetchFavoriteNames(sex: sex)
            
        } catch {
            SystemLogger.main.logCritical("Unable to fetch favorite \(sex.sexNamingConvention) names in Favorite Names View: \(error.localizedDescription)")
        }
        
        return []   // Fallback for when names cannot be fetched.
    }
}


#if DEBUG

import Store

// MARK: - Preview

#Preview("Favorites are available") {
    List {
        FavoriteNamesView()
    }
    .modelContainer(previewModelContainer_WithFavorites)
    .environmentObject(Store.premium)
}

#Preview("Favorites are not available") {
    List {
        FavoriteNamesView()
    }
    .modelContainer(previewModelContainer)
    .environmentObject(Store.premium)
}

#Preview("View is loading") {
    return List {
        Section {
            LoadingIndicator()
            
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
    .environmentObject(Store.premium)
}

#endif
