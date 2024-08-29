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
    /// - Parameter names: The list of names to be processed and presented.
    func load(_ names: [Name]) {
        // Check that names is not empty.
        guard !names.isEmpty else { return }
        
        // Empty the selected names array.
        selectedNames = []
        
        // Separate names into evaluated and not evaluated
        var evaluatedNames: [Name] = []
        var notEvaluatedNames: [Name] = []
        
        names.forEach { name in
            name.evaluated > 0 ? evaluatedNames.append(name) : notEvaluatedNames.append(name)
        }
        
        // Sort evaluated names by affinity rating
        evaluatedNames.sort { $0.affinityRating < $1.affinityRating }
        
        // Find the median index
        let medianIndex = evaluatedNames.count / 2
        let belowMedianNames = evaluatedNames.prefix(medianIndex)
        let aboveMedianNames = evaluatedNames.suffix(from: medianIndex)
        
        // Calculate top 20% count for above median names
        let top20PercentCount = max(1, Int(Double(aboveMedianNames.count) * 0.2))
        
        // The array of names to present to the view
        var namesToShow: [Name] = []
        
        if notEvaluatedNames.isEmpty {      // All names have been evaluated.
            namesToShow.append(contentsOf: belowMedianNames.shuffled().prefix(1))
            namesToShow.append(contentsOf: aboveMedianNames.suffix(top20PercentCount).shuffled().prefix(3))
            namesToShow.append(contentsOf: aboveMedianNames.dropLast(top20PercentCount).shuffled().prefix(6))
            
        } else {                            // Some names still need evaluated.
            namesToShow.append(contentsOf: aboveMedianNames.suffix(top20PercentCount).shuffled().prefix(2))
            namesToShow.append(contentsOf: notEvaluatedNames.shuffled().prefix(8))
        }
        
        presentedNames = namesToShow.shuffled()
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
    func updateRatings() {
        let winners = selectedNames
        let losers = presentedNames
        // Get the group rating.
        let groupRating = calculateGroupRating(winners: winners, losers: losers)
        
        // FIXME: Check error handling. Possibly refactor.
        // Assign new Affinity ratings to names.
        for name in winners {
            let ratings = AffinityCalculator.getScores(winnerRating: name.affinityRating, loserRating: groupRating)
            
            do {
                try name.setAffinity(ratings.newWinnerRating)
                name.increaseEvaluationCount()
                
            } catch Name.NameError.ratingBelowMinimum {
                try! name.setAffinity(Name.minimumAffinityRating)
                logError("Affinity Rating below minimum, \(Name.minimumAffinityRating). Affinity Calculator produced the updated rating when calculating winners.")
                
            } catch {
                logError("Unexpected error: \(error.localizedDescription)")
            }
        }
        
        // FIXME: Check error handling. Possibly refactor.
        for name in losers {
            let ratings = AffinityCalculator.getScores(winnerRating: groupRating, loserRating: name.affinityRating)
            
            do {
                try name.setAffinity(ratings.newLoserRating)
                name.increaseEvaluationCount()
                
            } catch Name.NameError.ratingBelowMinimum {
                try! name.setAffinity(Name.minimumAffinityRating)
                logError("Affinity Rating below minimum, \(Name.minimumAffinityRating). Affinity Calculator produced the updated rating when calculating winners.")
                
            } catch {
                logError("Unexpected error: \(error.localizedDescription)")
            }
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
