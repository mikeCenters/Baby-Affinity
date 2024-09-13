//
//  RefreshableNamesView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/13/24.
//

import SwiftUI


// MARK: - Refreshable Names View

/// A SwiftUI view that displays a list of names and can be expanded or collapsed.
/// When collapsed, a limited number of names are shown, and when expanded, all names are shown.
struct RefreshableNamesView: View {
    
    // MARK: - Properties
    
    /// An array of tuples where each tuple consists of a rank and a name. This data is displayed in the view.
    var names: [(Rank, Name)]
    
    /// The title displayed as the header of the section.
    var title: String = ""
    
    
    // MARK: - Controls and Constants
    
    /// A state variable that determines whether to show more names or a limited number of names.
    /// - `true`: Show all names.
    /// - `false`: Show only a limited number of names (determined by `nameLimit`).
    @State private var showMore: Bool = false
    
    /// The maximum number of names to display when the view is in a collapsed state.
    private let nameLimit = 5
    
    
    // MARK: - Body
    
    var body: some View {
        NamesViewSection(
            names: showMore ? names : Array(names.prefix(nameLimit)),
            title: title) {
            
            /// A button that toggles between showing more or fewer names in the section.
            collapseAndExpandButton
        }
    }
}


// MARK: - View Components

extension RefreshableNamesView {
    
    // MARK: - Footer Button
    
    /// A button view that toggles the `showMore` state.
    /// - Displays "Show More" when collapsed and "Show Less" when expanded.
    private var collapseAndExpandButton: some View {
        Button(action: {
            withAnimation {
                showMore.toggle()
            }
            
        }) {
            Image(systemName: showMore ? "chevron.up" : "chevron.down")
                .font(.headline)
        }
    }
}


#if DEBUG

// MARK: - Preview

#Preview("In a List and Tab View") {
    TabView {
        List {
            RefreshableNamesView(names: PreviewData.rankedMaleNames, title: "Expandable List of Names")
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
