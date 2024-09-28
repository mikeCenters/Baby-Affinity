//
//  NamePickerView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/5/24.
//

import SwiftUI
import SwiftData
import SystemLogger

/// A view for selecting baby names based on user preferences.
///
/// The `NamePickerView` allows users to pick a set number of names from a list of presented names.
/// Users can select names they like, and the app will update the affinity ratings for those names.
struct NamePickerView: View {
    
    // MARK: - Properties
    
    /// Environment variable for the model context.
    @Environment(\.modelContext) var modelContext
    
    /// App storage for the selected sex (male or female).
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    /// The names to present to the user.
    @State private var presentedNames: [Name] = []
    
    /// The names selected by the user.
    @State private var selectedNames: [Name] = []
    
    
    // MARK: - Controls and Constants
    
    /// The maximum number of names that can be selected by the user.
    private let maxSelections = 5
    
    /// State variable for showing the instructions sheet.
    @State private var showInstructions = true
    
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                if !selectedNames.isEmpty {
                    selectedNamesSection
                }
                
                presentedNamesSection
            }
            .navigationTitle("Pick \(maxSelections) Names")
            .toolbar {
                toolBars
            }
            .sheet(isPresented: $showInstructions) {
                InstructionsView(maxSelections: maxSelections, showInstructions: $showInstructions)
            }
        }
        
        
        // MARK: - On Appear
        .onAppear {
            withAnimation {
                loadNames()
            }
        }
        
        
        // MARK: - On Change
        .onChange(of: selectedSex) {
            withAnimation {
                loadNames()
            }
        }
    }
}


// MARK: - View Components

private extension NamePickerView {
    
    /// Section displaying the selected names.
    var selectedNamesSection: some View {
        Section(header: Text("Selected Names")) {
            ForEach(selectedNames) { name in
                HStack {
                    Text(name.text)
                    Spacer()
                    Button {
                        withAnimation {
                            deselect(name)
                        }
                        
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    /// Section displaying the presented names.
    var presentedNamesSection: some View {
        Section {
            ForEach(presentedNames) { name in
                Button {
                    withAnimation {
                        select(name)
                    }
                    
                } label: {
                    Text(name.text)
                }
            }
        }
    }
    
    /// Bottom toolbar with the submit button.
    var toolBars: some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: submitNames) {
                    Text(selectedNames.isEmpty ? "New Names" : "Submit")
                }
                .buttonStyle(BorderedButtonStyle())
                .padding(.bottom)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                SexSelectionIconView()
            }
        }
    }
}


// MARK: - Methods

extension NamePickerView: NamePersistenceController_Admin {
    
    /// Submits the selected names and reloads new names to be evaluated.
    private func submitNames() {
        updateRatings()
        loadNames()
    }
    
    /// Selects a name from the presented names and adds it to the selected names.
    ///
    /// If the number of selected names is less than the maximum allowed selections, the selected name is
    /// added to the selected names and removed from the presented names.
    /// - Parameter name: The name to be selected.
    private func select(_ name: Name) {
        if selectedNames.count < maxSelections {
            selectedNames.append(name)
            presentedNames.removeAll { $0 == name }
        }
    }
    
    /// Deselects a name from the chosen names and adds it back to the presented names.
    ///
    /// The deselected name is removed from the chosen names and added back to the presented names.
    /// - Parameter name: The name to be deselected.
    private func deselect(_ name: Name) {
        selectedNames.removeAll { $0 == name }
        presentedNames.insert(name, at: 0)
    }
    
    /// Update the ratings of selected and presented names.
    private func updateRatings() {
        updateAffinity(winners: selectedNames, losers: presentedNames)
    }
    
    /// Fetch names based on the selected sex and updates the view model.
    private func loadNames() {
        do {
            let names = try fetchNames(selectedSex)
            load(names)
            
        } catch {
            SystemLogger.main.logCritical("Unable to fetch names for name picker view to load: \(error.localizedDescription)")
        }
    }
    
    /// Loads the names to be presented to the user.
    ///
    /// This method filters the input list of names into groups based on the median affinity rating:
    /// one group below the median, one group above the median, and one group of "not evaluated" names.
    /// From these groups, it selects names to present based on the following rules:
    /// - If there are not evaluated names:
    ///     - Show 2 from the top 20% of the top median group.
    ///     - Show 8 from the not evaluated group.
    /// - Else:
    ///     - Show 1 below the median.
    ///     - Show 3 from the top 20% above the median.
    ///     - Show 6 from the median to the top 20%.
    func load(_ names: [Name]) {
        guard !names.isEmpty else { return }
        
        selectedNames.removeAll()
        
        let (evaluatedNames, notEvaluatedNames) = categorizeNames(names)
        let (belowMedianNames, aboveMedianNames) = splitByMedian(evaluatedNames)
        
        let top20PercentCount = calculateTop20PercentCount(for: aboveMedianNames)
        let namesToShow: [Name] = determineNamesToShow(
            from: belowMedianNames,
            aboveMedianNames: aboveMedianNames,
            notEvaluatedNames: notEvaluatedNames,
            top20PercentCount: top20PercentCount
        )
        
        presentedNames = namesToShow.shuffled()
    }
    

    // MARK: - Helper Methods

    /// Categorizes the names into evaluated and not evaluated lists.
    ///
    /// - Parameter names: The list of names to categorize.
    /// - Returns: A tuple containing two arrays: one with evaluated names and one with not evaluated names.
    private func categorizeNames(_ names: [Name]) -> ([Name], [Name]) {
        var evaluatedNames: [Name] = []
        var notEvaluatedNames: [Name] = []
        
        names.forEach { name in
            name.evaluated > 0 ? evaluatedNames.append(name) : notEvaluatedNames.append(name)
        }
        
        return (evaluatedNames, notEvaluatedNames)
    }

    /// Splits the evaluated names into two groups: below the median and above the median.
    ///
    /// - Parameter evaluatedNames: The list of evaluated names sorted by affinity rating.
    /// - Returns: A tuple containing two arrays: one with names below the median and one with names above the median.
    private func splitByMedian(_ evaluatedNames: [Name]) -> ([Name], [Name]) {
        let medianIndex = evaluatedNames.count / 2
        let belowMedianNames = evaluatedNames.prefix(medianIndex)
        let aboveMedianNames = evaluatedNames.suffix(from: medianIndex)
        
        return (Array(belowMedianNames), Array(aboveMedianNames))
    }

    /// Calculates the count of names that represent the top 20% of a list.
    ///
    /// - Parameter names: The list of names from which to calculate the top 20% count.
    /// - Returns: The number of names representing the top 20% of the list, with a minimum of 1.
    private func calculateTop20PercentCount(for names: [Name]) -> Int {
        return max(1, Int(Double(names.count) * 0.2))
    }

    /// Determines the names to show based on the evaluated status and affinity ratings.
    ///
    /// - Parameters:
    ///   - belowMedianNames: The list of names below the median affinity rating.
    ///   - aboveMedianNames: The list of names above the median affinity rating.
    ///   - notEvaluatedNames: The list of names that have not been evaluated.
    ///   - top20PercentCount: The count of names representing the top 20% of the above median list.
    /// - Returns: An array of names selected according to the specified rules, shuffled before being returned.
    private func determineNamesToShow(from belowMedianNames: [Name], aboveMedianNames: [Name], notEvaluatedNames: [Name], top20PercentCount: Int) -> [Name] {
        var namesToShow: [Name] = []
        
        if notEvaluatedNames.isEmpty { // All names have been evaluated.
            namesToShow.append(contentsOf: belowMedianNames.shuffled().prefix(1))
            namesToShow.append(contentsOf: aboveMedianNames.suffix(top20PercentCount).shuffled().prefix(3))
            namesToShow.append(contentsOf: aboveMedianNames.dropLast(top20PercentCount).shuffled().prefix(6))
        } else { // Some names still need evaluated.
            namesToShow.append(contentsOf: aboveMedianNames.suffix(top20PercentCount).shuffled().prefix(2))
            namesToShow.append(contentsOf: notEvaluatedNames.shuffled().prefix(8))
        }
        
        return namesToShow
    }
}


#if DEBUG

// MARK: - Preview

#Preview {
    NamePickerView()
        .modelContainer(previewModelContainer_WithFavorites)
}

#endif
