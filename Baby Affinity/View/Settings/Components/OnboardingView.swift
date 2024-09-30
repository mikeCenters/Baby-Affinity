//
//  OnboardingView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/27/24.
//

import SwiftUI

// MARK: - Onboarding View

struct OnboardingView: View, NamePersistenceController_Admin {
    
    // MARK: - Properties
    
    /// The environment variable to access the model context for data persistence.
    @Environment(\.modelContext) var modelContext
    
    
    // MARK: - Controls
    
    /// Controls whether the onboarding view is currently shown.
    @Binding var isShown: Bool
    
    /// Tracks the loading state, particularly for asynchronous data tasks.
    @State private var isLoading: Bool = false
    
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "books.vertical.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120)
                    .foregroundStyle(.tint)
                
                VStack {
                    Text("Welcome to")
                    
                    Text("Baby Affinity")
                        .foregroundStyle(.tint)
                }
                .font(.largeTitle).bold()
                
                    
                // Detail Section
                VStack(alignment: .leading, spacing: 16) {
                    getSectionDetail(imageName: "list.number",
                                     title: "Over 2,000 Names",
                                     subtitle: "...and growing! Welcome to the last list of names you need to search for your next baby's name! ")
                    
                    getSectionDetail(imageName: "plus.forwardslash.minus",
                                     title: "Affinity Rating",
                                     subtitle: "Every name you choose is assigned a unique rating to help identify your likeness!")
                    
                    getSectionDetail(imageName: "checkmark.square",
                                     title: "Fun and Exciting!",
                                     subtitle: "No more endless searching! Your baby's first important decision should be easy.")
                }
                
                Spacer()
                
                findNamesButton
            }
            .padding(.horizontal)
        }
        
        
        // MARK: - Animation
        
        .transition(.move(edge: .bottom))
        .animation(.easeInOut, value: isShown)
        
        
        // MARK: - Task
        
        .task {
            loadData()
        }
    }
    
    
    // MARK: - View Components
    
    private var findNamesButton: some View {
        Button {
            guard !isLoading else { return }
            
            withAnimation {
                isShown = false
            }
            
        } label: {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(.white)
                    .padding(8)
                
            } else {
                Text("Find Names!")
                    .font(.title3).bold()
                    .padding(8)
            }
        }
        .buttonStyle(BorderedProminentButtonStyle())
    }
    
    private func getSectionDetail(imageName: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .center) {
            Image(systemName: imageName)
                .font(.largeTitle)
                .foregroundStyle(.tint)
                .padding()
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(3, reservesSpace: true)
            }
        }
    }
    
    
    // MARK: - Methods
    
    /// Loads default name data asynchronously and updates the loading state.
    private  func loadData() {
        Task {
            setLoadingState(to: true)
            await loadDefaultNames()
            setLoadingState(to: false)
        }
    }
    
    /// Sets the loading state with animation.
    /// - Parameter state: A boolean indicating whether loading is in progress.
    private func setLoadingState(to state: Bool) {
        withAnimation {
            isLoading = state
        }
    }
}


#if DEBUG

// MARK: - Previews

#Preview {
    OnboardingView(isShown: .constant(true))
        .modelContainer(previewModelContainer)
}

#endif
