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
    @Published var selectedNames: [Name] = []
    
    
    // MARK: - Constants
    
    /// The maximum number of names that can be selected by the user.
    let maxSelections = 5
    
    
    // MARK: - Methods
    
    /// Loads the names to be presented to the user.
    ///
    /// This method divides the input list of names into three groups: top 20%, middle 60%, and bottom 20%.
    /// From these groups, it selects names to present: 2 from the top 20%, 7 from the middle 60%, and 1 from the bottom 20%.
    /// - Parameter names: The list of names to be processed and presented.
    func load(_ names: [Name]) {
        
        /// FIXME: Update what names are to be selected for viewing.
        /// Example:
        /// Filter the names into groups based on the median rating; one group below, one group above.
        /// One group of "not evaluated names".
        ///
        /// If not evaluated has a count:
        ///     Show 2 from the top median group.
        ///     Show 8 from the not evaluated group.
        ///
        /// Else:
        ///     Show 1 below the median.
        ///     Show 3 from the top 20% above the median.
        ///     Show 6 from the median to the top 20%.
        
        
        let totalNames = names.count
        let top20PercentCount = Int(Double(totalNames) * 0.2)
        let bottom20PercentCount = Int(Double(totalNames) * 0.2)
        
        let top20PercentNames = Array(names.prefix(top20PercentCount)).shuffled()
        let bottom20PercentNames = Array(names.suffix(bottom20PercentCount)).shuffled()
        let middleNames = Array(names.dropFirst(top20PercentCount).dropLast(bottom20PercentCount)).shuffled()
        
        let topNames = top20PercentNames.prefix(2)
        let middleNamesToShow = middleNames.prefix(7)
        let bottomNames = bottom20PercentNames.prefix(1)
        
        selectedNames = []
        presentedNames = Array(topNames) + Array(middleNamesToShow) + Array(bottomNames)
    }
    
    /// Selects a name from the presented names and adds it to the chosen names.
    ///
    /// If the number of chosen names is less than the maximum allowed selections, the selected name is added to the chosen names
    /// and removed from the presented names.
    /// - Parameter name: The name to be selected.
    func select(_ name: Name) {
        if selectedNames.count < maxSelections {
            selectedNames.append(name)
            presentedNames.removeAll { $0 == name }
        }
    }
    
    /// Deselects a name from the chosen names and adds it back to the presented names.
    ///
    /// The deselected name is removed from the chosen names and added back to the presented names.
    /// - Parameter name: The name to be deselected.
    func deselect(_ name: Name) {
        selectedNames.removeAll { $0 == name }
        presentedNames.append(name)
    }
    
    /// Updates the affinity ratings of the provided names..
    ///
    /// This method updates the affinity ratings of the provided winners and losers based on the group rating.
    /// The affinity ratings are recalculated using the `AffinityCalculator` based on the  group rating, and
    /// the evaluation count for each name is incremented.
    ///
    /// - Parameters:
    ///   - winners: An array of `Name` objects that have been selected.
    ///   - losers: An array of `Name` objects that have been presented but not selected.
    func updateRatings(winners: [Name], losers: [Name]) {
        // Get the group rating.
        let groupRating = calculateGroupRating(winners: winners, losers: losers)
        
        // Assign new Affinity ratings to names.
        for name in winners {
            let ratings = AffinityCalculator.getScores(winnerRating: name.affinityRating, loserRating: groupRating)
            name.setAffinity(ratings.newWinnerRating)
            name.increaseEvaluationCount()
        }
        
        for name in losers {
            let ratings = AffinityCalculator.getScores(winnerRating: groupRating, loserRating: name.affinityRating)
            name.setAffinity(ratings.newLoserRating)
            name.increaseEvaluationCount()
        }
    }
    
    /// Calculates the average affinity rating for the group of presented and selected names.
    ///
    /// This method computes the average affinity rating for both selected (winners) and presented (losers) names,
    /// and then returns the average of these two values as the group rating.
    ///
    /// - Parameters:
    ///   - winners: An array of `Name` objects that have been chosen as winners.
    ///   - losers: An array of `Name` objects that have been presented but not chosen.
    /// - Returns: The group average affinity rating as an integer.
    private func calculateGroupRating(winners: [Name], losers: [Name]) -> Rating {
        // Get Winner's Average Affinity Rating.
        let winnersTotalRating = winners.compactMap { $0.affinityRating }.reduce(0, +)
        let winnersAverageRating = Decimal(winnersTotalRating) / Decimal(winners.count)
        
        // Get Loser's Average Affinity Rating.
        let losersTotalRating = losers.compactMap { $0.affinityRating }.reduce(0, +)
        let losersAverageRating = Decimal(losersTotalRating) / Decimal(losers.count)
        
        // Get Group Average Affinity Rating.
        let groupRating = (winnersAverageRating + losersAverageRating) / 2
        return groupRating.convertToInt()
    }
}
