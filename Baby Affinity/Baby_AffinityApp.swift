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
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    withAnimation {
                        loadData()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}


// MARK: - Persistence Management
import SwiftUI

/// The main application class for Baby Affinity, which conforms to `NamePersistenceController_Admin`
/// to manage the persistence of name data.
@MainActor
extension Baby_AffinityApp: NamePersistenceController_Admin {

    /// Loads initial data into the application. This method checks if there are existing names in the context.
    /// If no names are found, it loads default names into the context. This method is invoked during
    /// the initial app launch to ensure that the app starts with the necessary data.
    ///
    /// The method runs asynchronously in a `Task` to handle potential asynchronous operations such as
    /// fetching and loading data. It is marked with `@MainActor` to ensure that all operations are executed
    /// on the main thread, which is important for thread safety with UI and context-related operations.
    ///
    /// **Note:** This implementation currently ignores potential data-racing issues related to using `ModelContext`
    /// in asynchronous contexts. It is advisable to review and address these issues in future Xcode releases,
    /// particularly Xcode 16 and beyond, for improved concurrency safety.
    private func loadData() {
        Task {
            do {
                // Access the main context from the shared model container
                let context = sharedModelContainer.mainContext
                
                // Check if there are existing names in the context
                if try fetchNames(context: context).isEmpty {
                    // If no names are found, load default names into the context
                    await loadDefaultNames(into: context)
                }
            } catch {
                // Handle any errors that occur during data loading
                fatalError("Unable to load default data on initial app launch: \(error)")
            }
        }
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
