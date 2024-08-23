import XCTest
import SwiftData
@testable import Baby_Affinity

final class NamePersistenceControllerTests: XCTestCase, NamePersistenceController_Admin {
    
    // MARK: - Properties
    
    var modelContext: ModelContext {
        ModelContext(container)
    }
    
    var container: ModelContainer = {       // In Memory
        let schema = Schema([
            Name.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    
    // MARK: - Persistence Integrity
    
    func testAppStartsEmptyPersistence() throws {
        let context = modelContext
        let fetchedNames = try fetchNames()
        
        XCTAssertTrue(fetchedNames.isEmpty, "Persistence should have no Name objects.")
    }
    
    
    // MARK: - Create
    
    func testCreateName_Success() {
        switch createName("Mike", sex: .male) {
        case .success(let name):
            XCTAssertEqual(name.text, "Mike", "Texts should be the same.")
            XCTAssertEqual(name.sex, .male, "Sexes should be the same.")
            
        case .failure(_):
            XCTFail("Unique name should be successful.")
        }
        
        switch createName("Hadley", sex: .female) {
        case .success(let name):
            XCTAssertEqual(name.text, "Hadley", "The text labels should be the same.")
            XCTAssertEqual(name.sex, .female, "The sex properties should be the same.")
            
        case .failure(_):
            XCTFail("Unique name should be successful.")
        }
    }
    
    func testCreateName_Failure_NameIsEmpty() {
        for sex in Sex.allCases {
            switch createName("", sex: sex) {
            case .success(_):
                XCTFail("Name should not be created with an empty string.")
                
            case .failure(let error):
                XCTAssertEqual(error, Name.NameError.nameIsEmpty, "Error should indicate an empty string: \(error.localizedDescription)")
            }
        }
    }
    
    func testCreateName_Failure_RatingBelowMinimum() {
        let rating = -1
        XCTAssertLessThan(rating, Name.minimumAffinityRating, "The rating is not low enough.")
        
        for sex in Sex.allCases {
            switch createName("Remi", sex: sex, affinityRating: rating) {
            case .success(_):
                XCTFail("Name should not be created with a rating below the minimum.")
                
            case .failure(let error):
                XCTAssertEqual(error, Name.NameError.ratingBelowMinimum(Name.minimumAffinityRating), "Error should indicate the rating is below the minimum rating: \(error.localizedDescription)")
            }
        }
    }
    
    func testCreateName_Failure_InvalidCharactersInName() {
        for sex in Sex.allCases {
            switch createName("*Remi*", sex: sex) {
            case .success(_):
                XCTFail("Name should not be created with special characters.")
                
            case .failure(let error):
                XCTAssertEqual(error, Name.NameError.invalidCharactersInName(Name.allowedSpecialCharacters.description), "Error should indicate that unacceptable characters were provided: \(error.localizedDescription)")
            }
        }
    }
    
    func testCreateName_Success_ValidSpecialCharactersInName() {
        for sex in Sex.allCases {
            switch createName("Remi 'Ton", sex: sex) {
            case .success(_): continue
                
            case .failure(let error):
                XCTFail("The name should allow spaces and apostrophes: \(error.localizedDescription)")
            }
        }
    }
    
    func testCreateName_RemovesWhitespaces() {
        // MARK: - FIXME: " Mike  Centers   " becomes "Mike Centers"
    }
    
    
        // MARK: - Fetch
    
    func testFetchNames_All() {
        var names: [Name] = []
        for _ in 0..<5 {
            let name = "Name ".appending(String(generateRandomLetters(count: 5)))
            
            for sex in Sex.allCases {
                switch createName(name, sex: sex) {
                case .success(let name): names.append(name)
                case .failure(let error):
                    XCTFail("Unique name should be created: \(error.localizedDescription)")
                }
            }
        }
        
        _ = insert(names)
        
        guard let fetchedNames = try? fetchNames()
        else { XCTFail("Unable to fetch names."); return }
        
        XCTAssertEqual(fetchedNames.count, names.count, "All names should be fetched successfully.")
    }
    
    func testFetchNames_BySex() {
        let count = 5
        var names: [Name] = []
        for _ in 0..<count {
            let name = "Name ".appending(String(generateRandomLetters(count: 5)))
            
            for sex in Sex.allCases {
                switch createName(name, sex: sex) {
                case .success(let name): names.append(name)
                case .failure(let error):
                    XCTFail("Unique name should be created: \(error.localizedDescription)")
                }
            }
        }
        
        _ =  insert(names)
        
        
        for sex in Sex.allCases {
            guard let fetchedNames = try? fetchNames(sex)
            else { XCTFail("Unable to fetch names."); return }
            
            XCTAssertEqual(fetchedNames.count, count, "All \(sex.sexNamingConvention) names are not fetched.")
        }
    }
    
    func testFetchName_ByText() {
        guard let femaleName = try? Name("Lily", sex: .female),
              let maleName = try? Name("Atlas", sex: .male)
        else { XCTFail("Unable to create Names."); return }
        
        let names = [femaleName, maleName]
        _ = insert(names)
        
        for name in names {
            guard let fetchedName = try? fetchName(byText: name.text, sex: name.sex!)
            else { XCTFail("Unable to fetch the name."); return }
            
            XCTAssertEqual(fetchedName.text, name.text, "The fetched name should have the same text.")
            XCTAssertEqual(fetchedName.sex, name.sex, "The fetched name should have the same sex.")
        }
    }
    
    func testFetchName_ByPartialText() {
        // Names to test
        guard let femaleName = try? Name("Lily", sex: .female),
              let maleName = try? Name("Atlas", sex: .male)
        else { XCTFail("Unable to create Names."); return }
        
        let testingNames = [femaleName, maleName]   // Names used for testing.
        var namesToInsert = testingNames            // Names to insert in persistence.
        
        // Add extra names for filtering out.
        for _ in 0..<5 {
            let name = "Name ".appending(String(generateRandomLetters(count: 5)))
            
            for sex in Sex.allCases {
                switch createName(name, sex: sex) {
                case .success(let name): namesToInsert.append(name)
                case .failure(let error):
                    XCTFail("Unique name should be created: \(error.localizedDescription)")
                }
            }
        }
        
        _ = insert(namesToInsert)
        
        for name in testingNames {
            let partial = String(name.text.prefix(2))
            guard let fetchedNames = try? fetchNames(byPartialText: partial, sex: name.sex!)
            else { XCTFail("Unable to fetch the name."); return }
            XCTAssertEqual(fetchedNames.count, 1, "Only 1 name should appear from the provided names.")
            
            guard let fetchedName = fetchedNames.first
            else { XCTFail("One name should be found."); return }
            XCTAssertEqual(fetchedName.text, name.text, "The fetched name should have the same text.")
            XCTAssertEqual(fetchedName.sex, name.sex, "The fetched name should have the same sex.")
        }
    }
    
    func testFetchFavoriteNames() {
        var names: [Name] = []
        
        // Create 10 favorite and non-favorite names for male and females.
        for _ in 0..<10 {
            let random = String(generateRandomLetters(count: 5))
            let favoriteName = "Favorite Name \(random)"
            let nonFavoriteName = "Non-Favorite Name \(random)"
            
            guard let maleFavoriteName = try? Name(favoriteName, sex: .male),
                  let femaleFavoriteName = try? Name(favoriteName, sex: .female),
                  let maleNonFavoriteName = try? Name(nonFavoriteName, sex: .male),
                  let femaleNonFavoriteName = try? Name(nonFavoriteName, sex: .female)
            else { XCTFail("Unable to create new Names."); return }
            
            maleFavoriteName.toggleFavorite()
            femaleFavoriteName.toggleFavorite()
            let allNames = [maleFavoriteName, maleNonFavoriteName,
                         femaleFavoriteName, femaleNonFavoriteName]
            
            names.append(contentsOf: allNames)
        }
        
        _ = insert(names)
        
        guard let maleFavoriteNames = try? fetchFavoriteNames(sex: .male),
              let femaleFavoriteNames = try? fetchFavoriteNames(sex: .female)
        else { XCTFail("Unable to fetch favorite names."); return }
        
        XCTAssertEqual(maleFavoriteNames.count, 10, "Not all favorite male names were fetched.")
        XCTAssertEqual(maleFavoriteNames.first?.isFavorite, true, "The name should be a favorite.")
        XCTAssertEqual(femaleFavoriteNames.count, 10, "Not all favorite female names were fetched.")
        XCTAssertEqual(femaleFavoriteNames.first?.isFavorite, true, "The name should not be a favorite.")
    }
    
    func testFetchNonFavoriteNames() {
        var names: [Name] = []
        
        // Create 10 favorite and non-favorite names for male and females.
        for _ in 0..<10 {
            let random = String(generateRandomLetters(count: 5))
            let favoriteName = "Favorite Name \(random)"
            let nonFavoriteName = "Non-Favorite Name \(random)"
            
            guard let maleFavoriteName = try? Name(favoriteName, sex: .male),
                  let femaleFavoriteName = try? Name(favoriteName, sex: .female),
                  let maleNonFavoriteName = try? Name(nonFavoriteName, sex: .male),
                  let femaleNonFavoriteName = try? Name(nonFavoriteName, sex: .female)
            else { XCTFail("Unable to create new Names."); return }
            
            maleFavoriteName.toggleFavorite()
            femaleFavoriteName.toggleFavorite()
            let allNames = [maleFavoriteName, maleNonFavoriteName,
                         femaleFavoriteName, femaleNonFavoriteName]
            
            names.append(contentsOf: allNames)
        }
        
        _ = insert(names)
        
        guard let maleFavoriteNames = try? fetchNonFavoriteNames(sex: .male),
              let femaleFavoriteNames = try? fetchNonFavoriteNames(sex: .female)
        else { XCTFail("Unable to fetch non-favorite names."); return }
        
        XCTAssertEqual(maleFavoriteNames.count, 10, "Not all non-favorite male names were fetched.")
        XCTAssertEqual(maleFavoriteNames.first?.isFavorite, false, "The name should not be a favorite.")
        XCTAssertEqual(femaleFavoriteNames.count, 10, "Not all non-favorite female names were fetched.")
        XCTAssertEqual(femaleFavoriteNames.first?.isFavorite, false, "The name should not be a favorite.")
    }
    
    func testFetchSortedNames_ByAffinity() {
        let lowestRating = 1150
        let highestRating = 1250
        
        var names: [Name] = []
        for rating in lowestRating...highestRating {
            let random = String(generateRandomLetters(count: 5))
            let text = "Name \(random)"
            
            for sex in Sex.allCases {
                guard let name = try? Name(text, sex: sex, affinityRating: rating)
                else { XCTFail("Unable to create unique name."); return }
                
                names.append(name)
            }
        }
        
        _ = insert(names)
        
        for sex in Sex.allCases {
            guard let fetchedNames = try? fetchNamesSortedByAffinity(sex)
            else { XCTFail("Unable to fetch sorted names."); return }
            
            guard let firstName = fetchedNames.first,
                  let lastName = fetchedNames.last
            else { XCTFail("Unable to get the first and last names."); return }
            
            XCTAssertEqual(firstName.affinityRating, highestRating)
            XCTAssertEqual(lastName.affinityRating, lowestRating)
        }
    }
    
    func testFetchNames_ByEvaluatedCount() {
        var names: [Name] = []
        for _ in 0..<10 {
            let random = String(generateRandomLetters(count: 5))
            let text = "Name \(random)"
            
            for sex in Sex.allCases {
                guard let name = try? Name(text, sex: sex)
                else { XCTFail("Unable to create unique name."); return }
                
                names.append(name)
            }
        }
        
        guard let femaleTestName = try? Name("Amara", sex: .female),
              let maleTestName = try? Name("Atlas", sex: .male)
        else { XCTFail("Unable to create unique name."); return }
        
        femaleTestName.increaseEvaluationCount()    // 1
        maleTestName.increaseEvaluationCount()      // 1
        
        names.append(femaleTestName)
        names.append(maleTestName)
        
        _ = insert(names)
        
        for sex in Sex.allCases {
            guard let fetchedNames = try? fetchNames(evaluatedCount: 1, sex: sex)
            else { XCTFail("Unable to fetch names."); return }
            
            XCTAssertEqual(fetchedNames.count, 1, "Only 1 name should be found.")
            
            guard let firstName = fetchedNames.first
            else { XCTFail("Unable to get the first and last names."); return }
            
            switch sex {
            case .female:
                XCTAssertEqual(firstName.text, "Amara")
            case .male:
                XCTAssertEqual(firstName.text, "Atlas")
            }
        }
    }
    
    func testGetRankOfName() {
        let nameToTest = "Hadley"
        let numberOfNames = 10
        let rankInPosition = 3
        let rankOfName = numberOfNames - rankInPosition
        
        var names: [Name] = []
        for num in 1...numberOfNames {
            let random = String(generateRandomLetters(count: 5))
            let text = num == rankInPosition ? nameToTest : "Name \(random)"
            
            for sex in Sex.allCases {
                guard let name = try? Name(text, sex: sex, affinityRating: 1200 + num)
                else { XCTFail("Unable to create unique name."); return }
                
                names.append(name)
            }
        }
        
        _ = insert(names)
        
        for sex in Sex.allCases {
            guard let name = try? fetchName(byText: nameToTest, sex: sex)
            else { XCTFail("Unable to fetch name to test."); return }
            
            guard let rank = try? getRank(of: name)
            else { XCTFail("Unable to get the rank of the name."); return }
            
            XCTAssertEqual(rank, rankOfName, "The rank is not correct.")
        }
    }
    
    
    

//    // MARK: - Default Data
//    
//    func testDuplicateGirlNameData() {
//        let nameData = DefaultBabyNames()
//        var seen = Set<String>()
//        var duplicates = Set<String>()
//        
//        for string in nameData.girlNames {
//            if seen.contains(string) {
//                duplicates.insert(string)
//            } else {
//                seen.insert(string)
//            }
//        }
//        
//        XCTAssertEqual(seen.count, nameData.girlNames.count, "All names should be seen.")
//        XCTAssertTrue(duplicates.isEmpty, "No duplicates should be in the default data.")
//    }
//    
//    func testDuplicateBoyNameData() {
//        let nameData = DefaultBabyNames()
//        var seen = Set<String>()
//        var duplicates = Set<String>()
//        
//        for string in nameData.boyNames {
//            if seen.contains(string) {
//                duplicates.insert(string)
//            } else {
//                seen.insert(string)
//            }
//        }
//        
//        XCTAssertEqual(seen.count, nameData.boyNames.count, "All names should be seen.")
//        XCTAssertTrue(duplicates.isEmpty, "No duplicates should be in the default data.")
//    }
//    
//    func testDefaultNamesData_Girls() {
//        let girlNames = getDefaultNames(.female)
//        
//        girlNames.forEach { XCTAssertEqual($0.sex, Sex.female, "Only girl names should exist in the array.") }
//        XCTAssertEqual(girlNames.count, DefaultBabyNames().girlNames.count, "Not all girl names were created.")
//    }
//    
//    func testDefaultNamesData_Boys() {
//        let boyNames = getDefaultNames(.male)
//        
//        boyNames.forEach { XCTAssertEqual($0.sex, Sex.male, "Only boy names should exist in the array.") }
//        XCTAssertEqual(boyNames.count, DefaultBabyNames().boyNames.count, "Not all boy names were created.")
//    }
//    
//    func testDefaultNamesData_All() {
//        let nameData = DefaultBabyNames()
//        let totalCount = nameData.boyNames.count + nameData.girlNames.count
//        let allNames = getDefaultNames()
//        
//        XCTAssertEqual(allNames.count, totalCount, "Not all names were created.")
//    }
//    
//    // FIXME: - Pause before fetching should resolve the error.
////    func testDefaultNames_AreLoaded() async {
////        await loadDefaultNames(into: context)
////        
////        do {
////            let maleNames = try fetchNames(.male, context: context)
////            let femaleNames = try fetchNames(.female, context: context)
////            
////            maleNames.forEach { XCTAssertEqual($0.sex, .male) }
////            femaleNames.forEach { XCTAssertEqual($0.sex, .female) }
////            
////            XCTAssertEqual(maleNames.count, DefaultBabyNames().boyNames.count, "Not all boy names were inserted into the context.")
////            XCTAssertEqual(femaleNames.count, DefaultBabyNames().girlNames.count, "Not all girl names were inserted into the context.")
////            
////        } catch {
////            XCTFail("Unable to fetch names.")
////        }
////    }
    
    
    // MARK: - Insert
//    
//    func testInsertName_Success() async {
//        let container = Self.container
//        guard let allNames = try? fetchNames(container: container)
//        else { XCTFail("Unable to fetch names."); return }
//        XCTAssertTrue(allNames.isEmpty, "No names should be in persistence.")
//        
//        guard let name = try? Name("James", sex: .male)
//        else { XCTFail("Unable to create a name."); return }
//        
//        let result = insert(name, container: container)
//        
//        switch result {
//        case .success:
//            guard let fetchedName = try? fetchName(byText: name.text, sex: name.sex!, container: container)
//            else { XCTFail("Unable to fetch names"); return }
//            
//            XCTAssertNotNil(fetchedName, "The inserted name should be fetched successfully.")
//            XCTAssertEqual(fetchedName.text, name.text, "The fetched name should have the same text as the inserted name.")
//            XCTAssertEqual(fetchedName.sex, name.sex, "The fetched name should have the same sex as the inserted name.")
//            XCTAssertEqual(fetchedName.sexRawValue, name.sexRawValue, "The fetched name should have the same sexRawValue as the inserted name.")
//            XCTAssertEqual(fetchedName.affinityRating, name.affinityRating, "The fetched name should have the same affinity rating as the inserted name.")
//            XCTAssertEqual(fetchedName.isFavorite, name.isFavorite, "The fetched name should have the same favorite state as the inserted name.")
//            XCTAssertEqual(fetchedName.evaluated, name.evaluated, "The fetched name should have the same evaluated count as the inserted name.")
//            
//        case .failure:
//            XCTFail("Insertion should succeed for unique names.")
//        }
//    }
//    
//    func testInsertNames_Success() async {
//        let container = Self.container
//        var names: [Name] = []
//        for _ in 1...2000 {
//            let random = String(generateRandomLetters(count: 10))
//            let name: String = "Name".appending(random)
//            
//            guard let name = try? Name(name, sex: .female)
//            else { XCTFail("Unable to create a name."); return }
//            
//            names.append(name)
//        }
//        
//        let results = insert(names, container: container)
//        
//        results.forEach {
//            switch $0 {
//            case .success: XCTAssert(true)  // Insertion is successful
//            case .failure:
//                XCTFail("All insertions should be successful for unique names.")
//            }
//        }
//        
//        let insertedNames = try? fetchNames(container: container)
//        XCTAssertEqual(insertedNames?.count, names.count, "All names should be inserted successfully.")
//    }
//    
//    func testInsertName_Failure() {
//        let container = Self.container
//        guard let name = try? Name("Emma", sex: .female)
//        else { XCTFail("Unable to create a name."); return }
//        
//        // Insert once
//        let initialResult = insert(name, container: container)
//        
//        switch initialResult {
//        case .success:
//            // Attempt to insert duplicate after confirming the first insertion succeeded
//            let duplicateResult = insert(name, container: container)
//            
//            switch duplicateResult {
//            case .success:
//                XCTFail("Insertion should fail for duplicate names.")
//                
//            case .failure(let error):
//                switch error {
//                case .duplicateNameInserted(let nameText):
//                    XCTAssertEqual(nameText, name.text, "The error should be about the duplicate name.")
//                    
//                default:
//                    XCTFail("Unexpected error during insertion.")
//                }
//            }
//            
//        case .failure(let error):
//            XCTFail("Initial insertion failed: \(error.localizedDescription)")
//        }
//    }
//    
//    func testInsertNames_Failure() {
//        let container = Self.container
//        guard let name1 = try? Name("Olivia", sex: .female),
//              let name2 = try? Name("Liam", sex: .female),
//              let name3 = try? Name("Olivia", sex: .female)     // Duplicate
//        else { XCTFail("Unable to create Names."); return }
//        
//        let names = [name1, name2, name3]
//        let results = insert(names, container: container)
//        
//        XCTAssertEqual(results.filter { if case .failure = $0 { return true } else { return false } }.count, 1, "One insertion should fail due to duplication.")
//        
//        guard let insertedNames = try? fetchNames(container: container)
//        else { XCTFail("Unable to fetch names"); return }
//        XCTAssertEqual(insertedNames.count, names.count - 1, "Only unique names should be inserted successfully.")
//    }
//    
//
//    // MARK: - Delete
//    
//    func testDeleteAllNames() {
//        let container = Self.container
//        guard let name1 = try? Name("Lily", sex: .female),
//              let name2 = try? Name("Amara", sex: .female),
//              let name3 = try? Name("Hadley", sex: .female),
//              let name4 = try? Name("Mike", sex: .male),
//              let name5 = try? Name("Atlas", sex: .male),
//              let name6 = try? Name("Tital", sex: .male)
//        else { XCTFail("Unable to create Names."); return }
//        
//        let names = [name1, name2, name3, name4, name5, name6]
//        _ = insert(names, container: container)
//        
//        delete(names, container: container)
//        
//        guard let fetchedNames = try? fetchNames(container: container)
//        else { XCTFail("Unable to fetch names."); return }
//        
//        XCTAssertTrue(fetchedNames.isEmpty, "All names should be deleted successfully.")
//    }
//    
//    func testDeleteName() async {
//        guard let name = try? Name("Amara", sex: .female)
//        else { XCTFail("Unable to create a new Name."); return }
//        
//        let container = Self.container
//        
//        switch insert(name, container: container) {
//        case .success:
//            guard let fetchedName = try? fetchName(byText: "Amara", sex: .female, container: container)
//            else { XCTFail("Unable to fetch names."); return }
//            
//            delete(fetchedName, container: container)
//            
//            XCTAssertNil(try? fetchName(byText: "Amara", sex: .female, container: container), "Name should have been deleted.")
//            
//        case .failure(let error):
//            XCTFail("Unable to insert name: \(error.localizedDescription)")
//        }
//        
//        
////        // FIXME: - Remove pause.
//////        try context.save()
////        
//////        let context = self.context
//////        guard let fetchedName = try? self.fetchName(byText: "Amara", sex: .female, context: context!)
//////        else { XCTFail("Unable to fetch names."); return }
//////        
//////        XCTAssertNil(fetchedName, "The name should be deleted successfully.")
//////        
////        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
////            let context = self.context
////            guard let fetchedName = try? self.fetchName(byText: "Amara", sex: .female, context: context!)
////            else { XCTFail("Unable to fetch names."); return }
////            
////            XCTAssertNil(fetchedName, "The name should be deleted successfully.")
////        }
//    }
//    
    
    // MARK: - Helper Functions
    
    private func generateRandomLetter() -> Character {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return letters.randomElement()!
    }
    
    private func generateRandomLetters(count: Int) -> [Character] {
        return (0..<count).map { _ in generateRandomLetter() }
    }
    
    private func saveChanges(in container: ModelContainer) async throws {
        let context = ModelContext(container)
        try context.save()
    }
}
