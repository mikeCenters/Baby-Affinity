//
//  Name.swift
//  Baby Affinity
//
//  Created by Mike Centers on 7/17/24.
//

import Foundation
import SwiftData

// FIXME: - Add Tags to create categories.
// FIXME: - Add ability to reference the same name with variant spellings.

@Model
final class Name {
    
    // MARK: - Errors
    
    /// Errors that can occur during `Name` initialization or modification.
    enum NameError: Error, Equatable {
        case nameIsEmpty
        case ratingBelowMinimum(_ minimumRating: Int)
        case unableToInitialize
    }
    
    
    // MARK: - Default Values
    
    /// Default affinity rating assigned to a new `Name` instance.
    static let defaultAffinityRating = 1200
    
    /// Default evaluation count assigned to a new `Name` instance.
    static let defaultEvaluationCount = 0
    
    /// Default favorite status assigned to a new `Name` instance.
    static let defaultFavoriteStatus = false
    
    /// Minimum value allowed for the affinity rating.
    static let minimumAffinityRating = 0
    
    
    
    // MARK: - Attributes
    
    /// The sex of the name, represented as a `Sex` enum value. It is derived from the raw value.
    var sex: Sex? { Sex(rawValue: self.sexRawValue) }
    
    /// Raw value representing the sex of the name. Used for sorting and comparisons.
    private(set) var sexRawValue: Int
    
    /// The text representation of the name. This must be unique.
    private(set) var text: String
    
    /// The number of times the name has been evaluated by the user.
    private(set) var evaluated: Int
    
    /// The affinity rating for the name, indicating the user's fondness.
    private(set) var affinityRating: Int
    
    /// Indicates whether the name is marked as a favorite.
    private(set) var isFavorite: Bool
    
    
    // MARK: - Init
    
    /// Initialize a `Name` object with the provided attributes. This initializer can throw errors if the input is invalid.
    /// - Parameters:
    ///   - text: The description of the name. Must not be empty.
    ///   - sex: The `Sex` of the name, represented as an enum value.
    ///   - affinityRating: The rating representing the user's fondness towards the name. Defaults to `Name.defaultAffinityRating`. Must be non-negative.
    /// - Throws: `NameError` if `text` is empty or`affinityRating` is below the minimum.
    init?(_ text: String, sex: Sex, affinityRating: Int = Name.defaultAffinityRating) throws {
        // Check if text is empty
        guard !text.isEmpty else {
            throw NameError.nameIsEmpty
        }
        // FIXME: Throw error when name exists for the sex.
        
        // Check if affinity rating is valid
        guard affinityRating >= Name.minimumAffinityRating else {
            throw NameError.ratingBelowMinimum(Name.minimumAffinityRating)
        }
        
        // Set default values
        self.text = text
        self.sexRawValue = sex.rawValue
        self.affinityRating = affinityRating
        self.evaluated = Name.defaultEvaluationCount
        self.isFavorite = Name.defaultFavoriteStatus
    }
}


// MARK: - Methods

extension Name {
    
    /// Increase the evaluation count by one.
    func increaseEvaluationCount() {
        self.evaluated += 1
    }
    
    /// Set the affinity rating to the provided value.
    /// - Parameter rating: The new affinity rating. Must be non-negative.
    /// - Throws: `NameError.ratingBelowMinimum` if the rating is below the minimum allowed value.
    func setAffinity(_ rating: Int) throws {
        guard rating >= Name.minimumAffinityRating else {
            throw NameError.ratingBelowMinimum(Name.minimumAffinityRating)
        }
        self.affinityRating = rating
    }
    
    /// Toggle the `isFavorite` status between true and false.
    func toggleFavorite() {
        self.isFavorite.toggle()
    }
}


// MARK: - Migrated to NameDataManager

extension Name {
    
    /// Insert names into the provided context in batches.
    /// - Parameters:
    ///   - names: An array of `Name` objects to be inserted.
    ///   - context: The context to insert the names into.
    /// - Throws: An error if the save operation fails.
    @MainActor
    static func insertNames(_ names: [Name], into context: ModelContext) async throws {
        // Fetch stored names and create a set of existing names' texts for fast lookup
        let storedNames: [Name] = try context.fetch(FetchDescriptor<Name>())
        let storedNamesSet = Set(storedNames.map { $0.text })

        // Filter out names that are already in the database
        let newNames = names.filter { !storedNamesSet.contains($0.text) }

        // Insert new names in batches
        let batchSize = 1000
        let totalObjects = newNames.count

        for i in 0..<(totalObjects / batchSize + 1) {
            let startIndex = i * batchSize
            let endIndex = min(startIndex + batchSize, totalObjects)
            
            for j in startIndex..<endIndex {
                context.insert(newNames[j])
            }
            
            try context.save()
        }
    }
    
    /// Get the rank of the `Name` within its `Sex` category, based on affinityRating.
    /// - Parameter context: The context to fetch the names from.
    /// - Returns: The rank of the name, or `nil` if the name is not found.
    func getRank(from context: ModelContext) -> Int? {
        let sex = self.sexRawValue
        let descriptor = FetchDescriptor<Name>(
            predicate: #Predicate { $0.sexRawValue == sex },
            sortBy: [
                .init(\.affinityRating, order: .reverse)
            ]
        )
        
        let names = try? context.fetch(descriptor)
        
        return names?.firstIndex(of: self).map { $0 + 1 }
    }
    
    
    /// Prepare the default names for insertion into the database.
    /// - Returns: An array of `Name` objects.
    static func prepareDefaultNames() async -> [Name] {
        // Access default names
        let names = DefaultBabyNames()
        
        // Prepare new names for insertion
        var newNames: [Name] = []

        
        // FIXME: Try statements
        // Add girl names
        for (_, name) in names.girlNames {
            newNames.append(try! Name(name, sex: .female)!)
        }
        
        // FIXME: Try statements
        // Add boy names
        for (_, name) in names.boyNames {
            newNames.append(try! Name(name, sex: .male)!)
        }
        
        return newNames
    }
}
