//
//  ContentView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 7/17/24.
//

import SwiftUI
import SwiftData

// MARK: - Content View

struct ContentView: View {
    
    // MARK: - Controls
    
    @AppStorage("selectedSex") private var selectedSex: Sex = .male
    
    
    // MARK: - View
    
    var body: some View {
        TabView {
            
            // MARK: - Home Feed
            
            HomeView()
                .tabItem {
                    Label {
                        Text("Home")
                    } icon: {
                        Image(systemName: "list.bullet.below.rectangle")
                    }
                }
            
            
            // MARK: - Pick Names
            
            NamePickerView()
                .tabItem {
                    Label {
                        Text("Pick Names")
                    } icon: {
                        Image(systemName: "hand.point.up.left.and.text")
                    }
                }
            
            
            // MARK: - Settings
            
            SettingsView()
                .tabItem {
                    Label {
                        Text("Settings")
                    } icon: {
                        Image(systemName: "gearshape")
                    }
                }
        }
        .tint(selectedSex == .male ? .blue : .pink)
    }
}


#if DEBUG

// MARK: - Preview

import Store

#Preview("Content View") {
    ContentView()
        .modelContainer(previewModelContainer_WithFavorites)
        .environmentObject(Store.main)
}

#Preview("Content View - Is Premium") {
    ContentView()
        .modelContainer(previewModelContainer_WithFavorites)
        .environmentObject(Store.premium)
        .loadPremiumFeatures()
}

#endif
