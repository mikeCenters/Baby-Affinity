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
    @Query private var names: [Name]
    
    
    var body: some View {
        List {
            
            
            
            HStack {
                
                Text("1")
                    .font(.title)
                
                Text("Michael")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            
            
            
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
