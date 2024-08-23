//
//  NamePersistenceController_Admin.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/15/24.
//

import Foundation
import SwiftData

// FIXME: Persistent Controller_Admin needs to throw errors, log them, and attempt to handle them. Then, build tests.
// FIXME: Update all methods to accept the ModelContainer.
// FIXME: Fix batch methods to operate independent of the single entry methods. Turn off autosave after context creation, then save before exiting. Maybe test Transaction methods. Transaction is likely correct way to perform batch operations. Autosave off will improve performance.


// MARK: - Error

/// Errors that can occur during name persistence operations.
enum NamePersistenceError: Error {
    case duplicateNameInserted(_ name: String)
    case noNamesInPersistence
    case unableToFetch(_ error: Error)
    case unexpectedError(_ error: Error)
}


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
    
    // MARK: - Methods
    
    /// Creates a new `Name` object with the given properties.
    ///
    /// - Parameters:
    ///   - name: The text of the name to create.
    ///   - sex: The sex associated with the name (male or female).
    ///   - affinityRating: The affinity rating for the name. Defaults to `Name.defaultAffinityRating`.
    /// - Returns: A `Result` containing either the created `Name` object or a `Name.NameError`.
    func createName(_ name: String, sex: Sex, affinityRating: Int) -> Result<Name, Name.NameError>
    
    /// Deletes a given `Name` from the persistent store.
    ///
    /// - Parameters:
    ///   - name: The `Name` object to delete.
    ///   - container: The `ModelContainer` managing the context.
    func delete(_ name: Name, container: ModelContainer)
    
    /// Deletes an array of `Name` objects from the persistent store.
    ///
    /// - Parameters:
    ///   - names: The array of `Name` objects to delete.
    ///   - container: The `ModelContainer` managing the context.
    func delete(_ names: [Name], container: ModelContainer)
    
    /// Inserts a new `Name` into the persistent store.
    ///
    /// - Parameters:
    ///   - name: The `Name` object to insert.
    ///   - container: The `ModelContainer` managing the context.
    /// - Returns: A `Result` indicating success or failure (`NamePersistenceError`).
    func insert(_ name: Name, container: ModelContainer) -> Result<Void, NamePersistenceError>
    
    /// Inserts an array of `Name` objects into the persistent store.
    ///
    /// - Parameters:
    ///   - names: The array of `Name` objects to insert.
    ///   - container: The `ModelContainer` managing the context.
    /// - Returns: An array of `Result` objects, each indicating the success or failure (`NamePersistenceError`) of an insertion.
    func insert(_ names: [Name], container: ModelContainer) -> [Result<Void, NamePersistenceError>]
    
    /// Retrieves default names, optionally filtered by sex.
    ///
    /// - Parameter sex: The sex to filter names by (`.male`, `.female`, or `nil` for all).
    /// - Returns: An array of `Name` objects.
    func getDefaultNames(_ sex: Sex?) -> [Name]
    
    /// Loads the default names into the persistent store.
    ///
    /// - Parameter container: The `ModelContainer` managing the context.
    func loadDefaultNames(into container: ModelContainer) async
    
    /// Resets all name data in the persistent store, reloading the default names.
    ///
    /// - Parameter container: The `ModelContainer` managing the context.
    func resetNameData(in container: ModelContainer) async
}


extension NamePersistenceController_Admin {
    
    // MARK: - Create
    
    func createName(_ name: String, sex: Sex, affinityRating: Int = Name.defaultAffinityRating) -> Result<Name, Name.NameError> {
        do {
            let name = try Name(name, sex: sex, affinityRating: affinityRating)
            return .success(name)
            
        } catch Name.NameError.nameIsEmpty {
            logError("Error: The name cannot be empty. Skipping: \(name)")
            return .failure(.nameIsEmpty)
            
        } catch Name.NameError.ratingBelowMinimum(let minimumRating) {
            logError("Error: The affinity rating is below the minimum (\(minimumRating)). Skipping: \(name)")
            return .failure(.ratingBelowMinimum(Name.minimumAffinityRating))
            
        } catch Name.NameError.invalidCharactersInName(let chars) {
            logError("Error: The provided name string contained non-alphabet characters or the allowed special characters (\(chars)). Skipping: \(name)")
            return .failure(.invalidCharactersInName(chars))
            
        } catch {
            logError("Unexpected error initializing Name: \(error.localizedDescription). Skipping: \(name)")
            return .failure(.unexpectedError(error))
        }
    }
    
    
    // MARK: - Delete
    
    func delete(_ name: Name, container: ModelContainer) {
        do {
            let context = ModelContext(container)
            context.delete(name)
            try context.save()
            
        } catch {
            logError("Unable to save the model context during the deletion of Name object: \(error.localizedDescription)")
        }
    }
    
    // FIXME: Test with the delete from protocol. Try Transaction. Try without saving.
    func delete(_ names: [Name], container: ModelContainer) {
        do {
            let context = ModelContext(container)
            context.autosaveEnabled = false
            
            for name in names {
                context.delete(name)
            }
            try context.save()
            
        } catch {
            logError("Unable to save the model context during the deletion of multiple Name objects: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Insert
    
    func insert(_ name: Name, container: ModelContainer) -> Result<Void, NamePersistenceError> {
        do {
            guard try fetchName(byText: name.text, sex: name.sex!) == nil
            else {
                logError("Attempted to insert a duplicate \(name.sex!.sexNamingConvention) name. Name: \(name.text)")
                return .failure(NamePersistenceError.duplicateNameInserted(name.text))
            }
            
            let context = ModelContext(container)
            
            context.insert(name)
            try context.save()
            
            return .success(())
            
        } catch NamePersistenceError.unableToFetch(let error) {
            logError("Unable to fetch names while attempting to insert name `\(name)`: \(error.localizedDescription)")
            return .failure(.unableToFetch(error))
            
        } catch {
            logError("Unexpected error occured while inserting a name `\(name)`: \(error.localizedDescription)")
            return .failure(.unexpectedError(error))
        }
    }
    
    func insert(_ names: [Name]) -> [Result<Void, NamePersistenceError>] {
        let context = modelContext
        context.autosaveEnabled = false
        var results: [Result<Void, NamePersistenceError>] = []
        
        // Filter out duplicate `Name` objects by `text` property within the provided array.
        let uniqueNames = Array(Set(names.map { $0.text })).compactMap { text in
            names.first { $0.text == text }
        }
        
        // Filter out duplicate `Name` objects within the provided array based on `text` and `sex` properties.
        var seenNames: Set<(String)> = []
        
        for name in names {
            let nameKey = "\(name.text)-\(name.sex!.rawValue)"  // Create a unique key using text and sex
            
            guard seenNames.insert(nameKey).inserted else {
                logError("Duplicate name found in the provided array. Name: \(name.text) with sex \(name.sex!.rawValue)")
                results.append(.failure(NamePersistenceError.duplicateNameInserted(name.text)))
                continue
            }
            
            do {
//                guard try fetchName(byText: name.text, sex: name.sex!, container: container) == nil
//                else {
//                    logError("Attempted to insert a duplicate \(name.sex!.sexNamingConvention) name. Name: \(name.text)")
//                    results.append(.failure(NamePersistenceError.duplicateNameInserted(name.text)))
//                    continue
//                }
                
                context.insert(name)
                results.append(.success(()))
                
            } catch {
                logError("Unable to fetch names while attempting to insert name. Name: \(name)")
                results.append(.failure(.unableToFetch(error)))
            }
        }
        
        try? context.save()  // Save the insertions.
        return results
    }
    
    func insert(_ names: [Name], container: ModelContainer) -> [Result<Void, NamePersistenceError>] {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        var results: [Result<Void, NamePersistenceError>] = []
        
        // Filter out duplicate `Name` objects by `text` property within the provided array.
        let uniqueNames = Array(Set(names.map { $0.text })).compactMap { text in
            names.first { $0.text == text }
        }
        
        // Filter out duplicate `Name` objects within the provided array based on `text` and `sex` properties.
        var seenNames: Set<(String)> = []
        
        for name in names {
            let nameKey = "\(name.text)-\(name.sex!.rawValue)"  // Create a unique key using text and sex
            
            guard seenNames.insert(nameKey).inserted else {
                logError("Duplicate name found in the provided array. Name: \(name.text) with sex \(name.sex!.rawValue)")
                results.append(.failure(NamePersistenceError.duplicateNameInserted(name.text)))
                continue
            }
            
            do {
                guard try fetchName(byText: name.text, sex: name.sex!) == nil
                else {
                    logError("Attempted to insert a duplicate \(name.sex!.sexNamingConvention) name. Name: \(name.text)")
                    results.append(.failure(NamePersistenceError.duplicateNameInserted(name.text)))
                    continue
                }
                
                context.insert(name)
                results.append(.success(()))
                
            } catch {
                logError("Unable to fetch names while attempting to insert name. Name: \(name)")
                results.append(.failure(.unableToFetch(error)))
            }
        }
        
        try? context.save()  // Save the insertions.
        return results
    }
}


// MARK: - Default Data

extension NamePersistenceController_Admin {
    
    func getDefaultNames(_ sex: Sex? = nil) -> [Name] {
        var names: [Name] = []
        let nameData = DefaultBabyNames()  // Default data is local.
        
        switch sex {
        case .female:
            for name in nameData.girlNames {
                switch createName(name, sex: .female) {
                case .success(let newName):
                    names.append(newName)
                    
                case .failure(let error):
                    switch error {
                    case .nameIsEmpty: continue
                    case .ratingBelowMinimum(_): continue
                    case .invalidCharactersInName(_): continue
                    case .unexpectedError(_): continue
                    }
                }
            }
        case .male:
            for name in nameData.boyNames {
                switch createName(name, sex: .male) {
                case .success(let newName):
                    names.append(newName)
                    
                case .failure(let error):
                    switch error {
                    case .nameIsEmpty: continue
                    case .ratingBelowMinimum(_): continue
                    case .invalidCharactersInName(_): continue
                    case .unexpectedError(_): continue
                    }
                }
            }
        default:
            names = getDefaultNames(.female) + getDefaultNames(.male)
        }
        
        return names
    }
    
    func loadDefaultNames(into container: ModelContainer) async {
        let nameData = DefaultBabyNames()
        
        for name in nameData.girlNames {
            switch createName(name, sex: .female) {
            case .success(let success):
                switch insert(success, container: container) {
                case .success: continue
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
            case .failure(let failure):
                print(failure.localizedDescription)
                continue
            }
        }
        
        for name in nameData.boyNames {
            switch createName(name, sex: .male) {
            case .success(let success):
                switch insert(success, container: container) {
                case .success: continue
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
            case .failure(let failure):
                print(failure.localizedDescription)
                continue
            }
        }
    }
    
    
    // MARK: - Methods
    
    func resetNameData(in container: ModelContainer) async {
        do {
            let names = try fetchNames()
            for name in names {
                name.resetValues()
            }
            
            await loadDefaultNames(into: container)
            
        } catch {
            logError("Unable to fetch names while attempting to reset name data. Error: \(error)")
        }
    }
}
