//
//  FavoriteNamesView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/3/24.
//

import SwiftUI
import SwiftData


/// A list view of the favorite `Name`s.
struct FavoriteNamesView: View {
    
    // MARK: - Properties
    
    /// The environment's model context.
    @Environment(\.modelContext) private var modelContext
    
    /// The selected sex for which the names are filtered, stored in `AppStorage`.
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    /// The names of the selected `Sex` that are labeled as a favorite.
    var names: [Name]
    
    /// The list of names to be presented within the view.
    @State private var presentedNames: [Name] = []
    
    
    // MARK: - Controls and Constants
    
    /// The maximum number of names to be presented.
    private let maxPresentedNames = 5
    
    
    // MARK: - Body
    
    var body: some View {
        Section(
            header: Text("Favorite \(self.selectedSex.alternateName) Names")) {
                
                // MARK: - Cell View
                
                if presentedNames.isEmpty {   // No favorite names are available
                    self.noFavoritesFound
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    
                } else {                      // Favorites are available
                    ForEach(self.presentedNames, id: \.self) { name in
                        NameCellView(name: name, rank: name.getRank(from: modelContext) ?? 0)
                    }
                }
                
                
                // MARK: - Footer View
                
                HStack {
                    Spacer()
                    
                    // Reload names
                    Button {
                        withAnimation {
                            self.loadNames()
                        }
                        
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline)
                    }
                    .buttonStyle(.borderless)
                    .sensoryFeedback(.impact, trigger: self.presentedNames)
                }
            }
            .onAppear {
                // MARK: - On Appear
                
                withAnimation {
                    self.loadNames()
                }
            }
            .onChange(of: self.names) { oldValue, newValue in
                // MARK: - On Change
                
                guard self.presentedNames.count < self.maxPresentedNames
                else { return }
                
                self.loadNames()
            }
    }
}


// MARK: - View Components

extension FavoriteNamesView {
    
    // MARK: - Empty Favorites View
    
    /// The text to be displayed when no favorite `Name`s are found.
    private var noFavoritesText: String {
        "No favorite \(self.selectedSex.alternateName.lowercased()) names are found! Try adding them to your favorites to keep them available here."
    }
    
    /// A view to display when no favorite `Name`s are found.
    private var noFavoritesFound: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundColor(.yellow)
            
            Text(noFavoritesText)
                .multilineTextAlignment(.center)
        }
    }
}


// MARK: - Methods

extension FavoriteNamesView {
    
    /// Load names to be presented in the view.
    private func loadNames() {
        let maxCount = min(self.maxPresentedNames, self.names.count)
        
        guard maxCount > 0 else {
            self.presentedNames = []
            return
        }
        
        self.presentedNames = self.names.randomElements(count: self.maxPresentedNames)
    }
}


#if DEBUG

// MARK: - Preview

#Preview {
    
    let names = (1...10).map {
        Name("Name \($0)", sex: .male, affinityRating: 1200)
    }
    
    
    return List {
        FavoriteNamesView(names: names)
            .modelContainer(previewModelContainer_WithFavorites)
    }
}

#endif
