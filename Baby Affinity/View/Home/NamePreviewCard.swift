//
//  NamePreviewCard.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/31/24.
//

import SwiftUI
import SystemLogger

// MARK: - Name Preview Card

struct NamePreviewCard: View, NamePersistenceController {
    
    // MARK: - Adjustment
    
    enum Adjustment {
        case increase, decrease
    }
    
    
    // MARK: - Properties
    
    /// The environment's model context.
    @Environment(\.modelContext) var modelContext
    
    /// The selected sex for which the names are filtered, stored in `AppStorage`.
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    /// The `Name` used to display within the card.
    @State private var name: Name?
    
    /// The last name, stored in `AppStorage`.
    @AppStorage("lastName") private(set) var lastName = ""
    
    
    // MARK: - Controls and Constants
    
    @State private var nameChangeTimer: Timer?
    private let rateOfNameChange: TimeInterval = 10
    
    @State private var buttonsDisabled = false
    
    private let dislikeInactiveImageName = "hand.thumbsdown"
    private let dislikeActiveImageName = "hand.thumbsdown.fill"
    @State private var dislikeImageName = "hand.thumbsdown"
    @State private var dislikeImageSize = CGSize(width: 1, height: 1)
    @State private var dislikeImageShowStars = false
    
    private let likeInactiveImageName = "hand.thumbsup"
    private let likeActiveImageName = "hand.thumbsup.fill"
    @State private var likeImageName = "hand.thumbsup"
    @State private var likeImageSize = CGSize(width: 1, height: 1)
    @State private var likeImageShowStars = false
    
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 32) {
            
            // MARK: - Title
            
            Text("How's this name?")
                .font(.headline).bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            // MARK: - Name and Rating Buttons
            
            HStack {
                getRatingButton(.decrease)
                    .font(.headline)
                
                Text("\(name?.text ?? "") \(lastName)")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                
                getRatingButton(.increase)
                    .font(.headline)
            }
        }
        .listRowBackground(Color.accentColor.opacity(0.3))
        
        
        // MARK: - Task
        
        .task {
            fetchAndStartTimer()
        }
        
        
        // MARK: - On Change
        
        .onChange(of: selectedSex) {
            nameChangeTimer?.invalidate()
            nameChangeTimer = nil
            fetchAndStartTimer()
        }
    }
}


// MARK: - View Component

extension NamePreviewCard {
    
    // MARK: - Rating Button
    
    /// A button used to make an adjustment to the affinity rating of the `Name`.
    /// - Parameter adjustment: The type that determines an increase or decrease in the rating.
    /// - Returns: The `Button` view used to increase or decrease the rating.
    private func getRatingButton(_ adjustment: Adjustment) -> some View {
        return Button {
            ratingTapped(adjustment)
            
        } label: {
            Image(systemName: adjustment == .decrease ? dislikeImageName : likeImageName)
        }
        .buttonStyle(BorderlessButtonStyle())
        .foregroundStyle(.primary)
        .scaleEffect(adjustment == .decrease ? dislikeImageSize : likeImageSize)
        .overlay(
            ZStack {
                if adjustment == .decrease ? dislikeImageShowStars : likeImageShowStars {
                    ForEach(0..<7) { i in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .scaleEffect(0.5)
                            .position(x: CGFloat.random(in: -30...30), y: CGFloat.random(in: -30...30))
                            .opacity(Double.random(in: 0.7...1))
                            .transition(.scale)
                            .animation(
                                .easeOut(duration: 0.4)
                                .delay(0.1 * Double(i)),
                                value: adjustment == .decrease ? dislikeImageShowStars : likeImageShowStars )
                    }
                }
            }
        )
        
        
        // MARK: - On Change
        
        .onChange(of: adjustment == .decrease ? dislikeImageName : likeImageName ) {
            handleImageSizeChange(for: adjustment)
        }
        
    }
    
    
    // MARK: - Rating Methods
    
    private func ratingTapped(_ adjustment: Adjustment) {
        // Prevent the buttons from being tapped repeatedly
        if buttonsDisabled { return } else {
            buttonsDisabled = true
        }
        
        // Update the affinity rating
        updateRating(adjustment)
        
        handleRatingAnimitation(adjustment)
    }
    
    private func updateRating(_ adjustment: Adjustment) {
        guard let name = name else {
            SystemLogger.main.logCritical("Unable to get Name object in Name Preview Card")
            return
        }
        switch adjustment {
        case .decrease:
            decreaseRating(of: name)
            
        case .increase:
            increaseRating(of: name)
        }
    }
    
    private func increaseRating(of name: Name, by amount: Int = 50) {
        do {
            try name.setAffinity(name.affinityRating + amount)
            
        } catch {
            SystemLogger.main.logError("Unable to set affinity to new rating in Name Preview Card while increasing: \(error.localizedDescription)")
        }
    }
    
    private func decreaseRating(of name: Name, by amount: Int = 50) {
        do {
            try name.setAffinity(name.affinityRating - amount)
            
        } catch {
            SystemLogger.main.logError("Unable to set affinity to new rating in Name Preview Card while increasing: \(error.localizedDescription)")
        }
    }
    
    private func handleRatingAnimitation(_ adjustment: Adjustment) {
        // Toggle image and show stars
        withAnimation {
            switch adjustment {
            case .decrease:
                toggleImage(.decrease)
                dislikeImageShowStars = true
                
            case .increase:
                toggleImage(.increase)
                likeImageShowStars = true
            }
        }
        
        // Hide stars after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                switch adjustment {
                case .decrease:
                    dislikeImageShowStars = false
                    
                case .increase:
                    likeImageShowStars = false
                }
            }
        }
    }
    
    private func handleImageSizeChange(for adjustment: Adjustment) {
        let temporarySize = CGSize(width: 1.3, height: 1.3)
        let originalSize = CGSize(width: 1, height: 1)
        
        switch adjustment {
        case .decrease:
            handleDislikeImageSize(original: originalSize, temporary: temporarySize)
            
        case .increase:
            handleLikeImageSize(original: originalSize, temporary: temporarySize)
        }
    }
    
    private func handleLikeImageSize(original: CGSize, temporary: CGSize) {
        withAnimation {
            likeImageSize = temporary
            
        } completion: {
            likeImageSize = original
        }
    }
    
    private func handleDislikeImageSize(original: CGSize, temporary: CGSize) {
        withAnimation {
            dislikeImageSize = temporary
            
        } completion: {
            dislikeImageSize = original
        }
    }
    
    private func setImagesInactive() {
        dislikeImageName = dislikeInactiveImageName
        likeImageName = likeInactiveImageName
    }
    
    private func toggleImage(_ adjustment: Adjustment) {
        switch adjustment {
        case .decrease:
            toggleDislikeImage()
            
        case .increase:
            toggleLikeImage()
        }
    }
    
    private func toggleDislikeImage() {
        dislikeImageName = dislikeImageName == dislikeInactiveImageName ? dislikeActiveImageName : dislikeInactiveImageName
    }
    
    private func toggleLikeImage() {
        likeImageName = likeImageName == likeInactiveImageName ? likeActiveImageName : likeInactiveImageName
    }
}


// MARK: - Methods

extension NamePreviewCard {
    
    private func fetchAndStartTimer() {
        if nameChangeTimer != nil { return }
        
        fetchName()
        
        nameChangeTimer = Timer.scheduledTimer(withTimeInterval: rateOfNameChange, repeats: true) { _ in
            withAnimation {
                fetchName()
                setImagesInactive()
            }
        }
    }
    
    private func fetchName() {
        do {
            name = try fetchNames(selectedSex).randomElement()
            buttonsDisabled = false
            
        } catch {
            SystemLogger.main.logCritical("Unable to fetch names to generate a random name for Name Preview Card: \(error.localizedDescription)")
        }
    }
}


#if DEBUG

// MARK: - Preview

#Preview("Name Preview Card in a List") {
    List {
        NamePreviewCard()
    }
    .modelContainer(previewModelContainer)
}

#endif
