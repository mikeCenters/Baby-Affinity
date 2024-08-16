//
//  LoadingIndicator.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/7/24.
//

import SwiftUI

/// A view that displays a loading indicator with animated circles.
/// The color of the circles is determined by the selected sex stored in `AppStorage`.
struct LoadingIndicator: View {
    
    // MARK: - Properties
    
    /// The selected sex for which the names are filtered, stored in `AppStorage`.
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    /// A binding to a boolean value that determines whether the loading animation should be displayed.
    @Binding var isLoading: Bool
    
    
    // MARK: - Body
    
    var body: some View {
        HStack() {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(selectedSex == .male ? .blue : .pink)
                    .scaleEffect(isLoading ? 0.9 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(0.2 * Double(index)),
                        value: isLoading
                    )
            }
        }
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .center)
        .onAppear {
            isLoading.toggle()
        }
    }
}

#if DEBUG

// MARK: - Preview

/// A preview provider for `LoadingIndicator`.
#Preview {
    struct Preview: View {
        @State private var isLoading = false
        
        var body: some View {
            LoadingIndicator(isLoading: $isLoading)
        }
    }
    
    return Preview()
}

#endif
