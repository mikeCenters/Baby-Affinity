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
    
    @Environment(\.modelContext) var modelContext
    
    
    // MARK: - Controls
    
    @AppStorage("selectedSex") private var selectedSex: Sex = .male
    
    @IsPersistentStoreEmpty<Name> private var isShowingOnboarding: Bool
    
    
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
        .overlay {
            if isShowingOnboarding {
                OnboardingView()
            }
        }
        .modelContext(modelContext)                     // FIXME: TEst removing
        .tint(selectedSex == .male ? .blue : .pink)
        .onChange(of: namePersistenceIsEmpty) { oldValue, newValue in
            if newValue && !isShowingOnboarding {
                isShowingOnboarding = true
            }
        }
    }
}

// MARK: - Persistence Management

extension ContentView: NamePersistenceController_Admin {
    
    private func loadData() async {
        do {
            // Check if there are existing names in the context
            if try fetchNames().isEmpty {
                // If no names are found, load default names into the context
                await loadDefaultNames()
            }
        } catch {
            // Handle any errors that occur during data loading
            logError("Unable to load default data on app launch: \(error)")
        }
    }
}

#if DEBUG

// MARK: - Preview
#Preview {
    ContentView()
        .modelContainer(previewModelContainer_WithFavorites)
}

#endif
