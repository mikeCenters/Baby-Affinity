//
//  ContentView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 7/17/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    
    // MARK: - Controls
    
    @AppStorage("selectedSex") private var selectedSex: Sex = .male
    
    
    // MARK: - View
    
    var body: some View {
        
        TabView {
            
            // MARK: - Home Feed
            
            HomeView()
                .modelContext(self.modelContext)
                .tabItem {
                    Label {
                        Text("Home")
                    } icon: {
                        Image(systemName: "house")
                    }
                }
            
            
            // MARK: - Pick Names
            
            Text("Pick Names View")
                .tabItem {
                    Label {
                        Text("Pick Names")
                    } icon: {
                        Image(systemName: "hand.point.up.left.and.text")
                    }
                }
            
            
            // MARK: - Settings
            
            Text("Settings")
            .tabItem {
                Label {
                    Text("Settings")
                } icon: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .tint(self.selectedSex == .male ? .blue : .pink)
    }
}

#Preview {
    ContentView()
        .modelContainer(previewModelContainer_WithFavorites)
}
