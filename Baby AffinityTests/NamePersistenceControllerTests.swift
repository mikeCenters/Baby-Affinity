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
            Name.self
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
    
    // MARK: - FIXME: " Mike  Centers   " becomes "Mike Centers"
    //    func testCreateName_RemovesWhitespaces() {
    //    }
    
    
    // MARK: - Fetch
    
    func testFetchNames_All() async {
        /// Add Names into persistent layer
        switch await _insertRandomNamesIntoContext(countPerSex: 100) {
        case .success(let randomNames):
            
            guard let fetchedNames = try? fetchNames()
            else { XCTFail("Unable to fetch names."); return }
            
            XCTAssertEqual(fetchedNames.count, randomNames.count, "All names should be fetched successfully.")
            
        case .failure(let error):
            XCTFail("Unable to insert random Names into the context: \(error)")
        }
    }
    
    func testFetchNames_BySex() async {
        /// Add Names into persistent layer
        switch await _insertRandomNamesIntoContext(countPerSex: 100) {
        case .success(let randomNames):
            
            for sex in Sex.allCases {
                let filteredNames = randomNames.filter { $0.sex == sex }
                
                guard let fetchedNames = try? fetchNames(sex)
                else { XCTFail("Unable to fetch names."); return }
                
                XCTAssertEqual(filteredNames.count, fetchedNames.count, "All names should be fetched successfully.")
            }
            
        case .failure(let error):
            XCTFail("Unable to insert random Names into the context: \(error)")
        }
    }
    
    func testFetchName_ByText() async {
        /// Add Names into persistent layer
        switch await _insertRandomNamesIntoContext(countPerSex: 100) {
        case .success(let randomNames):
            
            for sex in Sex.allCases {
                
                switch createName("Name", sex: sex) {
                case .success(let name):
                    
                    _ = await insert(name)              // Insert unique name
                    
                    guard let fetchedName = try? fetchName(byText: "Name", sex: sex)
                    else { XCTFail("Unable to fetch name."); return }
                    
                    XCTAssertEqual(fetchedName.text, name.text, "Names should have the same text.")
                    XCTAssertEqual(fetchedName.sex, name.sex, "Names should be of the same sex.")
                    
                    
                    
                case .failure(let error):
                    XCTFail("Unable to create a unique name: \(error)")
                }
            }
            
        case .failure(let error):
            XCTFail("Unable to insert random Names into the context: \(error)")
        }
    }
    
    func testFetchName_ByPartialText() async {
        /// Add Names into persistent layer
        switch await _insertRandomNamesIntoContext(countPerSex: 100) {
        case .success(let randomNames):
            
            for sex in Sex.allCases {
                
                switch createName("Hadley", sex: sex) {
                case .success(let name):
                    
                    _ = await insert(name)              // Insert unique name
                    
                    guard let fetchedNames = try? fetchNames(byPartialText: "Ha", sex: sex)
                    else { XCTFail("Unable to fetch names."); return }
                    
                    XCTAssertFalse(fetchedNames.isEmpty, "At least one name should be fetched.")
                    XCTAssert(fetchedNames.contains { $0.text == "Hadley" }, "The name should be found.")
                    
                case .failure(let error):
                    XCTFail("Unable to create a unique name: \(error)")
                }
            }
            
        case .failure(let error):
            XCTFail("Unable to insert random Names into the context: \(error)")
        }
    }
    
    func testFetchFavoriteNames() async {
        /// Add Names into persistent layer
        switch await _insertRandomFavoriteNamesIntoContext(10) {
        case .success(_):
            
            for sex in Sex.allCases {
                guard let favoriteNames = try? self.fetchFavoriteNames(sex: sex)
                else { XCTFail("Unable to fetch favorite names."); return }
                
                XCTAssertEqual(favoriteNames.count, 10, "Not all favorite \(sex.sexNamingConvention) names were fetched.")
                XCTAssertEqual(favoriteNames.first?.isFavorite, true, "The \(sex.sexNamingConvention) name should be a favorite.")
            }
            
        case .failure(let error):
            XCTFail("Unable to create and insert random favorite names: \(error)")
        }
    }
    
    func testFetchNonFavoriteNames() async {
        /// Add Names into persistent layer
        switch await _insertRandomFavoriteNamesIntoContext(10) {
        case .success(_):
            
            for sex in Sex.allCases {
                guard let nonFavoriteNames = try? self.fetchNonFavoriteNames(sex: sex)
                else { XCTFail("Unable to fetch favorite names."); return }
                
                XCTAssertEqual(nonFavoriteNames.count, 10, "Not all favorite \(sex.sexNamingConvention) names were fetched.")
                XCTAssertEqual(nonFavoriteNames.first?.isFavorite, false, "The \(sex.sexNamingConvention) name should be a favorite.")
            }
            
        case .failure(let error):
            XCTFail("Unable to create and insert random favorite names: \(error)")
        }
    }
    
    func testFetchSortedNames_ByAffinity() async {
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
        
        _ = await insert(names)
        
        for sex in Sex.allCases {
            guard let fetchedNames = try? self.fetchNamesSortedByAffinity(sex)
            else { XCTFail("Unable to fetch sorted names."); return }
            
            guard let firstName = fetchedNames.first,
                  let lastName = fetchedNames.last
            else { XCTFail("Unable to get the first and last names."); return }
            
            XCTAssertEqual(firstName.affinityRating, highestRating)
            XCTAssertEqual(lastName.affinityRating, lowestRating)
        }
    }
    
    func testFetchNames_ByEvaluatedCount() async {
        /// Add Names into persistent layer
        switch await _insertRandomNamesIntoContext(countPerSex: 100) {
        case .success(let names):
            
            for sex in Sex.allCases {
                guard let testName = try? Name("Test Name", sex: sex)
                else { XCTFail("Unable to create unique name."); return }
                
                testName.increaseEvaluationCount()          // 1
                _ = await insert(testName)
            }
            
            
            for sex in Sex.allCases {
                guard let fetchedNames = try? self.fetchNames(evaluatedCount: 1, sex: sex),
                      let firstName = fetchedNames.first
                else { XCTFail("Unable to fetch names."); return }
                
                XCTAssertEqual(fetchedNames.count, 1, "Only 1 name should be found.")
                XCTAssertEqual(firstName.text, "Test Name", "Test Name should be the only entry.")
                XCTAssertEqual(firstName.evaluated, 1, "Evaluation should be set to `1`.")
            }
            
        case .failure(let error):
            XCTFail("Unable to create and insert random names: \(error.localizedDescription)")
        }
    }
    
    func testGetRankOfName() async {
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
        
        _ = await insert(names)
        
        for sex in Sex.allCases {
            guard let name = try? self.fetchName(byText: nameToTest, sex: sex)
            else { XCTFail("Unable to fetch name to test."); return }
            
            guard let rank = try? self.getRank(of: name)
            else { XCTFail("Unable to get the rank of the name."); return }
            
            XCTAssertEqual(rank, rankOfName, "The rank is not correct.")
        }
    }
    
    
     // MARK: - Insert

    func testInsertName_Success() async {
        for sex in Sex.allCases {
            let nameResult = createName("Test Name", sex: sex)
            
            switch nameResult {
            case .success(let name):
                
                switch await insert(name) {
                case .success: continue
                case .failure(let error):
                    XCTFail("Unable to insert a unique name: \(error.localizedDescription)")
                }
                
            case .failure(let error):
                XCTFail("Unable to create a unique name: \(error.localizedDescription)")
            }
        }
        
        for sex in Sex.allCases {
            guard let fetchedName = try? self.fetchName(byText: "Test Name", sex: sex)
            else { XCTFail("Unable to fetch name to test."); return }
            
            XCTAssertEqual(fetchedName.text, "Test Name", "The names should be the same.")
            XCTAssertEqual(fetchedName.sex, sex, "The names should be of the same sex.")
        }
    }
    
    func testInsertNames_Success() async {
        let totalNames = 200
        /// Create Names to add to persistent layer
        switch await _createRandomNames(countPerSex: totalNames / 2) {
        case .success(let names):
            
            let results = await insert(names)
            
            for result in results {
                switch result {
                case .success: continue
                case .failure(let error):
                    XCTFail("Unable to insert name: \(error.localizedDescription)")
                }
            }
            
            let insertedNames = try? self.fetchNames()
            XCTAssertEqual(insertedNames?.count, totalNames, "All names should be inserted successfully.")
            
        case .failure(let error):
            XCTFail("Unable to create names: \(error.localizedDescription)")
        }
    }

    func testInsertName_Failure_ThrowsDuplicateInPersistence() async {
        var names: [Name] = []
        let nameText = "Name"
        for sex in Sex.allCases {
            guard let name = try? Name(nameText, sex: sex)
            else { XCTFail("Unable to create a name."); return }
            
            switch await insert(name) {
            case .success():                                    // Initial insert is successful.
                names.append(name)
                
            case .failure(let error):                           // Error on initial insert should not occur.
                XCTFail("Unable to insert unique name: \(error.localizedDescription)")
            }
        }
        
        for name in names {
            switch await insert(name) {
            case .success():
                XCTFail("Duplicate name should not insert.")
                
            case .failure(let error):
                switch error {
                    
                case .duplicateNameInserted(let nameText):      // The correct error is caught.
                    XCTAssertEqual(nameText, name.text, "The duplicate name error should throw.")
                    
                    // Fetch the inserted names to check if the duplicate is not inserted.
                    guard let insertedNames = try? self.fetchNames(name.sex!) else {
                        XCTFail("Unable to fetch names.")
                        return
                    }
                    
                    // Verify that only the 1 unique name were inserted successfully.
                    XCTAssertEqual(insertedNames.count, 1, "Only 1 unique name should be inserted successfully.")
                    
                default:                                        // Unexpected errors should not occur.
                    XCTFail("Unexpected error during insertion: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func testInsertNames_Failure_DuplicateInProvidedArray() async {
        for sex in Sex.allCases {
            // Create names, including a duplicate.
            guard let name1 = try? Name("Name One", sex: sex),
                  let name2 = try? Name("Name Two", sex: sex),
                  let name3 = try? Name("Name Three", sex: sex)
            else {
                XCTFail("Unable to create unique Names.")
                return
            }

            let names = [name1, name2, name2, name3]    // Duplicate in array
            let results = await insert(names)           // Attempt to insert names.
            
            // Verify that one insertion failed due to duplication.
            let failureCount = results.filter {
                switch $0 {
                case .success():
                    return false
                    
                case .failure(_):
                    return true
                }
            }.count
            XCTAssertEqual(failureCount, 1, "One insertion should fail due to duplication.")
            
            // Fetch the inserted names to check if the duplicate is not inserted.
            guard let insertedNames = try? self.fetchNames(sex) else {
                XCTFail("Unable to fetch names.")
                return
            }
            
            // Verify that only the unique names were inserted successfully.
            XCTAssertEqual(insertedNames.count, names.count - 1, "Only unique names should be inserted successfully.")
        }
    }
    
    func testInsertNames_Failure_DuplicateInPersistence() async {
        for sex in Sex.allCases {
            guard let name1 = try? Name("Name One", sex: sex),
                  let name2 = try? Name("Name Two", sex: sex),
                  let name3 = try? Name("Name Three", sex: sex)
            else {
                XCTFail("Unable to create unique Names.")
                return
            }
            
            let names = [name1, name2, name3]
            let results = await insert(names)           // Insert names successfully
            
            for result in results {                     // Verify that no insertion failed.
                switch result {
                case .success: continue
                case .failure(let error):
                    XCTFail("Unable to insert names: \(error)")
                }
            }
            
            let duplicateResults = await insert(names)  // Attempt to insert duplicate names
            
            for result in duplicateResults {            // Verify that no insertion failed.
                switch result {
                case .success:
                    XCTFail("No name should be inserted.")
                case .failure(let error): continue
                }
            }
            
            // Fetch the inserted names.
            guard let fetchedNames = try? self.fetchNames(sex) else {
                XCTFail("Unable to fetch names.")
                return
            }
            
            // Verify that only the unique names were inserted successfully.
            XCTAssertEqual(fetchedNames.count, names.count, "Only unique names should be inserted successfully.")
        }
    }
    
    
//    // MARK: - Delete
//    
//    func testDeleteAllNames() {
//        guard let name1 = try? Name("Lily", sex: .female),
//              let name2 = try? Name("Amara", sex: .female),
//              let name3 = try? Name("Hadley", sex: .female),
//              let name4 = try? Name("Mike", sex: .male),
//              let name5 = try? Name("Atlas", sex: .male),
//              let name6 = try? Name("Titan", sex: .male)
//        else { XCTFail("Unable to create Names."); return }
//        
//        let names = [name1, name2, name3, name4, name5, name6]
//        _ = insert(names)
//        
//        delete(names)
//        
//        DispatchQueue.main.async {
//            guard let fetchedNames = try? self.fetchNames()
//            else { XCTFail("Unable to fetch names."); return }
//            
//            XCTAssertTrue(fetchedNames.isEmpty, "All names should be deleted successfully.")
//        }
//    }
//    
//    func testDeleteName() {
//        var names: [Name] = []
//        for sex in Sex.allCases {
//            switch createName("Name", sex: sex) {
//                
//            case .success(let name): names.append(name)
//            case .failure(let error):
//                XCTFail("Unable to create unique name due to error: \(error.localizedDescription)")
//            }
//        }
//        
//        _ = insert(names)
//        
//        for name in names {
//            delete(name)
//        }
//        
//        DispatchQueue.main.async {
//            guard let fetchedNames = try? self.fetchNames()
//            else { XCTFail("Unable to fetch names."); return }
//            
//            XCTAssertTrue(fetchedNames.isEmpty, "All names should be deleted successfully.")
//            
//            XCTAssertNil(try? self.fetchName(byText: "Name", sex: .male))
//        }
//    }
//    
//
//    // MARK: - Default Data
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
//    func testDuplicateGirlNameData() {
//        let nameData = DefaultBabyNames()
//        var seen = Set<String>()
//        var duplicates = Set<String>()
//        
//        for string in nameData.girlNames {
//            if seen.contains(string) {
//                duplicates.insert(string)
//                
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
//                
//            } else {
//                seen.insert(string)
//            }
//        }
//        
//        XCTAssertEqual(seen.count, nameData.boyNames.count, "All names should be seen.")
//        XCTAssertTrue(duplicates.isEmpty, "No duplicates should be in the default data.")
//    }
//    
//    func testDefaultNames_AreLoaded() {
//        loadDefaultNames()
//        
//        guard let maleNames = try? self.fetchNames(.male),
//              let femaleNames = try? self.fetchNames(.female)
//        else { XCTFail("Unable to fetch names."); return }
//        
//        XCTAssertEqual(maleNames.count, DefaultBabyNames().boyNames.count, "Not all boy names were inserted into the context.")
//        XCTAssertEqual(femaleNames.count, DefaultBabyNames().girlNames.count, "Not all girl names were inserted into the context.")
//    }
    
    

    
    // MARK: - Helper Functions
    
    private func generateRandomLetter() -> Character {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return letters.randomElement()!
    }
    
    private func generateRandomLetters(count: Int) -> [Character] {
        return (0..<count).map { _ in generateRandomLetter() }
    }
    
    private func _createRandomNames(countPerSex namesCount: Int) async -> Result<[Name], Error> {
        var names: [Name] = []
        let randomLetterCount = 5
        for _ in 0..<namesCount {
            let randomText = String(generateRandomLetters(count: randomLetterCount))
            let name = "Name \(randomText)"
            
            /// Create names for both male and females.
            for sex in Sex.allCases {
                
                switch createName(name, sex: sex) {
                case .success(let name):
                    names.append(name)
                    
                case .failure(let error):
                    return .failure(error)
                }
            }
        }
        return .success(names)
    }
    
    private func _insertRandomNamesIntoContext(countPerSex namesCount: Int) async -> Result<[Name], Error> {
        let context = modelContext
        switch await _createRandomNames(countPerSex: namesCount) {
        case .success(let names):
            
            let results = await insert(names)
            for result in results {                 // Check for insertion errors.
                switch result {
                case .success: continue
                case .failure(let error):
                    print(error.localizedDescription)
                    return .failure(error)          // If an error exists: Fail the method.
                }
            }
            
            return .success(names)                  // Names were created and inserted.
            
        case .failure(let error):
            print(error.localizedDescription)
            return .failure(error)
        }
    }
    
    private func _insertRandomFavoriteNamesIntoContext(_ numFavorites: Int) async -> Result<[Name], Error> {
        let context = modelContext
        
        let favoriteNamesResult = await _createRandomNames(countPerSex: numFavorites)
        let nonFavoriteNamesResult = await _createRandomNames(countPerSex: numFavorites)
        var allNames: [Name] = []
        
        switch favoriteNamesResult {
        case .success(let names):
            for name in names {
                name.toggleFavorite()
                allNames.append(name)
            }
        case .failure(let error):
            return .failure(error)
        }
        
        switch nonFavoriteNamesResult {
        case .success(let names):
            for name in names {
                allNames.append(name)
            }
        case .failure(let error):
            return .failure(error)
        }
        
        let results = await insert(allNames)
        for result in results {                 // Check for insertion errors.
            switch result {
            case .success: continue
            case .failure(let error):
                print(error.localizedDescription)
                return .failure(error)          // If an error exists: Fail the method.
            }
        }
        
        return .success(allNames)                  // Names were created and inserted.
    }
}
