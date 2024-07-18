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
    private(set) var sex: Sex
    
    /// The text represation of the name.
    private(set) var text: String
    
    /// The number of times the name has been evaluated via the user.
    private(set) var evaluated: Int16
    
    /// The representation of the user's fondness of the name.
    private(set) var affinityRating: Int16
    
    
    // MARK: - Init
    
    /// Initialize a `Name` object with the provided attriibutes. These are the `Names` a user would consider for naming their child.
    /// - Parameters:
    ///   - text: The description of the name.
    ///   - sex: The `Sex` of the name. `Male` or `Female`.
    ///   - affinityRating: The rating that represents a user's fondness towards it. The default rating is 1200.
    init(_ text: String, sex: Sex, affinityRating: Int16 = 1200) {
        self.text = text
        self.sex = sex
        self.affinityRating = affinityRating
        self.evaluated = 0
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
}
