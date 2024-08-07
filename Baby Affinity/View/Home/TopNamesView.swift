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
    
    /// The names of the selected `Sex` that are labeled as a favorite.
    var names: [Name]
    
    
    // MARK: - Controls and Constants
    
    /// Boolean to control the visibility of additional names.
    @State private var showMore: Bool = false
    
    /// Boolean to indicate if the view is in a loading state.
    @State private var isLoading = false
    
    
    // MARK: - Body
    
    var body: some View {
        Section(header: Text("Top \(selectedSex.alternateName) Names")) {
            
            // MARK: - Cell View
            
            if names.isEmpty {         // Names are not loaded
                LoadingIndicator(isLoading: $isLoading)
                
                
            } else {                        // Show the list of top names
                ForEach(Array(names.enumerated()).prefix(showMore ? names.count : 5), id: \.element) { (index, name) in
                    NameCellView(name: name, rank: index + 1)
                }
            }
            
            
            // MARK: - Footer View
            
            HStack {
                Spacer()
                
                Button {                    /// Toggle to show more names.
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
    
    let names = (1...10).map {
        Name("Name \($0)", sex: .male, affinityRating: 1200)
    }
    
    
    return List {
        TopNamesView(names: names)
            .modelContainer(previewModelContainer_WithFavorites)
    }
}

#endif
