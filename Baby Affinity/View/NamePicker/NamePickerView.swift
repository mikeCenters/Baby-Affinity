//
//  NamePickerView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/5/24.
//

import SwiftUI
import SwiftData
import SystemLogger

// MARK: - Name Picker View

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
                Button {
                    withAnimation {
                        deselect(name)
                    }
                    
                } label: {
                    HStack {
                        Text(name.text)
                            .tint(.primary)
                        Spacer()
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
                .listRowBackground(selectedSex == .male ? Color.blue.opacity(0.2) : Color.pink.opacity(0.2))
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
    
    /// The toolbars used within the view.
    private var toolBars: some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: submitNames) {
                    Text(selectedNames.isEmpty ? "New Names" : "Submit")
                }
                .buttonStyle(BorderedButtonStyle())
                .padding(.bottom)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showInstructions.toggle()
                    
                } label: {
                    Image(systemName: "i.circle")
                        .font(.headline)
                }

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
    
    /// Empty the presentedNames and selectedNames arrays.
    private func resetNames() {
        withAnimation {
            presentedNames.removeAll()
            selectedNames.removeAll()
        }
    }
    
    /// This function loads names for presentation based on certain criteria.
    /// It resets the names, fetches them from a data source, filters based on evaluation status,
    /// and then presents either random unevaluated names or selects names based on statistical analysis.
    ///
    /// The function follows these steps:
    /// - Resets existing name lists.
    /// - Fetches names from the data source based on the selected sex.
    /// - Filters names that have not been evaluated (`evaluated == 0`).
    /// - If no unevaluated names exist, selects names based on affinity rating statistics.
    /// - Otherwise, presents 10 random unevaluated names.
    private func loadNames() {
        do {
            // Step 1: Clear the arrays before loading new names
            resetNames()
            
            // Step 2: Fetch the names from the data source based on selectedSex
            let names = try fetchNames(selectedSex)
            
            // Step 3: Filter names where evaluated == 0
            let unEvaluatedNames = names.filter { $0.evaluated == 0 }
            
            // Step 4: Present Names
            if unEvaluatedNames.isEmpty {
                // If no unevaluated names, find names to present based on statistical analysis
                findNamesToPresent(with: names)
            } else {
                // Present 10 random unevaluated names
                presentedNames = unEvaluatedNames.randomElements(count: 10)
            }
            
        } catch {
            // Log a critical error if name fetching fails
            SystemLogger.main.logCritical("Unable to fetch names for name picker view to load: \(error.localizedDescription)")
        }
    }

    /// This function selects names for presentation based on their statistical distribution of affinity ratings.
    /// It uses the mean and standard deviation to select names with high, low, and average affinity ratings.
    /// Specifically, it picks:
    /// - 2 names with affinity ratings higher than the mean by 2 standard deviations or more.
    /// - 1 name with an affinity rating lower than the mean by more than 1 standard deviation.
    /// - 7 names with affinity ratings within 1 standard deviation of the mean.
    ///
    /// - Parameter names: An array of `Name` objects representing the names to filter and present.
    private func findNamesToPresent(with names: [Name]) {
        // Calculate mean and standard deviation for names based on Affinity Rating
        let mean: Double = calculateMeanAffinityRating(names)
        let squaredDiffs: [Double] = calculateSquaredDifferences(names, mean: mean)
        let standardDeviation = calculateStandardDeviation(squaredDiffs)
        
        // Filter names based on standard deviation criteria
        let highDeviationNames = names.filter { Double($0.affinityRating) >= mean + 2 * standardDeviation }
        let lowDeviationNames = names.filter { Double($0.affinityRating) < mean - standardDeviation }
        let remainingNames = names.filter {
            Double($0.affinityRating) >= mean - standardDeviation && Double($0.affinityRating) < mean + 2 * standardDeviation
        }
        
        // Select 2 names with high deviation, 1 with low deviation, and 7 remaining names
        let selectedHighDeviationNames = Array(highDeviationNames.randomElements(count: 2))
        let selectedLowDeviationName = Array(lowDeviationNames.randomElements(count: 1))
        let selectedRemainingNames = Array(remainingNames.randomElements(count: 7))
        
        // Combine the selected names into the presentedNames array
        presentedNames = selectedHighDeviationNames + selectedLowDeviationName + selectedRemainingNames
    }

    /// This function calculates the standard deviation based on an array of squared differences.
    ///
    /// - Parameter squaredDiffs: An array of squared differences between each affinity rating and the mean.
    /// - Returns: The standard deviation of the affinity ratings.
    private func calculateStandardDeviation(_ squaredDiffs: [Double]) -> Double {
        sqrt(Double(squaredDiffs.reduce(0, +)) / Double(squaredDiffs.count))
    }

    /// This function calculates the squared differences between each affinity rating and the mean.
    ///
    /// - Parameters:
    ///   - names: An array of `Name` objects representing the names to calculate squared differences for.
    ///   - mean: The mean of the affinity ratings.
    /// - Returns: An array of squared differences between the affinity ratings and the mean.
    private func calculateSquaredDifferences(_ names: [Name], mean: Double) -> [Double] {
        names.map { pow(Double($0.affinityRating) - mean, 2) }
    }

    /// This function calculates the mean (average) affinity rating for an array of names.
    ///
    /// - Parameter names: An array of `Name` objects representing the names to calculate the mean affinity rating for.
    /// - Returns: The mean of the affinity ratings for the provided names.
    private func calculateMeanAffinityRating(_ names: [Name]) -> Double {
        names.map { Double($0.affinityRating) }.reduce(0.0, +) / Double(names.count)
    }
}


#if DEBUG

// MARK: - Preview

#Preview("Name Picker View") {
    NamePickerView()
        .modelContainer(previewModelContainer_WithFavorites)
}

#endif
