//
//  MultipeerCommunicator.swift
//  Tinkoff Chat
//
//  Created by Даниил on 08.04.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol Communicator {
    func sendMessage(string: String, to userID: String, completionHandler: ((_ success : Bool,_ error: Error?) -> ())?)
    weak var delegate: CommunicatorDelegate? {get set}
    var online: Bool {get set}
}


class MultipeerCommunicator: NSObject, Communicator{

    private let userServiceType = "tinkoff-chat"
    let localPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    let userName: String
    let advertiser: MCNearbyServiceAdvertiser
    let browser: MCNearbyServiceBrowser
    
    var online: Bool
    var delegate: CommunicatorDelegate?
    
    var sessionDictionary = [String: MCSession]()
    var sessionArray = [MCSession]()
    var foundPeers = [MCPeerID]()
    
    //for multichats
    
//    func availableSession() -> MCSession {
//        
//        for session in sessionArray {
//            if session.connectedPeers.count < kMCSessionMaximumNumberOfPeers {
//                return session
//            }
//        }
//        
//        let newSession: MCSession = self.newSession()
//        sessionArray.append(newSession)
//        
//        return newSession
//    }
//    
//    func newSession() -> MCSession {
//        let session = MCSession(peer: self.localPeerID, securityIdentity: nil, encryptionPreference: .none)
//        session.delegate = self
//        
//        return session
//    }
    
    func setSession(session: MCSession?, peer: MCPeerID) {
        self.sessionDictionary[peer.displayName] = session
    }
    
    func prepareSession(peer: MCPeerID) -> MCSession? {
        var session = self.sessionDictionary[peer.displayName]
        
        if session == nil {
            print("Session is nill")
            session = MCSession(peer: self.localPeerID, securityIdentity: nil, encryptionPreference: .none)
            session?.delegate = self
            self.setSession(session: session, peer: peer)
        }
        return session
    }
    
    override init() {
        
        if Platform.isSimulator {
            self.userName = "Daniil Chepenko - simulator"
        } else {
            self.userName = "Daniil Chepenko - device"
        }
        
        self.advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: ["userName": userName], serviceType: userServiceType)
        self.browser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: userServiceType)
        self.online = true
        
        super.init()
        
        self.advertiser.delegate = self
        self.browser.delegate = self
        
        self.advertiser.startAdvertisingPeer()
        self.browser.startBrowsingForPeers()
    }
    
    func sendMessage(string: String, to userID: String, completionHandler: ((_ success : Bool,_ error: Error?) -> ())?) {
        
        let jsonMessage: [String: String] = [
            "eventType": "TextMessage",
            "messageId": generateMessageId(),
            "text": string
        ]
        
        if JSONSerialization.isValidJSONObject(jsonMessage) {
            do {
                let rawData = try JSONSerialization.data(withJSONObject: jsonMessage, options: .prettyPrinted)
                
                if let sessionWithUser = sessionDictionary[userID] {
                    if sessionWithUser.connectedPeers.count > 0 {
                        do {
                            try sessionWithUser.send(rawData, toPeers: sessionWithUser.connectedPeers, with: .reliable)
                        } catch let error {
                            print("Error for sending: \(error)")
                        }
                    }
                }
            } catch let error {
                print ("Error for parsing \(error)")
            }
        }
        
    }

    
    func generateMessageId() -> String {
        let string = "\(arc4random_uniform(UINT32_MAX)) + \(Date.timeIntervalSinceReferenceDate) + \(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString()
        return string!
    }
}

//MARK: - MCNearbyServiceAdvertiserDelegate

extension MultipeerCommunicator: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Recieved invitation from: \(peerID.displayName)")
        let session = prepareSession(peer: peerID)
        invitationHandler(true, session)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Error is: \(error)")
    }
}

//MARK: - MCNearbyServiceBrowserDelegate

extension MultipeerCommunicator: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer: \(peerID.displayName)")
        
//        if !foundPeers.contains(peerID) {
//            foundPeers.append(peerID)
            if let info = info?["userName"] {
                print("name \(info)")
                delegate?.didFoundUser(userID: peerID.displayName, userName: info)
                browser.invitePeer(peerID, to: prepareSession(peer: peerID)!, withContext: nil, timeout: 10)
//            }
        } else {
            print("This peer is already exist in the dictionary")
        }
}
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
        delegate?.didLostUser(userID: peerID.displayName)
    }
}

//MARK: - MCSessionDelegate

extension MultipeerCommunicator : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            //TO-DO: сделать проверку на нахождение пира
            online = true
            print("peer \(peerID) state is connceted")
        default:
            online = false
            print("peer \(peerID) state is not connected: \(state)")
        }
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
            //let recievedData = String(data: data, encoding: String.Encoding.utf8)
            let recievedData = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:String]
        
            delegate?.didRecieveMessage(text: recievedData["text"]!, fromUser: peerID.displayName, toUser: "")
            print("didRecieveData \(recievedData["text"]!)")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        print("didFinishReceivingResourceWithName")
    }
    
}
