//
//  TopNamesView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/1/24.
//

import SwiftUI
import SwiftData

/// A list view of the top 10 `Name`s based on the Affinity Rating attribute.
struct TopNamesView: View {
    
    // MARK: - View States
    
    enum States {
        case isLoading, showNames
    }
    
    
    // MARK: - Properties
    
    /// The environment's model context.
    @Environment(\.modelContext) private var modelContext
    
    /// The selected sex for which the names are filtered, stored in `AppStorage`.
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    /// All names stored in persistence, ordered by the affinity rating.
    @Query(sort: \Name.affinityRating, order: .reverse)
    private var nameQuery: [Name]
    
    /// The top `nameLimit` of names to present.
    @State private var presentedNames: [Name] = []
    
    
    // MARK: - Controls and Constants
    
    /// Boolean to control the visibility of additional names.
    @State private var showMore: Bool = false
    
    /// The limit of names to be presented.
    static private let nameLimit = 10
    
    /// The limit of names to show when the view is collapsed.
    static private let abvLimit = 5
    
    /// The state of the view.
    @State private var viewState: TopNamesView.States = .isLoading
    
    
    // MARK: - Body
    
    var body: some View {
        Section(header: Text("Top \(selectedSex.childNaming) Names")) {
            
            // MARK: - Cell View
            
            switch viewState {
            case .isLoading:        /// Names are not loaded
                LoadingIndicator()
                
            case .showNames:        /// Show the list of top names
                ForEach(Array(presentedNames.enumerated()).prefix(showMore ? Self.nameLimit : Self.abvLimit), id: \.element) { (index, name) in
                    /// The topNames array is arranged in descending order of the rank.
                    /// The array is already set to reflect their rank, so index+1 gives the correct value.
                    NameCellView(name: name, rank: index + 1)
                }
            }
            
            
            // MARK: - Footer View
            
            HStack {
                Spacer()
                
                Button {                    /// Toggle to expand and collapse the view..
                    withAnimation {
                        showMore.toggle()
                    }
                    
                } label: {
                    Image(systemName: showMore ? "chevron.up" : "chevron.down")
                        .font(.headline)
                }
                .buttonStyle(.borderless)   /// Disable List cell tapping.
            }
            
        }
        // MARK: - On Appear
        .onAppear {
            presentNames()
            handleViewState()
        }
        // MARK: - On Change
        .onChange(of: nameQuery) {
            presentNames()
            handleViewState()
        }
    }
}


// MARK: - Methods

extension TopNamesView {
    /// Set the view state based on whether names are queried.
    private func handleViewState() {
        viewState = nameQuery.isEmpty ? .isLoading : .showNames
    }
    
    /// Present names from the query.
    private func presentNames() {
        let names = nameQuery.filter { $0.sex == selectedSex }
        presentedNames = Array(names.prefix(Self.nameLimit))
    }
}


#if DEBUG

// MARK: - Preview

#Preview {
    List {
        TopNamesView()
    }
    .modelContainer(previewModelContainer_WithFavorites)
}

#endif
