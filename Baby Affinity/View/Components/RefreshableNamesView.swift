//
//  RefreshableNamesView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/13/24.
//

import SwiftUI


// MARK: - Refreshable Names View

/// A SwiftUI view that displays a list of names with a refresh button.
/// The view includes a section header and a button to trigger a refresh action.
///
/// - Note: When the refresh button is tapped, it refreshes the list with the provided data, then executes
/// the provided `onRefresh` closure and triggers a haptic feedback.
struct RefreshableNamesView: View {
    
    // MARK: - Properties
    
    /// An array of tuples where each tuple consists of a rank and a name.
    var names: [(Rank, Name)]
    
    /// The title displayed as the header of the section.
    var title: String = ""
    
    /// The limit of names to be presented in the view.
    var nameLimit: Int = 5
    
    /// The action to be executed when the refresh button is tapped.
    var onRefresh: (() -> Void)?
    
    /// An array of tuples where each tuple consists of a rank and a name. This is the data presented to the view.
    @State private var presentedNames: [(Rank, Name)] = []
    
    
    // MARK: - Body
    
    var body: some View {
        NamesViewSection(names: presentedNames, title: title) {
            
            Button {
                withAnimation {
                    refreshNames()
                }
                
                if let action = onRefresh {
                    action()
                }
                
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.headline)
            }
            .buttonStyle(.borderless)
        }
        
        
        // MARK: - On Appear
        
        .onAppear() {
            if presentedNames.isEmpty {
                withAnimation {
                    refreshNames()
                }
            }
        }
    }
}


// MARK: - Methods

extension RefreshableNamesView {
    
    /// Refresh the presented names array with random names from the names array.
    private func refreshNames() {
        presentedNames = names.randomElements(count: nameLimit)
    }
}


#if DEBUG

import Store

// MARK: - Preview

#Preview("In a List and Tab View") {
    TabView {
        List {
            RefreshableNamesView(names: PreviewData.rankedMaleNames(count: 100), title: "Refreshable List of Names")
        }
        .tabItem {
            Label {
                Text("Home")
            } icon: {
                Image(systemName: "list.bullet.below.rectangle")
            }
        }
    }
    .environmentObject(Store.premium)
}

#endif
