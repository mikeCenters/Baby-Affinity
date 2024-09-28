//
//  InstructionsView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/10/24.
//

import SwiftUI

// MARK: - Instructions View

/// A view presenting the instructions sheet.
struct InstructionsView: View {
    
    // MARK: - Properties
    
    private var instructionsText: String {
        """
        Choose up to \(maxSelections) names from the list that are to your liking.
        
        While there may be other names that you would want to name your baby, pick among these that you like the most. If you don't like the available names, simply select new names.
        """
    }
    
    
    // MARK: - Controls and Constants
    
    /// The number of selections about to be made within the list of names.
    let maxSelections: Int
    
    /// A binding that shows the instructions for name picking.
    @Binding var showInstructions: Bool
    
    
    // MARK: - Body
    
    var body: some View {
        PresentationLayout {
            VStack(spacing: 16) {
                Spacer()
                
                Image(systemName: "checklist")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80)
                    .foregroundStyle(.yellow)
                
                Text("Pick \(maxSelections) Names")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.tint)
            }
            .padding(.horizontal)
            
            VStack {
                Text(instructionsText)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Button {
                    showInstructions = false
                    
                } label: {
                    Text("Find Names!")
                        .font(.headline)
                }
                .buttonStyle(BorderedButtonStyle())
                
                Spacer()
            }
            .padding([.top, .horizontal], 16)
        }
    }
}


#if DEBUG

// MARK: - Previews

#Preview("Instructions View in a Sheet") {
    Text("Root View")
        .sheet(isPresented: .constant(true)) {
            InstructionsView(maxSelections: 5, showInstructions: .constant(true))
        }
}

#endif
