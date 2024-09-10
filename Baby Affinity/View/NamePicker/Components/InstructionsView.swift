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
    
    var instructionsText: String {
        "Choose up to \(maxSelections) names from the list that are to your liking. While there may be other names that you would want to name your baby, pick among these that you like the most. \n\nIf you don't like the available names, simply select new names."
    }
    
    
    // MARK: - Controls and Constants
    
    let maxSelections: Int
    @Binding var showInstructions: Bool
    
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            Image(systemName: "checklist")
                .resizable()
                .scaledToFit()
                .frame(height: 90)
                .padding(.top, 40)
                .padding([.horizontal, .bottom])
                .foregroundStyle(.yellow)
            
            Text("Pick \(maxSelections) Names")
                .font(.largeTitle)
                .bold()
                .padding()
                .foregroundStyle(.tint)
            
            Text(instructionsText)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                showInstructions = false
            } label: {
                Text("Find Names!")
                    .font(.headline)
            }
            .buttonStyle(BorderedButtonStyle())
            .padding(.top, 40)

            Spacer()
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
