//
//  AffinityCalculator.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/6/24.
//

import Foundation

typealias Rating = Int

/// A tool used for calculating affinity ratings. This is essentially an ELO calculator with a modified K factor.
class AffinityCalculator {
    
    /// The K factor in the ELO rating system, which determines the maximum possible adjustment per game.
    /// - Note: A higher K factor means ratings change more significantly with each game, making the system more responsive to recent performance.
    /// In contrast, a lower K factor means ratings change more slowly, making the system more stable.
    static let kFactor: Decimal = 50
    
    /// Calculates the probability rating for a match between two ratings.
    /// - Parameters:
    ///   - r1: The rating of the first participant.
    ///   - r2: The rating of the second participant.
    /// - Returns: The probability of the first participant winning against the second participant.
    static func probabilityRating(r1: Rating, r2: Rating) -> Decimal {
        let exponent = (r2 - r1) / 400
        let denominator = pow(10, exponent) + 1
        return 1.0 / denominator
    }
    
    /// Returns the updated affinity ratings for the winner and loser of a match.
    /// - Parameters:
    ///   - winnerRating: The current rating of the winner.
    ///   - loserRating: The current rating of the loser.
    /// - Returns: A tuple containing the new ratings for the winner and the loser.
    static func getScores(winnerRating: Rating, loserRating: Rating) -> (newWinnerRating: Rating, newLoserRating: Rating) {
        // Calculate the expected scores for the winner and the loser
        let winnerExpectedScore = probabilityRating(r1: winnerRating, r2: loserRating)
        let loserExpectedScore = 1.0 - winnerExpectedScore
        
        // Define actual scores
        let winnerActualScore: Decimal = 1.0
        let loserActualScore: Decimal = 0.0
        
        // Calculate new ratings
        let newWinnerRating = Decimal(winnerRating) + kFactor * (winnerActualScore - winnerExpectedScore)
        let newLoserRating = Decimal(loserRating) + kFactor * (loserActualScore - loserExpectedScore)
        
        return (newWinnerRating.convertToInt(), newLoserRating.convertToInt())
    }
}
