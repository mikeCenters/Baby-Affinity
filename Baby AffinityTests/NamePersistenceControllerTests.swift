//
//  NamePersistenceControllerTests.swift
//  Baby AffinityTests
//
//  Created by Mike Centers on 8/13/24.
//

import XCTest
import SwiftData
@testable import Baby_Affinity

final class NamePersistenceControllerTests: XCTestCase, NamePersistenceController_Admin {
    
    private var context: ModelContext!
    
    @MainActor
    override func setUp() {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Name.self, configurations: config)
            context = container.mainContext
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    override func tearDown() {
        let fetchDescriptor = FetchDescriptor<Name>()
        let allNames = try? context.fetch(fetchDescriptor)
        allNames?.forEach { context.delete($0) }
        try? context.save()
    }
    
    
    // MARK: - Persistence Integrity
    
    func testAppStartsEmptyPersistence() throws {
        let names = try fetchNames(context: context)
        
        XCTAssertTrue(names.isEmpty, "Persistence should have no Name objects.")
    }
    
    
    // MARK: - Default Data
    
    func testDefaultNamesData_Girls() throws {
        let girlNames = getDefaultNames(.female)
        
        girlNames.forEach { XCTAssertEqual($0.sex, Sex.female) }
        XCTAssertEqual(girlNames.count, DefaultBabyNames().girlNames.count, "Not all girl names were added.")
    }
    
    func testDefaultNamesData_Boys() throws {
        let boyNames = getDefaultNames(.male)
        
        boyNames.forEach { XCTAssertEqual($0.sex, Sex.male) }
        XCTAssertEqual(boyNames.count, DefaultBabyNames().boyNames.count, "Not all boy names were added.")
    }
    
    func testDefaultNamesData_All() throws {
        let nameData = DefaultBabyNames()
        let totalCount = nameData.boyNames.count + nameData.girlNames.count
        let allNames = getDefaultNames()
        
        XCTAssertEqual(allNames.count, totalCount, "Not all names were added.")
    }
    
    func testLoadDefaultNames() {
        let nameData = DefaultBabyNames()
        let totalNamesCount = nameData.girlNames.count + nameData.boyNames.count
        
        do {
            try loadDefaultNames(into: self.context)
            let names = try fetchNames(context: self.context)
            
            XCTAssertEqual(names.count, totalNamesCount, "Not all names are in persistence.")
            
        } catch {
            XCTFail("Unable to fetch names. Error: \(error)")
        }
    }
    
    func testLoadDefaultNames_Raw() {
        let nameData = DefaultBabyNames()
        let totalNamesCount = nameData.girlNames.count + nameData.boyNames.count
        
        /// Add girl names.
        for (_, name) in nameData.girlNames {
            let n = try! Name(name, sex: .female)!
            context.insert(n)
        }
        
        /// Add boy names.
        for (_, name) in nameData.boyNames {
            let n = try! Name(name, sex: .male)!
            context.insert(n)
        }
        
        do {
            let names = try fetchNames(context: context)
            
            XCTAssertEqual(names.count, totalNamesCount, "Not all names are in persistence.")
            
        } catch {
            XCTFail("Unable to fetch names. Error: \(error)")
        }
    }
    
    
    // MARK: - Create
    func testCreateName() throws {
        let name = try createName("Mike", sex: .male)
        XCTAssertNotNil(name, "Name should have been created with default values.")
    }
    
    func testCreateName_NilOnBelowMinimumAffinityRating() {
        let name = try? createName("Mike", sex: .male, affinityRating: -1)
        XCTAssertNil(name, "Name should not be created with a rating below the minimum.")
    }
    
    func testCreateName_NilOnEmptyString() {
        let name = try? createName("", sex: .male)
        XCTAssertNil(name, "Name should not be created with an empty string.")
    }
    
    // MARK: - Insert
    
    func testInsertName() throws {
        guard let name = try createName("Mike", sex: .male) else {
            XCTFail("Unable to create a new Name.")
            return
        }
        
        try insert(name, context: context)
        let fetchedName = try fetchName(byText: "Mike", sex: .male, context: context)
        
        XCTAssertEqual(fetchedName?.text, "Mike", "The inserted name text should be 'Mike'.")
    }
    
    func testInsertNames() throws {
        var names: [Name] = []
        (0..<10).forEach {
            guard let name = try? createName("Name \($0 + 1)", sex: .male) else {
                XCTFail("Unable to create a new Name.")
                return
            }
            names.append(name)
        }
        
        try insert(names, context: context)
        let fetchedNames = try fetchNames(context: context)
        
        XCTAssertEqual(names.count, fetchedNames.count, "Not all names were inserted.")
        for name in names {
            XCTAssertTrue(fetchedNames.contains(name), "\(name.text) was not inserted.")
        }
    }
    
    func testInsertName_ThrowsDuplicateNameInserted() throws {
        guard let maleName = try createName("Mike", sex: .male),
              let femaleName = try createName("Mike", sex: .female)
        else {
            XCTFail("Unable to create a new Name.")
            return
        }
        
        XCTAssertNoThrow(try insert(maleName, context: context), "Should be able to insert Name.")
        XCTAssertNoThrow(try insert(femaleName, context: context), "Should be able to insert Name.")
        XCTAssertThrowsError(try insert(maleName, context: context), "Should be not be able to insert Name.")
        XCTAssertThrowsError(try insert(femaleName, context: context), "Should be not be able to insert Name.")
    }
    
    
    // MARK: - Fetch
    
    func testFetchNames_ByText() throws {
        guard let maleName = try Name("Mike", sex: .male),
              let femaleName = try Name("Mike", sex: .female)
        else {
            XCTFail("Unable to create a Name.")
            return
        }
        
        XCTAssertTrue(try fetchNames(context: context).isEmpty, "No names should be inserted")
        XCTAssertNoThrow(try insert(maleName, context: context), "Should be able to insert name.")
        XCTAssertNoThrow(try insert(femaleName, context: context), "Should be able to insert name.")
        
        guard let maleFetch = try fetchName(byText: maleName.text, sex: .male, context: context),
              let femaleFetch = try fetchName(byText: femaleName.text, sex: .female, context: context)
        else {
            XCTFail("Unable to fetch inserted names.")
            return
        }
        
        XCTAssertEqual(maleName, maleFetch, "Male names should be the same.")
        XCTAssertEqual(femaleName, femaleFetch, "Female names should be the same.")
    }
    
    func testFetchNames_BySex() throws {
        guard let maleName = try createName("Mike", sex: .male),
              let femaleName = try createName("Lily", sex: .female)
        else {
            XCTFail("Unable to create a new Name.")
            return
        }
        
        try insert(maleName, context: context)
        try insert(femaleName, context: context)

        let fetchedMaleNames = try fetchNames(.male, context: context)
        XCTAssertEqual(fetchedMaleNames.count, 1, "One Name is not fetched.")
        XCTAssertEqual(fetchedMaleNames.first?.text, "Mike")

        let fetchedFemaleNames = try fetchNames(.female, context: context)
        XCTAssertEqual(fetchedFemaleNames.count, 1, "One Name is not fetched.")
        XCTAssertEqual(fetchedFemaleNames.first?.text, "Lily")
    }
    
    func testFetchNames_ByEvaluatedCount() throws {
        guard let name = try Name("Mike", sex: .male) else {
            XCTFail("Unable to create a new Name.")
            return
        }
        
        try insert(name, context: context)
        
        let fetchedNames = try fetchNames(evaluatedCount: 0, context: context)
        XCTAssertEqual(fetchedNames.count, 1, "One Name is not fetched.")
        XCTAssertEqual(fetchedNames.first?.text, "Mike", "Unable to fetch the Name.")
    }
    
    func testFetchName_ByText() throws {
        guard let name = try Name("Mike", sex: .male) else {
            XCTFail("Unable to create a new Name.")
            return
        }
        
        try insert(name, context: context)

        let fetchedName = try fetchName(byText: "Mike", sex: .male, context: context)
        XCTAssertEqual(fetchedName?.text, "Mike", "Unable to find the Name by its text.")
    }

    func testFetchFavoriteNames() throws {
        var names: [Name] = []
        /// Create 10 favorite male names.
        (0..<10).forEach {
            guard let name = try? createName("Male Favorite Name \($0 + 1)", sex: .male) else {
                XCTFail("Unable to create a new Name.")
                return
            }
            name.toggleFavorite()
            names.append(name)
        }
        
        /// Create 10 non-favorite male names.
        (0..<10).forEach {
            guard let name = try? createName("Male Non-Favorite Name \($0 + 1)", sex: .male) else {
                XCTFail("Unable to create a new Name.")
                return
            }
            names.append(name)
        }
        
        /// Create 10 favorite female names.
        (0..<10).forEach {
            guard let name = try? createName("Female Favorite Name \($0 + 1)", sex: .female) else {
                XCTFail("Unable to create a new Name.")
                return
            }
            name.toggleFavorite()
            names.append(name)
        }
        
        /// Create 10 non-favorite female names.
        (0..<10).forEach {
            guard let name = try? createName("Female Non-Favorite Name \($0 + 1)", sex: .female) else {
                XCTFail("Unable to create a new Name.")
                return
            }
            names.append(name)
        }
        
        try insert(names, context: context)

        let maleFavoriteNames = try fetchFavoriteNames(sex: .male, context: context)
        XCTAssertEqual(maleFavoriteNames.count, 10, "Only 10 favorite male names should exist.")
        
        let femaleFavoriteNames = try fetchFavoriteNames(sex: .female, context: context)
        XCTAssertEqual(femaleFavoriteNames.count, 10, "Only 10 favorite male names should exist.")
    }
    
    
    // MARK: - Delete
    
    // FIXME: Wont work for some reason.
//    func testDeleteSingleName() throws {
//        guard let name = try Name("Mike", sex: .male) else {
//            XCTFail("Unable to create a new Name.")
//            return
//        }
//        
//        // Insert the name.
//        try insert(name, context: context)
//        guard let fetchedName = try fetchName(byText: "Mike", sex: .male, context: context) else {
//            XCTFail("Name is not inserted.")
//            return
//        }
//        
//        // Delete the inserted name.
//        try delete(fetchedName, context: context)
//        
//        let nilName = try fetchName(byText: "Mike", sex: .male, context: context)
//        XCTAssertNil(nilName, "Name is not deleted.")
//    }
    
    func testDeleteMultipleNames() throws {
        var names: [Name] = []
        (0..<10).forEach {
            guard let name = try? createName("Name \($0 + 1)", sex: .male) else {
                XCTFail("Unable to create a new Name.")
                return
            }
            names.append(name)
        }
        
        try insert(names, context: context)
        let fetchedNames = try fetchNames(context: context)
        XCTAssertEqual(fetchedNames.count, names.count, "10 names should be in the context.")
        
        delete(fetchedNames, context: context)
        
        let emptyNames = try fetchNames(context: context)
        XCTAssertTrue(emptyNames.isEmpty, "The names should be deleted from the context")
    }
    
    // MARK: - Methods

    func testGetRank() throws {
        guard let name1 = try Name("Lily", sex: .female, affinityRating: 1500),
              let name2 = try Name("Amara", sex: .female, affinityRating: 1600),
              let name3 = try Name("Hadley", sex: .female, affinityRating: 1400)
        else {
            return
        }
        
        let names = [name1, name2, name3]
        try insert(names, context: context)
        
        for name in names {
            let rank = try getRank(of: name, from: context)
            
            switch name.text {
            case "Lily":
                XCTAssertEqual(rank, 2, "Names are not ranked properly.")
                
            case "Amara":
                XCTAssertEqual(rank, 1, "Names are not ranked properly.")
                
            case "Hadley":
                XCTAssertEqual(rank, 3, "Names are not ranked properly.")
                
            default:
                XCTFail("Unknown name is inserted.")
            }
        }
    }
}
