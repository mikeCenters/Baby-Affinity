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
    
    /// Fetches all `Name` objects from the persistence layer.
    ///
    /// This method retrieves all the `Name` objects stored in the persistence layer using the provided `ModelContainer`.
    ///
    /// - Parameter container: The `ModelContainer` used to perform the fetch operation.
    /// - Returns: An array of `Name` objects containing all the names stored in the persistence layer.
    /// - Throws: A `NamePersistenceError.unableToFetch` error if the fetch operation fails. The underlying error is logged.
    ///
    /// Example usage:
    /// ```swift
    /// do {
    ///     let allNames = try fetchNames(container: container)
    ///     // Use the allNames array
    /// } catch {
    ///     // Handle the error
    /// }
    /// ```
    func fetchNames(container: ModelContainer) throws -> [Name]
    
    /// Fetches `Name` objects filtered by a specified sex.
    ///
    /// This method retrieves `Name` objects that match a specific sex from the persistence layer.
    ///
    /// - Parameters:
    ///   - sex: The sex to filter the `Name` objects by.
    ///   - container: The `ModelContainer` used to perform the fetch operation.
    /// - Returns: An array of `Name` objects that match the specified sex.
    /// - Throws: A `NamePersistenceError.unableToFetch` error if the fetch operation fails. The underlying error is logged.
    ///
    /// Example usage:
    /// ```swift
    /// do {
    ///     let femaleNames = try fetchNames(.female, container: container)
    ///     // Use the femaleNames array
    /// } catch {
    ///     // Handle the error
    /// }
    /// ```
    func fetchNames(_ sex: Sex, container: ModelContainer) throws -> [Name]
    
    /// Fetches `Name` objects based on the evaluation count.
    ///
    /// This method retrieves `Name` objects that have been evaluated a certain number of times and match a specific sex.
    ///
    /// - Parameters:
    ///   - evaluatedCount: The number of times the `Name` objects have been evaluated.
    ///   - sex: The sex to filter the `Name` objects by.
    ///   - container: The `ModelContainer` used to perform the fetch operation.
    /// - Returns: An array of `Name` objects that match the specified evaluation count and sex.
    /// - Throws: A `NamePersistenceError.unableToFetch` error if the fetch operation fails. The underlying error is logged.
    ///
    /// Example usage:
    /// ```swift
    /// do {
    ///     let evaluatedNames = try fetchNames(evaluatedCount: 5, sex: .male, container: container)
    ///     // Use the evaluatedNames array
    /// } catch {
    ///     // Handle the error
    /// }
    /// ```
    func fetchNames(evaluatedCount: Int, sex: Sex, container: ModelContainer) throws -> [Name]
    
    /// Fetches a `Name` object by its text property.
    ///
    /// This method retrieves a specific `Name` object based on its text and sex properties.
    ///
    /// - Parameters:
    ///   - text: The `String` representation of the name to be fetched.
    ///   - sex: The `Sex` of the `Name` object.
    ///   - container: The `ModelContainer` used to perform the fetch operation.
    /// - Returns: The `Name` object with the specified text and sex, or `nil` if not found.
    /// - Throws: A `NamePersistenceError.unableToFetch` error if the fetch operation fails. The underlying error is logged.
    ///
    /// Example usage:
    /// ```swift
    /// do {
    ///     if let specificName = try fetchName(byText: "John", sex: .male, container: container) {
    ///         // Use the specificName object
    ///     }
    /// } catch {
    ///     // Handle the error
    /// }
    /// ```
    func fetchName(byText text: String, sex: Sex, container: ModelContainer) throws -> Name?
    
    /// Fetches `Name` objects by a partial match on the text property.
    ///
    /// This method retrieves `Name` objects whose text property contains the provided partial text and match a specific sex.
    ///
    /// - Parameters:
    ///   - partialText: The `String` that represents the partial text to match against the names.
    ///   - sex: The sex to filter the `Name` objects by.
    ///   - container: The `ModelContainer` used to perform the fetch operation.
    /// - Returns: An array of `Name` objects whose text property contains the provided partial text.
    /// - Throws: A `NamePersistenceError.unableToFetch` error if the fetch operation fails. The underlying error is logged.
    ///
    /// Example usage:
    /// ```swift
    /// do {
    ///     let partialNames = try fetchNames(byPartialText: "Ann", sex: .female, container: container)
    ///     // Use the partialNames array
    /// } catch {
    ///     // Handle the error
    /// }
    /// ```
    func fetchNames(byPartialText partialText: String, sex: Sex, container: ModelContainer) throws -> [Name]
    
    /// Fetches `Name` objects that are marked as favorites, filtered by sex.
    ///
    /// This method retrieves `Name` objects marked as favorites, filtered by the specified sex.
    ///
    /// - Parameters:
    ///   - sex: The sex to filter the `Name` objects by.
    ///   - container: The `ModelContainer` used to perform the fetch operation.
    /// - Returns: An array of `Name` objects marked as favorites.
    /// - Throws: A `NamePersistenceError.unableToFetch` error if the fetch operation fails. The underlying error is logged.
    ///
    /// Example usage:
    /// ```swift
    /// do {
    ///     let favoriteNames = try fetchFavoriteNames(sex: .male, container: container)
    ///     // Use the favoriteNames array
    /// } catch {
    ///     // Handle the error
    /// }
    /// ```
    func fetchFavoriteNames(sex: Sex, container: ModelContainer) throws -> [Name]
    
    /// Fetches and returns a list of names of a specified sex, sorted by their affinity rating in descending order.
    ///
    /// This function utilizes a `ModelContext` to fetch names from the provided `ModelContainer`.
    /// It applies a predicate to filter names based on the specified sex and sorts the results
    /// by their `affinity` property in descending order.
    ///
    /// - Parameters:
    ///   - sex: The sex of the names to fetch.
    ///   - container: The `ModelContainer` used to perform the fetch operation.
    /// - Returns: An array of `Name` objects matching the specified sex, sorted by their affinity in descending order.
    /// - Throws: A `NamePersistenceError.unableToFetch` error if the fetch operation fails. The underlying error is logged.
    ///
    /// Example usage:
    /// ```swift
    /// do {
    ///     let topAffinityNames = try fetchNamesSortedByAffinity(sex: .female, container: container)
    ///     // Use the topAffinityNames array
    /// } catch {
    ///     // Handle the error
    /// }
    /// ```
    func fetchNamesSortedByAffinity(_ sex: Sex, container: ModelContainer) throws -> [Name]
    
    /// Retrieves the rank of a given `Name` object based on its position in a ranked list of names of the same sex.
    ///
    /// This method fetches a list of `Name` objects sorted by their affinity rating in descending order from the persistence layer, filtered by the same sex as the provided `Name`.
    /// It then determines the position of the given `Name` within that list, returning the rank as an integer.
    /// The rank is 1-based, meaning the top-ranked name will return `1`.
    ///
    /// - Parameters:
    ///   - name: The `Name` object for which the rank is being retrieved. The `Name` must have a valid `sex` property.
    ///   - container: The `ModelContainer` used to perform the fetch operation.
    /// - Returns: The rank of the `Name` object within the ranked list of names of the same sex, or `nil` if the name is not found in the list.
    /// - Throws: A `NamePersistenceError.unableToFetch` error if the fetch operation fails. The underlying error is logged.
    ///
    /// Example usage:
    /// ```swift
    /// do {
    ///     if let rank = try getRank(of: someName, from: container) {
    ///         print("The rank of the name \(someName.text) is \(rank).")
    ///     } else {
    ///         print("The name \(someName.text) was not found in the ranked list.")
    ///     }
    /// } catch {
    ///     // Handle the error
    ///     print("Failed to retrieve the rank of the name: \(error)")
    /// }
    /// ```
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
    
    func fetchNamesSortedByAffinity(_ sex: Sex, container: ModelContainer) throws -> [Name] {
        let context = ModelContext(container)
        let sortDescriptors = [SortDescriptor<Name>(\Name.affinityRating, order: .reverse)]
        let descriptor = FetchDescriptor<Name>(
            predicate: #Predicate {
                $0.sexRawValue == sex.rawValue
            },
            sortBy: sortDescriptors)
        
        do {
            return try context.fetch(descriptor)
            
        } catch {
            logError("Failed to fetch all \(sex.sexNamingConvention) names: \(error.localizedDescription)")
            throw NamePersistenceError.unableToFetch(error)
        }
    }
}


// MARK: - Methods

extension NamePersistenceController {
    
    func getRank(of name: Name, from container: ModelContainer) throws -> Int? {
        do {
            let names = try fetchNamesSortedByAffinity(name.sex!, container: container)
            return names.firstIndex(of: name).map { $0 + 1 }
            
        } catch {
            logError("Failed to get rank for \(name.sex!.sexNamingConvention) name '\(name.text)' due to a failed fetch request: \(error.localizedDescription)")
            throw NamePersistenceError.unableToFetch(error)
        }
    }
}
