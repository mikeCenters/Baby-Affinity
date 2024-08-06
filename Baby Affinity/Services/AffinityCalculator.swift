//
//  AffinityCalculator.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/6/24.
//

import Foundation

typealias WinnerRating = Double
typealias LoserRating = Double

/// A tool used for calculating affinity ratings. This is essentially an ELO calculator with a modified K factor.
class AffinityCalculator {
    
    /// The K factor for ELO rating.
    static let kFactor: Double = 100.0
    
    /// Calculates the probability rating for a match between two ratings.
    /// - Parameters:
    ///   - rating1: The rating of the first participant.
    ///   - rating2: The rating of the second participant.
    /// - Returns: The probability of the first participant winning against the second participant.
    static func probabilityRating(rating1: Double, rating2: Double) -> Double {
        return 1.0 / (1 + pow(10, (rating2 - rating1) / 400))
    }
    
    /// Returns the updated affinity ratings for the winner and loser of a match.
    /// - Parameters:
    ///   - winnerRating: The current rating of the winner.
    ///   - loserRating: The current rating of the loser.
    /// - Returns: A tuple containing the new ratings for the winner and the loser.
    static func getScores(winnerRating: Double, loserRating: Double) -> (WinnerRating, LoserRating) {
        let winnerExpectedScore = probabilityRating(rating1: winnerRating, rating2: loserRating)
        let loserExpectedScore = probabilityRating(rating1: loserRating, rating2: winnerRating)
        
        let winnerNewRating = winnerRating + kFactor * (1.0 - winnerExpectedScore)
        let loserNewRating = loserRating + kFactor * (0.0 - loserExpectedScore)
        
        return (winnerNewRating, loserNewRating)
    }
}
