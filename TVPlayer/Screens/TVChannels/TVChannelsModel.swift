//
//  TVChannelsModel.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import Foundation

final class TVChannelsModel {
    private var networkService: TVChannelServiceProtocol
    private var storageService: TVChannelsStorageServiceProtocol
    enum SegmentsElement: String, CaseIterable {
        case all = "Все"
        case favorites = "Избранное"
    }
    
    init(networkService: TVChannelServiceProtocol, storageService: TVChannelsStorageServiceProtocol) {
        self.networkService = networkService
        self.storageService = storageService
        subscribe()
    }
    
    var allChannels: [TVChannel] = []
    var favoriteChannels: [TVChannel] = []
    var channels = Observable<[TVChannel]>([])
    var currentSegment = Observable<SegmentsElement>(.all)
    
    func subscribe() {
        currentSegment.subscribe { element in
            switch element {
            case .all:
                self.channels.send(self.allChannels)
            case .favorites:
                self.channels.send(self.favoriteChannels)
            }
        }
    }
    
    func loadChannels() {
        networkService.getChannels { [self] channels in
            self.allChannels = channels
        }
        let storageChannels = storageService.fetchAll()
        favoriteChannels = storageChannels
        
        for channel in allChannels {
            if storageChannels.contains(where: { $0.id == channel.id }) {
                channel.isFavorite = true
            }
        }
        self.channels.send(allChannels)
    }
    
    func changeFavoriteState(for channel: TVChannel) {
        switch currentSegment.value {
        case .all:
            channel.isFavorite.toggle()
            channel.isFavorite ? createFavorite(channel) : removeFavorite(channel)
            channels.send(allChannels)
        case .favorites:
            removeFavorite(channel)
            allChannels.first(where: { $0.name == channel.name })?.isFavorite.toggle()
            channels.send(favoriteChannels)
        }
    }
    
    func searchChannels(with text: String) {
        if text == "" {
            channels.send(currentSegment.value == .all ? allChannels : favoriteChannels)
        } else {
            let filteredChannels = (currentSegment.value == .all ? allChannels : favoriteChannels).filter { channel in
                channel.name.uppercased().contains(text.uppercased())
            }
            channels.send(filteredChannels)
        }
    }
    
    func createFavorite(_ channel: TVChannel) {
        guard channel.isFavorite else { return }
        if !favoriteChannels.contains(where: { $0.name == channel.name }) {
            favoriteChannels.append(channel)
        }
        storageService.create(channel: channel)
    }
    
    func removeFavorite(_ channel: TVChannel) {
        guard let index = favoriteChannels.firstIndex(where: { $0.name == channel.name }) else {
            return
        }
        favoriteChannels.remove(at: index)
        storageService.remove(with: channel.id)
    }
}
