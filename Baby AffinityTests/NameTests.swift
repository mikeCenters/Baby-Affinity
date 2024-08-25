//
//  NameTests.swift
//  Baby AffinityTests
//
//  Created by Mike Centers on 8/13/24.
//

import XCTest
@testable import Baby_Affinity

final class NameTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    // Test successful initialization with valid parameters for both sexes
    func testInitializationWithValidParameters() {
        do {
            let femaleName = try Name("Remi", sex: .female, affinityRating: 1300)
            XCTAssertNotNil(femaleName)
            XCTAssertEqual(femaleName.text, "Remi")
            XCTAssertEqual(femaleName.sex, .female)
            XCTAssertEqual(femaleName.affinityRating, 1300)
            XCTAssertEqual(femaleName.evaluated, Name.defaultEvaluationCount)
            XCTAssertEqual(femaleName.isFavorite, Name.defaultFavoriteStatus)
            
            let maleName = try Name("Alex", sex: .male, affinityRating: 1300)
            XCTAssertNotNil(maleName)
            XCTAssertEqual(maleName.text, "Alex")
            XCTAssertEqual(maleName.sex, .male)
            XCTAssertEqual(maleName.affinityRating, 1300)
            XCTAssertEqual(maleName.evaluated, Name.defaultEvaluationCount)
            XCTAssertEqual(maleName.isFavorite, Name.defaultFavoriteStatus)
        } catch {
            XCTFail("Initialization failed with valid parameters")
        }
    }
    
    // Test successful initialization with valid capitalization for both sexes.
    func testInitializationWithCapitalization() {
        do {
            let femaleName = try Name("reMi", sex: .female)
            XCTAssertNotNil(femaleName)
            XCTAssertEqual(femaleName.text, "Remi")
            XCTAssertEqual(femaleName.sex, .female)
            
            let maleName = try Name("aLex", sex: .male)
            XCTAssertNotNil(maleName)
            XCTAssertEqual(maleName.text, "Alex")
            XCTAssertEqual(maleName.sex, .male)
        } catch {
            XCTFail("Initialization failed with valid parameters")
        }
    }
    
    // Test successful initialization with default affinity rating for both sexes
    func testInitializationWithDefaultAffinityRating() {
        do {
            let femaleName = try Name("Remi", sex: .female)
            XCTAssertNotNil(femaleName)
            XCTAssertEqual(femaleName.text, "Remi")
            XCTAssertEqual(femaleName.sex, .female)
            XCTAssertEqual(femaleName.affinityRating, Name.defaultAffinityRating)
            XCTAssertEqual(femaleName.evaluated, Name.defaultEvaluationCount)
            XCTAssertEqual(femaleName.isFavorite, Name.defaultFavoriteStatus)
            
            let maleName = try Name("Alex", sex: .male)
            XCTAssertNotNil(maleName)
            XCTAssertEqual(maleName.text, "Alex")
            XCTAssertEqual(maleName.sex, .male)
            XCTAssertEqual(maleName.affinityRating, Name.defaultAffinityRating)
            XCTAssertEqual(maleName.evaluated, Name.defaultEvaluationCount)
            XCTAssertEqual(maleName.isFavorite, Name.defaultFavoriteStatus)
        } catch {
            XCTFail("Initialization failed with default affinity rating")
        }
    }
    
    // Test initialization failure with empty text for both sexes
    func testInitializationWithEmptyText() {
        XCTAssertThrowsError(try Name("", sex: .female)) { error in
            XCTAssertEqual(error as? Name.NameError, Name.NameError.nameIsEmpty)
        }
        XCTAssertThrowsError(try Name("", sex: .male)) { error in
            XCTAssertEqual(error as? Name.NameError, Name.NameError.nameIsEmpty)
        }
    }
    
    // Test initialization failure with negative affinity rating for both sexes
    func testInitializationWithNegativeAffinityRating() {
        XCTAssertThrowsError(try Name("Remi", sex: .female, affinityRating: -1)) { error in
            print(error.localizedDescription)
            XCTAssertEqual(error as? Name.NameError, Name.NameError.ratingBelowMinimum(Name.minimumAffinityRating))
        }
        XCTAssertThrowsError(try Name("Alex", sex: .male, affinityRating: -1)) { error in
            XCTAssertEqual(error as? Name.NameError, Name.NameError.ratingBelowMinimum(Name.minimumAffinityRating))
        }
    }
    
    
    // MARK: - Attribute Update Tests
    
    // Test increasing the evaluation count for both sexes
    func testIncreaseEvaluationCount() {
        do {
            let femaleName = try Name("Remi", sex: .female)
            XCTAssertNotNil(femaleName)
            femaleName.increaseEvaluationCount()
            XCTAssertEqual(femaleName.evaluated, 1)
            
            let maleName = try Name("Alex", sex: .male)
            XCTAssertNotNil(maleName)
            maleName.increaseEvaluationCount()
            XCTAssertEqual(maleName.evaluated, 1)
        } catch {
            XCTFail("Initialization failed")
        }
    }
    
    // Test setting the affinity rating for both sexes
    func testSetAffinity() {
        do {
            let femaleName = try Name("Remi", sex: .female)
            XCTAssertNotNil(femaleName)
            try femaleName.setAffinity(1500)
            XCTAssertEqual(femaleName.affinityRating, 1500)
            
            let maleName = try Name("Alex", sex: .male)
            XCTAssertNotNil(maleName)
            try maleName.setAffinity(1500)
            XCTAssertEqual(maleName.affinityRating, 1500)
        } catch {
            XCTFail("Initialization or setting affinity failed")
        }
    }
    
    // Test setting the affinity rating to a negative value for both sexes
    func testSetNegativeAffinity() {
        do {
            let femaleName = try Name("Remi", sex: .female)
            XCTAssertNotNil(femaleName)
            XCTAssertThrowsError(try femaleName.setAffinity(-1)) { error in
                XCTAssertEqual(error as? Name.NameError, Name.NameError.ratingBelowMinimum(Name.minimumAffinityRating))
            }
            
            let maleName = try Name("Alex", sex: .male)
            XCTAssertNotNil(maleName)
            XCTAssertThrowsError(try maleName.setAffinity(-1)) { error in
                XCTAssertEqual(error as? Name.NameError, Name.NameError.ratingBelowMinimum(Name.minimumAffinityRating))
            }
        } catch {
            XCTFail("Initialization failed")
        }
    }
    
    // Test toggling the favorite status for both sexes
    func testToggleFavorite() {
        do {
            let femaleName = try Name("Remi", sex: .female)
            XCTAssertNotNil(femaleName)
            femaleName.toggleFavorite()
            XCTAssertEqual(femaleName.isFavorite, true)
            femaleName.toggleFavorite()
            XCTAssertEqual(femaleName.isFavorite, false)
            
            let maleName = try Name("Alex", sex: .male)
            XCTAssertNotNil(maleName)
            maleName.toggleFavorite()
            XCTAssertEqual(maleName.isFavorite, true)
            maleName.toggleFavorite()
            XCTAssertEqual(maleName.isFavorite, false)
        } catch {
            XCTFail("Initialization failed")
        }
    }
    
    // Test resetting values to default for both sexes
    func testResetValues() {
        do {
            let femaleName = try Name("Remi", sex: .female)
            XCTAssertNotNil(femaleName)
            try femaleName.setAffinity(1500)
            femaleName.increaseEvaluationCount()
            femaleName.toggleFavorite()
            femaleName.resetValues()
            XCTAssertEqual(femaleName.affinityRating, Name.defaultAffinityRating)
            XCTAssertEqual(femaleName.evaluated, Name.defaultEvaluationCount)
            XCTAssertEqual(femaleName.isFavorite, Name.defaultFavoriteStatus)
            
            let maleName = try Name("Alex", sex: .male)
            XCTAssertNotNil(maleName)
            try maleName.setAffinity(1500)
            maleName.increaseEvaluationCount()
            maleName.toggleFavorite()
            maleName.resetValues()
            XCTAssertEqual(maleName.affinityRating, Name.defaultAffinityRating)
            XCTAssertEqual(maleName.evaluated, Name.defaultEvaluationCount)
            XCTAssertEqual(maleName.isFavorite, Name.defaultFavoriteStatus)
        } catch {
            XCTFail("Initialization or resetting values failed")
        }
    }
    
    // Test setting the affinity rating to the minimum allowed value for both sexes
    func testSetMinimumAffinity() {
        do {
            let femaleName = try Name("Remi", sex: .female)
            XCTAssertNotNil(femaleName)
            try femaleName.setAffinity(Name.minimumAffinityRating)
            XCTAssertEqual(femaleName.affinityRating, Name.minimumAffinityRating)
            
            let maleName = try Name("Alex", sex: .male)
            XCTAssertNotNil(maleName)
            try maleName.setAffinity(Name.minimumAffinityRating)
            XCTAssertEqual(maleName.affinityRating, Name.minimumAffinityRating)
        } catch {
            XCTFail("Initialization or setting minimum affinity failed")
        }
    }
    
    // Test setting the affinity rating to a very high value for both sexes
    func testSetHighAffinity() {
        let highAffinityRating = Int.max
        do {
            let femaleName = try Name("Remi", sex: .female)
            XCTAssertNotNil(femaleName)
            try femaleName.setAffinity(highAffinityRating)
            XCTAssertEqual(femaleName.affinityRating, highAffinityRating)
            
            let maleName = try Name("Alex", sex: .male)
            XCTAssertNotNil(maleName)
            try maleName.setAffinity(highAffinityRating)
            XCTAssertEqual(maleName.affinityRating, highAffinityRating)
        } catch {
            XCTFail("Initialization or setting high affinity failed")
        }
    }
    
    // Test maximum affinity rating for both sexes
    func testMaxAffinityRating() {
        let maxAffinityRating = Int.max
        do {
            let femaleName = try Name("Remi", sex: .female, affinityRating: maxAffinityRating)
            XCTAssertEqual(femaleName.affinityRating, maxAffinityRating)
            
            let maleName = try Name("Alex", sex: .male, affinityRating: maxAffinityRating)
            XCTAssertEqual(maleName.affinityRating, maxAffinityRating)
        } catch {
            XCTFail("Initialization failed with maximum affinity rating")
        }
    }
    
    
    // Test initialization with invalid characters in name text for both sexes
    func testInitializationWithInvalidCharacters_Numbers() {
        let invalidCharacters = "1234"
        let allowedSpecialCharacters = Name.allowedSpecialCharacters.description
        
        XCTAssertThrowsError(try Name(invalidCharacters, sex: .female)) { error in
            XCTAssertEqual(error as? Name.NameError, Name.NameError.invalidCharactersInName(allowedSpecialCharacters))
        }
        XCTAssertThrowsError(try Name(invalidCharacters, sex: .male)) { error in
            XCTAssertEqual(error as? Name.NameError, Name.NameError.invalidCharactersInName(allowedSpecialCharacters))
        }
    }
    
    // Test initialization with invalid characters in name text for both sexes
    func testInitializationWithInvalidCharacters_Symbols() {
        let invalidCharacters = CharacterSet.symbols.description
        let allowedSpecialCharacters = Name.allowedSpecialCharacters.description
        
        XCTAssertThrowsError(try Name(invalidCharacters, sex: .female)) { error in
            XCTAssertEqual(error as? Name.NameError, Name.NameError.invalidCharactersInName(allowedSpecialCharacters))
        }
        XCTAssertThrowsError(try Name(invalidCharacters, sex: .male)) { error in
            XCTAssertEqual(error as? Name.NameError, Name.NameError.invalidCharactersInName(allowedSpecialCharacters))
        }
    }
    
    // Test initialization with invalid characters in name text for both sexes
    func testInitializationWithInvalidCharacters_Newlines() {
        let invalidCharacters = CharacterSet.newlines.description
        let allowedSpecialCharacters = Name.allowedSpecialCharacters.description
        
        XCTAssertThrowsError(try Name(invalidCharacters, sex: .female)) { error in
            XCTAssertEqual(error as? Name.NameError, Name.NameError.invalidCharactersInName(allowedSpecialCharacters))
        }
        XCTAssertThrowsError(try Name(invalidCharacters, sex: .male)) { error in
            XCTAssertEqual(error as? Name.NameError, Name.NameError.invalidCharactersInName(allowedSpecialCharacters))
        }
    }
    
    // Test initialization with invalid characters in name text for both sexes
    func testInitializationWithWhitespaces() {
        let nameWithWhitespace = "Mi ke B"  /// While odd, test for multiple whitespaces for allowed names.
        
        /// THIS IS A PASS. Allow the space.
        XCTAssertNoThrow(try Name(nameWithWhitespace, sex: .female))
        XCTAssertNoThrow(try Name(nameWithWhitespace, sex: .male))
    }
}
