//
//  SectionView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/16/24.
//

import SwiftUI

/// A reusable section view with an icon, title, description, and optional customizable content.
struct SectionView<Content: View>: View {
    
    // MARK: - Properties
    
    /// The name of the system image icon to display.
    let iconName: String
    
    /// The title text to display.
    let title: String
    
    /// The description text to display.
    let description: String
    
    /// An optional closure that provides additional content to display below the description.
    var extendedContent: (() -> Content)? = nil
    
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Spacer()
                    Image(systemName: iconName)
                        .headerSymbolStyle()
                    Spacer()
                }
                .padding()
                
                Text(title)
                    .font(.title).bold()
                
                Text(description)
                
                // Conditionally show the content if it's available
                if let contentView = extendedContent {
                    contentView()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            Divider()
        }
    }
}


#if DEBUG

// MARK: - Previews

/// Provides a preview for the `SectionView` with example content.
struct SectionView_Previews: PreviewProvider {
    static var previews: some View {
        SectionView(iconName: "star.fill",
                    title: "Sample Title",
                    description: "Sample description text.") {
            Text("Extended content goes here.")
        }
    }
}

#endif
