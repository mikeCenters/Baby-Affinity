//
//  Name.swift
//  Baby Affinity
//
//  Created by Mike Centers on 7/17/24.
//

import Foundation
import SwiftData

@Model
final class Name {
    
    // MARK: - Attributes
    /// The sex of the name.
    var sex: Sex? { Sex(rawValue: self.sexRawValue) }
    
    /// The rawValue of the `Sex` attribute. This attribute is required for sorting.
    private(set) var sexRawValue: Int
    
    /// The text representation of the name.
    @Attribute(.unique) private(set) var text: String
    
    /// The number of times the name has been evaluated via the user.
    private(set) var evaluated: Int
    
    /// The representation of the user's fondness of the name.
    private(set) var affinityRating: Int
    
    /// Indicates whether the name is marked as a favorite.
    private(set) var isFavorite: Bool
    
    // FIXME: - Add Tags to create categories.
    // FIXME: - Add ability to reference the same name with variant spellings.
    
    
    // MARK: - Init
    
    /// Initialize a `Name` object with the provided attributes. These are the `Names` a user would consider for naming their child.
    /// - Parameters:
    ///   - text: The description of the name.
    ///   - sex: The `Sex` of the name. `Male` or `Female`.
    ///   - affinityRating: The rating that represents a user's fondness towards it. The default rating is 1200.
    init(_ text: String, sex: Sex, affinityRating: Int = 1200) {
        self.text = text
        self.sexRawValue = sex.rawValue
        self.affinityRating = affinityRating
        self.evaluated = 0
        self.isFavorite = false
    }
}


extension Name {
    
    // MARK: - Methods
    
    /// Increase the times evaluated by one interval.
    func increaseEvaluationCount() {
        self.evaluated += 1
    }
    
    /// Set the affinityRating attribute to the provided rating.
    /// - Parameter rating: The new affinity rating.
    func setAffinity(_ rating: Int) {
        self.affinityRating = rating
    }
    
    /// Toggle the `.isFavorite` attribute.
    func toggleFavorite() {
        self.isFavorite.toggle()
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
}


extension Name {
    /// Prepare the default names for insertion into the database.
    /// - Returns: An array of `Name` objects.
    static func prepareDefaultNames() async -> [Name] {
        // Access default names
        let names = DefaultBabyNames()
        
        // Prepare new names for insertion
        var newNames: [Name] = []

        // Add girl names
        for (_, name) in names.girlNames {
            newNames.append(Name(name, sex: .female))
        }

        // Add boy names
        for (_, name) in names.boyNames {
            newNames.append(Name(name, sex: .male))
        }
        
        return newNames
    }
    
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
}
