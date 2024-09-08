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
    
    /// The environment model context.
    @Environment(\.modelContext) internal var modelContext
    
    /// The object used to inferface with the App Store.
    @EnvironmentObject internal var store: Store
    
    /// The selected sex for filtering the names.
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    /// The list of names to be presented.
    @State private var names: [Name] = []
    
    
    // MARK: - Controls
    
    /// The property used to check the premium status of the user's account.
    private var isPremiumAccount: Bool {
        store.purchasedProductIDs.contains(Store.premiumProductID)
    }
    
    /// A binding to control the visibility of the view.
    @Binding var isShown: Bool
    
    
    // MARK: - Body
    
    var body: some View { NavigationStack {
        List {
            Section(header: Text("All \(selectedSex.childNaming) Names")) {
                
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
    }
}


// MARK: - Methods

extension NamesView: NamePersistenceController {
    
    /// Load names from the query to the view.
    private func loadNames() {
        do {
            let fetchedNames = try fetchNamesSortedByAffinity(selectedSex)
            
            if isPremiumAccount {
                names = fetchedNames
                
            } else {
                names = fetchedNames.shuffled()
            }
            
        } catch {
            logError("Unable to fetch names in Names View: \(error.localizedDescription)")
        }
    }
}


#if DEBUG

// MARK: - Preview

#Preview("Names View - Non-Premium Account") {
    @StateObject var store = Store.shared
    @State var isShown = true
    
    return NamesView(isShown: $isShown)
        .modelContainer(previewModelContainer_WithFavorites)
        .environmentObject(store)
}

#Preview("Names View - Premium Account") {
    @StateObject var store = Store.premium
    @State var isShown = true
    
    return NamesView(isShown: $isShown)
        .modelContainer(previewModelContainer_WithFavorites)
        .environmentObject(store)
}

#endif
