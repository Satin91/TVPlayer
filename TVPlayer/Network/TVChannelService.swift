//
//  TVChannelService.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import Foundation

final class TVChannelService {
    let networkManager = NetworkManager()
    
    func getChannels(completion: @escaping ([TVChannel]) -> Void) {
        networkManager.parse(responseOf: TVChannelsResponse.self) { response in
            completion(response.channels)
        }
    }
}
