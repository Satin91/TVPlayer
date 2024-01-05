//
//  TVPlayerModel.swift
//  TVPlayer
//
//  Created by Артур Кулик on 25.12.2023.
//

import Foundation

class TVPlayerModel {
    enum PlayerActions {
        case loadVideo
        case showError
        case playVideo
        case pauseVideo
        case stopPlayer
    }
    var tvChannel: TVChannel?
    var playerActions = Observable(TVPlayerModel.PlayerActions.loadVideo)
    
    init(tvChannel: TVChannel? = nil) {
        self.tvChannel = tvChannel
    }
}
