//
//  NamePersistenceController_Admin.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/15/24.
//

import Foundation
import SwiftData

// FIXME: Persistent Controller_Admin needs to throw errors, log them, and attempt to handle them. Then, build tests.

// MARK: - Error

enum NamePersistenceError: Error {
    case duplicateNameInserted(_ name: String)
    case noNamesInPersistence
    case unableToFetch(_ error: Error)
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
    
    func createName(_ name: String, sex: Sex, affinityRating: Int) -> Result<Name, Name.NameError>
    
    func delete(_ name: Name, context: ModelContext)
    
    func delete(_ names: [Name], context: ModelContext)
    
    func insert(_ name: Name, context: ModelContext) -> Result<Void, NamePersistenceError>
    
    func insert(_ names: [Name], context: ModelContext) -> [Result<Void, NamePersistenceError>]
    
    func getDefaultNames(_ sex: Sex?) -> [Name]
    
    func loadDefaultNames(into context: ModelContext) async
    
    func resetNameData(in context: ModelContext) async
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
            return .failure(.nameIsEmpty)
        }
    }
    
    
    // MARK: - Delete
    
    func delete(_ name: Name, context: ModelContext) {
        context.delete(name)
    }
    
    func delete(_ names: [Name], context: ModelContext) {
        for name in names {
            delete(name, context: context)
        }
    }
    
    
    // MARK: - Insert
    
    func insert(_ name: Name, context: ModelContext) -> Result<Void, NamePersistenceError> {
        do {
            guard try fetchName(byText: name.text, sex: name.sex!, context: context) == nil
            else {
                logError("Attempted to insert a duplicate \(name.sex!.sexNamingConvention) name. Name: \(name.text)")
                return .failure(NamePersistenceError.duplicateNameInserted(name.text))
            }
            
            context.insert(name)
            return .success(())
            
        } catch {
            logError("Unable to fetch names while attempting to insert name. Name: \(name)")
            return .failure(.unableToFetch(error))
        }
    }
    
    func insert(_ names: [Name], context: ModelContext) -> [Result<Void, NamePersistenceError>] {
        var results: [Result<Void, NamePersistenceError>] = []
        for name in names {
            switch insert(name, context: context) {
            case .success(): 
                results.append(.success(()))
            case .failure(let error): 
                results.append(.failure(error))
            }
        }
        return results
    }
}


// MARK: - Default Data

extension NamePersistenceController_Admin {
    
    func getDefaultNames(_ sex: Sex? = nil) -> [Name] {
        var names: [Name] = []
        let nameData = DefaultBabyNames()                   /// Default data is local.
        
        switch sex {
        case .female:                                       // Female Names
            for name in nameData.girlNames {
                switch createName(name, sex: .female) {
                case .success(let newName):                 /// Should always succeed with local data.
                    names.append(newName)
                    
                case .failure(let error):                   /// The default names data should not fail; local data.
                    switch error {                          /// Switch is used to handle future implementations.
                    case .nameIsEmpty: break                /// The error is logged.
                    case .ratingBelowMinimum(_): break      /// The error is logged.
                    case .invalidCharactersInName: break    /// The error is logged.
                    }
                }
            }
        case .male:                                         // Male Names
            for name in nameData.girlNames {
                switch createName(name, sex: .male) {
                case .success(let newName):                 /// Should always succeed with local data.
                    names.append(newName)
                    
                case .failure(let error):                   /// The default names data should not fail; local data.
                    switch error {                          /// Switch is used to handle future implementations.
                    case .nameIsEmpty: break                /// The error is logged.
                    case .ratingBelowMinimum(_): break      /// The error is logged.
                    case .invalidCharactersInName(_): break /// The error is logged.
                    }
                }
            }
        default:                                            // All Names
            names = getDefaultNames(.female) + getDefaultNames(.male)
        }
        
        return names
    }
    
    func loadDefaultNames(into context: ModelContext) async {
//        let names = getDefaultNames()
//        try? context.transaction {
//            let results = insert(names, context: context)
//            for result in results {
//                switch result {
//                case .success: break
//                case .failure(let error):   /// Placeholder for if needed. Errors are handled deeper in the method.
//                    switch error {
//                    case .duplicateNameInserted(_): break
//                    case .noNamesInPersistence: break
//                    case .unableToFetch(_): break
//                    }
//                }
//            }
//        }
        
        
        
        let nameData = DefaultBabyNames()
        
        // Add girl names.
        for name in nameData.girlNames {
            switch createName(name, sex: .female) {
            case .success(let success):
                switch insert(success, context: context) {
                case .success: continue
                case .failure(let error): 
                    print(error.localizedDescription)
                }
                
            case .failure(let failure):
                print(failure.localizedDescription)
                continue
            }
        }
        
        // Add boy names.
        for name in nameData.boyNames {
            switch createName(name, sex: .male) {
            case .success(let success):
                switch insert(success, context: context) {
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
    
    func resetNameData(in context: ModelContext) async {
        do {
            let names = try fetchNames(context: context)    /// Get all names to reset.
            for name in names {
                name.resetValues()                          /// Reset the name data.
            }
            
            await loadDefaultNames(into: context)           /// Recover lost names.
            
        } catch {
            logError("Unable to fetch names while attempting to reset name data. Error: \(error)")
        }
    }
}
