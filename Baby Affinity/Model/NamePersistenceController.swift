//
//  NamePersistenceController.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/13/24.
//

import Foundation
import SwiftData

/// A protocol for managing name data in the Baby Affinity app.
///
/// The `NamePersistenceController` protocol defines a set of methods for performing CRUD (Create, Read, Update, Delete)
/// operations on `Name` objects, as well as additional methods for specific data queries.
/// These methods support various functionalities within the app, including fetching names by different criteria,
/// adding new names, deleting existing names, updating name details, and retrieving the rank of a name based on
/// its affinity rating.
///
/// Implementers of this protocol are expected to handle the interaction with the underlying data storage
/// mechanisms, ensuring that the data operations are executed asynchronously and can throw errors if any
/// operation fails.
protocol NamePersistenceController {
    
    /// Fetches all `Name` objects.
    /// - Parameter context: The model context used for fetching data.
    /// - Returns: An array of `Name` objects.
    /// - Throws: An error if the fetch operation fails.
    func fetchNames(context: ModelContext) async throws -> [Name]
    
    /// Fetches `Name` objects filtered by sex.
    /// - Parameters:
    ///   - sex: The sex to filter the `Name` objects by.
    ///   - context: The model context used for fetching data.
    /// - Returns: An array of `Name` objects with the specified sex.
    /// - Throws: An error if the fetch operation fails.
    func fetchNames(_ sex: Sex, context: ModelContext) async throws -> [Name]
    
    /// Fetches a `Name` object by its unique identifier.
    /// - Parameters:
    ///   - id: The unique identifier of the `Name` object.
    ///   - context: The model context used for fetching data.
    /// - Returns: The `Name` object with the specified identifier, or `nil` if not found.
    /// - Throws: An error if the fetch operation fails.
    func fetchName(byID id: PersistentIdentifier, context: ModelContext) async throws -> Name?
    
    /// Fetches `Name` objects based on the evaluation count.
    /// - Parameters:
    ///   - evaluatedCount: The number of times the `Name` objects have been evaluated.
    ///   - context: The model context used for fetching data.
    /// - Returns: An array of `Name` objects with the specified evaluation count.
    /// - Throws: An error if the fetch operation fails.
    func fetchNames(evaluatedCount: Int, context: ModelContext) async throws -> [Name]
    
    /// Fetches `Name` objects that are marked as favorites.
    /// - Parameter context: The model context used for fetching data.
    /// - Returns: An array of `Name` objects marked as favorites.
    /// - Throws: An error if the fetch operation fails.
    func fetchFavoriteNames(context: ModelContext) async throws -> [Name]
    
    /// Adds a new `Name` object.
    /// - Parameters:
    ///   - name: The `Name` object to be added.
    ///   - context: The model context used for adding data.
    /// - Throws: An error if the add operation fails.
    func addName(_ name: Name, context: ModelContext) async throws
    
    /// Deletes a `Name` object.
    /// - Parameters:
    ///   - name: The `Name` object to be deleted.
    ///   - context: The model context used for deleting data.
    /// - Throws: An error if the delete operation fails.
    func deleteName(_ name: Name, context: ModelContext) async throws
    
    /// Deletes multiple `Name` objects.
    /// - Parameters:
    ///   - names: An array of `Name` objects to be deleted.
    ///   - context: The model context used for deleting data.
    /// - Throws: An error if the delete operation fails.
    func deleteNames(_ names: [Name], context: ModelContext) async throws
    
    /// Updates an existing `Name` object.
    /// - Parameters:
    ///   - name: The `Name` object to be updated.
    ///   - context: The model context used for updating data.
    /// - Throws: An error if the update operation fails.
    func updateName(_ name: Name, context: ModelContext) async throws
    
    /// Gets the rank of a `Name` object based on its affinity rating.
    /// - Parameters:
    ///   - name: The `Name` object to get the rank of.
    ///   - context: The model context used for fetching data.
    /// - Returns: The rank of the `Name` object, or `nil` if not found.
    /// - Throws: An error if the fetch operation fails.
    func getRank(of name: Name, from context: ModelContext) async throws -> Int?
}

extension NamePersistenceController {
    func fetchNames(context: ModelContext) async throws -> [Name] {
        let descriptor = FetchDescriptor<Name>()
        return try context.fetch(descriptor)
    }

    func fetchNames(_ sex: Sex, context: ModelContext) async throws -> [Name] {
        let descriptor = FetchDescriptor<Name>(predicate: #Predicate { $0.sex == sex })
        return try context.fetch(descriptor)
    }
    
    func fetchName(byID id: PersistentIdentifier, context: ModelContext) async throws -> Name? {
        let descriptor = FetchDescriptor<Name>(predicate: #Predicate { $0.id == id })
        return try context.fetch(descriptor).first
    }
    
    func fetchNames(evaluatedCount: Int, context: ModelContext) async throws -> [Name] {
        let descriptor = FetchDescriptor<Name>(predicate: #Predicate { $0.evaluated == evaluatedCount })
        return try context.fetch(descriptor)
    }
    
    func fetchFavoriteNames(context: ModelContext) async throws -> [Name] {
        let descriptor = FetchDescriptor<Name>(predicate: #Predicate { $0.isFavorite })
        return try context.fetch(descriptor)
    }
    
    func addName(_ name: Name, context: ModelContext) async throws {
        context.insert(name)
        try context.save()
    }
    
    func deleteName(_ name: Name, context: ModelContext) async throws {
        context.delete(name)
        try context.save()
    }
    
    func deleteNames(_ names: [Name], context: ModelContext) async throws {
        names.forEach { context.delete($0) }
        try context.save()
    }
    
    func updateName(_ name: Name, context: ModelContext) async throws {
        try context.save()
    }
    
    func getRank(of name: Name, from context: ModelContext) async throws -> Int? {
        let sex = name.sexRawValue
        let descriptor = FetchDescriptor<Name>(
            predicate: #Predicate { $0.sexRawValue == sex },
            sortBy: [
                .init(\.affinityRating, order: .reverse)
            ]
        )
        
        let names = try context.fetch(descriptor)
        
        return names.firstIndex(of: name).map { $0 + 1 }
    }
}
