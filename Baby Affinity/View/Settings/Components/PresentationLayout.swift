//
//  PresentationLayout.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/5/24.
//

import SwiftUI


struct PresentationLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let width = proposal.width ?? 0
        let height = proposal.height ?? 0
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        guard (1...2).contains(subviews.count) else { return }
        
        let availableWidth = bounds.width
        
        // Calculate the height for each section (1/3 for top, 2/3 for bottom)
        let topHeight = bounds.height * 1 / 3
        let bottomHeight = bounds.height * 2 / 3
        
        // Helper function to place a subview at a centered position
        func placeSubview(_ subview: LayoutSubview, in sectionHeight: CGFloat, yOffset: CGFloat) {
            let subviewSize = subview.sizeThatFits(ProposedViewSize(width: availableWidth, height: sectionHeight))
            let xOffset = (availableWidth - subviewSize.width) / 2
            let yPosition = bounds.minY + yOffset + (sectionHeight - subviewSize.height) / 2
            
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
#Preview("Presentation Layout") {
    PresentationLayout {
        Text("Top Section")
        
        Text("Bottom Section")
    }
}

#endif
