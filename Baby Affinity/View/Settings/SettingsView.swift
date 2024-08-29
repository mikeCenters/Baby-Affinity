//
//  SettingsView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/12/24.
//

import SwiftUI



struct SettingsLoadingIndicator: View {
    var body: some View {
        VStack {
            ProgressView("Resetting Data...")
                .progressViewStyle(CircularProgressViewStyle())
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.6))
        .cornerRadius(10)
    }
}



struct SettingsView: View, NamePersistenceController_Admin {
    
    // MARK: - Properties
    
    @Environment(\.modelContext) var modelContext
    
    
    // MARK: - Controls
    
    @State private var isLoading: Bool = false
    
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            SettingsNavigationStack(isLoading: $isLoading)
                .disabled(isLoading)
                .blur(radius: isLoading ? 3 : 0)
            
            if isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                SettingsLoadingIndicator()
            }
        }
    }
}


#if DEBUG

// MARK: - Previews

#Preview("Settings View in Tab View") {
    TabView {
        SettingsView()
            .tabItem {
                Label {
                    Text("Settings")
                } icon: {
                    Image(systemName: "gearshape")
                }
            }
    }
    .modelContainer(previewModelContainer)
}

#Preview("Settings View") {
    SettingsView()
        .modelContainer(previewModelContainer)
}

#endif
