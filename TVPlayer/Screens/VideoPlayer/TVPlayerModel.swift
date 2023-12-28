//
//  TVPlayerModel.swift
//  TVPlayer
//
//  Created by Артур Кулик on 25.12.2023.
//

import Foundation

class TVPlayerModel {
    enum PlayerState {
        case loading
        case failed
        case playing
        case pause
        case stop
    }
    var tvChannel: TVChannel?
    var playerState = Observable(TVPlayerModel.PlayerState.loading)
    
    init(tvChannel: TVChannel? = nil) {
        self.tvChannel = tvChannel
    }
    
    func changeResolution(scale: String) {
        
    }
}
