//
//  NamePersistenceController.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/15/24.
//

import Foundation
import SwiftData

// MARK: - Name Persistence Controller

/// A protocol for managing name data within the persistence store.
/// This protocol provides methods for fetching `Name` objects from a persistence layer, allowing for various filters such as sex, evaluated count, or favorite status. It also includes a method to determine the rank of a `Name` object based on its affinity rating.
protocol NamePersistenceController {

    // MARK: - Methods
    
    /// Fetches all `Name` objects.
    ///
    /// This method retrieves all the `Name` objects stored in the persistence layer.
    ///
    /// - Parameter container: The model container used for fetching data.
    /// - Returns: An array of `Name` objects.
    /// - Throws: An error if the fetch operation fails.
    func fetchNames(container: ModelContainer) throws -> [Name]
    
    /// Fetches `Name` objects filtered by sex.
    ///
    /// This method retrieves `Name` objects that match a specific sex.
    ///
    /// - Parameters:
    ///   - sex: The sex to filter the `Name` objects by.
    ///   - container: The model container used for fetching data.
    /// - Returns: An array of `Name` objects with the specified sex.
    /// - Throws: An error if the fetch operation fails.
    func fetchNames(_ sex: Sex, container: ModelContainer) throws -> [Name]
    
    /// Fetches `Name` objects based on the evaluation count.
    ///
    /// This method retrieves `Name` objects that have been evaluated a certain number of times.
    ///
    /// - Parameters:
    ///   - evaluatedCount: The number of times the `Name` objects have been evaluated.
    ///   - sex: The sex to filter the `Name` objects by.
    ///   - container: The model container used for fetching data.
    /// - Returns: An array of `Name` objects with the specified evaluation count.
    /// - Throws: An error if the fetch operation fails.
    func fetchNames(evaluatedCount: Int, sex: Sex, container: ModelContainer) throws -> [Name]
    
    /// Fetches a `Name` object by its text property.
    ///
    /// This method retrieves a specific `Name` object based on its text and sex properties.
    ///
    /// - Parameters:
    ///   - text: The `String` representation of the name to be fetched.
    ///   - sex: The `Sex` of the `Name` object.
    ///   - container: The model container used for fetching data.
    /// - Returns: The `Name` object with the specified text and sex, or `nil` if not found.
    /// - Throws: An error if the fetch operation fails.
    func fetchName(byText text: String, sex: Sex, container: ModelContainer) throws -> Name?
    
    /// Fetches `Name` objects by a partial match on the text property.
    ///
    /// This method retrieves `Name` objects whose text property contains the provided partial text.
    ///
    /// - Parameters:
    ///   - partialText: The `String` that represents the partial text to match against the names.
    ///   - container: The `ModelContainer` used for fetching data.
    /// - Returns: An array of `Name` objects whose text property contains the provided partial text.
    /// - Throws: An error if the fetch operation fails.
    func fetchNames(byPartialText partialText: String, sex: Sex, container: ModelContainer) throws -> [Name]
    
    /// Fetches `Name` objects that are marked as favorites filtered by sex.
    ///
    /// This method retrieves `Name` objects marked as favorites, filtered by the specified sex.
    ///
    /// - Parameters:
    ///   - sex: The sex to filter the `Name` objects by.
    ///   - container: The model container used for fetching data.
    /// - Returns: An array of `Name` objects marked as favorites.
    /// - Throws: An error if the fetch operation fails.
    func fetchFavoriteNames(sex: Sex, container: ModelContainer) throws -> [Name]
    
    /// Gets the rank of a `Name` object based on its affinity rating.
    ///
    /// This method calculates the rank of a specific `Name` object among all `Name` objects of the same sex, sorted by affinity rating in descending order.
    ///
    /// - Parameters:
    ///   - name: The `Name` object to get the rank of.
    ///   - container: The model container used for fetching data.
    /// - Returns: The rank of the `Name` object, or `nil` if not found.
    /// - Throws: An error if the fetch operation fails.
    func getRank(of name: Name, from container: ModelContainer) throws -> Int?
}


// MARK: - Fetch

extension NamePersistenceController {
    
    func fetchNames(container: ModelContainer) throws -> [Name] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Name>()
        
        do {
            return try context.fetch(descriptor)
            
        } catch {
            logError("Failed to fetch all names of both sexes: \(error.localizedDescription)")
            throw NamePersistenceError.unableToFetch(error)
        }
    }
    
    func fetchNames(_ sex: Sex, container: ModelContainer) throws -> [Name] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Name>(
            predicate: #Predicate { $0.sexRawValue == sex.rawValue })
        
        do {
            return try context.fetch(descriptor)
            
        } catch {
            logError("Failed to fetch all \(sex.sexNamingConvention) names: \(error.localizedDescription)")
            throw NamePersistenceError.unableToFetch(error)
        }
    }
    
    func fetchNames(evaluatedCount: Int, sex: Sex, container: ModelContainer) throws -> [Name] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Name>(
            predicate: #Predicate {
                $0.sexRawValue == sex.rawValue &&
                $0.evaluated == evaluatedCount
            })
        
        do {
            return try context.fetch(descriptor)
            
        } catch {
            logError("Failed to fetch \(sex.sexNamingConvention) names with evaluated count \(evaluatedCount): \(error.localizedDescription)")
            throw NamePersistenceError.unableToFetch(error)
        }
    }
    
    func fetchName(byText text: String, sex: Sex, container: ModelContainer) throws -> Name? {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Name>(
            predicate: #Predicate {
                $0.sexRawValue == sex.rawValue &&
                $0.text == text
            })
        
        do {
            let namesFetch = try context.fetch(descriptor)
            
            if namesFetch.count > 1 {
                logError("Multiple \(sex.sexNamingConvention.lowercased()) names of `\(text.capitalized)` were fetched!")
            }
            
            return namesFetch.first
            
        } catch {
            logError("Failed to fetch \(sex.sexNamingConvention) name by text '\(text)': \(error.localizedDescription)")
            throw NamePersistenceError.unableToFetch(error)
        }
    }
    
    func fetchNames(byPartialText partialText: String, sex: Sex, container: ModelContainer) throws -> [Name] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Name>(
            predicate: #Predicate {
                $0.sexRawValue == sex.rawValue &&
                $0.text.contains(partialText)
            })
        
        do {
            return try context.fetch(descriptor)
            
        } catch {
            logError("Failed to fetch \(sex.sexNamingConvention) names by partial text '\(partialText)': \(error.localizedDescription)")
            throw NamePersistenceError.unableToFetch(error)
        }
    }
    
    func fetchFavoriteNames(sex: Sex, container: ModelContainer) throws -> [Name] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Name>(
            predicate: #Predicate {
                $0.sexRawValue == sex.rawValue &&
                $0.isFavorite
            })
        
        do {
            return try context.fetch(descriptor)
            
        } catch {
            logError("Failed to fetch favorite \(sex.sexNamingConvention) names: \(error.localizedDescription)")
            throw NamePersistenceError.unableToFetch(error)
        }
    }
}


// MARK: - Methods

extension NamePersistenceController {
    
    func getRank(of name: Name, from container: ModelContainer) throws -> Int? {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Name>(
            predicate: #Predicate { $0.sexRawValue == name.sexRawValue },
            sortBy: [
                .init(\.affinityRating, order: .reverse)
            ])
        
        do {
            let names = try context.fetch(descriptor)
            return names.firstIndex(of: name).map { $0 + 1 }
            
        } catch {
            logError("Failed to get rank for \(name.sex!.sexNamingConvention) name '\(name.text)' due to a failed fetch request: \(error.localizedDescription)")
            throw NamePersistenceError.unableToFetch(error)
        }
    }
}
