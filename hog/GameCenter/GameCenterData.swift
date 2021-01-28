//
//  GameCenterData.swift
//  hog
//
//  Created by Mike Cargal on 1/25/21.
//

import GameKit

class GameCenterData: Codable {
    private var players: [GameCenterPlayer] = []
    
    func addPlayer(_ player: GameCenterPlayer) {
        print(">>>>> add player \(player)\nto:\(players)")
        if let p = getPlayer(withId: player.playerId) {
            p.isLocalPlayer = player.isLocalPlayer
            p.isWinner = player.isWinner
        } else {
            players.append(player)
        }
    }
    
    func getLocalPlayer() -> GameCenterPlayer? {
        return players.first { $0.isLocalPlayer }
    }
    
    func getRemotePlayer() -> GameCenterPlayer? {
        return players.first { !$0.isLocalPlayer }
    }
    
    func getPlayer(withId playerId: String) -> GameCenterPlayer? {
        return players.first { $0.playerId == playerId }
    }
    
    func getPlayerIndex(for player: GameCenterPlayer) -> Int? {
        return players.firstIndex(of: player)
    }
}

extension GameCenterData: CustomDebugStringConvertible {
    var debugDescription: String {
        "GameCenterData with players: \(players)"
    }
}
