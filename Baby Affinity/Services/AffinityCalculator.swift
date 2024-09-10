//
//  AffinityCalculator.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/6/24.
//

import Foundation


// MARK: - Affinity Calculator

typealias Rating = Int

/// A tool used for calculating affinity ratings. This is essentially an ELO calculator with a modified K factor.
class AffinityCalculator {
    
    // MARK: - K-Factor
    /// The K factor in the ELO rating system, which determines the maximum possible adjustment per game.
    /// - Note: A higher K factor means ratings change more significantly with each game, making the system more responsive to recent performance.
    /// In contrast, a lower K factor means ratings change more slowly, making the system more stable.
    static let kFactor: Decimal = 50
    
    
    // MARK: - Methods
    
    /// Calculates the probability rating for a match between two ratings.
    /// - Parameters:
    ///   - r1: The rating of the first participant.
    ///   - r2: The rating of the second participant.
    /// - Returns: The probability of the first participant winning against the second participant.
    func probabilityRating(for r1: Rating, against r2: Rating) -> Decimal {
        let exponent = Double(r2 - r1) / 400.0
        let result = 1.0 / (1.0 + pow(10, exponent))
        return Decimal(round(result * 100) / 100)   // Round to hundredths; 0.12
    }
    
    /// Calculates the updated ratings for the winner and loser after a match.
    /// - Parameters:
    ///   - winnerRating: The current rating of the winner.
    ///   - loserRating: The current rating of the loser.
    /// - Returns: A tuple containing the updated ratings for the winner and the loser.
    func calculateNewRatings(winnerRating: Rating, loserRating: Rating) -> (newWinnerRating: Rating, newLoserRating: Rating) {
        // Calculate the expected scores for the winner and the loser
        let winnerExpectedScore = probabilityRating(for: winnerRating, against: loserRating)
        let loserExpectedScore = 1.0 - winnerExpectedScore
        
        // Define actual scores
        let winnerActualScore: Decimal = 1.0
        let loserActualScore: Decimal = 0.0
        
        // Calculate new ratings
        let newWinnerRating = updateRating(for: winnerRating, actualScore: winnerActualScore, expectedScore: winnerExpectedScore)
        let newLoserRating = updateRating(for: loserRating, actualScore: loserActualScore, expectedScore: loserExpectedScore)
        
        return (newWinnerRating, newLoserRating)
    }
    
    /// Updates a rating based on the actual and expected scores.
    /// - Parameters:
    ///   - rating: The current rating.
    ///   - actualScore: The actual score obtained (1.0 for win, 0.0 for loss).
    ///   - expectedScore: The expected score based on the opponent's rating.
    /// - Returns: The updated rating.
    private func updateRating(for rating: Rating, actualScore: Decimal, expectedScore: Decimal) -> Rating {
        let newRating = Decimal(rating) + Self.kFactor * (actualScore - expectedScore)
        return newRating.convertToInt()
    }
}


// MARK: - Group Ratings

extension AffinityCalculator {
    
    func calculateNewRating(for rating: Rating, against ratings: [Rating], isWinner: Bool) -> Rating {
        let groupRating = averageRating(of: ratings)
        
        let scores: (newWinnerRating: Rating, newLoserRating: Rating)
        if isWinner {
            scores = calculateNewRatings(winnerRating: rating, loserRating: groupRating)
        } else {
            scores = calculateNewRatings(winnerRating: groupRating, loserRating: rating)
        }
        
        return isWinner ? scores.newWinnerRating : scores.newLoserRating
    }
    
    func calculate(winner rating: Rating, against ratings: [Rating]) -> Rating {
        calculateNewRating(for: rating, against: ratings, isWinner: true)
    }

    func calculate(loser rating: Rating, against ratings: [Rating]) -> Rating {
        calculateNewRating(for: rating, against: ratings, isWinner: false)
    }
    
    func averageRating(of ratings: [Rating]) -> Rating {
        let totalRating = ratings.reduce(0, +)
        return totalRating / ratings.count
    }
    
    func groupAverageRating(winnerRatings: [Rating], loserRatings: [Rating]) -> Rating {
        averageRating(of: winnerRatings + loserRatings)
    }
}
















class EloRating {
    var kFactor: Double
    
    init(kFactor: Double = 32) {
        self.kFactor = kFactor
    }
    
    // Calculate expected score between two ratings
    private func expectedScore(forPlayer playerRating: Double, againstOpponent opponentRating: Double) -> Double {
        let ratingDifference = opponentRating - playerRating
        let exponent = ratingDifference / 400
        return 1 / (1 + pow(10, exponent))
    }
    
    // Calculate average rating of a group of players
    private func averageRating(of players: [Double]) -> Double {
        let totalRating = players.reduce(0, +)
        return totalRating / Double(players.count)
    }
    
    // Update the rating of a single player based on expected score and result
    private func updateRating(currentRating: Double, expectedScore: Double, result: Double) -> Double {
        return currentRating + kFactor * (result - expectedScore)
    }
    
    // Update the ratings of individual players based on the average rating of the opposing group
    func updateGroupRatings(winners: [Double], losers: [Double]) -> ([Double], [Double]) {
        let averageLoserRating = averageRating(of: losers)
        let averageWinnerRating = averageRating(of: winners)
        
        // Update each winner against the average rating of the losers
        let newWinnerRatings = winners.map { winnerRating in
            let expectedWinnersScore = expectedScore(forPlayer: winnerRating, againstOpponent: averageLoserRating)
            return updateRating(currentRating: winnerRating, expectedScore: expectedWinnersScore, result: 1.0)
        }
        
        // Update each loser against the average rating of the winners
        let newLoserRatings = losers.map { loserRating in
            let expectedLosersScore = expectedScore(forPlayer: loserRating, againstOpponent: averageWinnerRating)
            return updateRating(currentRating: loserRating, expectedScore: expectedLosersScore, result: 0.0)
        }
        
        return (newWinnerRatings, newLoserRatings)
    }
}
