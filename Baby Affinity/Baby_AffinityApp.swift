//
//  Baby_AffinityApp.swift
//  Baby Affinity
//
//  Created by Mike Centers on 7/17/24.
//

import SwiftUI
import SwiftData

@main
struct Baby_AffinityApp: App {
    
    // MARK: - Properties
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Name.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject private var store = Store.shared
    
    @AppStorage("isShowingOnboarding") var isShowingOnboarding: Bool = true
    
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            if isShowingOnboarding {
                OnboardingView(isShown: $isShowingOnboarding)
                
            } else {
                ContentView()
            }
        }
        .environmentObject(store)
        .modelContainer(sharedModelContainer)
    }
}


#if DEBUG

// MARK: - Preview Model Container

/// `Model Container` used for testing and previews.
let previewModelContainer: ModelContainer = {
    let schema = Schema([
        Name.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    
    do {
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        
        /// Load preview data.
        Task { @MainActor in
            let context = container.mainContext
            
            let names = DefaultBabyNames()
            
            /// Add girl names.
            for name in names.girlNames {
                let n = try! Name(name, sex: .female)
                try! n.setAffinity((900...1500).randomElement() ?? 1200)
                context.insert(n)
            }
            
            /// Add boy names.
            for name in names.boyNames {
                let n = try! Name(name, sex: .male)
                try! n.setAffinity((900...1500).randomElement() ?? 1200)
                context.insert(n)
            }
        }
        
        return container
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()


/// `Model Container` used for testing and previews. Will have random favorites within the data.
let previewModelContainer_WithFavorites: ModelContainer = {
    let schema = Schema([
        Name.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    
    do {
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        
        /// Load preview data.
        Task { @MainActor in
            let context = container.mainContext
            
            let names = DefaultBabyNames()
            
            /// Add girl names.
            for name in names.girlNames {
                let n = try! Name(name, sex: .female)
                if n.text.contains("e") { n.toggleFavorite() }
                try! n.setAffinity((900...1500).randomElement() ?? 1200)
                context.insert(n)
            }
            
            /// Add boy names.
            for name in names.boyNames {
                let n = try! Name(name, sex: .male)
                if n.text.contains("e") { n.toggleFavorite() }
                try! n.setAffinity((900...1500).randomElement() ?? 1200)
                context.insert(n)
            }
        }
        
        return container
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()

/// `Model Container` used for testing and previews. Will have an empty persistent store.
let previewModelContainer_EmptyStore: ModelContainer = {
    let schema = Schema([
        Name.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    
    do {
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        
        return container
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()

#endif
