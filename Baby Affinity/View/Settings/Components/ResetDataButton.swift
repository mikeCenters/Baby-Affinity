//
//  ResetDataButton.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/16/24.
//

import SwiftUI

// MARK: - Reset Data Button

/// A view that provides a button to reset the name data within the app.
/// This view conforms to `NamePersistenceController_Admin` to access the functionality for resetting name data.
/// It presents a confirmation dialog to ensure that the user wants to proceed with resetting all data.
///
/// The `ResetDataButton` view is designed to be used in contexts where the user needs
/// an option to reset the name data, such as in settings or administration panels.
struct ResetDataButton: View, NamePersistenceController_Admin {
    
    // MARK: - Properties
    
    /// The environment's model context used for interacting with the data model.
    @Environment(\.modelContext) var modelContext
    
    /// A closure to be executed before the reset process begins. This allows any additional
    /// logic or UI updates to be triggered before resetting the name data.
    var beforeReset: () -> Void
    
    /// A closure to be executed after the reset process completes. This allows any additional
    /// logic or UI updates to be triggered once the reset operation is done.
    var afterReset: () -> Void
    
    
    // MARK: - Controls
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
                .foregroundColor(.red)
        }
        .confirmationDialog("Reset data", isPresented: $isShowingConfirmation) {
            Button("Yes", role: .destructive) {
                resetData()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You are about to reset all data!\nAre you sure?")
        }
    }
    
    
    // MARK: - Methods
    
    /// Initiates the process to reset the name data in the model context.
    private func resetData() {
        withAnimation{
            beforeReset()
            
        } completion: {
            Task {
                await resetNameData()
                afterReset()
            }
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
            ResetDataButton(beforeReset: { }, afterReset: { })
        }
    }
    .modelContainer(previewModelContainer)
}

// Preview for the `ResetDataButton` along with a debugging view showing a list of names.
#Preview("Reset Data Button with Debugging View") {
    struct PreviewNames: View {
        @Query(sort: \Name.affinityRating, order: .reverse) var names: [Name]
        @Binding var text: String
        
        var body: some View {
            Text("Status: \(text)")
            ForEach(names) { name in
                HStack {
                    Text(name.text)
                    Spacer()
                    Text(name.affinityRating.description)
                }
            }
        }
    }
    
    @Previewable @State var text: String = "Data Loaded"
    
    return List {
        Section {
            ResetDataButton(beforeReset: { text = "Resetting Data"},
                            afterReset: { text = "Data is reset"})
        }
        Section("Debugging List") {
            PreviewNames(text: $text)
        }
        .listRowBackground(Color(.systemGray3))
    }
    .modelContainer(previewModelContainer)
}

#endif
