//
//  AffinityCalculator.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/6/24.
//

import Foundation

typealias Rating = Double

/// A tool used for calculating affinity ratings. This is essentially an ELO calculator with a modified K factor.
class AffinityCalculator {
    
    /// The K factor in the ELO rating system, which determines the maximum possible adjustment per game.
    /// - Note: A higher K factor means ratings change more significantly with each game, making the system more responsive to recent performance.
    /// In contrast, a lower K factor means ratings change more slowly, making the system more stable.
    static let kFactor: Double = 100.0
    
    /// Calculates the probability rating for a match between two ratings.
    /// - Parameters:
    ///   - r1: The rating of the first participant.
    ///   - r2: The rating of the second participant.
    /// - Returns: The probability of the first participant winning against the second participant.
    static func probabilityRating(r1: Double, r2: Double) -> Double {
        return 1.0 / (1 + pow(10, (r2 - r1) / 400))
    }
    
    /// Returns the updated affinity ratings for the winner and loser of a match.
    /// - Parameters:
    ///   - winnerRating: The current rating of the winner.
    ///   - loserRating: The current rating of the loser.
    /// - Returns: A tuple containing the new ratings for the winner and the loser.
    static func getScores(winnerRating: Rating, loserRating: Rating) -> (newWinnerRating: Rating, newLoserRating: Rating) {
        // Calculate the expected score for the winner
        let winnerExpectedScore = probabilityRating(r1: winnerRating, r2: loserRating)
        
        // The loser's expected score is the complement of the winner's expected score
        let loserExpectedScore = 1.0 - winnerExpectedScore
        
        // Actual scores
        let winnerActualScore: Double = 1.0
        let loserActualScore: Double = 0.0
        
        // Update the ratings based on the actual and expected scores
        let newWinnerRating = winnerRating + kFactor * (winnerActualScore - winnerExpectedScore)
        let newLoserRating = loserRating + kFactor * (loserActualScore - loserExpectedScore)
        
        return (newWinnerRating, newLoserRating)
    }
}
