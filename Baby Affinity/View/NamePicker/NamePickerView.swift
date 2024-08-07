//
//  NamePickerView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/5/24.
//

import SwiftUI
import SwiftData

// FIXME: Upon submission, the app crashes when calculating new ratings. When rapidly submitted. Try fixing Home View's performance first.

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
    
    
    // MARK: - Controls and Constants
    
    /// Title for the navigation bar, indicating the number of names to pick.
    private var title: String { "Pick \(viewModel.maxSelections) Names" }
    
    /// State variable for showing the sex selection dialog.
    @State private var showSexSelection = false
    
    /// State variable for showing the instructions sheet.
    @State private var showInstructions = true
    
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            List {
                
                // Chosen Names
                
                if !viewModel.selectedNames.isEmpty { // Only show if names are chosen
                    Section(header: Text("Chosen Names")) {
                        ForEach(viewModel.selectedNames) { name in
                            HStack {
                                Text(name.text)
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        viewModel.deselect(name)
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
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
            // MARK: - Toolbar
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    submitNamesButton
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
    }
    
    
    // MARK: - Methods
    
    /// Submit the names for rating.
    private func loadNames() {
        viewModel.load(names.filter { $0.sex == selectedSex })
    }
}


// MARK: - View Components

extension NamePickerView {
    
    /// Button for submitting chosen names or fetching new names.
    private var submitNamesButton: some View {
        Button {
            Task {
                await viewModel.updateRatings()
                
                withAnimation {
                    viewModel.load(names.filter { $0.sex == selectedSex})
                }
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
    NamePickerView()
        .modelContainer(previewModelContainer_WithFavorites)
}

#endif
