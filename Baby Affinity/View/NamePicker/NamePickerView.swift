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
                findNamesToPresent(with: names)
            
            // Step 3: Show 10 random unevaluated names.
            } else {
                presentedNames = unEvaluatedNames.randomElements(count: 10)
            }
            
        } catch {
            // Log critical error if name fetching fails
            SystemLogger.main.logCritical("Unable to fetch names for name picker view to load: \(error.localizedDescription)")
        }
    }
    
    
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
        
        // Pick the appropriate number of names for each category
        let selectedHighDeviationNames = Array(highDeviationNames.randomElements(count: 2))
        let selectedLowDeviationName = Array(lowDeviationNames.randomElements(count: 1))
        let selectedRemainingNames = Array(remainingNames.randomElements(count: 7))
        
        // Combine the names into the presentedNames array
        presentedNames = selectedHighDeviationNames + selectedLowDeviationName + selectedRemainingNames
    }
    
    
    private func calculateStandardDeviation(_ squaredDiffs: [Double]) -> Double {
        sqrt(Double(squaredDiffs.reduce(0, +)) / Double(squaredDiffs.count))
    }
    
    
    private func calculateSquaredDifferences(_ names: [Name], mean: Double) -> [Double] {
        names.map { pow(Double($0.affinityRating) - mean, 2) }
    }
    
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
