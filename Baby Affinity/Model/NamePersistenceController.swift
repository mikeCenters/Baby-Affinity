//
//  NamePersistenceController.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/13/24.
//

import Foundation
import SwiftData

enum NamePersistenceError: Error {
    case duplicateNameInserted(_ name: String)
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

// MARK: - Admin

/// A protocol for administrative operations on name data in the Baby Affinity app.
///
/// The `NamePersistenceController_Admin` protocol extends the `NamePersistenceController` protocol by adding methods
/// for creating, deleting, and inserting `Name` objects, as well as retrieving default names. These methods are
/// intended for use in administrative tasks, such as initializing the app's database with default names or
/// removing names from the database.
///
/// Implementers of this protocol are responsible for ensuring that these administrative operations are performed
/// correctly and efficiently, handling any errors that may occur during the process.
protocol NamePersistenceController_Admin: NamePersistenceController {
    
    /// Creates a `Name` object.
    /// - Parameters:
    ///   - name: The `String` representation of the name to be created. This must not be empty.
    ///   - sex: The `Sex` associated with the name, which determines its gender classification.
    ///   - affinityRating: The initial affinity rating for the name. This must be a non-negative integer.
    /// - Returns: A `Name` object if the creation is successful, or `nil` if an error occurs during initialization.
    func createName(_ name: String, sex: Sex, affinityRating: Int) -> Name?
    
    /// Deletes a `Name` object.
    /// - Parameters:
    ///   - name: The `Name` object to be deleted.
    ///   - context: The model context used for deleting data.
    /// - Throws: An error if the delete operation fails.
    func delete(_ name: Name, context: ModelContext) throws
    
    /// Deletes multiple `Name` objects.
    /// - Parameters:
    ///   - names: An array of `Name` objects to be deleted.
    ///   - context: The model context used for deleting data.
    /// - Throws: An error if the delete operation fails.
    func delete(_ names: [Name], context: ModelContext) throws
    
    /// Inserts a `Name` object.
    /// - Parameters:
    ///   - name: The `Name` object to be inserted.
    ///   - context: The model context used for inserting data.
    /// - Throws: An error if the insert operation fails.
    
    /**
     Inserts a `Name` into the given context if it does not already exist.

     This method checks if a `Name` with the same text and sex already exists in the context.
     If it does, it throws a `NamePersistenceError.duplicateNameInserted` error. If not,
     it inserts the `Name` and saves the context.

     - Parameters:
       - name: The `Name` object to be inserted.
       - context: The `ModelContext` where the `Name` should be inserted.

     - Throws:
       - `NamePersistenceError.duplicateNameCreated` if a `Name` with the same text and sex already exists.
       - Any error that occurs during the save operation.

     - Example:
     */
    func insert(_ name: Name, context: ModelContext) throws
    
    /// Inserts multiple `Name` objects.
    /// - Parameters:
    ///   - names: An array of `Name` objects to be inserted.
    ///   - context: The model context used for inserting data.
    /// - Throws: An error if the insert operation fails.
    func insert(_ names: [Name], context: ModelContext) throws
    
    /// Retrieves a list of default `Name` objects, optionally filtered by sex.
    /// - Parameter sex: An optional `Sex` value to filter the names by. If `nil`, both male and female names are returned.
    /// - Returns: An array of `Name` objects. If `sex` is provided, only names of that sex are returned. If `sex` is `nil`, names of both sexes are returned.
    func getDefaultNames(_ sex: Sex?) -> [Name]
    
    /// Loads default `Name` objects into the data context.
    /// - Parameter context: The model context used for inserting data.
    /// - Throws: An error if the insert operation fails.
    func loadDefaultNames(into context: ModelContext) throws
}


extension NamePersistenceController_Admin {
    
    // MARK: - Create
    
    func createName(_ name: String, sex: Sex, affinityRating: Int = Name.defaultAffinityRating) -> Name? {
        do {
            return try Name(name, sex: sex, affinityRating: affinityRating)
        } catch Name.NameError.nameIsEmpty {
            logError("Error: The name cannot be empty. Skipping: \(name)")
        } catch Name.NameError.ratingBelowMinimum(let minimum) {
            logError("Error: The affinity rating is below the minimum (\(minimum)). Skipping: \(name)")
        } catch {
            logError("Unexpected error initializing Name: \(error.localizedDescription). Skipping: \(name)")
        }
        return nil
    }
    
    
    // MARK: - Delete
    
    func delete(_ name: Name, context: ModelContext) throws {
        context.delete(name)
        try context.save()
    }
    
    func delete(_ names: [Name], context: ModelContext) throws {
        for name in names {
            try delete(name, context: context)
        }
    }
    
    
    // MARK: - Insert
    
    func insert(_ name: Name, context: ModelContext) throws {
        guard try fetchName(byText: name.text, sex: name.sex!, context: context) == nil
        else {
            throw NamePersistenceError.duplicateNameInserted(name.text)
        }
        context.insert(name)
        try context.save()
    }
    
    func insert(_ names: [Name], context: ModelContext) throws {
        for name in names {
            try insert(name, context: context)
        }
    }
}


// MARK: - Default Data

extension NamePersistenceController_Admin {
    
    func getDefaultNames(_ sex: Sex? = nil) -> [Name] {
        var names: [Name] = []
        
        switch sex {
        case .female:   // Female Names
            for (_, name) in DefaultBabyNames().girlNames {
                if let newName = createName(name, sex: .female) {
                    names.append(newName)
                }
            }
        case .male:     // Male Names
            for (_, name) in DefaultBabyNames().boyNames {
                if let newName = createName(name, sex: .male) {
                    names.append(newName)
                }
            }
        default:        // All Names
            for (_, name) in DefaultBabyNames().girlNames {
                if let newName = createName(name, sex: .female) {
                    names.append(newName)
                }
            }
            for (_, name) in DefaultBabyNames().boyNames {
                if let newName = createName(name, sex: .male) {
                    names.append(newName)
                }
            }
        }
        return names
    }
    
    func loadDefaultNames(into context: ModelContext) throws {
        let defaultNames = getDefaultNames()
        try insert(defaultNames, context: context)
    }
}
