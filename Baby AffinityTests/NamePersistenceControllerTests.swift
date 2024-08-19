import XCTest
import SwiftData
@testable import Baby_Affinity

final class NamePersistenceControllerTests: XCTestCase, NamePersistenceController_Admin {
    
    private var context: ModelContext!
    
    @MainActor
    override func setUp() {
        super.setUp()
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
        super.tearDown()
    }
    
    // MARK: - Persistence Integrity
    
    func testAppStartsEmptyPersistence() throws {
        let names = try fetchNames(context: context)
        
        XCTAssertTrue(names.isEmpty, "Persistence should have no Name objects.")
        XCTAssertNil(try fetchName(byText: "Mike", sex: .male, context: context))
    }
    
    // MARK: - Default Data
    
    func testDuplicateGirlNameData() {
        let nameData = DefaultBabyNames()
        var seen = Set<String>()
        var duplicates = Set<String>()
        
        for string in nameData.girlNames {
            if seen.contains(string) {
                duplicates.insert(string)
            } else {
                seen.insert(string)
            }
        }
        
        XCTAssertEqual(seen.count, nameData.girlNames.count, "All names should be seen.")
        XCTAssertTrue(duplicates.isEmpty, "No duplicates should be in the default data.")
    }
    
    func testDuplicateBoyNameData() {
        let nameData = DefaultBabyNames()
        var seen = Set<String>()
        var duplicates = Set<String>()
        
        for string in nameData.boyNames {
            if seen.contains(string) {
                duplicates.insert(string)
            } else {
                seen.insert(string)
            }
        }
        
        XCTAssertEqual(seen.count, nameData.boyNames.count, "All names should be seen.")
        XCTAssertTrue(duplicates.isEmpty, "No duplicates should be in the default data.")
    }
    
    func testDefaultNamesData_Girls() {
        let girlNames = getDefaultNames(.female)
        
        girlNames.forEach { XCTAssertEqual($0.sex, Sex.female, "Only girl names should exist in the array.") }
        XCTAssertEqual(girlNames.count, DefaultBabyNames().girlNames.count, "Not all girl names were created.")
    }
    
    func testDefaultNamesData_Boys() {
        let boyNames = getDefaultNames(.male)
        
        boyNames.forEach { XCTAssertEqual($0.sex, Sex.male, "Only boy names should exist in the array.") }
        XCTAssertEqual(boyNames.count, DefaultBabyNames().boyNames.count, "Not all boy names were created.")
    }
    
    func testDefaultNamesData_All() {
        let nameData = DefaultBabyNames()
        let totalCount = nameData.boyNames.count + nameData.girlNames.count
        let allNames = getDefaultNames()
        
        XCTAssertEqual(allNames.count, totalCount, "Not all names were created.")
    }
    
    // FIXME: - Pause before fetching should resolve the error.
//    func testDefaultNames_AreLoaded() async {
//        await loadDefaultNames(into: context)
//        
//        do {
//            let maleNames = try fetchNames(.male, context: context)
//            let femaleNames = try fetchNames(.female, context: context)
//            
//            maleNames.forEach { XCTAssertEqual($0.sex, .male) }
//            femaleNames.forEach { XCTAssertEqual($0.sex, .female) }
//            
//            XCTAssertEqual(maleNames.count, DefaultBabyNames().boyNames.count, "Not all boy names were inserted into the context.")
//            XCTAssertEqual(femaleNames.count, DefaultBabyNames().girlNames.count, "Not all girl names were inserted into the context.")
//            
//        } catch {
//            XCTFail("Unable to fetch names.")
//        }
//    }
    
    // MARK: - Create
    
    func testCreateName_Success() {
        switch createName("Mike", sex: .male) {
        case .success(let name):
            XCTAssertEqual(name.text, "Mike", "Texts should be the same.")
            XCTAssertEqual(name.sex, .male, "Sexes should be the same.")
            
        case .failure(_):
            XCTFail("Unique name should be successful.")
        }
    }
    
    func testCreateName_Failure_NameIsEmpty() {
        switch createName("", sex: .male) {
        case .success(_):
            XCTFail("Name should not be created with an empty string.")
            
        case .failure(let error):
            XCTAssertEqual(error, Name.NameError.nameIsEmpty, "Error should indicate an empty string")
        }
    }
    
    func testCreateName_Failure_RatingBelowMinimum() {
        switch createName("Mike", sex: .male, affinityRating: -1) {
        case .success(_):
            XCTFail("Name should not be created with a rating below the minimum.")
            
        case .failure(let error):
            XCTAssertEqual(error, Name.NameError.ratingBelowMinimum(Name.minimumAffinityRating), "Error should indicate the rating is below the minimum rating.")
        }
    }
    
    func testCreateName_Failure_InvalidCharactersInName() {
        switch createName("*Mike*", sex: .male) {
        case .success(_):
            XCTFail("Name should not be created with special characters.")
            
        case .failure(let error):
            XCTAssertEqual(error, Name.NameError.invalidCharactersInName(Name.allowedSpecialCharacters.description), "Error should indicate that unacceptable characters were provided.")
        }
    }
    
    
    // MARK: - Insert
    
    func testInsertName_Success() {
        guard let name = try? Name("James", sex: .male)
        else { XCTFail("Unable to create a name."); return }
        
        let result = insert(name, context: context)
        
        switch result {
        case .success:
            let fetchedName = try? fetchName(byText: name.text, sex: name.sex!, context: context)
            XCTAssertNotNil(fetchedName, "The inserted name should be fetched successfully.")
            XCTAssertEqual(fetchedName?.text, name.text, "The fetched name should have the same text as the inserted name.")
            XCTAssertEqual(fetchedName?.sex, name.sex, "The fetched name should have the same sex as the inserted name.")
            XCTAssertEqual(fetchedName?.sexRawValue, name.sexRawValue, "The fetched name should have the same sexRawValue as the inserted name.")
            XCTAssertEqual(fetchedName?.affinityRating, name.affinityRating, "The fetched name should have the same affinity rating as the inserted name.")
            XCTAssertEqual(fetchedName?.isFavorite, name.isFavorite, "The fetched name should have the same favorite state as the inserted name.")
            XCTAssertEqual(fetchedName?.evaluated, name.evaluated, "The fetched name should have the same evaluated count as the inserted name.")
            
        case .failure:
            XCTFail("Insertion should succeed for unique names.")
        }
    }
    
    func testInsertNames_Success() {
        var names: [Name] = []
        for _ in 1...2000 {
            let random = String(generateRandomLetters(count: 10))
            let name: String = "Name".appending(random)
            
            guard let name = try? Name(name, sex: .female)
            else { XCTFail("Unable to create a name."); return }
            
            names.append(name)
        }
        
        let results = insert(names, context: context)
        
        results.forEach {
            switch $0 {
            case .success:
                break  // Insertion succeeded
                
            case .failure:
                XCTFail("All insertions should succeed for unique names.")
            }
        }
        
        let insertedNames = try? fetchNames(context: context)
        XCTAssertEqual(insertedNames?.count, names.count, "All names should be inserted successfully.")
    }
    
    func testInsertName_Failure() {
        guard let name = try? Name("Emma", sex: .female)
        else { XCTFail("Unable to create a name."); return }
        
        _ = insert(name, context: context)  // Insert once
        
        let duplicateResult = insert(name, context: context)  // Attempt to insert duplicate
        
        switch duplicateResult {
        case .success:
            XCTFail("Insertion should fail for duplicate names.")
            
        case .failure(let error):
            switch error {
            case .duplicateNameInserted(let nameText):
                XCTAssertEqual(nameText, name.text, "The error should be about the duplicate name.")
                
            default:
                XCTFail("Unexpected error during insertion.")
            }
        }
    }
    
    func testInsertNames_Failure() {
        guard let name1 = try? Name("Olivia", sex: .female),
              let name2 = try? Name("Liam", sex: .female),
              let name3 = try? Name("Olivia", sex: .female)     // Duplicate
        else { XCTFail("Unable to create Names."); return }
        
        let names = [name1, name2, name3]
        let results = insert(names, context: context)
        
        XCTAssertEqual(results.filter { if case .failure = $0 { return true } else { return false } }.count, 1, "One insertion should fail due to duplication.")
        
        let insertedNames = try? fetchNames(context: context)
        XCTAssertEqual(insertedNames?.count, names.count - 1, "Only unique names should be inserted successfully.")
    }
    
    
    // MARK: - Fetch
    
    func testFetchName_ByTextAndSex() {
        guard let name = try? Name("Lily", sex: .female)
        else { XCTFail("Unable to create Names."); return }
        
        _ = insert(name, context: context)
        
        guard let fetchedName = try? fetchName(byText: "Lily", sex: .female, context: context)
        else { XCTFail("Unable to fetch the name."); return }
        
        XCTAssertEqual(fetchedName.text, "Lily", "The fetched name should have the correct text.")
        XCTAssertEqual(fetchedName.sex, .female, "The fetched name should have the correct sex.")
    }
    
    func testFetchNames_All() {
        guard let name1 = try? Name("Olivia", sex: .female),
              let name2 = try? Name("Liam", sex: .female),
              let name3 = try? Name("Sara", sex: .female)
        else { XCTFail("Unable to create Names."); return }
        
        let names = [name1, name2, name3]
        _ = insert(names, context: context)
        
        guard let fetchedNames = try? fetchNames(context: context)
        else { XCTFail("Unable to fetch names."); return }
        
        XCTAssertEqual(fetchedNames.count, names.count, "All names should be fetched successfully.")
    }
    
    func testFetchNames_BySex() {
        guard let maleName = try? Name("Mike", sex: .male),
              let femaleName = try? Name("Amara", sex: .female)
        else { XCTFail("Unable to create a new Name."); return }
        
        _ = insert(maleName, context: context)
        _ =  insert(femaleName, context: context)

        guard let fetchedMaleNames = try? fetchNames(.male, context: context),
              let fetchedFemaleNames = try? fetchNames(.female, context: context)
        else { XCTFail("Unable to fetch names."); return }
        
        XCTAssertEqual(fetchedMaleNames.count, 1, "One Name is not fetched.")
        XCTAssertEqual(fetchedMaleNames.first?.text, "Mike")
        XCTAssertEqual(fetchedFemaleNames.count, 1, "One Name is not fetched.")
        XCTAssertEqual(fetchedFemaleNames.first?.text, "Amara")
    }

    func testFetchFavoriteNames() {
        var names: [Name] = []
        /// Create 10 favorite male and female names.
        (0..<10).forEach { _ in
            let random = String(generateRandomLetters(count: 5))
            let name = "Favorite Name \(random)"
            
            guard let maleName = try? Name(name, sex: .male),
                  let femaleName = try? Name(name, sex: .female)
            else { XCTFail("Unable to create a new Name."); return }
            
            maleName.toggleFavorite()
            femaleName.toggleFavorite()
            names.append(maleName)
            names.append(femaleName)
        }
        
        /// Create 10 non-favorite male and female names.
        (0..<10).forEach { _ in
            let random = String(generateRandomLetters(count: 5))
            let name = "Non-Favorite Name \(random)"
            
            guard let maleName = try? Name(name, sex: .male),
                  let femaleName = try? Name(name, sex: .female)
            else { XCTFail("Unable to create a new Name."); return }
            
            names.append(maleName)
            names.append(femaleName)
        }
        
        _ = insert(names, context: context)
        
        guard let maleFavoriteNames = try? fetchFavoriteNames(sex: .male, context: context),
              let femaleFavoriteNames = try? fetchFavoriteNames(sex: .female, context: context)
        else { XCTFail("Unable to fetch favorite names."); return }
        
        XCTAssertEqual(maleFavoriteNames.count, 10, "Not all favorite male names were fetched.")
        XCTAssertEqual(femaleFavoriteNames.count, 10, "Not all favorite female names were fetched.")
    }
    
    
    // MARK: - Update
    
    func testToggleFavorite() {
        guard let name = try? Name("Hadley", sex: .female)
        else { XCTFail("Unable to create a new Name."); return }
        
        _ = insert(name, context: context)
        
        guard let fetchedName = try? fetchName(byText: name.text, sex: name.sex!, context: context)
        else { XCTFail("Unable to fetch inserted name."); return }
        
        XCTAssertFalse(fetchedName.isFavorite, "The name should not be a favorite as default.")
        
        fetchedName.toggleFavorite()    // Is favorite
        
        guard let fetchedName = try? fetchName(byText: name.text, sex: name.sex!, context: context)
        else { XCTFail("Unable to fetch inserted name."); return }
        
        XCTAssertTrue(fetchedName.isFavorite, "The name should be a favorite after toggling.")
        
        fetchedName.toggleFavorite()    // Is not favorite
        
        guard let fetchedName = try? fetchName(byText: name.text, sex: name.sex!, context: context)
        else { XCTFail("Unable to fetch inserted name."); return }
        
        XCTAssertFalse(fetchedName.isFavorite, "The name should not be a favorite after toggling.")
    }
    
    func testUpdateAffinityRating() {
        guard let name = try? Name("Hadley", sex: .female)
        else { XCTFail("Unable to create a new Name."); return }
        
        _ = insert(name, context: context)
        
        guard let fetchedName = try? fetchName(byText: name.text, sex: name.sex!, context: context)
        else { XCTFail("Unable to fetch inserted name."); return }
        
        guard ((try? fetchedName.setAffinity(1021)) != nil)
        else { XCTFail("Unable to set affinity rating"); return }
        
        guard let fetchedName = try? fetchName(byText: name.text, sex: name.sex!, context: context)
        else { XCTFail("Unable to fetch inserted name."); return }
        
        XCTAssertEqual(fetchedName.affinityRating, 1021, "The name should have the updated affinity rating.")
    }
    
    
    // MARK: - Delete
    
    func testDeleteAllNames() {
        guard let name1 = try? Name("Lily", sex: .female),
              let name2 = try? Name("Amara", sex: .female),
              let name3 = try? Name("Hadley", sex: .female),
              let name4 = try? Name("Mike", sex: .male),
              let name5 = try? Name("Atlas", sex: .male),
              let name6 = try? Name("Tital", sex: .male)
        else { XCTFail("Unable to create Names."); return }
        
        let names = [name1, name2, name3, name4, name5, name6]
        _ = insert(names, context: context)
        
        delete(names, context: context)
        
        guard let fetchedNames = try? fetchNames(context: context)
        else { XCTFail("Unable to fetch names."); return }
        
        XCTAssertTrue(fetchedNames.isEmpty, "All names should be deleted successfully.")
    }
    
    func testDeleteName() async {
        guard let name = try? Name("Amara", sex: .female)
        else { XCTFail("Unable to create a new Name."); return }
        
        _ = insert(name, context: context)
        
        guard let fetchedName = try? fetchName(byText: "Amara", sex: .female, context: context)
        else { XCTFail("Unable to fetch names."); return }
        
        delete(fetchedName, context: context)
        
        // FIXME: - Remove pause.
//        try context.save()
        
//        let context = self.context
//        guard let fetchedName = try? self.fetchName(byText: "Amara", sex: .female, context: context!)
//        else { XCTFail("Unable to fetch names."); return }
//        
//        XCTAssertNil(fetchedName, "The name should be deleted successfully.")
//        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let context = self.context
            guard let fetchedName = try? self.fetchName(byText: "Amara", sex: .female, context: context!)
            else { XCTFail("Unable to fetch names."); return }
            
            XCTAssertNil(fetchedName, "The name should be deleted successfully.")
        }
    }
    
    
    // MARK: - Helper Functions
    
    private func generateRandomLetter() -> Character {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return letters.randomElement()!
    }
    
    private func generateRandomLetters(count: Int) -> [Character] {
        return (0..<count).map { _ in generateRandomLetter() }
    }
    
}
