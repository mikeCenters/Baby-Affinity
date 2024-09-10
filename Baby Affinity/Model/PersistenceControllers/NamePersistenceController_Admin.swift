//
//  NamePersistenceController_Admin.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/15/24.
//

import Foundation
import SwiftData


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
    func delete(_ name: Name) async
    
    /// Deletes an array of `Name` objects from the persistent store.
    ///
    /// - Parameters:
    ///   - names: The array of `Name` objects to delete.
    ///   - container: The `ModelContainer` managing the context.
    func delete(_ names: [Name]) async
    
    /// Inserts a new `Name` into the persistent store.
    ///
    /// - Parameters:
    ///   - name: The `Name` object to insert.
    ///   - container: The `ModelContainer` managing the context.
    /// - Returns: A `Result` indicating success or failure (`NamePersistenceError`).
    func insert(_ name: Name) async -> Result<Void, NamePersistenceError>
    
    /// Inserts an array of `Name` objects into the persistent store.
    ///
    /// - Parameters:
    ///   - names: The array of `Name` objects to insert.
    ///   - container: The `ModelContainer` managing the context.
    /// - Returns: An array of `Result` objects, each indicating the success or failure (`NamePersistenceError`) of an insertion.
    func insert(_ names: [Name]) async -> [Result<Void, NamePersistenceError>]
    
    /// Retrieves default names, optionally filtered by sex.
    ///
    /// - Parameter sex: The sex to filter names by (`.male`, `.female`, or `nil` for all).
    /// - Returns: An array of `Name` objects.
    func getDefaultNames(_ sex: Sex?) async -> [Name]
    
    /// Loads the default names into the persistent store.
    ///
    /// - Parameter container: The `ModelContainer` managing the context.
    func loadDefaultNames() async
    
    /// Resets all name data in the persistent store, reloading the default names.
    ///
    /// - Parameter container: The `ModelContainer` managing the context.
    func resetNameData()
    
    /// Updates the affinity ratings for a list of winning and losing names.
    ///
    /// - Parameters:
    ///   - winners: An array of `Name` objects that won the comparison.
    ///   - losers: An array of `Name` objects that lost the comparison.
    func updateAffinity(winners: [Name], losers: [Name])
    
    /// Applies a penalty to the affinity ratings of the provided names by subtracting a value derived from the `kFactor`.
    /// The new rating for each name is calculated by subtracting the `kFactor` from the current affinity rating.
    /// If the resulting rating is below the minimum allowed (`Name.minimumAffinityRating`), it is set to the minimum rating.
    /// After updating the rating, the evaluation count for each name is incremented.
    ///
    /// - Parameter names: An array of `Name` objects to which the penalty will be applied.
    /// - Throws: Throws an error if the `setAffinity` method fails when updating the name's affinity rating.
    /// - Note: The `increaseEvaluationCount` method is called for each name, regardless of whether the affinity was updated or not.
    func applyPenalty(to names: [Name])
    
    /// Applies a bonus to the affinity ratings of the provided names by adding a value derived from the `kFactor`.
    /// The new rating for each name is calculated by adding the `kFactor` to the current affinity rating.
    /// If the resulting rating is below the minimum allowed (`Name.minimumAffinityRating`), it is set to the minimum rating.
    /// After updating the rating, the evaluation count for each name is incremented.
    ///
    /// - Parameter names: An array of `Name` objects to which the bonus will be applied.
    /// - Throws: Throws an error if the `setAffinity` method fails when updating the name's affinity rating.
    /// - Note: The `increaseEvaluationCount` method is called for each name, regardless of whether the affinity was updated or not.
    func applyBonus(to names: [Name])
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
    
    
    // MARK: - Insert
    
    func insert(_ name: Name) async -> Result<Void, NamePersistenceError> {
        do {
            guard try fetchName(byText: name.text, sex: name.sex!) == nil
            else {
                logError("Attempted to insert a duplicate \(name.sex!.sexNamingConvention) name. Name: \(name.text)")
                return .failure(NamePersistenceError.duplicateNameInserted(name.text))
            }
            
            modelContext.insert(name)
            try modelContext.save()
            
            return .success(())
            
        } catch NamePersistenceError.unableToFetch(let error) {
            logError("Unable to fetch names while attempting to insert name `\(name)`: \(error.localizedDescription)")
            return .failure(.unableToFetch(error))
            
        } catch {
            logError("Unexpected error occured while inserting a name `\(name)`: \(error.localizedDescription)")
            return .failure(.unexpectedError(error))
        }
    }
    
    func insert(_ names: [Name]) async -> [Result<Void, NamePersistenceError>] {
        var results: [Result<Void, NamePersistenceError>] = []
        
        guard let fetchedNames = try? fetchNames()
        else {
            logError("Unable to fetch names during batch insertion.")
            return results
        }
            
        // Filter out duplicate `Name` objects within the provided array based on `text` and `sex` properties.
        var seenNames: Set<(String)> = []
        
        do {
            try modelContext.transaction {
                for name in names {
                    let nameKey = "\(name.text)-\(name.sex!.rawValue)"  // Create a unique key using text and sex
                    
                    guard seenNames.insert(nameKey).inserted else {     // Attempt to insert a unique name to the seen array.
                        logError("Duplicate name found in the provided array. Name: \(name.text) with sex \(name.sex!.rawValue)")
                        results.append(.failure(NamePersistenceError.duplicateNameInserted(name.text)))
                        continue
                    }
                    
                    if fetchedNames.contains(                           // Check if the fetched names contains the new `Name`.
                        where: { $0.text == name.text && $0.sex == name.sex }) {
                        results.append(.failure(.duplicateNameInserted(name.text)))
                        
                    } else {
                        modelContext.insert(name)                       // Insert unique `Name`.
                        results.append(.success(()))
                    }
                }
            }
        } catch {
            logError("Unable to batch insert Names: \(error.localizedDescription)")
        }
        
        return results
    }
    
    
    // MARK: - Delete
    
    func delete(_ name: Name) async {
        do {
            modelContext.delete(name)
            try modelContext.save()
            
        } catch {
            logError("Unable to save the model context during the deletion of Name object: \(error.localizedDescription)")
        }
    }
    
    func delete(_ names: [Name]) async {
        do {
            try modelContext.transaction {
                for name in names {
                    modelContext.delete(name)
                }
            }
        }
        catch {
            logError("Unable to batch delete Names: \(error.localizedDescription)")
        }
    }
}


// MARK: - Update

extension NamePersistenceController_Admin {
    
    func applyPenalty(to names: [Name]) {
        let kFactor = AffinityCalculator.kFactor.convertToInt()
        
        for name in names {
            do {
                let newRating = name.affinityRating - kFactor
                if newRating >= Name.minimumAffinityRating {
                    try name.setAffinity(newRating)
                    
                } else {
                    try name.setAffinity(Name.minimumAffinityRating)
                }
                
                name.increaseEvaluationCount()
                
            } catch {
                logError("Unable to set affinity for \(name): \(error.localizedDescription)")
            }
        }
    }
    
    func applyBonus(to names: [Name]) {
        let kFactor = AffinityCalculator.kFactor.convertToInt()
        
        for name in names {
            do {
                let newRating = name.affinityRating + kFactor
                if newRating >= Name.minimumAffinityRating {
                    try name.setAffinity(newRating)
                    
                } else {
                    try name.setAffinity(Name.minimumAffinityRating)
                }
                
                name.increaseEvaluationCount()
                
            } catch {
                logError("Unable to set affinity for \(name): \(error.localizedDescription)")
            }
        }
    }
    
    
    func updateAffinity(winners: [Name], losers: [Name]) {
        guard !winners.isEmpty && !losers.isEmpty else {
            applyPenalty(to: losers)
            applyBonus(to: winners)
            return
        }
        
        let calc = AffinityCalculator()
        let winnerRatings = winners.map { $0.affinityRating }
        let loserRatings = losers.map { $0.affinityRating }
        
        updateNames(winners, against: loserRatings, isWinner: true, calc: calc)
        updateNames(losers, against: winnerRatings, isWinner: false, calc: calc)
    }
    
    /// Updates the affinity ratings for a given list of names.
    ///
    /// - Parameters:
    ///   - names: The array of `Name` objects to update.
    ///   - ratings: The list of opposing ratings that these names are compared against.
    ///   - isWinner: A Boolean indicating whether these names are considered winners.
    ///   - calc: The `AffinityCalculator` used to calculate the new affinity ratings.
    private func updateNames(_ names: [Name], against ratings: [Rating], isWinner: Bool, calc: AffinityCalculator) {
        names.forEach { name in
            updateAffinity(for: name, against: ratings, isWinner: isWinner, calc: calc)
        }
    }
    
    /// Updates the affinity rating for a single name based on opposing ratings.
    /// The method also increments the evaluation count of the name.
    ///
    /// - Parameters:
    ///   - name: The `Name` object whose affinity is being updated.
    ///   - ratings: The opposing ratings to compare against.
    ///   - isWinner: A Boolean indicating whether the name is a winner.
    ///   - calc: The `AffinityCalculator` used to calculate the new rating.
    private func updateAffinity(for name: Name, against ratings: [Rating], isWinner: Bool, calc: AffinityCalculator) {
        let newRating = calc.calculateNewRating(for: name.affinityRating, against: ratings, isWinner: isWinner)
        
        do {
            try name.setAffinity(newRating)
            name.increaseEvaluationCount()
            
        } catch {
            logError("Unable to set affinity to new rating: \(error.localizedDescription)")
        }
    }
}


// MARK: - Default Data

extension NamePersistenceController_Admin {
    
    func getDefaultNames(_ sex: Sex? = nil) async -> [Name] {
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
            let femaleNames = await getDefaultNames(.female)
            let maleNames = await getDefaultNames(.male)
            names = femaleNames + maleNames
        }
        
        return names
    }
    
    func loadDefaultNames() async {
        let names = await getDefaultNames()
        
        let results = await insert(names)
        for result in results {
            switch result {
            case .success(_): continue
            case .failure(let error):
                logError("Unable to insert name when loading default names: \(error.localizedDescription)")
            }
        }
    }
    
    
    // MARK: - Methods
    
    func resetNameData() {
        do {
            let names = try fetchNames()
            
            try modelContext.transaction {
                for name in names {
                    name.resetValues()
                }
            }
            
        } catch {
            logError("Unable to reset Name data: \(error.localizedDescription)")
        }
        
    }
}
