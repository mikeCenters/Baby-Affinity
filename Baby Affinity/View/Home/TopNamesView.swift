//
//  TopNamesView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/1/24.
//

import SwiftUI
import SwiftData

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
            SortDescriptor<Name>(\Name.affinityRating, order: .reverse)
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
    @Environment(\.modelContext) private var modelContext
    
    /// The selected sex stored in user defaults.
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    /// The list of male names fetched from the model context.
    @Query(getFetchDescriptor(of: .male)) var maleNames: [Name]
    
    /// The list of female names fetched from the model context.
    @Query(getFetchDescriptor(of: .female)) var femaleNames: [Name]
    
    /// The list of names to be presented, including their rank.
    @State private var presentedNames: [(Rank, Name)] = []
    
    
    // MARK: - Controls and Constants
    
    /// The current state of the view.
    @State private var viewState: TopNamesView.ViewState = .isLoading
    
    /// A state to control whether more names are shown.
    @State private var showMore: Bool = false
    
    /// The limit on the number of names to be displayed initially.
    private let nameLimit = 5
    
    
    // MARK: - Body
    
    var body: some View {
        Section(header: Text("Top \(selectedSex.childNaming) Names")) {
            
            // MARK: - Cell View
            
            switch viewState {
            case .isLoading:
                LoadingIndicator()                              /// Show a loading indicator when the view is loading data.
                
            case .showNames:
                ForEach(presentedNames, id: \.0) { (rank, name) in
                    if rank <= nameLimit {
                        NameCellView(name: name, rank: rank)    /// Show the name cell view for the top names.
                    } else if showMore {
                        NameCellView(name: name, rank: rank)    /// Show the name cell view for additional names if "show more" is toggled.
                    }
                }
            }
            
            // MARK: - Footer View
            collapseAndExpandButton
                .disabled(viewState == .isLoading)              /// Disable the button if the view is still loading.
        }
        // MARK: - On Appear
        .onAppear {
            if viewState == .isLoading {
                presentNames()                      /// Present the names when the view appears.
                handleViewState()                   /// Handle the view state based on the names presented.
            }
        }
        // MARK: - On Change
        .onChange(of: selectedSex) {
            presentNames()              /// Recalculate the presented names when the list of seletced sex changes.
            handleViewState()           /// Update the view state accordingly.
        }
        .onChange(of: maleNames) {
            presentNames()              /// Recalculate the presented names when the list of male names changes.
            handleViewState()           /// Update the view state accordingly.
        }
        .onChange(of: femaleNames) {
            presentNames()              /// Recalculate the presented names when the list of female names changes.
            handleViewState()           /// Update the view state accordingly.
        }
    }
}


// MARK: - View Components

extension TopNamesView {
    
    /// A view representing the collapse and expand button to toggle between showing more or fewer names.
    var collapseAndExpandButton: some View {
        
        HStack {
            Spacer()
            
            Button {
                withAnimation {
                    showMore.toggle()                   /// Toggle the state to show more or fewer names.
                }
                
            } label: {
                Image(systemName: showMore ? "chevron.up" : "chevron.down")
                    .font(.headline)
            }
            .buttonStyle(.borderless)                   /// Apply a borderless button style.
        }
    }
}


// MARK: - Methods

extension TopNamesView {
    
    /// Handles the view state based on whether there are names to present.
    /// If no names are available, the view stays in the `isLoading` state.
    private func handleViewState() {
        withAnimation {
            viewState = presentedNames.isEmpty ? .isLoading : .showNames
            
            if viewState == .isLoading {
                showMore = false
            }
        }
    }
    
    /// Updates the `presentedNames` state with the names to be displayed, based on the selected sex.
    private func presentNames() {
        withAnimation {
            presentedNames = getNamesToPresent()
        }
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
}


#if DEBUG

// MARK: - Preview

#Preview("Top Names View in a List and Tab View") {
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
}

#Preview("Top Names View in a List") {
    List {
        TopNamesView()
    }
    .modelContainer(previewModelContainer_WithFavorites)
}

#endif
