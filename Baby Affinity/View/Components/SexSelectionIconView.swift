//
//  SexSelectionIconView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/6/24.
//
import SwiftUI

/// A view that displays an icon for selecting the sex (male or female).
struct SexSelectionIconView: View {
    
    // MARK: - Properties
    
    /// The selected sex, stored in AppStorage for persistence.
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    /// State variable to control the display of the sex selection dialog.
    @State private var showSexSelection = false
    
    
    // MARK: - Body
    
    /// The main content view.
    var body: some View {
        // A button that toggles the sex selection dialog.
        Button {
            withAnimation {
                showSexSelection.toggle()
            }
        } label: {
            // The button's icon.
            Image(systemName: "switch.2")
        }
        // A confirmation dialog that allows the user to select a sex.
        .confirmationDialog("Show which names?", isPresented: $showSexSelection) {
            // Iterate over all possible sex values and create a button for each.
            ForEach(Sex.allCases, id: \.self) { sex in
                Button {
                    withAnimation {
                        selectedSex = sex
                    }
                } label: {
                    // Display the child naming convention for each sex.
                    Text(sex.childNaming)
                }
            }
        }
    }
}


#if DEBUG

// MARK: - Preview

/// A preview for the SexSelectionIconView.
#Preview {
    NavigationView {
        // A placeholder text view to show where the icon will be placed in the navigation bar.
        Text("Sex Selection Icon View placed in the navigation bar.")
            .multilineTextAlignment(.center)
            .toolbar {
                // Place the SexSelectionIconView in the top bar trailing position.
                ToolbarItem(placement: .topBarTrailing) {
                    SexSelectionIconView()
                }
            }
    }
}

#endif
