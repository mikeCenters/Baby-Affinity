//
//  SettingsView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/12/24.
//

import SwiftUI

// MARK: - Settings View

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

import Store

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
    .environmentObject(Store.main)
    .loadProducts(in: Store.main)
}

#Preview("Settings View") {
    SettingsView()
        .modelContainer(previewModelContainer)
        .environmentObject(Store.premium)
        .loadProducts(in: Store.premium)
}

#endif
