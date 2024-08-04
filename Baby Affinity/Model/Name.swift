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
    private(set) var sexRawValue: Int16
    
    /// The text representation of the name.
    private(set) var text: String
    
    /// The number of times the name has been evaluated via the user.
    private(set) var evaluated: Int16
    
    /// The representation of the user's fondness of the name.
    private(set) var affinityRating: Int16
    
    
    private(set) var isFavorite: Bool
    
    
    // MARK: - Init
    
    /// Initialize a `Name` object with the provided attriibutes. These are the `Names` a user would consider for naming their child.
    /// - Parameters:
    ///   - text: The description of the name.
    ///   - sex: The `Sex` of the name. `Male` or `Female`.
    ///   - affinityRating: The rating that represents a user's fondness towards it. The default rating is 1200.
    init(_ text: String, sex: Sex, affinityRating: Int16 = 1200) {
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
    func setAffinity(_ rating: Int16) {
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
    
    @MainActor
    static func loadDefaultNames(_ context: ModelContext) {
        let storedNames = try? context.fetch(FetchDescriptor<Name>())
        
        /// Load default data.
        Task {
            let names = DefaultBabyNames()
            
            /// Add girl names.
            for (_, name) in names.girlNames {
                let n = Name(name, sex: .female)
                
                if let stored = storedNames {
                    if !stored.contains(n) {
                        context.insert(n)
                    } else {
                        print("It was missed.")
                    }
                }
            }
            
            /// Add boy names.
            for (_, name) in names.boyNames {
                let n = Name(name, sex: .male)
                
                if let stored = storedNames {
                    if !stored.contains(n) {
                        context.insert(n)
                    }
                }
            }
        }
    }
}
