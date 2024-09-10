//
//  AffinityCalculatorTests.swift
//  Baby AffinityTests
//
//  Created by Mike Centers on 9/9/24.
//

import XCTest
@testable import Baby_Affinity


// MARK: - Affinity Calculator Tests

final class AffinityCalculatorTests: XCTestCase {
    
    // MARK: K-Factor of 50 is used for the unit tests.
    
    let calc = AffinityCalculator()
    
    
    // MARK: Standard Tests
    
    func testProbabilityRating() {
        let winnerRating = 1200
        let loserRating = 1200
        
        let result1 = calc.probabilityRating(for: winnerRating, against: loserRating)
        let result2 = calc.probabilityRating(for: loserRating, against: winnerRating)
        
        XCTAssertEqual(result1, 0.5)
        XCTAssertEqual(result2, 0.5)
    }
    
    func testProbabilityRating_LowerRating() {
        let winnerRating = 1000
        let loserRating = 1200
        
        let result1 = calc.probabilityRating(for: winnerRating, against: loserRating)
        let result2 = calc.probabilityRating(for: loserRating, against: winnerRating)
        
        XCTAssertEqual(result1, 0.24)
        XCTAssertEqual(result2, 0.76)
    }
    
    func testProbabilityRating_HigherRating() {
        let winnerRating = 1200
        let loserRating = 1000
        
        let result1 = calc.probabilityRating(for: winnerRating, against: loserRating)
        let result2 = calc.probabilityRating(for: loserRating, against: winnerRating)
        
        XCTAssertEqual(result1, 0.76)
        XCTAssertEqual(result2, 0.24)
    }
    
    func testCalculateNewRatings() {
        let winnerRating = 1200
        let loserRating = 1200
        
        let results = calc.calculateNewRatings(winnerRating: winnerRating, loserRating: loserRating)
        
        XCTAssertEqual(results.newWinnerRating, 1225)
        XCTAssertEqual(results.newLoserRating, 1175)
    }
    
    func testCalculateNewRatings_HigherRating() {
        let winnerRating = 1200
        let loserRating = 1000
        
        let results = calc.calculateNewRatings(winnerRating: winnerRating, loserRating: loserRating)
        
        XCTAssertEqual(results.newWinnerRating, 1212)
        XCTAssertEqual(results.newLoserRating, 988)
    }
    
    func testCalculateNewRatings_LowerRating() {
        let winnerRating = 1000
        let loserRating = 1200
        
        let results = calc.calculateNewRatings(winnerRating: winnerRating, loserRating: loserRating)
        
        XCTAssertEqual(results.newWinnerRating, 1038)
        XCTAssertEqual(results.newLoserRating, 1162)
    }
    
    
    // MARK: - Group Tests
    
    func testAverageRating() {
        let knownAverage = 1277
        let ratings = [
            1250, 1200, 958, 1023, 1154, 1423, 1932
        ]
        
        let average = calc.averageRating(of: ratings)
        
        XCTAssertEqual(average, knownAverage)
    }
    
    func testGroupAverageRating() {
        let knownAverage = 1221
        let winnerRatings = [
            1250, 1200, 958, 1023, 1154, 1423, 1932
        ]
        let loserRatings = [
            1100, 1532, 999, 1052, 1034
        ]
        
        let average = calc.averageRating(of: winnerRatings + loserRatings)
        
        XCTAssertEqual(average, knownAverage)
    }
    
    func testCalculateLoser_Group() {
        let knownResult = 1181
        let loserRating = 1200
        let groupRatings = [
            1250, 1200, 958, 1023, 1154, 1423, 1932
        ]
        
        let newRating = calc.calculate(loser: loserRating, against: groupRatings)
        
        XCTAssertEqual(newRating, knownResult)
    }
    
    func testCalculateNewRatingLoser_Group() {
        let knownResult = 1181
        let winnerRating = 1200
        let groupRatings = [
            1250, 1200, 958, 1023, 1154, 1423, 1932
        ]
        
        let newRating = calc.calculateNewRating(for: winnerRating, against: groupRatings, isWinner: false)
        
        XCTAssertEqual(newRating, knownResult)
    }
    
    func testCalculateWinner_Group() {
        let knownResult = 1231
        let winnerRating = 1200
        let groupRatings = [
            1250, 1200, 958, 1023, 1154, 1423, 1932
        ]
        
        let newRating = calc.calculate(winner: winnerRating, against: groupRatings)
        
        XCTAssertEqual(newRating, knownResult)
    }
    
    func testCalculateNewRatingWinner_Group() {
        let knownResult = 1231
        let winnerRating = 1200
        let groupRatings = [
            1250, 1200, 958, 1023, 1154, 1423, 1932
        ]
        
        let newRating = calc.calculateNewRating(for: winnerRating, against: groupRatings, isWinner: true)
        
        XCTAssertEqual(newRating, knownResult)
    }
    
}
