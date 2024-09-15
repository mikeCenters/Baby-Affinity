//
//  NameSharingView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/8/24.
//

import SwiftUI


// MARK: - Name Sharing View

struct NameSharingView: View, NamePersistenceController {
    
    // MARK: - Properties
    
    @Environment(\.modelContext) internal var modelContext
    
    @StateObject var nameSharingService: NameSharingService = NameSharingService()
    
    
    // MARK: - Controls and Constants
    
    @State private var isShowingReceivedNames: Bool = false
    @State private var isSharingActive = true
    @State private var animationAmount: CGFloat = 1.0
    
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            VStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 100))
                    .foregroundColor(isSharingActive ? .green : .gray)
                    .scaleEffect(animationAmount)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isSharingActive)
                    .onAppear {
                        self.animationAmount = 1.3
                    }
                
                Text("Bring your phones together to share names!")
                    .font(.title)
                    .padding()
                
            }
            
            if nameSharingService.sessionState != .connected {
                VStack {
                    RadiatingSemiCircles()
                        .edgesIgnoringSafeArea(.top)
                        .offset(y: -100)
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $isShowingReceivedNames) {
            let receivedNames = getNames()
            SharedNamesView(maleNames: receivedNames.0, femaleNames: receivedNames.1)
        }
        
        
        // MARK: - On Appear
        
        .onAppear {
            if isSharingActive {
                nameSharingService.startAdvertisingAndBrowsing()
            }
        }
        
        
        // MARK: - On Disappear
        
        .onDisappear {
            nameSharingService.stopAdvertisingAndBrowsing()
        }
        
        
        // MARK: - On Receive
        
        .onReceive(nameSharingService.$receivedNames.receive(on: DispatchQueue.main)) { names in
            guard let names = names, !names.isEmpty else {
                return
            }
            
            isShowingReceivedNames = true
        }
        
        .onReceive(nameSharingService.$sessionState.receive(on: DispatchQueue.main)) { sessionState in
            switch sessionState {
            case .connected:
                do {
                    let fetchedNames = try fetchNames()
                    nameSharingService.sendNames(fetchedNames)
                } catch {
                    logError("Unable to fetch names to send in Name Sharing View: \(error.localizedDescription)")
                }
                
            default:
                break
            }
        }
        
    }
}


// MARK: - Methods

extension NameSharingView: NamePersistenceController_Admin {
    
    private func getNames() -> (RankedMaleNames, RankedFemaleNames) {
        guard let receivedNames = nameSharingService.receivedNames
        else {
            return ([],[])
        }
        
        let maleNames = receivedNames.filter { $0.sex == .male }
        let femaleNames = receivedNames.filter { $0.sex == .female }
        
        return compareNames(maleNames: maleNames, femaleNames: femaleNames)
    }
}


#if DEBUG

// MARK: - Previews

#Preview {
    NameSharingView()
        .modelContainer(previewModelContainer)
}

#endif
