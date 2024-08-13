//
//  NamePickerView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/5/24.
//

import SwiftUI
import SwiftData

/// A view for selecting baby names based on user preferences.
///
/// The `NamePickerView` allows users to pick a set number of names from a list of presented names.
/// Users can select names they like, and the app will update the affinity ratings for those names.
struct NamePickerView: View {
    
    // MARK: - Properties
    
    /// Environment variable for the model context.
    @Environment(\.modelContext) private var modelContext
    
    /// App storage for the selected sex (male or female).
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    /// Query for fetching `Name` objects.
    @Query private var names: [Name]
    
    /// State object for managing the view model.
    @StateObject private var viewModel: NamePickerViewModel = .init()
    
    /// Title for the navigation bar, indicating the number of names to pick.
    private var title: String { "Pick \(viewModel.maxSelections) Names" }
    
    
    // MARK: - Controls
    
    /// State variable for showing the instructions sheet.
    @State private var showInstructions = true
    
    
    // MARK: - Init
    
    /// Initializes the `NamePickerView` with a specified sex.
    ///
    /// - Parameter sex: The sex of the names to be picked (male or female).
    init(sex: Sex) {
        let descriptor = FetchDescriptor<Name>(
            predicate: #Predicate { $0.sexRawValue == sex.rawValue },
            sortBy: [.init(\.affinityRating, order: .reverse)]
        )
        
        _names = Query(descriptor)
    }
    
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                
                // Selected Names
                /// Only show if names are chosen
                if !viewModel.selectedNames.isEmpty {
                    selectedNamesSection
                }
                
                
                // Presented Names
                Section {
                    ForEach(viewModel.presentedNames) { name in
                        Button {
                            withAnimation {
                                viewModel.select(name)
                            }
                        } label: {
                            Text(name.text)
                        }
                    }
                }
            }
            .navigationTitle(title)
            // MARK: - Toolbar
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    submitNamesButton
                        .padding(.bottom)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    SexSelectionIconView()
                }
            }
            // MARK: - Sheet
            .sheet(isPresented: $showInstructions) {
                instructions
            }
        }
        // MARK: - On Appear
        .onAppear {
            withAnimation {
                loadNames()
            }
        }
        // MARK: - On Change
        .onChange(of: selectedSex, { oldValue, newValue in
            withAnimation {
                loadNames()
            }
        })
    }
    
    
    // MARK: - Methods
    
    /// Loads the names based on the selected sex and updates the view model.
    private func loadNames() {
        viewModel.load(names)
    }
}


// MARK: - View Components

extension NamePickerView {
    
    /// A section of names that have been selected.
    var selectedNamesSection: some View {
        Section(header: Text("Chosen Names")) {
            ForEach(viewModel.selectedNames) { name in
                HStack {
                    Text(name.text)
                    Spacer()
                    Button {
                        withAnimation {
                            viewModel.deselect(name)
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    
    /// A button for submitting chosen names or fetching new names.
    private var submitNamesButton: some View {
        Button {
            let winners = viewModel.selectedNames
            let losers = viewModel.presentedNames
            
            Task(priority: .medium) {
                viewModel.updateRatings(winners: winners, losers: losers)
            }
            
            withAnimation {
                loadNames()
            }
        } label: {
            Text(viewModel.selectedNames.isEmpty ? "New Names" : "Submit")
        }
        .buttonStyle(BorderedButtonStyle())
    }
    
    
    /// Text providing instructions for using the name picker.
    private var instructionsText: String {
        "Choose up to \(viewModel.maxSelections) names from the list that are to your liking. While there may be other names that you would want to name your baby, pick among these that you like the most. \n\nIf you don't like the available names, simply select new names."
    }
    
    /// View presenting the instructions sheet.
    private var instructions: some View {
        VStack {
            Image(systemName: "checklist")
                .resizable()
                .scaledToFit()
                .frame(height: 90)
                .padding(.top, 40)
                .padding([.horizontal, .bottom])
                .foregroundStyle(.yellow)
            
            Text("Pick \(viewModel.maxSelections) Names")
                .font(.largeTitle)
                .bold()
                .padding()
                .foregroundStyle(.tint)
            
            Text(instructionsText)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                withAnimation {
                    showInstructions = false
                }
            } label: {
                Text("Find Names!")
                    .font(.headline)
            }
            .buttonStyle(BorderedButtonStyle())
            .padding(.top, 40)

            Spacer()
        }
    }
}


#if DEBUG

// MARK: - Preview

#Preview {
    NamePickerView(sex: .male)
        .modelContainer(previewModelContainer_WithFavorites)
}

#endif
