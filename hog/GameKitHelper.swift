//
//  GameKitHelper.swift
//  hog
//
//  Created by Mike Cargal on 1/22/21.
//

import GameKit

class GameKitHelper: NSObject {
    
    var authenticationViewController : UIViewController?
    var gameCenterViewController: GKGameCenterViewController?
    
    // MARK: - GAME CENTER METHODS
    func authenticateLocalPlayer() {
        // prepare for the new controller
        authenticationViewController = nil
        
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let viewController = viewController {
                self.authenticationViewController = viewController
                NotificationCenter.default.post(
                    name: .presentAuthenticationViewController,
                    object: self)
               return
            }
            if error != nil {
               return // player could not be authenticated
            }
            if GKLocalPlayer.local.isUnderage {
                // hide explicit content (??? whatever ???)
            }
            if GKLocalPlayer.local.isMultiplayerGamingRestricted {
                // disble multiplayer game features
            }
            if GKLocalPlayer.local.isPersonalizedCommunicationRestricted {
                // disable in-game communication
            }
            
        }
    }
    
    static let shared: GameKitHelper = {
        let instance = GameKitHelper()
        return instance
    }()
}

// MARK: DELEGATE EXTENSIONS
extension GameKitHelper: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func showGKGamecenter(state: GKGameCenterViewControllerState) {
        guard GKLocalPlayer.local.isAuthenticated else {return}
        gameCenterViewController = nil
        if #available(iOS 14, *) {
            gameCenterViewController = GKGameCenterViewController(state: state)
        } else {
            gameCenterViewController = GKGameCenterViewController()
            gameCenterViewController?.viewState = state
        }
        gameCenterViewController?.gameCenterDelegate = self
        NotificationCenter.default.post(name: .presentGameCenterViewController, object: self)
    }
}

extension Notification.Name {
    static let presentAuthenticationViewController = Notification.Name("presentAuthenticationViewController")
    static let presentGameCenterViewController = Notification.Name("presentGameCenterViewController")
}
