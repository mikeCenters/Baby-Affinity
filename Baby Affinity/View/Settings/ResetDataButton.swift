//
//  ResetDataButton.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/16/24.
//

import SwiftUI

/// A button that resets the name data within the app.
/// This view conforms to `NamePersistenceController_Admin` to access the reset functionality.
struct ResetDataButton: View, NamePersistenceController_Admin {
    
    // MARK: - Properties
    
    /// The environment's model context used for interacting with the data model.
    @Environment(\.modelContext) var modelContext
    
    /// A state variable to control the presentation of the confirmation dialog.
    @State private var isShowingConfirmation = false
    
    
    // MARK: - Body
    
    var body: some View {
        Button {
            withAnimation {
                isShowingConfirmation.toggle()
            }
            
        } label: {
            Text("Reset Data")
        }
        .foregroundColor(.red)
        .confirmationDialog("Reset data", isPresented: $isShowingConfirmation) {
            Button("Yes", role: .destructive) {
                withAnimation {
                    resetNameData(in: modelContext)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You are about to reset all data!\nAre you sure?")
        }
    }
}


#if DEBUG

import SwiftData

// MARK: - Previews

// Preview for the `ResetDataButton` in a list.
#Preview("Reset Data Button in List") {
    List {
        Section {
            ResetDataButton()
        }
    }
    .modelContainer(previewModelContainer)
}

// Preview for the `ResetDataButton` along with a debugging view showing a list of names.
#Preview("Reset Data Button with Debugging View") {
    struct PreviewNames: View {
        @Query(sort: \Name.affinityRating, order: .reverse) var names: [Name]
        
        var body: some View {
            ForEach(names) { name in
                HStack {
                    Text(name.text)
                    Spacer()
                    Text(name.affinityRating.description)
                }
            }
        }
    }
    
    return List {
        Section {
            ResetDataButton()
        }
        Section("Debugging List") {
            PreviewNames()
        }
        .listRowBackground(Color(.systemGray3))
    }
    .modelContainer(previewModelContainer)
}

#endif
