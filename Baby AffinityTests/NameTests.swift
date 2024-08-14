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
    
    /// Tests successful initialization of a `Name` instance.
    /// - Throws: An error if the initialization fails.
    func testInitialization_Success() throws {
        let name = try Name("Mike", sex: .male)
        XCTAssertNotNil(name, "Name should be initialized successfully.")
        XCTAssertEqual(name?.text, "Mike", "Name text should be 'Mike'.")
        XCTAssertEqual(name?.sex, .male, "Name sex should be .male.")
        XCTAssertEqual(name?.affinityRating, Name.defaultAffinityRating, "Affinity rating should match the default value.")
        XCTAssertEqual(name?.evaluated, Name.defaultEvaluationCount, "Evaluation count should match the default value.")
        XCTAssertEqual(name?.isFavorite, Name.defaultFavoriteStatus, "Favorite status should match the default value.")
    }
    
    /// Tests that initialization fails when the provided name text is empty.
    func testInitialization_Failure_EmptyText() {
        XCTAssertThrowsError(try Name("", sex: .male)) { error in
            XCTAssertEqual(error as? Name.NameError, .nameIsEmpty, "Error should be nameIsEmpty.")
        }
    }
    
    /// Tests that initialization fails when the provided affinity rating is negative.
    func testInitialization_Failure_NegativeAffinityRating() {
        XCTAssertThrowsError(try Name("Mike", sex: .male, affinityRating: -1)) { error in
            XCTAssertEqual(error as? Name.NameError, .ratingBelowMinimum(Name.minimumAffinityRating), "Error should be ratingBelowMinimum with the minimum rating.")
        }
    }
    
    
    // MARK: - Attribute Update Tests
    
    /// Tests successful updating of the affinity rating for a `Name` instance.
    /// - Throws: An error if updating the affinity rating fails.
    func testSetAffinity_Success() throws {
        let name = try Name("Mike", sex: .male)
        try name?.setAffinity(1500)
        XCTAssertEqual(name?.affinityRating, 1500, "Affinity rating should be updated to 1500.")
    }
    
    /// Tests that updating the affinity rating fails when the new rating is negative.
    /// - Throws: An error if updating the affinity rating fails.
    func testSetAffinity_Failure_NegativeRating() throws {
        let name = try Name("Mike", sex: .male)
        XCTAssertThrowsError(try name?.setAffinity(-1)) { error in
            XCTAssertEqual(error as? Name.NameError, .ratingBelowMinimum(Name.minimumAffinityRating), "Error should be ratingBelowMinimum with the minimum rating.")
        }
    }
    
    /// Tests that the evaluation count increases correctly when the method is called.
    /// - Throws: An error if the name initialization fails.
    func testIncreaseEvaluationCount() throws {
        let name = try Name("Mike", sex: .male)
        name?.increaseEvaluationCount()
        XCTAssertEqual(name?.evaluated, 1, "Evaluation count should be incremented to 1.")
    }
    
    /// Tests the toggling of the favorite status for a `Name` instance.
    /// - Throws: An error if the name initialization fails.
    func testToggleFavorite() throws {
        let name = try Name("Mike", sex: .male)!
        name.toggleFavorite()
        XCTAssertTrue(name.isFavorite, "Favorite status should be true after toggling once.")
        name.toggleFavorite()
        XCTAssertFalse(name.isFavorite, "Favorite status should be false after toggling twice.")
    }
}
