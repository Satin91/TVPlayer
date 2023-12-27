//
//  DependencyContainer.swift
//  TVPlayer
//
//  Created by Артур Кулик on 26.12.2023.
//

import UIKit

final class DependencyContainer {
    let networkManager: NetworkManagerProtocol = NetworkManager()
    let tvChannelNetworkService: TVChannelServiceProtocol
    let storageManager: StorageManagerProtocol = StorageManager(entityName: "TVChannelCore")
    let tvChannelStorageService: TVChannelsStorageServiceProtocol
    
    init() {
        tvChannelNetworkService = TVChannelNetworkService(manager: networkManager)
        tvChannelStorageService = TVChannelsStorageService(manager: storageManager, context: storageManager.context)
    }
    
    func makeTvChannelsController(coordinator: AppCoordinator) -> TVChannelsController {
        let controller = TVChannelsController()
        let model = TVChannelsModel(networkService: tvChannelNetworkService, storageService: tvChannelStorageService)
        controller.coordinator = coordinator
        controller.model = model
        return controller
    }
    
    func makeTVPlayerController(coordinator: AppCoordinator, channel: TVChannel) -> TVPlayerController {
        let controller = TVPlayerController(tvChannel: channel)
        controller.coordinator = coordinator
        return controller
    }
}
