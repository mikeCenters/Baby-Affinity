//
//  NamesView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/11/24.
//

import SwiftUI
import SwiftData

/// A view that displays a list of names filtered by the selected sex and sorted by affinity rating.
struct NamesView: View {
    
    // MARK: - Properties
    
    /// The list of names to be queried.
    @Query private var namesQuery: [Name]
    
    /// The selected sex for filtering the names.
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    /// The list of names to be presented.
    @State private var names: [Name] = []
    
    
    // MARK: - Controls
    
    /// A binding to control the visibility of the view.
    @Binding var isShown: Bool
    
    
    // MARK: - Init
    
    /// Initializes a new instance of `NamesView`.
    ///
    /// A view that shows all list of all names in descending order, based on the affinity rating attribute.
    ///
    /// - Parameters:
    ///   - isShown: A binding to control the visibility of the view.
    init(isShown: Binding<Bool>) {
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
            // MARK: - Toolbar
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
        // MARK: - On Appear
        .onAppear() {
            withAnimation {
                loadNames()
            }
        }
        // MARK: - On Change
        .onChange(of: namesQuery) {
            withAnimation {
                loadNames()
            }
        }
    }
    
    
    // MARK: - Methods
    
    /// Load names from the query to the view.
    private func loadNames() {
        names = namesQuery.filter { $0.sex == selectedSex }
    }
}


#if DEBUG

// MARK: - Preview

#Preview {
    NamesView(isShown: .constant(true))
        .modelContainer(previewModelContainer_WithFavorites)
}

#endif
