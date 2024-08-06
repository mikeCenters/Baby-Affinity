//
//  NamePickerViewModel.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/6/24.
//
import Foundation

/// `NamePickerViewModel` is a view model for managing the process of presenting and selecting names.
class NamePickerViewModel: ObservableObject {
    
    // MARK: - Properties
    
    /// The names to present to the user.
    @Published var presentedNames: [Name] = []
    
    /// The names chosen by the user.
    @Published var chosenNames: [Name] = []
    
    
    // MARK: - Constants
    
    /// The maximum number of names that can be selected by the user.
    let maxSelections = 5
    
    /// The number of names to present to the user.
    let numChoices = 10
    
    
    // MARK: - Methods
    
    /// Loads the names to be presented to the user.
    ///
    /// This method divides the input list of names into three groups: top 20%, middle 60%, and bottom 20%.
    /// From these groups, it selects names to present: 2 from the top 20%, 7 from the middle 60%, and 1 from the bottom 20%.
    /// - Parameter names: The list of names to be processed and presented.
    func load(_ names: [Name]) {
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
    
    /// Selects a name from the presented names and adds it to the chosen names.
    ///
    /// If the number of chosen names is less than the maximum allowed selections, the selected name is added to the chosen names
    /// and removed from the presented names.
    /// - Parameter name: The name to be selected.
    func select(_ name: Name) {
        if self.chosenNames.count < maxSelections {
            self.chosenNames.append(name)
            self.presentedNames.removeAll { $0 == name }
        }
    }
    
    /// Deselects a name from the chosen names and adds it back to the presented names.
    ///
    /// The deselected name is removed from the chosen names and added back to the presented names.
    /// - Parameter name: The name to be deselected.
    func deselect(_ name: Name) {
        self.chosenNames.removeAll { $0 == name }
        self.presentedNames.append(name)
    }
    
    /// Submits the chosen names for rating asynchronously.
    ///
    /// This method is a placeholder for the actual submission logic, which should be implemented in the FIXME section.
    func submitNames() async {
        // FIXME: Submit
    }
}
