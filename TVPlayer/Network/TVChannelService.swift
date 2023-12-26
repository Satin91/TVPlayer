//
//  TVChannelService.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import Foundation

protocol TVChannelServiceProtocol {
    func getChannels(completion: @escaping ([TVChannel]) -> Void)
}

final class TVChannelService: TVChannelServiceProtocol {
    let manager: NetworkManagerProtocol
    
    init(manager: NetworkManagerProtocol) {
        self.manager = manager
    }
    
    func getChannels(completion: @escaping ([TVChannel]) -> Void) {
        manager.parse(responseOf: TVChannelsResponse.self) { response in
            completion(response.channels)
        }
    }
}
