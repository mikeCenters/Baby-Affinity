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
    /// The sex of the name
    var sex: Sex? { Sex(rawValue: self.sexRawValue) }
    
    /// The rawValue of the `Sex` attribute. This attribute is required for sorting.
    private(set) var sexRawValue: Int
    
    /// The text representation of the name.
    @Attribute(.unique) private(set) var text: String
    
    /// The number of times the name has been evaluated via the user.
    private(set) var evaluated: Int
    
    /// The representation of the user's fondness of the name.
    private(set) var affinityRating: Int
    
    
    private(set) var isFavorite: Bool
    
    
    // MARK: - Init
    
    /// Initialize a `Name` object with the provided attriibutes. These are the `Names` a user would consider for naming their child.
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
    func setAffinity(_ rating: Int) {
        self.affinityRating = rating
    }
    
    /// Toggle the `.isFavorite` attribute.
    func toggleFavorite() {
        self.isFavorite.toggle()
    }
    
    /// Get the rank of the `Name`.
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
    
    
//    static func loadDefaultNames(_ context: ModelContext) async throws {
////                let storedNames = try? context.fetch(FetchDescriptor<Name>())
////                let names = DefaultBabyNames()
////        
////                /// Add girl names.
////                for (_, name) in names.girlNames {
////                    let n = Name(name, sex: .female)
////        
////                    if let stored = storedNames {
////                        if !stored.contains(n) {
////                            context.insert(n)
////                        }
////                    }
////                }
////        
////                /// Add boy names.
////                for (_, name) in names.boyNames {
////                    let n = Name(name, sex: .male)
////        
////                    if let stored = storedNames {
////                        if !stored.contains(n) {
////                            context.insert(n)
////                        }
////                    }
////                }
//        
//        do {
//            // Fetch all stored names' text once and create a set for fast lookup
//            let storedNames = try context.fetch(FetchDescriptor<Name>())
//            let storedNamesSet = Set(storedNames.map { $0.text })
//            
//            // Access default names
//            let names = DefaultBabyNames()
//            
//            // Prepare new names for insertion
//            var newNames: [Name] = []
//            
//            // Add girl names if they don't exist in the stored names
//            for (_, name) in names.girlNames {
//                if !storedNamesSet.contains(name) {
//                    newNames.append(Name(name, sex: .female))
//                }
//            }
//            
//            // Add boy names if they don't exist in the stored names
//            for (_, name) in names.boyNames {
//                if !storedNamesSet.contains(name) {
//                    newNames.append(Name(name, sex: .male))
//                }
//            }
//            
//            // Batch size for insertion
//            let batchSize = 1000
//            let totalObjects = newNames.count
//            
//            for i in 0..<(totalObjects / batchSize + 1) {
//                let startIndex = i * batchSize
//                let endIndex = min(startIndex + batchSize, totalObjects)
//                
//                for j in startIndex..<endIndex {
//                    context.insert(newNames[j])
//                }
//                
//                do {
//                    try context.save()
//                    print("Saved batch \(i + 1)")
//                } catch {
//                    print("Failed to save batch \(i + 1): \(error)")
//                    throw error
//                }
//            }
//        } catch {
//            print("Failed to fetch stored names: \(error)")
//            throw error
//        }
//    }
}


extension Name {
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
