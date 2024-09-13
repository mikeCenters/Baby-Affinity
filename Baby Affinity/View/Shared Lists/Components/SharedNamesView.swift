//
//  SharedNamesView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/12/24.
//

import SwiftUI


// MARK: - Expandable Names View

/// A SwiftUI view that displays a list of names and can be expanded or collapsed.
/// When collapsed, a limited number of names are shown, and when expanded, all names are shown.
struct ExpandableNamesView: View {
    
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
        Section(header: Text(title)) {
            
            /// Displays either all names or a subset of them based on the `showMore` state.
            ForEach(showMore ? names : Array(names.prefix(nameLimit)), id: \.1.id) { (rank, name) in
                NameCellView(name: name, rank: rank)
            }
            
            
            // MARK: - Footer View
            
            /// A button that toggles between showing more or fewer names in the list.
            collapseAndExpandButton
        }
    }
    
    
    // MARK: - Footer Button
    
    /// A button view that toggles the `showMore` state.
    /// - Displays "Show More" when collapsed and "Show Less" when expanded.
    private var collapseAndExpandButton: some View {
        Button(action: {
            withAnimation {
                showMore.toggle()
            }
        }) {
            Text(showMore ? "Show Less" : "Show More")
                .foregroundColor(.blue)
        }
    }
}


#if DEBUG

// MARK: - Preview

#Preview("Expandable Names View in a List and Tab View - Non-Premium Account") {
    let names: [Name] = (0..<10).map { _ in try! Name("Some Name", sex: .male) }
    let rankedNames: [(Int, Name)] = names.enumerated().map { (index, name) in
        (index + 1, name)
    }
    
    return TabView {
        List {
            ExpandableNamesView(names: rankedNames, title: "Expandable List of Names")
        }
        .tabItem {
            Label {
                Text("Home")
            } icon: {
                Image(systemName: "list.bullet.below.rectangle")
            }
        }
        
    }
    .modelContainer(previewModelContainer_WithFavorites)
    .environmentObject(Store.premium)
}
//
//#Preview("Top Names View in a List - Non-Premium Account") {
//    return List {
//        SharedNamesView()
//    }
//    .modelContainer(previewModelContainer_WithFavorites)
//    .environmentObject(Store.shared)
//}
//
//#Preview("Top Names View in a List and Tab View - Premium Account") {
//    return TabView {
//        List {
//            SharedNamesView()
//        }
//        .tabItem {
//            Label {
//                Text("Home")
//            } icon: {
//                Image(systemName: "list.bullet.below.rectangle")
//            }
//        }
//        
//    }
//    .modelContainer(previewModelContainer_WithFavorites)
//    .environmentObject(Store.shared)
//}
//
//#Preview("Top Names View in a List - Premium Account") {
//    return List {
//        SharedNamesView()
//    }
//    .modelContainer(previewModelContainer_WithFavorites)
//    .environmentObject(Store.shared)
//}

#endif
