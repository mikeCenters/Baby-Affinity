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
    
    @State private var selectedSex: Sex = .male
    @State private var showSexSelection = false
    
    // MARK: - View
    
    var body: some View {
        
        TabView {
            
            // MARK: - Home Feed
            
            NavigationStack {
                
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
                .navigationTitle("Baby Affinity")
                .toolbar {
                    Button {
                        withAnimation {
                            self.showSexSelection.toggle()
                        }
                    } label: {
                        Image(systemName: "switch.2")
                    }
                    .tint(self.selectedSex == .male ? .blue : .pink)
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
        .modelContainer(previewModelContainer)
}
