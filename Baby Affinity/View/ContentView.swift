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
        List {
            
            TopNamesView(show: selectedSex)
                .modelContext(modelContext)
            
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(previewModelContainer)
}
