//
//  PresentationLayout.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/5/24.
//

import SwiftUI

// MARK: - Presentation Layout

/// A custom layout that divides its space into two sections:
/// 1. The top section occupies 1/3 of the height.
/// 2. The bottom section occupies 2/3 of the height.
/// The layout centers one or two subviews in these sections.
struct PresentationLayout: Layout {
    
    /// Calculates the size that best fits the proposal, based on the subviews.
    /// - Parameters:
    ///   - proposal: The proposed size for the view.
    ///   - subviews: The list of subviews to be laid out.
    ///   - cache: A cache used for any data that may persist between layout passes (unused here).
    /// - Returns: The best fitting size based on the proposal.
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        // Use the proposed size if provided, or fallback to 0 if nil
        let width = proposal.width ?? 0
        let height = proposal.height ?? 0
        
        return CGSize(width: width, height: height)
    }
    
    /// Places the subviews within the given bounds.
    /// - Parameters:
    ///   - bounds: The rectangle that defines the layout area.
    ///   - proposal: The proposed size for the view.
    ///   - subviews: The list of subviews to be laid out.
    ///   - cache: A cache used for any data that may persist between layout passes (unused here).
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        // Ensure the number of subviews is either 1 or 2
        guard (1...2).contains(subviews.count) else { return }
        
        // Available width of the layout
        let availableWidth = bounds.width
        
        // Calculate the height for the top and bottom sections
        let topHeight = bounds.height * 1 / 3
        let bottomHeight = bounds.height * 2 / 3
        
        /// A helper function to place a subview in a section, centering it.
        /// - Parameters:
        ///   - subview: The subview to be placed.
        ///   - sectionHeight: The height of the section where the subview is placed.
        ///   - yOffset: The vertical offset within the layout for the section.
        func placeSubview(_ subview: LayoutSubview, in sectionHeight: CGFloat, yOffset: CGFloat) {
            // Calculate the size that best fits the subview within the available width and section height
            let subviewSize = subview.sizeThatFits(ProposedViewSize(width: availableWidth, height: sectionHeight))
            
            // Center the subview horizontally within the available width
            let xOffset = (availableWidth - subviewSize.width) / 2
            
            // Calculate the vertical position to center the subview in the section
            let yPosition = bounds.minY + yOffset + (sectionHeight - subviewSize.height) / 2
            
            // Place the subview at the calculated position
            subview.place(at: CGPoint(x: bounds.minX + xOffset, y: yPosition),
                          proposal: ProposedViewSize(width: availableWidth, height: sectionHeight))
        }
        
        // Place the first subview in the top section
        placeSubview(subviews[0], in: topHeight, yOffset: 0)
        
        // If there's a second subview, place it in the bottom section
        if subviews.count == 2 {
            placeSubview(subviews[1], in: bottomHeight, yOffset: topHeight)
        }
    }
}


#if DEBUG

// MARK: - Previews

/// A preview for the `PresentationLayout` that displays two text views:
/// 1. "Top Section" in the top section.
/// 2. "Bottom Section" in the bottom section.
#Preview("Presentation Layout") {
    PresentationLayout {
        Text("Top Section")
        
        Text("Bottom Section")
    }
}

#endif
