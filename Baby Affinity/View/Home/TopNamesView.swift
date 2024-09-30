//
//  TopNamesView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/1/24.
//

import SwiftUI
import SwiftData
import SystemLogger

/// `TopNamesView` is a view that displays the top names based on the selected sex (male or female).
/// The names are fetched from the model context and displayed in a ranked list, with options to show more or fewer names and toggle the favorite status of the `Name`.
struct TopNamesView: View {
    
    // MARK: - View States
    
    /// `ViewState` is an enum representing the different states of the view.
    enum ViewState {
        case isLoading  // The view is currently loading data.
        case showNames  // The view is displaying the names.
    }
    
    
    // MARK: - Class Methods
    
    /// A class method that returns a `FetchDescriptor` to fetch names of a specific sex.
    /// The names are sorted by affinity rating in descending order and limited to the top 10.
    /// - Parameter sex: The sex for which names should be fetched.
    /// - Returns: A configured `FetchDescriptor` for fetching names.
    static func getFetchDescriptor(of sex: Sex) -> FetchDescriptor<Name> {
        let sortDescriptors = [
            SortDescriptor<Name>(\Name.affinityRating, order: .reverse),
            SortDescriptor<Name>(\Name.evaluated, order: .reverse),
            SortDescriptor<Name>(\Name.text, order: .forward)
        ]
        
        var descriptor = FetchDescriptor<Name>(
            predicate: #Predicate {
                $0.sexRawValue == sex.rawValue
            },
            sortBy: sortDescriptors
        )
        
        descriptor.fetchLimit = 10
        return descriptor
    }
    
    
    // MARK: - Properties
    
    /// The environment model context.
    @Environment(\.modelContext) var modelContext
    
    /// The object used to inferface with the App Store.
    @EnvironmentObject private var store: Store
    
    /// The selected sex stored in user defaults.
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    /// The list of male names fetched from the model context.
    @Query(getFetchDescriptor(of: .male)) var maleNames: [Name]
    
    /// The list of female names fetched from the model context.
    @Query(getFetchDescriptor(of: .female)) var femaleNames: [Name]
    
    /// The list of names to be presented, including their rank.
    @State private var presentedNames: [(Rank, Name)] = []
    
    
    // MARK: - Controls and Constants
    
    @ProductStatus(ProductID.premiumAccount.rawValue) private var isPremium
    
    /// The current state of the view.
    @State private var viewState: TopNamesView.ViewState = .isLoading
    
    
    // MARK: - Body
    
    var body: some View {
        Group {
            switch viewState {
            case .isLoading:
                LoadingIndicator()              /// Show a loading indicator when the view is loading data.
                
            case .showNames:
                ExpandableNamesView(names: presentedNames, title: "Top \(selectedSex.sexNamingConvention) Names")
            }
        }
        
        
        // MARK: - Task
        
        .task {
            try? await Task.sleep(nanoseconds: 100_000_000) /// Sleep of 0.1 second to allow data to load.
            
            withAnimation {
                if viewState == .isLoading {
                    presentNames()          /// Present the names when the view appears.
                    handleViewState()       /// Handle the view state based on the names presented.
                }
            }
        }
        
        
        // MARK: - On Change
        
        .onChange(of: selectedSex) {    /// Handle an update when the selected sex changes
            withAnimation {
                presentNames()          /// Refresh the presented names
                handleViewState()       /// Update the view state
            }
        }
        
        .onChange(of: isPremium) {      /// Handle an update in purchase state
            withAnimation {
                presentNames()          /// Refresh the presented names
                handleViewState()       /// Update the view state
            }
        }
        
        .onChange(of: maleNames) {      /// Handle a background update of male names
            guard selectedSex == .male else { return }
            
            withAnimation {
                presentNames()          /// Refresh the presented names
                handleViewState()       /// Update the view state
            }
        }
        
        .onChange(of: femaleNames) {    /// Handle a background update of female names
            guard selectedSex == .female else { return }
            
            withAnimation {
                presentNames()          /// Refresh the presented names
                handleViewState()       /// Update the view state
            }
        }
    }
}


// MARK: - Methods

extension TopNamesView: NamePersistenceController {
    
    /// Handles the view state based on whether there are names to present.
    /// If no names are available, the view stays in the `isLoading` state.
    private func handleViewState() {
        viewState = presentedNames.isEmpty ? .isLoading : .showNames
    }
    
    /// Updates the `presentedNames` state with the names to be displayed, based on the selected sex.
    private func presentNames() {
        presentedNames = isPremium ? getNamesToPresent() : getRandomNamesToPresent()
    }
    
    /// Returns a list of names with their ranks, based on the selected sex.
    /// - Returns: A list of tuples containing the rank and the corresponding name.
    private func getNamesToPresent() -> [(Rank, Name)] {
        switch selectedSex {
        case .male:
            return maleNames.enumerated().map { ($0.offset + 1, $0.element) }
            
        case .female:
            return femaleNames.enumerated().map { ($0.offset + 1, $0.element) }
        }
    }
    
    /// Returns a list of names with an obfuscated `Rank`, based on the selected sex. The rank will represent
    /// the name's position in the array, and not its rank in relation to all `Name` objects.
    /// - Returns: A list of tuples containing the rank and the corresponding name.
    private func getRandomNamesToPresent() -> [(Rank, Name)] {
        do {
            let names = try fetchNames(selectedSex)
            let randomNames = names.randomElements(count: 10)
            
            return randomNames.enumerated().map { ($0.offset + 1, $0.element) }
            
        } catch {
            SystemLogger.main.logCritical("Unable to fetch \(selectedSex.sexNamingConvention) names: \(error.localizedDescription)")
        }
        return []
    }
}


#if DEBUG

import Store

// MARK: - Preview

#Preview("Top Names View in a List and Tab View - Non-Premium Account") {
    TabView { NavigationStack {
        List {
            TopNamesView()
        }
    }
    .tabItem {
        Label {
            Text("Home")
        } icon: {
            Image(systemName: "list.bullet.below.rectangle")
        }
    }
    }
    .modelContainer(previewModelContainer_WithFavorites)
    .environmentObject(Store.main)
}

#Preview("Top Names View in a List - Non-Premium Account") {
    List {
        TopNamesView()
    }
    .modelContainer(previewModelContainer_WithFavorites)
    .environmentObject(Store.main)
}

#Preview("Top Names View in a List and Tab View - Premium Account") {
    TabView {
        List {
            TopNamesView()
        }
        .tabItem {
            Label {
                Text("Home")
            } icon: {
                Image(systemName: "list.bullet.below.rectangle")
            }
        }
        
    }
    .modelContainer(previewModelContainer_WithFavorites)
    .environmentObject(Store.main)
}

#Preview("Top Names View in a List - Premium Account") {
    List {
        TopNamesView()
    }
    .modelContainer(previewModelContainer_WithFavorites)
    .environmentObject(Store.main)
}

#endif
