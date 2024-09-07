//
//  NamePreviewCard.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/31/24.
//
import SwiftUI

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
    @AppStorage("lastName") private var lastName = ""
    
    
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
            HStack {
                Text("How's this name?")
                    .font(.headline).bold()
                Spacer()
            }
            
            HStack {
                getRatingButton(.decrease)
                    .font(.headline)
                
                Spacer()
                Text(name?.text ?? "No")
                Text(lastName)
                Spacer()
                
                getRatingButton(.increase)
                    .font(.headline)
            }
            .font(.title2).bold()
        }
        .listRowBackground(Color.accentColor.opacity(0.3))
        // MARK: - On Appear
        .task {
            fetchAndStartTimer()
        }
    }
    
    
    // MARK: - View Component
    
    private func getRatingButton(_ adjustment: Adjustment) -> some View {
        return Button {
            // Prevent button from being tapped repeatedly
            if buttonsDisabled {
                return
            } else {
                buttonsDisabled = true
            }
            
            // Update the affinity rating
            updateRating(adjustment)
            
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
            
        } label: {
            Image(systemName: adjustment == .decrease ? dislikeImageName : likeImageName)
        }
        .buttonStyle(BorderlessButtonStyle())
        .foregroundStyle(.primary)
        .scaleEffect(adjustment == .decrease ? dislikeImageSize : likeImageSize)
        .overlay(
            ZStack {
                if adjustment == .decrease ? dislikeImageShowStars : likeImageShowStars {
                    ForEach(0..<5) { i in
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
        .onChange(of: adjustment == .decrease ? dislikeImageName : likeImageName ) {
            handleImageSizeChange(for: adjustment)
        }
        
    }
    
    
    // MARK: - Methods
    
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
            logError("Unable to fetch names to generate a random name for Name Preview Card: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Image Methods
    
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
    
    
    // MARK: - Rating Methods
    
    private func updateRating(_ adjustment: Adjustment) {
        guard let name = name else {
            logError("Unable to get Name object in Name Preview Card")
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
            logError("Unable to set affinity to new rating in Name Preview Card while increasing: \(error.localizedDescription)")
        }
    }
    
    private func decreaseRating(of name: Name, by amount: Int = 50) {
        do {
            try name.setAffinity(name.affinityRating - amount)
            
        } catch {
            logError("Unable to set affinity to new rating in Name Preview Card while increasing: \(error.localizedDescription)")
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
