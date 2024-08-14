//
//  Sex.swift
//  Baby Affinity
//
//  Created by Mike Centers on 7/17/24.
//

import Foundation

/**
 An enumeration representing the sex of a baby, which can be either female or male.

 This enumeration conforms to `Int`, `Codable`, and `CaseIterable` protocols.
 */
enum Sex: Int, Codable, CaseIterable {
    
    // MARK: - Case
    
    case female = 0
    case male = 1
    
    
    // MARK: - Properties
    
    /**
     A string representation of the alternate name for the sex.
     
     - Returns: "Girl" if the sex is female, "Boy" if the sex is male.
     */
    var childNaming: String {
        switch self {
        case .female:
            return "Girl"
        case .male:
            return "Boy"
        }
    }
    
    /**
     A string representation of the adult naming convention for the sex.
     
     - Returns: "Woman" if the sex is female, "Man" if the sex is male.
     */
    var adultNaming: String {
        switch self {
        case .female:
            return "Woman"
        case .male:
            return "Man"
        }
    }
    
    /**
     A string representation of the alternate name for the sex.
     
     - Returns: "Female" if the sex is female, "Male" if the sex is male.
     */
    var sexNamingConvention: String {
        switch self {
        case .female:
            return "Girl"
        case .male:
            return "Boy"
        }
    }
    
    
    // MARK: - Init
    
    /**
     Initializes a `Sex` instance from a given integer value.
     
     - Parameter value: An integer value representing the sex. Use 0 for female and 1 for male.
     
     - Returns: A `Sex` instance corresponding to the provided integer value, or `nil` if the value is invalid.
     */
    init?(rawValue: Int) {
        switch rawValue {
        case 0:
            self = .female
        case 1:
            self = .male
        default:
            return nil
        }
    }
    
    /**
     Initializes a `Sex` instance from a given string value.
     
     - Parameter value: A string value representing the sex. Use "female", "girl", or "woman" for female and "male", "boy", or "man" for male (case insensitive).
     
     - Returns: A `Sex` instance corresponding to the provided string value, or `nil` if the value is invalid.
     */
    init?(value: String) {
        switch value.lowercased() {
        case "female", "girl", "woman":
            self = .female
        case "male", "boy", "man":
            self = .male
        default:
            return nil
        }
    }
}
