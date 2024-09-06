//
//  PresentationLayout.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/5/24.
//

import SwiftUI


struct PresentationLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        // We assume two subviews (top and bottom)
        guard subviews.count == 2 else { return .zero }
        
        // Use the proposed width and height, or fallback to a default if unavailable
        let width = proposal.width ?? 0
        let height = proposal.height ?? 0
        
        return CGSize(width: width, height: height)
    }
    
    // This method places the subviews in the calculated layout bounds
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        guard subviews.count == 2 else { return }

        let totalHeight = bounds.height
        let availableWidth = bounds.width

        // Calculate the heights for each section (2/5 for top, 3/5 for bottom)
        let topHeight = totalHeight * 2 / 5
        let bottomHeight = totalHeight * 3 / 5

        // Get subview sizes
        let topSubview = subviews[0]
        let bottomSubview = subviews[1]
        let topSubviewSize = topSubview.sizeThatFits(ProposedViewSize(width: availableWidth, height: topHeight))
        let bottomSubviewSize = bottomSubview.sizeThatFits(ProposedViewSize(width: availableWidth, height: bottomHeight))

        // Calculate the x and y coordinates to center each subview
        let topXOffset = (availableWidth - topSubviewSize.width) / 2
        let topYOffset = (topHeight - topSubviewSize.height) / 2
        let bottomXOffset = (availableWidth - bottomSubviewSize.width) / 2
        let bottomYOffset = (bottomHeight - bottomSubviewSize.height) / 2

        // Place the top view centered within its section
        topSubview.place(
            at: CGPoint(x: bounds.minX + topXOffset, y: bounds.minY + topYOffset),
            proposal: ProposedViewSize(width: availableWidth, height: topHeight)
        )
        
        // Place the bottom view centered within its section
        bottomSubview.place(
            at: CGPoint(x: bounds.minX + bottomXOffset, y: bounds.minY + topHeight + bottomYOffset),
            proposal: ProposedViewSize(width: availableWidth, height: bottomHeight)
        )
    }
}

#if DEBUG

// MARK: - Previews
#Preview("Presentation Layout") {
    PresentationLayout {
        Text("Top Section")
        
        Text("Bottom Section")
    }
}

#endif
