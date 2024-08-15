//
//  NamePersistenceController_Admin.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/15/24.
//

import Foundation
import SwiftData

// FIXME: Persistent Controller_Admin needs to throw errors, log them, and attempt to handle them. Then, build tests.

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
     it inserts the `Name`.

     - Parameters:
       - name: The `Name` object to be inserted.
       - context: The `ModelContext` where the `Name` should be inserted.

     - Throws:
       - `NamePersistenceError.duplicateNameCreated` if a `Name` with the same text and sex already exists.
     */
    func insert(_ name: Name, context: ModelContext) throws
    
    /**
     Inserts multiple `Name` objects into the given context if it does not already exist.

     This method checks if a `Name` with the same text and sex already exists in the context.
     If it does, it throws a `NamePersistenceError.duplicateNameInserted` error. If not,
     it inserts the `Name`.

     - Parameters:
       - name: The `Name` object to be inserted.
       - context: The `ModelContext` where the `Name` should be inserted.

     - Throws:
       - `NamePersistenceError.duplicateNameCreated` if a `Name` with the same text and sex already exists.
     */
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
        try context.transaction {
            let defaultNames = getDefaultNames()
            try insert(defaultNames, context: context)
        }
    }
}
