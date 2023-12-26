//
//  DependencyContainer.swift
//  TVPlayer
//
//  Created by Артур Кулик on 26.12.2023.
//

import UIKit

final class DependencyContainer {
    let networkManager: NetworkManagerProtocol = NetworkManager()
    let tvChannelService: TVChannelServiceProtocol
    
    init() {
        tvChannelService = TVChannelService(manager: networkManager)
    }
    
    func makeTvChannelsController(coordinator: AppCoordinator) -> TVChannelsController {
        let controller = TVChannelsController()
        controller.coordinator = coordinator
        controller.service = tvChannelService
        return controller
    }
    
    func makeTVPlayerController(coordinator: AppCoordinator, channel: TVChannel) -> TVPlayerController {
        let controller = TVPlayerController(tvChannel: channel)
        controller.coordinator = coordinator
        return controller
    }
}
