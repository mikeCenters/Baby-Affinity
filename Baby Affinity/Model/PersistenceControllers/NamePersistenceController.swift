//
//  NamePersistenceController.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/13/24.
//

import Foundation
import SwiftData

// MARK: - Error

enum NamePersistenceError: Error {
    case duplicateNameInserted(_ name: String)
    case noNamesInPersistence
}


// MARK: - Name Persistence Controller

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
    
    // MARK: - Methods
    
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
    ///   - sex: The `Sex` of the `Name` object.
    ///   - context: The model context used for fetching data.
    /// - Returns: The `Name` object with the specified text and sex, or `nil` if not found.
    /// - Throws: An error if the fetch operation fails.
    func fetchName(byText text: String, sex: Sex, context: ModelContext) throws -> Name?
    
    /// Fetches `Name` objects by a partial match on the text property.
    /// - Parameters:
    ///   - partialText: The `String` that represents the partial text to match against the names. This method performs a search for names that contain this partial text.
    ///   - context: The `ModelContext` used for fetching data from the persistence layer.
    /// - Returns: An array of `Name` objects whose text property contains the provided partial text. The results may include names with varying degrees of match to the partial text.
    /// - Throws: An error if the fetch operation fails due to issues with the data context or other reasons.
    func fetchNames(byPartialText partialText: String, context: ModelContext) throws -> [Name]
    
    /// Fetches `Name` objects that are marked as favorites filtered by sex.
    /// - Parameters:
    ///   - sex: The sex to filter the `Name` objects by.
    ///   - context: The model context used for fetching data.
    /// - Returns: An array of `Name` objects marked as favorites.
    /// - Throws: An error if the fetch operation fails.
    func fetchFavoriteNames(sex: Sex, context: ModelContext) throws -> [Name]
    
    /// Gets the rank of a `Name` object based on its affinity rating.
    /// - Parameters:
    ///   - name: The `Name` object to get the rank of.
    ///   - context: The model context used for fetching data.
    /// - Returns: The rank of the `Name` object, or `nil` if not found.
    /// - Throws: An error if the fetch operation fails.
    func getRank(of name: Name, from context: ModelContext) throws -> Int?
}


extension NamePersistenceController {
    
    // MARK: - Defined Methods
    
    func fetchNames(context: ModelContext) throws -> [Name] {
        let descriptor = FetchDescriptor<Name>()
        do {
            return try context.fetch(descriptor)
        } catch {
            logError("Failed to fetch names: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchNames(_ sex: Sex, context: ModelContext) throws -> [Name] {
        let descriptor = FetchDescriptor<Name>(predicate: #Predicate { $0.sexRawValue == sex.rawValue })
        do {
            return try context.fetch(descriptor)
        } catch {
            logError("Failed to fetch names for sex \(sex.rawValue): \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchNames(evaluatedCount: Int, context: ModelContext) throws -> [Name] {
        let descriptor = FetchDescriptor<Name>(predicate: #Predicate { $0.evaluated == evaluatedCount })
        do {
            return try context.fetch(descriptor)
        } catch {
            logError("Failed to fetch names with evaluated count \(evaluatedCount): \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchName(byText text: String, sex: Sex, context: ModelContext) throws -> Name? {
        let descriptor = FetchDescriptor<Name>(
            predicate: #Predicate {
                $0.text == text &&
                $0.sexRawValue == sex.rawValue
            })
        do {
            let namesFetch = try context.fetch(descriptor)
            
            // Check for multiple names being found.
            if namesFetch.count > 1 {
                logError("Multiple \(sex.sexNamingConvention.lowercased()) names of `\(text.capitalized)` were fetched!")
            }
            return namesFetch.first
        } catch {
            logError("Failed to fetch name by text '\(text)' and sex \(sex.rawValue): \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchNames(byPartialText partialText: String, context: ModelContext) throws -> [Name] {
        let descriptor = FetchDescriptor<Name>(
            predicate: #Predicate {
                $0.text.contains(partialText)
            }
        )
        do {
            return try context.fetch(descriptor)
        } catch {
            logError("Failed to fetch names by partial text '\(partialText)': \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchFavoriteNames(sex: Sex, context: ModelContext) throws -> [Name] {
        let descriptor = FetchDescriptor<Name>(
            predicate: #Predicate {
                $0.isFavorite &&
                $0.sexRawValue == sex.rawValue
            })
        do {
            return try context.fetch(descriptor)
        } catch {
            logError("Failed to fetch favorite names for sex \(sex.rawValue): \(error.localizedDescription)")
            throw error
        }
    }
    
    func getRank(of name: Name, from context: ModelContext) throws -> Int? {
        let sex = name.sexRawValue
        let descriptor = FetchDescriptor<Name>(
            predicate: #Predicate { $0.sexRawValue == sex },
            sortBy: [
                .init(\.affinityRating, order: .reverse)
            ]
        )
        do {
            let names = try context.fetch(descriptor)
            return names.firstIndex(of: name).map { $0 + 1 }
        } catch {
            logError("Failed to get rank for name '\(name.text)' of sex \(sex): \(error.localizedDescription)")
            throw error
        }
    }
}
