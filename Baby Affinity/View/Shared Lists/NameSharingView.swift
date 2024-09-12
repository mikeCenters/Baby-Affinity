//
//  NameSharingView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/8/24.
//

import SwiftUI

import MultipeerConnectivity

class NameSharingService: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private var peerID: MCPeerID
    private var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser
    private var browser: MCNearbyServiceBrowser
    
    @Published private(set) var sessionState: MCSessionState = .notConnected
    @Published private(set) var receivedNames: [Name]? = nil
    
    
    // MARK: - Init
    
    override init() {
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        self.advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "name-sharing")
        self.browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "name-sharing")
        super.init()
        
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
    }
    
    
    // MARK: - Methods
    
    func sendNames(_ names: [Name]) {
        if session.connectedPeers.count > 0 {
            do {
                let data = try JSONEncoder().encode(names)
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                
            } catch let error {
                logError("Error sending names: \(error.localizedDescription)")
            }
        }
    }
}


// MARK: - Session Delegate

extension NameSharingService: MCSessionDelegate {
    
    // Called when a peer's state changes (connected, connecting, not connected)
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            withAnimation {
                sessionState = .connected
            }
            
        case .connecting:
            withAnimation {
                sessionState = .connecting
            }
            
        case .notConnected:
            withAnimation {
                sessionState = .notConnected
            }
            
        @unknown default:
            logError("Unknown state for \(peerID.displayName): \(state)")
        }
    }
    
    // Called when data is received from a peer
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            receivedNames = try JSONDecoder().decode([Name].self, from: data)
            
        } catch let error {
            logError("Error decoding received names: \(error.localizedDescription)")
        }
    }
    
    // Called when a stream is received (not used here, but required to implement)
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Not needed for this implementation
    }
    
    // Called when a resource is received (not used here, but required to implement)
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Not needed for this implementation
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Not needed for this implementation
    }
    
    
    // MARK: - Start and Stop Methods
    
    func startAdvertisingAndBrowsing() {
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }
    
    func stopAdvertisingAndBrowsing() {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
    }
}


// MARK: - Advertiser Delegate

extension NameSharingService: MCNearbyServiceAdvertiserDelegate {
    // Called when a peer invites you to connect
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Received invitation from \(peerID.displayName)")
        // Automatically accept the invitation
        invitationHandler(true, session)
    }
    
    // Handle advertiser errors
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Error starting advertiser: \(error.localizedDescription)")
    }
}


// MARK: - Browser Delegate

extension NameSharingService: MCNearbyServiceBrowserDelegate {
    // Called when a peer is found nearby
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer: \(peerID.displayName)")
        // Automatically invite the found peer to join the session
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    // Called when a peer is lost (out of range or disconnected)
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
    }
    
    // Handle browser errors
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Error starting browser: \(error.localizedDescription)")
    }
}


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
            Text("Names Received")
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
        
        
        // MARK: - On Change
        
        .onChange(of: nameSharingService.sessionState) { oldValue, newValue in
            switch newValue {
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
        
        
        // MARK: - On Receive
        
        .onReceive(nameSharingService.$receivedNames) { names in
            guard let names = names, !names.isEmpty else {
                return
            }
            
            isShowingReceivedNames = true
        }
    }
}

#if DEBUG

// MARK: - Previews

#Preview {
    NameSharingView()
        .modelContainer(previewModelContainer)
}

#endif
