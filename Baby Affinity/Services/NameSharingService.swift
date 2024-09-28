//
//  NameSharingService.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/15/24.
//

import Foundation
import MultipeerConnectivity
import SystemLogger

// MARK: - Name Sharing Service

/// A service class for handling name sharing between peers using Multipeer Connectivity.
///
/// This class manages the process of advertising the peer, browsing for other peers, and exchanging
/// data (specifically an array of `Name` objects) with connected peers. It conforms to the `MCSessionDelegate`,
/// `MCNearbyServiceAdvertiserDelegate`, and `MCNearbyServiceBrowserDelegate` protocols to handle session
/// and service-related events.
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
    
    /// Sends an array of `Name` objects to all connected peers.
    ///
    /// This method checks if there are any connected peers and, if so, encodes the provided array
    /// of `Name` objects into JSON data. The encoded data is then sent to all connected peers
    /// using the `MCSession` instance. If an error occurs during encoding or sending, it is logged.
    ///
    /// - Parameter names: An array of `Name` objects to be sent to the connected peers.
    ///
    /// - Throws: This method does not throw errors directly. However, it handles any errors thrown
    ///   by the `JSONEncoder().encode(_:)` and `session.send(_:toPeers:with:)` methods and logs them.
    ///
    /// - Note: This method assumes that `session` is an instance of `MCSession` and that it is
    ///   properly configured and connected to peers. If no peers are connected, the method does nothing.
    func sendNames(_ names: [Name]) {
        if session.connectedPeers.count > 0 {
            do {
                let data = try JSONEncoder().encode(names)
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                
            } catch let error {
                SystemLogger.main.logError("Error sending names: \(error.localizedDescription)")
            }
        }
    }
    
    /// Updates the session state based on the provided state and peer ID.
    ///
    /// This method is run on the main actor to ensure updates to the session state are performed
    /// on the main thread. It updates the internal `sessionState` property to reflect the current
    /// state of the session with the specified peer.
    ///
    /// - Parameters:
    ///   - state: The new state of the session. This can be `.connected`, `.connecting`, or
    ///     `.notConnected`.
    ///   - peerID: The identifier of the peer whose connection state has changed.
    ///
    /// This method handles the following states:
    /// - `.connected`: Updates the session state to `.connected`.
    /// - `.connecting`: Updates the session state to `.connecting`.
    /// - `.notConnected`: Updates the session state to `.notConnected`.
    /// - `@unknown default`: Logs an error if the state is unknown or unhandled.
    @MainActor
    private func setSessionState(to state: MCSessionState, peer peerID: MCPeerID) {
        switch state {
        case .connected:
            self.sessionState = .connected
            
        case .connecting:
            self.sessionState = .connecting
            
        case .notConnected:
            self.sessionState = .notConnected
            
        @unknown default:
            SystemLogger.main.logWarning("Unknown state for \(peerID.displayName): \(state)")
        }
    }
    
    /// Decodes JSON data into an array of `Name` objects and updates the `receivedNames` property.
    ///
    /// This method attempts to decode the provided JSON-encoded data into an array of `Name` objects.
    /// If the decoding is successful, the `receivedNames` property is updated on the main actor to
    /// ensure thread safety and UI consistency. Any errors encountered during decoding are logged.
    ///
    /// - Parameter data: The JSON-encoded data to be decoded. It is expected to be an array of `Name` objects.
    ///
    /// - Note: This method uses `Task { @MainActor in ... }` to update the `receivedNames` property
    ///   on the main actor, ensuring that UI updates are performed on the main thread.
    func decodeAndPublishNames(from data: Data) {
        do {
            let names = try JSONDecoder().decode([Name].self, from: data)
            
            Task { @MainActor in
                self.receivedNames = names
            }
            
        } catch let error {
            SystemLogger.main.logError("Error decoding received names: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Start and Stop Methods
    
    /// Starts advertising the peer and browsing for other peers.
    ///
    /// This method initiates the process of advertising the current peer to other peers in the network
    /// and starts browsing for nearby peers that are advertising themselves. It is typically called
    /// to make the peer discoverable and to find other peers for connection.
    ///
    /// - Note: Ensure that the `advertiser` and `browser` instances are properly configured before
    ///   calling this method.
    func startAdvertisingAndBrowsing() {
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }

    /// Stops advertising the peer and browsing for other peers.
    ///
    /// This method halts the advertising of the current peer to other peers in the network and stops
    /// browsing for nearby peers. It is typically called to cease peer discovery and advertising when
    /// they are no longer needed or when the application is being closed.
    ///
    /// - Note: This method should be called to clean up resources and stop network activity when
    ///   advertising and browsing are no longer required.
    func stopAdvertisingAndBrowsing() {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
    }
}


// MARK: - Session Delegate

extension NameSharingService: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor in
            setSessionState(to: state, peer: peerID)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        decodeAndPublishNames(from: data)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Not needed for this implementation
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Not needed for this implementation
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Not needed for this implementation
    }
}


// MARK: - Advertiser Delegate

extension NameSharingService: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Received invitation from \(peerID.displayName)")
        
        // Automatically accept the invitation
        invitationHandler(true, session)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        SystemLogger.main.logError("Error starting advertiser: \(error.localizedDescription)")
    }
}


// MARK: - Browser Delegate

extension NameSharingService: MCNearbyServiceBrowserDelegate {
    // Called when a peer is found nearby
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        SystemLogger.main.logInfo("Found peer: \(peerID.displayName)")
        
        // Automatically invite the found peer to join the session
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    // Called when a peer is lost (out of range or disconnected)
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        SystemLogger.main.logInfo("Lost peer: \(peerID.displayName)")
    }
    
    // Handle browser errors
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        SystemLogger.main.logError("Error starting browser: \(error.localizedDescription)")
    }
}
