//
//  NamePersistenceController.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/13/24.
//

import Foundation
import SwiftData

// FIXME: Persistent Controller needs to throw errors, log them, and attempt to handle them. Then, build tests.

enum NamePersistenceError: Error {
    case duplicateNameInserted(_ name: String)
    case noNamesInPersistence
}


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
    func fetchNames(context: ModelContext) throws -> [Name]
    
    /// Fetches `Name` objects filtered by sex.
    /// - Parameters:
    ///   - sex: The sex to filter the `Name` objects by.
    ///   - context: The model context used for fetching data.
    /// - Returns: An array of `Name` objects with the specified sex.
    /// - Throws: An error if the fetch operation fails.
    func fetchNames(_ sex: Sex, context: ModelContext) throws -> [Name]
    
    /// Fetches `Name` objects based on the evaluation count.
    /// - Parameters:
    ///   - evaluatedCount: The number of times the `Name` objects have been evaluated.
    ///   - context: The model context used for fetching data.
    /// - Returns: An array of `Name` objects with the specified evaluation count.
    /// - Throws: An error if the fetch operation fails.
    func fetchNames(evaluatedCount: Int, context: ModelContext) throws -> [Name]
    
    /// Fetches a `Name` object by its text property.
    /// - Parameters:
    ///   - text: The `String` representation of the name to be fetched.
    ///   - context: The model context used for fetching data.
    ///   - sex: The `Sex` of the `Name` object.
    /// - Returns: The `Name` object with the specified identifier, or `nil` if not found.
    /// - Throws: An error if the fetch operation fails.
    func fetchName(byText text: String, sex: Sex, context: ModelContext) throws -> Name?
    
    /// Fetches `Name` objects that are marked as favorites.
    /// - Parameter context: The model context used for fetching data.
    /// - Returns: An array of `Name` objects marked as favorites.
    /// - Throws: An error if the fetch operation fails.
    func fetchFavoriteNames(context: ModelContext) throws -> [Name]
    
    /// Gets the rank of a `Name` object based on its affinity rating.
    /// - Parameters:
    ///   - name: The `Name` object to get the rank of.
    ///   - context: The model context used for fetching data.
    /// - Returns: The rank of the `Name` object, or `nil` if not found.
    /// - Throws: An error if the fetch operation fails.
    func getRank(of name: Name, from context: ModelContext) throws -> Int?
}

extension NamePersistenceController {
    
    // MARK: - Fetch
    
    func fetchNames(context: ModelContext) throws -> [Name] {
        let descriptor = FetchDescriptor<Name>()
        return try context.fetch(descriptor)
    }
    
    func fetchNames(_ sex: Sex, context: ModelContext) throws -> [Name] {
        let descriptor = FetchDescriptor<Name>(predicate: #Predicate { $0.sexRawValue == sex.rawValue })
        return try context.fetch(descriptor)
    }
    
    func fetchNames(evaluatedCount: Int, context: ModelContext) throws -> [Name] {
        let descriptor = FetchDescriptor<Name>(predicate: #Predicate { $0.evaluated == evaluatedCount })
        return try context.fetch(descriptor)
    }
    
    func fetchName(byText text: String, sex: Sex, context: ModelContext) throws -> Name? {
        let descriptor = FetchDescriptor<Name>(
            predicate: #Predicate {
                $0.text == text &&
                $0.sexRawValue == sex.rawValue
            })
        let namesFetch = try context.fetch(descriptor)
        
        /// Check for multiple names being found.
        if namesFetch.count > 1 {
            logError("Multiple \(sex.sexNamingConvention.lowercased()) names of `\(text.capitalized)` were fetched!")
        }
        return namesFetch.first
    }
    
    func fetchFavoriteNames(context: ModelContext) throws -> [Name] {
        let descriptor = FetchDescriptor<Name>(predicate: #Predicate { $0.isFavorite })
        return try context.fetch(descriptor)
    }
    
    // MARK: - Methods
    
    func getRank(of name: Name, from context: ModelContext) throws -> Int? {
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
