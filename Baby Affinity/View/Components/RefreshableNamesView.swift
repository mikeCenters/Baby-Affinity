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
/// - Note: When the refresh button is tapped, it executes the provided `onRefresh` closure
///   and triggers a haptic feedback.
struct RefreshableNamesView: View {
    
    // MARK: - Properties
    
    /// An array of tuples where each tuple consists of a rank and a name. This data is displayed in the view.
    var names: [(Rank, Name)]
    
    /// The title displayed as the header of the section.
    var title: String = ""
    
    /// The action to be executed when the refresh button is tapped.
    var onRefresh: () -> Void
    
    
    // MARK: - Body
    
    var body: some View {
        NamesViewSection(names: names, title: title) {
            
            Button {
                onRefresh()
                
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.headline)
            }
            .buttonStyle(.borderless)
        }
    }
}


#if DEBUG

// MARK: - Preview

#Preview("In a List and Tab View") {
    TabView {
        List {
            RefreshableNamesView(names: Array(PreviewData.rankedMaleNames.prefix(5)), title: "Refreshable List of Names") {
                
            }
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
