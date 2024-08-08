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
    
    // MARK: - Properties
    
    /// The environment's model context.
    @Environment(\.modelContext) private var modelContext
    
    /// The selected sex for which the names are filtered, stored in `AppStorage`.
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    /// The top `nameLimit` of names to present.
    @Query private var names: [Name]
    
    
    // MARK: - Controls and Constants
    
    /// Boolean to control the visibility of additional names.
    @State private var showMore: Bool = false
    
    /// Boolean to indicate if the view is in a loading state.
    @State private var isLoading = false
    
    /// The limit of names to be presented.
    static private let nameLimit = 10
    
    /// The limit of names to show when the view is collapsed.
    static private let abvLimit = 5
    
    
    // MARK: - Init
    
    /**
     Initializes a `TopNamesView` with a specific sex filter.

     - Parameter sex: The `Sex` to filter the names by. This parameter determines which names are displayed based on their associated sex.

     This initializer creates a `FetchDescriptor` configured with a predicate to filter names based on the provided sex, and a sort descriptor to order the names by their `affinityRating` in descending order. The fetch limit is set to the top `nameLimit` names to be presented.

     Example usage:
     ```
     TopNamesView(sex: .female)
     ```
     */
    init(sex: Sex) {
        var descriptor = FetchDescriptor<Name>(
            predicate: #Predicate { $0.sexRawValue == sex.rawValue },
            sortBy: [.init(\.affinityRating, order: .reverse)]
        )
        descriptor.fetchLimit = Self.nameLimit
        
        _names = Query(descriptor)
    }
    
    
    // MARK: - Body
    
    var body: some View {
        Section(header: Text("Top \(selectedSex.alternateName) Names")) {
            
            // MARK: - Cell View
            
            if names.isEmpty {           // Names are not loaded
                LoadingIndicator(isLoading: $isLoading)
                
                
            } else {                        // Show the list of top names
                ForEach(Array(names.enumerated()).prefix(showMore ? Self.nameLimit : Self.abvLimit), id: \.element) { (index, name) in
                    /// The topNames array is arranged in descending order of the rank.
                    /// The array is already set to reflect their rank, so index+1 gives the correct value.
                    NameCellView(name: name, rank: index + 1)
                        .onAppear { print("showing \(name.text)")}
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
    }
}


#if DEBUG

// MARK: - Preview

#Preview {
    List {
        TopNamesView(sex: .male)
    }
    .modelContainer(previewModelContainer_WithFavorites)
}

#endif
