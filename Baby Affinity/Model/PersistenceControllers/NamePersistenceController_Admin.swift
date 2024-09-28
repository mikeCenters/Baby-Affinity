//
//  NamePersistenceController_Admin.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/15/24.
//

import Foundation
import SwiftData
import SystemLogger


// MARK: - Error

/// Errors that can occur during name persistence operations.
enum NamePersistenceError: Error {
    case duplicateNameInserted(_ name: String)
    case noNamesInPersistence
    case unableToFetch(_ error: Error)
    case unexpectedError(_ error: Error)
}


// MARK: - Types

typealias RankedMaleNames = [(Rank, Name)]
typealias RankedFemaleNames = [(Rank, Name)]


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
    
    /// Compares two lists of `Name` objects, one for males and one for females, and returns ranked results for both.
    ///
    /// This method creates compared name lists for males and females, assigns ranks based on their affinity ratings,
    /// and returns the ranked names as tuples of `(Rank, Name)`.
    ///
    /// - Parameters:
    ///   - maleNames: An array of `Name` objects representing male names.
    ///   - femaleNames: An array of `Name` objects representing female names.
    ///
    /// - Returns: A tuple containing two arrays:
    ///   - `RankedMaleNames`: The ranked list of male names based on affinity rating.
    ///   - `RankedFemaleNames`: The ranked list of female names based on affinity rating.
    func compareNames(maleNames: [Name], femaleNames: [Name]) -> (RankedMaleNames, RankedFemaleNames)
    
    /// Assigns ranks to a list of `Name` objects based on their affinity rating.
    ///
    /// The list is sorted in descending order of affinity ratings, and each name is assigned a rank based on its position in the sorted list.
    ///
    /// - Parameter names: An array of `Name` objects to be ranked.
    ///
    /// - Returns: An array of tuples where each tuple contains a rank and a `Name`.
    func assignRanks(to names: [Name]) -> [(Rank, Name)]
        
    /// Creates a list of compared names of a provided `Sex`.
    ///
    /// This method fetches names from the database based on `Sex` and attempts to merge them with the provided list of names.
    ///
    /// - Parameters:
    ///   - names: The list of `Name` objects to be compared.
    ///   - sex: The`Sex` of the provided names.
    ///
    /// - Returns: A list of `Name` objects that have been compared and merged. If an error occurs or a name doesn't match the specified `Sex`, it is skipped.
    func createComparedNames(with names: [Name], of sex: Sex) -> [Name]
        
    /// Finds a matching `Name` in a list and merges it with another name if found.
    ///
    /// This method attempts to find a `Name` in a given list and, if successful, merges it with the provided name.
    ///
    /// - Parameters:
    ///   - name: The `Name` object to be merged.
    ///   - names: An array of `Name` objects in which to search for a match.
    ///
    /// - Returns: A merged `Name` object if successful, or `nil` if no match is found or the merge fails.
    func findAndMerge(_ name: Name, in names: [Name]) -> Name?
        
    /// Merges two `Name` objects if they have the same text and sex.
    ///
    /// This method combines two `Name` objects by averaging their affinity ratings and setting their favorite status. It returns a new `Name` object upon successful merging. If both names are set to favorite, the merged name will be favorite as well; otherwise, the status is set to `false`.
    ///
    /// - Parameters:
    ///   - n1: The first `Name` object to merge.
    ///   - n2: The second `Name` object to merge.
    ///
    /// - Returns: A new merged `Name` object if the merge is successful, or `nil` if the names do not match or merging fails.
    func mergeNames(_ n1: Name, _ n2: Name) -> Name?
    
    /// Calculates the average affinity rating of two `Name` objects.
    ///
    /// This method takes the affinity ratings of two names and returns their average value.
    ///
    /// - Parameters:
    ///   - n1: The first `Name` object.
    ///   - n2: The second `Name` object.
    ///
    /// - Returns: The average of the affinity ratings of `n1` and `n2`.
    func averageRating(_ n1: Name, _ n2: Name) -> Rating
    
    /// Finds a matching `Name` object in a given array of names based on the name text and sex.
    ///
    /// This method searches through an array of `Name` objects to find the first match where both
    /// the `text` and `sexRawValue` properties are equal to the specified `Name`.
    ///
    /// - Parameters:
    ///   - name: The `Name` object to search for in the array. It must contain both `text` and `sexRawValue` properties.
    ///   - names: An array of `Name` objects to search within.
    ///
    /// - Returns: The first `Name` in the array that matches both the `text` and `sexRawValue`
    ///            of the provided `name`, or `nil` if no match is found.
    func find(_ name: Name, in names: [Name]) -> Name?
}


extension NamePersistenceController_Admin {
    
    // MARK: - Create
    
    func createName(_ name: String, sex: Sex, affinityRating: Int = Name.defaultAffinityRating) -> Result<Name, Name.NameError> {
        do {
            let name = try Name(name, sex: sex, affinityRating: affinityRating)
            return .success(name)
            
        } catch Name.NameError.nameIsEmpty {
            SystemLogger.main.logError("Error: The name cannot be empty. Skipping: \(name)")
            return .failure(.nameIsEmpty)
            
        } catch Name.NameError.ratingBelowMinimum(let minimumRating) {
            SystemLogger.main.logError("Error: The affinity rating is below the minimum (\(minimumRating)). Skipping: \(name)")
            return .failure(.ratingBelowMinimum(Name.minimumAffinityRating))
            
        } catch Name.NameError.invalidCharactersInName(let chars) {
            SystemLogger.main.logError("Error: The provided name string contained non-alphabet characters or the allowed special characters (\(chars)). Skipping: \(name)")
            return .failure(.invalidCharactersInName(chars))
            
        } catch {
            SystemLogger.main.logError("Unexpected error initializing Name: \(error.localizedDescription). Skipping: \(name)")
            return .failure(.unexpectedError(error))
        }
    }
    
    
    // MARK: - Insert
    
    func insert(_ name: Name) async -> Result<Void, NamePersistenceError> {
        do {
            guard try fetchName(byText: name.text, sex: name.sex!) == nil
            else {
                SystemLogger.main.logError("Attempted to insert a duplicate \(name.sex!.sexNamingConvention) name. Name: \(name.text)")
                return .failure(NamePersistenceError.duplicateNameInserted(name.text))
            }
            
            modelContext.insert(name)
            try modelContext.save()
            
            return .success(())
            
        } catch NamePersistenceError.unableToFetch(let error) {
            SystemLogger.main.logCritical("Unable to fetch names while attempting to insert name `\(name)`: \(error.localizedDescription)")
            return .failure(.unableToFetch(error))
            
        } catch {
            SystemLogger.main.logError("Unexpected error occured while inserting a name `\(name)`: \(error.localizedDescription)")
            return .failure(.unexpectedError(error))
        }
    }
    
    func insert(_ names: [Name]) async -> [Result<Void, NamePersistenceError>] {
        var results: [Result<Void, NamePersistenceError>] = []
        
        guard let fetchedNames = try? fetchNames()
        else {
            SystemLogger.main.logCritical("Unable to fetch names during batch insertion.")
            return results
        }
            
        // Filter out duplicate `Name` objects within the provided array based on `text` and `sex` properties.
        var seenNames: Set<(String)> = []
        
        do {
            try modelContext.transaction {
                for name in names {
                    let nameKey = "\(name.text)-\(name.sex!.rawValue)"  // Create a unique key using text and sex
                    
                    guard seenNames.insert(nameKey).inserted else {     // Attempt to insert a unique name to the seen array.
                        SystemLogger.main.logError("Duplicate name found in the provided array. Name: \(name.text) with sex \(name.sex!.rawValue)")
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
            SystemLogger.main.logCritical("Unable to batch insert Names: \(error.localizedDescription)")
        }
        
        return results
    }
    
    
    // MARK: - Delete
    
    func delete(_ name: Name) async {
        do {
            modelContext.delete(name)
            try modelContext.save()
            
        } catch {
            SystemLogger.main.logCritical("Unable to save the model context during the deletion of Name object: \(error.localizedDescription)")
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
            SystemLogger.main.logCritical("Unable to batch delete Names: \(error.localizedDescription)")
        }
    }
    
    func resetNameData() {
        do {
            let names = try fetchNames()
            
            try modelContext.transaction {
                for name in names {
                    name.resetValues()
                }
            }
            
        } catch {
            SystemLogger.main.logCritical("Unable to reset Name data: \(error.localizedDescription)")
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
                SystemLogger.main.logError("Unable to set affinity for \(name): \(error.localizedDescription)")
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
                SystemLogger.main.logError("Unable to set affinity for \(name): \(error.localizedDescription)")
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
            SystemLogger.main.logError("Unable to set affinity to new rating: \(error.localizedDescription)")
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
                SystemLogger.main.logCritical("Unable to insert name when loading default names: \(error.localizedDescription)")
            }
        }
    }
}


// MARK: - Methods

extension NamePersistenceController_Admin {
    
    func compareNames(maleNames: [Name], femaleNames: [Name]) -> (RankedMaleNames, RankedFemaleNames) {
        let comparedMaleNames = createComparedNames(with: maleNames, of: .male)
        let comparedFemaleNames = createComparedNames(with: femaleNames, of: .female)
        
        let rankedMaleNames = assignRanks(to: comparedMaleNames)
        let rankedFemaleNames = assignRanks(to: comparedFemaleNames)
        
        return (rankedMaleNames, rankedFemaleNames)
    }
    
    func assignRanks(to names: [Name]) -> [(Rank, Name)] {
        let sorted = names.sorted { $0.affinityRating > $1.affinityRating }
        return Array(sorted.enumerated()).map { (index, name) in
            (index + 1, name)
        }
    }
    
    func createComparedNames(with names: [Name], of sex: Sex) -> [Name] {
        var newNames: [Name] = []
        
        do {
            let fetchedNames = try fetchNames(sex)
            
            for name in names {
                guard name.sexRawValue == sex.rawValue,
                      let newName = findAndMerge(name, in: fetchedNames)
                else {
                    SystemLogger.main.logError("The provided name to compare is not of the selected sex.")
                    continue
                }
                
                newNames.append(newName)
            }
            
        } catch {
            SystemLogger.main.logCritical("Unable to create a compared name: \(error.localizedDescription)")
        }
        
        return newNames
    }
    
    func findAndMerge(_ name: Name, in names: [Name]) -> Name? {
        guard let foundName = find(name, in: names),
              let newName = mergeNames(name, foundName)
                
        else { return nil }
        
        return newName
    }
    
    func mergeNames(_ n1: Name, _ n2: Name) -> Name? {
        guard n1.text == n2.text, n1.sexRawValue == n2.sexRawValue else {
            return nil
        }
        
        let averageRating = averageRating(n1, n2)
        let result = createName(n1.text, sex: .male, affinityRating: averageRating)
        
        switch result {
        case .success(let newName):
            
            // Set the favorite status
            if n1.isFavorite && n2.isFavorite {
                newName.toggleFavorite()
            }
            
            return newName
            
        case .failure(_):
            return nil
        }
    }
    
    func averageRating(_ n1: Name, _ n2: Name) -> Rating {
        (n1.affinityRating + n2.affinityRating) / 2
    }
    
    func find(_ name: Name, in names: [Name]) -> Name? {
        names.first { $0.text == name.text && $0.sexRawValue == name.sexRawValue }
    }
}
