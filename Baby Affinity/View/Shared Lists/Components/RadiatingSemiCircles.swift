//
//  RadiatingSemiCircles.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/8/24.
//

import SwiftUI

// MARK: - SemiCircleShape

/// A shape that represents a semi-circle.
struct SemiCircleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.minY),
                    radius: rect.width / 2,
                    startAngle: .degrees(0),
                    endAngle: .degrees(180),
                    clockwise: false)
        return path
    }
}


// MARK: - Radiating Semi Circles

/// A view that displays a series of radiating semi-circles with animation effects.
struct RadiatingSemiCircles: View {
    
    // MARK: - Controls and Constants
    
    /// The diameter of each semi-circle.
    private let diameter: CGFloat = 200
    
    /// The current scale factor for the semi-circles' animation.
    @State private var animationAmount: CGFloat = 0.4
    
    /// The current opacity of the semi-circles during the animation.
    @State private var fadeAmount: Double = 1.0
    
    /// The line width of the semi-circle strokes.
    @State private var lineWidth: CGFloat = 8
    
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Create multiple semi-circles with animation
            ForEach(0..<5, id: \.self) { index in
                SemiCircleShape()
                    .stroke(.blue, lineWidth: lineWidth)
                    .frame(width: diameter, height: diameter / 2)
                    .scaleEffect(animationAmount)
                    .opacity(fadeAmount)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.5),
                        value: animationAmount // Animation value to watch
                    )
            }
        }
        
        
        // MARK: - On Appear
        
        .onAppear {
            // Start the animation with specific properties
            withAnimation {
                animationAmount = 1.5       // Controls the scale size
                fadeAmount = 0.0            // Fades away
                lineWidth *= 1.8            // Increase line size
            }
        }
    }
}


#if DEBUG

// MARK: - Previews

/// Preview for the RadiatingSemiCircles view.
#Preview("Radiating Semi Circles") {
    RadiatingSemiCircles()
}

#endif
