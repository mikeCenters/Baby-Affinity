//
//  PreviewModelContainer.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/28/24.
//

#if DEBUG

import SwiftData

// MARK: - Preview Model Container Helpers

/// Helper function to create a `ModelContainer` with a given schema and configuration.
private func createModelContainer(schema: Schema) -> ModelContainer {
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    
    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}

/// Helper function to insert names into a container's context.
@MainActor
private func insertPreviewData(context: ModelContext, names: DefaultBabyNames, withFavorites: Bool = false) {
    // Insert girl names.
    for name in names.girlNames {
        let n = try! Name(name, sex: .female)
        if withFavorites && n.text.contains("e") { n.toggleFavorite() }
        try! n.setAffinity((900...1500).randomElement() ?? 1200)
        context.insert(n)
    }
    
    // Insert boy names.
    for name in names.boyNames {
        let n = try! Name(name, sex: .male)
        if withFavorites && n.text.contains("e") { n.toggleFavorite() }
        try! n.setAffinity((900...1500).randomElement() ?? 1200)
        context.insert(n)
    }
}

// MARK: - Preview Model Containers

/// `Model Container` used for testing and previews; no favorites are selected.
let previewModelContainer: ModelContainer = {
    let schema = Schema([Name.self])
    let container = createModelContainer(schema: schema)
    
    /// Load preview data.
    Task { @MainActor in
        let context = container.mainContext
        let names = DefaultBabyNames()
        insertPreviewData(context: context, names: names)
    }
    
    return container
}()

/// `Model Container` used for testing and previews with random favorites.
let previewModelContainer_WithFavorites: ModelContainer = {
    let schema = Schema([Name.self])
    let container = createModelContainer(schema: schema)
    
    /// Load preview data with favorites.
    Task { @MainActor in
        let context = container.mainContext
        let names = DefaultBabyNames()
        insertPreviewData(context: context, names: names, withFavorites: true)
    }
    
    return container
}()

/// `Model Container` used for testing and previews with an empty store.
let previewModelContainer_EmptyStore: ModelContainer = {
    let schema = Schema([Name.self])
    return createModelContainer(schema: schema)
}()

#endif
