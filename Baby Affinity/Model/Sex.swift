//
//  Sex.swift
//  Baby Affinity
//
//  Created by Mike Centers on 7/17/24.
//

import Foundation

/// A male or female representation.
enum Sex: Int, Codable, CaseIterable {
    case female = 0
    case male = 1
    
    /// Returns "Boy" or "Girl" based upon the `Sex`.
    var alternateName: String {
        switch self {
        case .female:
            return "Girl"
        case .male:
            return "Boy"
        }
    }
}
