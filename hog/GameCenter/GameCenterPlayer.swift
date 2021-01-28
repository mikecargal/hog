//
//  GameCenterPlayer.swift
//  hog
//
//  Created by Mike Cargal on 1/25/21.
//

class GameCenterPlayer: Codable, Equatable {
    var playerId: String
    var playerName: String
    
    var isLocalPlayer: Bool = false
    var isWinner: Bool = false
    
    var totalPoints: Int = 0
    
    static func == (lhs: GameCenterPlayer, rhs: GameCenterPlayer) -> Bool {
        return lhs.playerId == rhs.playerId
        // && lhs.playerName == rhs.playerName
    }
    
    init(playerId: String, playerName: String) {
        self.playerId = playerId
        self.playerName = playerName
    }
}

extension GameCenterPlayer: CustomDebugStringConvertible {
    var debugDescription: String {
        "GameCenterPayer {playerID: \(playerId), playerName: \(playerName), isLocalPlayer: \(isLocalPlayer), isWinner: \(isWinner), totalPoints: \(totalPoints)"
    }
}
