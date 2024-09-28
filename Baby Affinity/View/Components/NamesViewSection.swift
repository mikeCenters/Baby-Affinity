//
//  NamesViewSection.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/13/24.
//

import SwiftUI


// MARK: - Names View Section

/// A SwiftUI view that represents a section of names with an optional footer.
///
/// This view displays a list of names along with their ranks, a section title, and an optional footer view.
///
/// - Parameters:
///   - names: A tuple array of `(Rank, Name)`, where `Rank` represents the ranking of the name and `Name` is the name to be displayed.
///   - title: A string to be used as the header title for the section. Defaults to an empty string.
///   - footer: An optional closure that returns a view of type `Footer` to be displayed as a footer at the bottom of the section. Defaults to `nil`.
///
/// Example usage:
/// ```swift
/// NamesViewSection(names: [(rank1, name1), (rank2, name2)], title: "Top Names") {
///     Text("Footer Content")
/// }
/// ```
///
/// In the example above, `rank1` and `rank2` are instances of `Rank`, and `name1` and `name2` are instances of `Name`. The section will display these names with their ranks, and a footer with the text "Footer Content".
///
/// ```swift
/// NamesViewSection<EmptyView>(names: [(rank1, name1), (rank2, name2)], title: "Top Names")
/// ```
///
/// In the example above, `rank1` and `rank2` are instances of `Rank`, and `name1` and `name2` are instances of `Name`. The section will display these names with their ranks, and have no footer content.
struct NamesViewSection<FooterContent: View>: View {
    
    // MARK: - Properties
    
    /// An array of tuples where each tuple contains a `Rank` and a `Name` to be displayed in the section.
    var names: [(Rank, Name)]
    
    /// The title of the section header.
    var title: String = ""
    
    /// An optional closure that returns a view to be used as the footer for the section.
    var content: (() -> FooterContent)?
    
    
    // MARK: - Body
    
    var body: some View {
        Section(header: Text(title)) {
            
            ForEach(names, id: \.1.id) { (rank, name) in
                NameCellView(name: name, rank: rank)
            }
            
            if let content = content {
                content()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}


#if DEBUG

import Store

// MARK: - Previews

#Preview("In a List - With Title and Footer") {
    List {
        NamesViewSection(names: PreviewData.rankedMaleNames(count: 10),
                         title: "All Male Names") {
            Text("Some Footer")
        }
    }
    .modelContainer(previewModelContainer)
    .environmentObject(Store.main)
}

#Preview("In a List - With Title") {
    List {
        NamesViewSection<EmptyView>(names: PreviewData.rankedMaleNames(count: 10),
                                    title: "All Male Names")
    }
    .modelContainer(previewModelContainer)
    .environmentObject(Store.main)
}

#Preview("In a List - With Footer") {
    List {
        NamesViewSection(names: PreviewData.rankedMaleNames(count: 10)) {
            Text("Some Footer")
        }
    }
    .modelContainer(previewModelContainer)
    .environmentObject(Store.main)
}

#Preview("In a List - With No Title or Footer") {
    List {
        NamesViewSection<EmptyView>(names: PreviewData.rankedMaleNames(count: 10))
    }
    .modelContainer(previewModelContainer)
    .environmentObject(Store.main)
}

#endif
