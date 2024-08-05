//
//  HomeView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/5/24.
//

import SwiftUI

// FIXME: - Update query to load names into memory instead of pulling from SwiftData every time. Pull from SwiftData only once and monitor for changes. Else, use a new variable.

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    
    
    // MARK: - Controls and Constants
    
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    @State private var showSexSelection = false
    
    private let headerTitle = "Baby Affinity"
    
    
    // MARK: - View
    
    var body: some View {
        
        NavigationStack {
            
            List {
                TopNamesView(show: self.selectedSex)
                    .modelContext(self.modelContext)
                
                FavoriteNamesView(show: self.selectedSex)
                    .modelContext(self.modelContext)
                
                // FIXME: Create Shared List
                Section("Shared List") {
                    ForEach(0..<5) { i in
                        Text("Name \(i+1)")
                    }
                }
                
                // FIXME: Add precurated top names as a banner to add names to your favorites. These could be pulled from the global list as rising names or top 10 global names.
            }
            .navigationTitle(self.headerTitle)
            .toolbar {
                Button {
                    withAnimation {
                        self.showSexSelection.toggle()
                    }
                } label: {
                    Image(systemName: "switch.2")
                }
                .confirmationDialog("Show which names?", isPresented: self.$showSexSelection) {
                    
                    ForEach(Sex.allCases, id: \.self) { sex in
                        Button {
                            withAnimation {
                                self.selectedSex = sex
                            }
                            
                        } label: {
                            Text(sex.alternateName)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
