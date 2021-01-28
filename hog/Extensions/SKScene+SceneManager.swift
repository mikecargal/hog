//
//  SKScene+SceneManager.swift
//  hog
//
//  Created by Tammy Coron on 10/31/2020.
//  Copyright © 2020 Just Write Code LLC. All rights reserved.
//

import GameKit
import GameplayKit
import SpriteKit

extension SKScene {
    func loadGameScene(gameType: GameType,
                       matchData: GameCenterData? = nil,
                       matchID: String? = nil)
    {
        print("Attempting to load the game scene.")
    
        // Create actions to load the next scene
        let wait = SKAction.wait(forDuration: 0.50)
        let block = SKAction.run {
            // Load 'GameScene.sks' as a GKScene
            if let scene = GKScene(fileNamed: "GameScene") {
                // Get the SKScene from the loaded GKScene
                if let sceneNode = scene.rootNode as! GameScene? {
                    // Copy gameplay related content over to the scene
                    sceneNode.entities = scene.entities
                    sceneNode.graphs = scene.graphs
          
                    sceneNode.gameCenterData = matchData
                    sceneNode.gameCenterMatchID = matchID
          
                    // Set up match game type (Solo, Local, Remote)
                    sceneNode.gameType = gameType
          
                    // Set the scale mode to scale to fit the window
                    sceneNode.scaleMode = .aspectFill
          
                    // Present the scene
                    self.view?.presentScene(sceneNode, transition:
                        SKTransition.doorsOpenHorizontal(withDuration: 1.0))
                }
            } else {
                print("Can't load game scene.")
            }
        }
    
        // Run the actions in sequence
        run(SKAction.sequence([wait, block]))
    }
  
    func loadGameOverScene(isWinner: Bool) {
        print("Attempting to load the game over scene.")
    
        // Create actions to load the game over scene
        let wait = SKAction.wait(forDuration: 0.50)
        let block = SKAction.run {
            if let scene = GameOverScene(fileNamed: "GameOverScene") {
                scene.scaleMode = .aspectFill
                scene.isWinner = isWinner
        
                self.view?.presentScene(scene, transition:
                    SKTransition.doorsOpenHorizontal(withDuration: 1.0))
            } else {
                print("Can't load game over scene.")
            }
        }
    
        // Run the actions in sequence
        run(SKAction.sequence([wait, block]))
    }
  
    func loadLobbyScene() {
        print("Attempting to load the lobby scene.")
    
        // Create actions to load the game over scene
        let wait = SKAction.wait(forDuration: 0.50)
        let block = SKAction.run {
            if let scene = LobbyScene(fileNamed: "LobbyScene") {
                scene.scaleMode = .aspectFill
        
                self.view?.presentScene(scene, transition:
                    SKTransition.doorsOpenHorizontal(withDuration: 1.0))
            } else {
                print("Can't load lobby scene.")
            }
        }
    
        // Run the actions in sequence
        run(SKAction.sequence([wait, block]))
    }
  
    func loadGameCenterGame(match: GKTurnBasedMatch) {
        print("Attempting to load the game scene using Game Center Match data.")
        match.loadMatchData { data, error in
            if let error = error {
                print("Error in loadGameCenterGaem(match) \(error)")
                return
            }
            GameKitHelper.shared.currentMatch = match
            var gcDataModel = GameCenterData()
            if let data = data {
                do {
                    gcDataModel = try JSONDecoder().decode(GameCenterData.self,
                                                           from: data)
                } catch let decodeError {
                    print("Error decoding JSON from GameCenter \(decodeError)\n\(data)")
                    // we'll just use the default
                }
            }
            print("GKLocalPlayer.local=\(GKLocalPlayer.local)")
            for participant in match.participants {
                if let player = participant.player {
                    let gcPlayer = GameCenterPlayer(playerId: player.gamePlayerID,
                                                    playerName: player.displayName)
                    print("adding player: \(gcPlayer)")
                    if player == GKLocalPlayer.local {
                        gcPlayer.isLocalPlayer = true
                    }
                    
                    if participant.matchOutcome == .won {
                        gcPlayer.isWinner = true
                    }
                    gcDataModel.addPlayer(gcPlayer)
                }
            }
            self.loadGameScene(gameType: .remoteMatch,
                               matchData: gcDataModel,
                               matchID: match.matchID)
        }
    }
}
