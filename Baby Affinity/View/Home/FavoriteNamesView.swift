//
//  FavoriteNamesView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/3/24.
//

import SwiftUI
import SwiftData

/// A view that displays the user's favorite names based on the selected sex.
/// The names are fetched and displayed with their corresponding ranks. The view supports
/// different states such as loading, showing names, or indicating that no favorites are available.
struct FavoriteNamesView: View, NamePersistenceController {
    
    // MARK: - View States
    
    /// Enum representing the different states the view can be in.
    enum ViewState {
        case isLoading, noFavorites, showNames
    }
    
    
    // MARK: - Class Methods
    
    /// A class method that returns a `FetchDescriptor` to fetch names of a specific sex.
    /// The names are filtered to show only favorites and are sorted by affinity rating in descending order.
    /// - Parameter sex: The sex for which names should be fetched.
    /// - Returns: A configured `FetchDescriptor` for fetching names.
    static func getFetchDescriptor(of sex: Sex) -> FetchDescriptor<Name> {
        return FetchDescriptor<Name>(
            predicate: #Predicate {
                $0.sexRawValue == sex.rawValue &&
                $0.isFavorite
            }
        )
    }
    
    
    // MARK: - Properties
    
    /// The environment model context.
    @Environment(\.modelContext) internal var modelContext
    
    /// The selected sex for filtering the names, stored in `AppStorage`.
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    /// An array of favorite male names fetched from the model context.
    @Query(getFetchDescriptor(of: .male)) private var maleNames: [Name]
    
    /// An array of favorite female names fetched from the model context.
    @Query(getFetchDescriptor(of: .female)) private var femaleNames: [Name]
    
    /// The names to be presented in the view, each paired with its rank.
    @State private var presentedNames: [(Rank, Name)] = []
    
    
    // MARK: - Controls and Constants
    
    /// The current state of the view, determining which content is displayed.
    @State private var viewState: FavoriteNamesView.ViewState = .isLoading
    
    /// The maximum number of names to display in the list.
    private let nameLimit = 5
    
    
    // MARK: - Body
    
    var body: some View {
        Section(header: Text("Favorite \(selectedSex.childNaming) Names")) {
            switch viewState {
                
            case .isLoading:
                LoadingIndicator()
                
            case .noFavorites:
                noFavoritesFound
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                
            case .showNames:
                ForEach(presentedNames, id: \.0) { (rank, name) in
                    NameCellView(name: name, rank: rank)
                }
            }
            
            
            // MARK: - Footer View
            
            refreshButton
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
            }
        }
        
        .onChange(of: maleNames) {
            if viewState == .isLoading {
                withAnimation {
                    presentNames()
                }
            }
        }
        
        .onChange(of: femaleNames) {
            if viewState == .isLoading {
                withAnimation {
                    presentNames()
                }
            }
        }
    }
}


// MARK: - View Components

extension FavoriteNamesView {
    
    // MARK: - Refresh Button
    
    /// A button that refreshes the list of favorite names when pressed.
    private var refreshButton: some View {
        HStack {
            Spacer()
            
            Button {
                if viewState != .isLoading {
                    withAnimation {
                        presentNames()
                    }
                    
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.headline)
            }
            .buttonStyle(.borderless)
        }
    }
    
    
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
    
    /// Updates the `presentedNames` state with the names to be displayed, based on the selected sex.
    private func presentNames() {
        let randomNames = getNamesToPresent(for: selectedSex)
        presentedNames = randomNames
        viewState = randomNames.isEmpty ? .noFavorites : .showNames
    }

    /// Returns a list of names with their ranks, based on the selected sex.
    /// - Parameter sex: The selected sex to filter the names.
    /// - Returns: A list of tuples containing the rank and the corresponding name.
    private func getNamesToPresent(for sex: Sex) -> [(Rank, Name)] {
        let names = randomNames(for: sex, count: nameLimit)
        
        return names.map { name in
            let rank = (try? getRank(of: name)) ?? 0
            
            if rank == 0 {
                logError("Unable to get the rank of \(String(describing: name.sex?.sexNamingConvention.description)) name \(name.text) for Favorite Name View.")
            }
            
            return (rank, name)
        }
    }

    /// Returns a random selection of names based on the selected sex.
    /// - Parameters:
    ///   - sex: The selected sex to filter the names.
    ///   - count: The number of names to select.
    /// - Returns: A list of random names.
    private func randomNames(for sex: Sex, count: Int) -> [Name] {
        switch sex {
        case .male:
            return maleNames.randomElements(count: count)
        case .female:
            return femaleNames.randomElements(count: count)
        }
    }
    
    /// Handles the view state based on the availability of names to present.
    private func handleViewState() {
        viewState = presentedNames.isEmpty ? .noFavorites : .showNames
    }
}


#if DEBUG

// MARK: - Preview

#Preview("Favorites are available") {
    @StateObject var store = Store.shared
    
    return List {
        FavoriteNamesView()
    }
    .modelContainer(previewModelContainer_WithFavorites)
    .environmentObject(store)
}

#Preview("Favorites are not available") {
    @StateObject var store = Store.shared
    
    return List {
        FavoriteNamesView()
    }
    .modelContainer(previewModelContainer)
    .environmentObject(store)
}

#Preview("View is loading") {
    @StateObject var store = Store.shared
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
    .environmentObject(store)
}

#endif
