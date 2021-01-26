//
//  GameCenterData.swift
//  hog
//
//  Created by Mike Cargal on 1/25/21.
//

import GameKit

class GameCenterData: Codable {
    var players: [GameCenterPlayer] = []
    
    func addPlayer(_ player: GameCenterPlayer) {
        if let p = getPlayer(withName: player.playerName) {
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
    
    func getPlayer(withName playerName: String) -> GameCenterPlayer? {
        return players.first { $0.playerName == playerName }
    }
    
    func getPlayerIndex(for player: GameCenterPlayer) -> Int? {
        return players.firstIndex(of: player)
    }
}
