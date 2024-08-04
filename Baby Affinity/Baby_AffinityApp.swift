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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Name.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}


#if DEBUG

// MARK: -- Preview Model Container

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
            for (sex, name) in names.girlNames {
                let n = Name(name, sex: .female)
                context.insert(n)
            }
            
            /// Add boy names.
            for (sex, name) in names.boyNames {
                let n = Name(name, sex: .male)
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
            for (sex, name) in names.girlNames {
                let n = Name(name, sex: .female)
                if n.text.contains("e") { n.toggleFavorite() }
                context.insert(n)
            }
            
            /// Add boy names.
            for (sex, name) in names.boyNames {
                let n = Name(name, sex: .male)
                if n.text.contains("e") { n.toggleFavorite() }
                context.insert(n)
            }
        }
        
        return container
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()

#endif
