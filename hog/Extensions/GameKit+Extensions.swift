//
//  GameKit+Extensions.swift
//  hog
//
//  Created by Mike Cargal on 1/25/21.
//

import GameKit

extension GKTurnBasedMatch {
    var locaPlayer: GKTurnBasedParticipant? {
        return participants.first { $0.player == GKLocalPlayer.local }
    }

    var opponents: [GKTurnBasedParticipant] {
        return participants.filter {
            return $0.player != GKLocalPlayer.local
        }
    }
}
