//
//  IsPersistentStoreEmpty.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/27/24.
//

import SwiftUI
import SwiftData

/// A property wrapper that checks if a persistent store for a specific model type is empty.
///
/// This property wrapper is designed to be used with SwiftUI views to dynamically determine
/// whether a persistent store (e.g., CoreData or any other SwiftData-supported storage)
/// contains any instances of a specific `PersistentModel`. If the store is empty, the wrapper
/// returns `true`; otherwise, it returns `false`.
///
/// The property wrapper uses `@Query` to fetch a limited number of items (just one item) to
/// check for the presence of data efficiently, minimizing memory usage and fetch times.
@propertyWrapper
struct IsPersistentStoreEmpty<T: PersistentModel>: DynamicProperty {
    
    // Inject the model context from the environment to allow the query to function correctly.
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    /// Creates a `FetchDescriptor` configured to fetch only one item from the persistent store.
    ///
    /// This function is used to create a fetch descriptor that limits the number of fetched
    /// items to one, which is sufficient to determine if the store contains any items.
    ///
    /// - Returns: A `FetchDescriptor` configured to fetch a single item of type `T`.
    static private func descriptor() -> FetchDescriptor<T> {
        var descriptor = FetchDescriptor<T>()
        descriptor.fetchLimit = 1
        return descriptor
    }
    
    /// The fetched items from the persistent store.
    ///
    /// This array will either contain one item or be empty, depending on the state of the
    /// persistent store. It is populated using the `@Query` property wrapper with the
    /// fetch descriptor.
    @Query(descriptor()) private var items: [T]
    
    /// A Boolean value that indicates whether the persistent store is empty.
    ///
    /// This computed property returns `true` if the `items` array is empty, indicating that
    /// there are no items of type `T` in the persistent store. Otherwise, it returns `false`.
    var isEmpty: Bool {
        items.isEmpty
    }
    
    /// The wrapped value of the property wrapper, providing direct access to `isEmpty`.
    ///
    /// This allows the property wrapper to be used directly in SwiftUI views as a Boolean
    /// that indicates whether the persistent store is empty.
    var wrappedValue: Bool {
        isEmpty
    }
}
