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
    
    var body: some View {
        List {
            
            
            TopNamesView()
                .modelContext(modelContext)
            
            
            
//            ForEach(names) { name in
//                Text(name.text)
//            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(previewModelContainer)
}
