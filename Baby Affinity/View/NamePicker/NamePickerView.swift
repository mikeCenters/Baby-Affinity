//
//  NamePickerView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/5/24.
//

import SwiftUI
import SwiftData

struct NamePickerView: View {
    
    // MARK: - Fetch Descriptor
    
    /// The `FetchDescriptor` used to return the names of the provided `Sex`.
    static private func fetchDescriptor(for sex: Sex) -> FetchDescriptor<Name> {
        return FetchDescriptor<Name>(
            predicate: #Predicate { $0.sexRawValue == sex.rawValue },
            sortBy: [
                .init(\.affinityRating, order: .reverse)
            ]
        )
    }
    
    
    // MARK: - Properties
    
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    @Query private var names: [Name]
    
    /// The names to present to the user.
    @State private var presentedNames: [Name] = []
    /// The names chosen via the user.
    @State private var chosenNames: [Name] = []
    
    
    // MARK: - Controls and Constants
    
    private let maxSelections = 5
    private let numChoices = 10
    @State private var showSexSelection = false
    @State private var showInstructions = true
    
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            List {
                
                // Chosen Names
                
                if !chosenNames.isEmpty {
                    Section(header: Text("Chosen Names")) {
                        ForEach(chosenNames) { name in
                            HStack {
                                Text(name.text)
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        deselectName(name)
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
                
                ForEach(self.presentedNames) { name in
                    Button {
                        withAnimation {
                            self.selectName(name)
                        }
                        
                    } label: {
                        Text(name.text)
                    }
                }
                
                
            }
            .onAppear {
                // MARK: - On Appear
                
                withAnimation {
                    self.loadNames()
                }
            }
            .onChange(of: self.selectedSex, { oldValue, newValue in
                // MARK: - On Change
                
                withAnimation {
                    self.loadNames()
                }
            })
            .navigationTitle("Pick \(self.maxSelections) Names")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        withAnimation {
                            self.submitNames()
                        }
                        
                    } label: {
                        Text(self.chosenNames.isEmpty ? "New Names" : "Submit")
                    }
                    .buttonStyle(BorderedButtonStyle())
                    
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            self.showSexSelection.toggle()
                        }
                    } label: {
                        Image(systemName: "switch.2")
                    }
                    .confirmationDialog("Show which names?", isPresented: self.$showSexSelection) {
                        
                        ForEach(Sex.allCases, id: \.self) { sex in
                            Button {
                                withAnimation {
                                    self.selectedSex = sex
                                }
                                
                            } label: {
                                Text(sex.alternateName)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: self.$showInstructions) {
                VStack {
                    Image(systemName: "checklist")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 90)
                        .padding(.top, 40)
                        .padding([.horizontal, .bottom])
                        .foregroundStyle(.yellow)
                    
                    Text("Pick \(self.maxSelections) Names")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                        .foregroundStyle(.tint)
                    
                    Text("Choose up to \(self.maxSelections) names from the list that are to your liking. While there may be other names that you would want to name your baby, pick among these that you like the most. \n\nIf you don't like the available names, simply select new names.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button {
                        withAnimation {
                            self.showInstructions = false
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
    }
    
    
    // MARK: - Methods
    
    private func loadNames() {
        let totalNames = names.count
        let top20PercentCount = Int(Double(totalNames) * 0.2)
        let bottom20PercentCount = Int(Double(totalNames) * 0.2)
        
        let top20PercentNames = Array(names.prefix(top20PercentCount)).shuffled()
        let bottom20PercentNames = Array(names.suffix(bottom20PercentCount)).shuffled()
        let middleNames = Array(names.dropFirst(top20PercentCount).dropLast(bottom20PercentCount)).shuffled()
        
        let topNames = top20PercentNames.prefix(2)
        let middleNamesToShow = middleNames.prefix(7)
        let bottomNames = bottom20PercentNames.prefix(1)
        
        self.chosenNames = []
        self.presentedNames = Array(topNames) + Array(middleNamesToShow) + Array(bottomNames)
    }
    
    private func selectName(_ name: Name) {
        if self.chosenNames.count < maxSelections {
            self.chosenNames.append(name)
            self.presentedNames.removeAll { $0 == name }
        }
    }
    
    private func deselectName(_ name: Name) {
        self.chosenNames.removeAll { $0 == name }
        self.presentedNames.append(name)
    }
    
    private func submitNames() {
        // FIXME: Submit
        self.chosenNames = []
        self.loadNames()
    }
}


#if DEBUG

// MARK: - Preview

#Preview {
    NamePickerView()
        .modelContainer(previewModelContainer_WithFavorites)
}

#endif
