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
    
    @State private var selectedSex: Sex = .male
    
    var body: some View {
        
        //FIXME: Work on navigation bar and toolbars.
        
        NavigationStack {
            
            
            // MARK: - Home Feed
            List {
                TopNamesView(show: selectedSex)
                    .modelContext(modelContext)
                
                // FIXME: Create Favorites List
                Section("Favorites") {
                    ForEach(0..<5) { i in
                        Text("Name \(i+1)")
                    }
                }
                
                // FIXME: Create Shared List
                Section("Shared List") {
                    ForEach(0..<5) { i in
                        Text("Name \(i+1)")
                    }
                }
            }
            .navigationTitle("Baby Names")
            
        }
        
    }
}

#Preview {
    ContentView()
        .modelContainer(previewModelContainer)
}
