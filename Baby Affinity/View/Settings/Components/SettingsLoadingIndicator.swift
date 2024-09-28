//
//  SettingsLoadingIndicator.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/29/24.
//

import SwiftUI

// MARK: - Settings Loading Indicator

/// A loading indicator for when data is resetting.
struct SettingsLoadingIndicator: View {
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            ProgressView("Resetting Data...")
                .progressViewStyle(CircularProgressViewStyle())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.6))
    }
}


#if DEBUG

// MARK: - Preview

#Preview("Settings View Loading Indicator") {
    SettingsLoadingIndicator()
        .tint(.blue)
}

#endif
