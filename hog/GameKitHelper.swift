//
//  GameKitHelper.swift
//  hog
//
//  Created by Mike Cargal on 1/22/21.
//

import GameKit

class GameKitHelper: NSObject {
    // Leaderboard IDs

    static let leaderBoardIDMostWins = "com.mikecargal.hogdice.wins"

    var authenticationViewController: UIViewController?
    var gameCenterViewController: GKGameCenterViewController?
    var matchmakerViewController: GKTurnBasedMatchmakerViewController?

    // turn-based match properties
    var currentMatch: GKTurnBasedMatch?

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

            if GKLocalPlayer.local.isAuthenticated {
                print("register self as authenicated player")
                GKLocalPlayer.local.register(self)
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

    // Report Score
    func reportScore(score: Int, forLeaderboardID leaderboardID: String, errorHandler: ((Error?) -> Void)? = nil) {
        guard GKLocalPlayer.local.isAuthenticated else {
            return
        }
        if #available(iOS 14, *) {
            GKLeaderboard.submitScore(score,
                                      context: 0,
                                      player: GKLocalPlayer.local,
                                      leaderboardIDs: [leaderboardID],
                                      completionHandler: errorHandler ?? {
                                          error in
                                          print("error: \(String(describing: error))")
                                      })
        } else {
            let gkScore = GKScore(leaderboardIdentifier: leaderboardID)
            gkScore.value = Int64(score)
            GKScore.report([gkScore], withCompletionHandler: errorHandler)
        }
    }

    func reportachievements(acheivements: [GKAchievement],
                            errorHandler: ((Error?) -> Void)? = nil)
    {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        GKAchievement.report(acheivements, withCompletionHandler: errorHandler)
    }

    static let shared: GameKitHelper = {
        let instance = GameKitHelper()
        return instance
    }()
}

// MARK: - ACHIEVEMENT HELPER CLASS

class AchievementsHelper {
    static let achievementIdFirstWin = "com.mikecargal.hogdice.first.win"
    class func firstWinAchievement(didWin: Bool) -> GKAchievement {
        let achievement = GKAchievement(identifier: AchievementsHelper.achievementIdFirstWin)

        if didWin {
            achievement.percentComplete = 100
            achievement.showsCompletionBanner = true
        }
        return achievement
    }
}

// MARK: - DELEGATE EXTENSIONS

extension GameKitHelper: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }

    func showGKGamecenter(state: GKGameCenterViewControllerState) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
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

extension GameKitHelper: GKTurnBasedMatchmakerViewControllerDelegate {
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }

    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController,
                                           didFailWithError error: Error)
    {
        print("MatchmackerViewController failed with error: \(error)")
    }

    func findMatch() {
        guard GKLocalPlayer.local.isAuthenticated else { return }

        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        request.defaultNumberOfPlayers = 2
        request.inviteMessage = "Do you want to play Hog Dice?"

        matchmakerViewController = nil
        matchmakerViewController = GKTurnBasedMatchmakerViewController(matchRequest: request)
        matchmakerViewController?.turnBasedMatchmakerDelegate = self
        NotificationCenter.default.post(name: .presentTurnBasedGameCenterViewController, object: nil)
    }
}

extension GameKitHelper: GKLocalPlayerListener {
    func showMatchData(_ match: GKTurnBasedMatch) {
        var md: GameCenterData?
        if let matchData = match.matchData {
            do {
                md = try JSONDecoder().decode(GameCenterData.self, from: matchData)
                print("matchData: \(String(describing: md!))")
            } catch {
                print("error (\(error))\nparsing:\(matchData)")
            }
        } else { print("no matchData") }
    }

    func player(_ player: GKPlayer,
                receivedTurnEventFor match: GKTurnBasedMatch,
                didBecomeActive: Bool)
    {
        print("player( \(player)\n receivedTurnEventFor:\(match)\ndidBecomeActive:\(didBecomeActive)")
        print(" -- currentplayer: \(String(describing: match.currentParticipant?.player))")
        showMatchData(match)
        matchmakerViewController?.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: .receivedTurnEvent, object: match)
    }

    func canTakeTurn() -> Bool {
        guard let match = currentMatch else { return false }
        let currentParticipant = match.currentParticipant
        let currentPlayer = currentParticipant?.player
        print("match = \(match)\ncurrentPlayer = \(String(describing: currentPlayer))\nlocalPlayer = \(GKLocalPlayer.local)")
        return match.currentParticipant?.player == GKLocalPlayer.local
    }

    func endTurn(_ gcDataModel: GameCenterData,
                 errorHandler: ((Error?) -> Void)? = nil)
    {
        guard let match = currentMatch else { return }
        do {
            match.message = nil
            match.endTurn(withNextParticipants: match.opponents,
                          turnTimeout: GKExchangeTimeoutDefault,
                          match: try JSONEncoder().encode(gcDataModel),
                          completionHandler: errorHandler)
            print("End Turn Game Center Data has been sent")
        } catch {
            print("There was an error sending the match data: \(error)")
        }
    }

    func winGame(_ gcDateModel: GameCenterData,
                 errorHhandler: ((Error?) -> Void)? = nil)
    {
        guard let match = currentMatch else { return }

        match.currentParticipant?.matchOutcome = .won
        match.opponents.forEach { participants in
            participants.matchOutcome = .lost
        }
        print("endMatchInTurn -- win")
        match.endMatchInTurn(withMatch: match.matchData ?? Data(),
                             completionHandler: errorHhandler)
    }

    func lostGame(_ gcDateModel: GameCenterData,
                  errorHhandler: ((Error?) -> Void)? = nil)
    {
        guard let match = currentMatch else { return }
        match.currentParticipant?.matchOutcome = .lost
        match.opponents.forEach {
            participants in
            participants.matchOutcome = .won
        }
        print("endMatchInTurn -- lose")
        match.endMatchInTurn(withMatch: match.matchData ?? Data(),
                             completionHandler: errorHhandler)
    }
}

extension Notification.Name {
    static let presentAuthenticationViewController = Notification.Name("presentAuthenticationViewController")
    static let presentGameCenterViewController = Notification.Name("presentGameCenterViewController")
    static let presentTurnBasedGameCenterViewController = Notification.Name("presentTurnBasedGameCenterViewController")
    static let receivedTurnEvent = Notification.Name("receivedTurnEvent")
}
