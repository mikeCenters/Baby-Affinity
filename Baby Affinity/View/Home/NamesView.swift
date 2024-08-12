//
//  NamesView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/11/24.
//

import SwiftUI
import SwiftData

struct NamesView: View {
    
    // MARK: - Properties
    
    @Query private var names: [Name]
    
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    
    // MARK: - Controls
    @Binding var isShown: Bool
    
    
    // MARK: - Init
    
    init(sex: Sex, isShown: Binding<Bool>) {
        let descriptor = FetchDescriptor<Name>(
            predicate: #Predicate { $0.sexRawValue == sex.rawValue },
            sortBy: [.init(\.affinityRating, order: .reverse)]
        )
        
        _names = Query(descriptor)
        _isShown = isShown
    }
    
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("All \(selectedSex.alternateName) Names")) {
                    
                    ForEach(Array(names.enumerated()), id: \.element) { (index, name) in
                        /// The array is arranged in descending order of the rank.
                        /// The array is already set to reflect their rank, so index+1 gives the correct value.
                        NameCellView(name: name, rank: index + 1)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            isShown.toggle()
                        }
                        
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
    }
}


#if DEBUG

// MARK: - Preview

#Preview {
    NamesView(sex: .male, isShown: .constant(true))
        .modelContainer(previewModelContainer_WithFavorites)
}

#endif
