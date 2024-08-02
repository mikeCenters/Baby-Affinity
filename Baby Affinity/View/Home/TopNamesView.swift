//
//  TopNamesView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/1/24.
//

import SwiftUI
import SwiftData

struct TopNamesView: View {
    
    // MARK: - Fetch Descriptor
    /// The `FetchDescriptor` used to return the top 10 names of the user.
    static private var fetchDescriptor: FetchDescriptor<Name> {
        var descriptor = FetchDescriptor<Name>()
        descriptor.sortBy = [SortDescriptor(\Name.affinityRating, order: .reverse)]
        descriptor.fetchLimit = 10
        
        return descriptor
    }
    
    
    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    
    @Query(Self.fetchDescriptor)
    private var names: [Name]
    
    
    @State private var showMore: Bool = false
    
    private let headerTitle: String = "Your Top Names"
    
    
    // MARK: - Body
    
    var body: some View {
        Section(header: Text(headerTitle)) {
            
            // MARK: - Cell View
            
            // List of top names
            ForEach(Array(names.enumerated()).prefix(showMore ? names.count : 5), id: \.element) { (index, name) in
                CellView(name, rank: index + 1)
            }
            
            
            // MARK: - Footer View
            HStack {
                Spacer()
                
                Button {
                    withAnimation {
                        // Show top names
                        self.showMore.toggle()
                    }
                    
                } label: {
                    Image(systemName: showMore ? "chevron.up" : "chevron.down")
                        .font(.headline)
                }
            }
        }
    }
    
    
    // MARK: - View Components
    
    /// The view that displays the rank, name, rating, and favorite status of a `Name` object.
    private func CellView(_ name: Name, rank: Int) -> some View {
        
        /// The `.frame` modifier is used to place components perfectly in their position. Use of `Spacer()` will create offsets for the center component.
        HStack {
            
            // Rank
            Text("\(rank)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            // Name and Rating
            VStack(alignment: .center) {
                Text(name.text)
                    .font(.title3)
                
                Text("Rating: \(name.affinityRating)")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            
            // Favorite Indicator
            Button {
                // Toggle Favorite.
                withAnimation {
                    name.toggleFavorite()
                }
                
            } label: {
                Image(systemName: name.isFavorite ? "star.fill" : "star")
                    .foregroundColor(name.isFavorite ? .yellow : .gray)
                    .font(.headline)
            }
            .sensoryFeedback(.impact, trigger: name.isFavorite)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}


#if DEBUG

// MARK: - Preview

#Preview {
    List {
        TopNamesView()
            .modelContainer(previewModelContainer)
    }
}

#endif
