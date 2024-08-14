//
//  ContentView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 7/17/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    // MARK: - Properties
    
    @Environment(\.modelContext) private var modelContext
    
    
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
                        Image(systemName: "house")
                    }
                }
            
            
            // MARK: - Pick Names
            
            NamePickerView(sex: selectedSex)
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
        .modelContext(modelContext)
        .tint(selectedSex == .male ? .blue : .pink)
    }
}


#if DEBUG

// MARK: - Preview
#Preview {
    ContentView()
        .modelContainer(previewModelContainer_WithFavorites)
}

#endif
