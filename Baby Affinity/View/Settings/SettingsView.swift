//
//  SettingsView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/12/24.
//

import SwiftUI

// FIXME: Need to fix data manager first.

extension SettingsView {
    enum Destinations: Int, CaseIterable {
        case about, contact, products
        
        var label: String {
            switch self {
            case .about:
                "About"
            case .contact:
                "Contact Us"
            case .products:
                "Products"
            }
        }
        
        var section: Int {
            switch self {
            case .about:
                1
            case .contact:
                1
            case .products:
                1
            }
        }
        
        var destination: some View {
            Text("Some View")
        }
    }
}


struct SettingsView: View, NamePersistenceController_Admin {
    @Environment(\.modelContext) var modelContext
    
    @State private var isShowingDataConfirmation: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 60/3.14)
                            .frame(width: 60, height: 60)
                        
                        Text("Baby Affinity")
                            .font(.title3).bold()
                        
                        Text("Discover the perfect name for your baby, the app that generates a unique list of names just for you.")
                            .font(.callout)
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                }
                
                
                // Section 1
                Section {
                    ForEach(SettingsView.Destinations.allCases, id: \.self) { item in
                        if item.section == 1 {
                            NavigationLink(destination: item.destination) {
                                Text("Item \(item.label)")
                            }
                        }
                    }
                }
                
                
                // Reset Data
                Section {
                    Button {
                        withAnimation {
                            isShowingDataConfirmation.toggle()
                        }
                        
                    } label: {
                        Text("Reset Data")
                    }
                    .foregroundColor(.red)
                    .confirmationDialog("Reset data",
                                        isPresented: $isShowingDataConfirmation) {
                        Button("Yes", role: .destructive) { 
                            resetNameData(in: modelContext)
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("You are about to reset all data. Are you sure?")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
