//
//  EmailRequiredView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/16/24.
//

import SwiftUI

// MARK: - Email Required View

/// A view that informs the user that email setup is required for in-app support.
struct EmailRequiredView: View {
    
    // MARK: - Properties
    
    /// A binding to the presentation mode environment value, used to dismiss the view.
    @Environment(\.presentationMode) private var presentationMode
    
    
    // MARK: - Body
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer().frame(height: 100)
                
                Image(systemName: "envelope.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128)
                    .foregroundColor(.yellow)
                
                Text("Email Required")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.tint)
                
                Text("To offer in-app support, you will need to be able to send emails from your device.\n\nSetup the iOS mail app to get started.")
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        
                    } label: {
                        Text("Return")
                            .bold()
                    }
                }
            }
        }
    }
}


#if DEBUG

// MARK: - Previews

/// Previews the EmailRequiredView presented in a sheet.
#Preview("Presented in a Sheet") {
    struct Preview: View {
        @State var isShown = true
        
        var body: some View {
            Button {
                isShown.toggle()
            } label: {
                Text("Show Email Required View")
            }
            .sheet(isPresented: $isShown) {
                EmailRequiredView()
            }
        }
    }
    
    return Preview()
}

/// Previews the EmailRequiredView.
#Preview("Email Required View") {
    EmailRequiredView()
}

#endif
