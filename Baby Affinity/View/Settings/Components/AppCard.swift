//
//  AppCard.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/16/24.
//

import SwiftUI

/// A view that displays an informational card for the Baby Affinity app.
struct AppCard: View {
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 8) {
            Image("icon")
                .resizable()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 60 / 5.8, style: .continuous))
            
            Text("Baby Affinity")
                .font(.title3).bold()
            
            Text("Discover the perfect name for your baby, the app that generates a unique list of names just for you.")
                .font(.callout)
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}


#if DEBUG

// MARK: - Previews

#Preview("App Card view in List") {
    List {
        AppCard()
    }
}

#endif
