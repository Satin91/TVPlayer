//
//  TVChannelsController.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import UIKit

class TVChannelsController: UIViewController {
    
    var coordinator: AppCoordinatorProtocol?
    var networkService: TVChannelServiceProtocol?
    var storageService: TVChannelsStorageServiceProtocol?
    
    private var presentedView = TVChannelsView()
    
    private var allChannels: [TVChannel] = []
    private var favoriteChannels: [TVChannel] = []
    private var channels = Observable<[TVChannel]>([])
    
    override func loadView() {
        super.loadView()
        setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadChannels()
        subscribe()
    }
    
    func subscribe() {
        channels.bind { [weak self] in self?.presentedView.dynamicChannels.value = $0 }
    }
    
    func setupView() {
        self.view = presentedView
        self.presentedView.actionsDelegate = self
    }
    
    func loadChannels() {
        networkService?.getChannels { [self] channels in
            self.allChannels = channels
        }
        let storageChannels = storageService?.fetchAll() ?? []
        favoriteChannels = storageChannels
        
        for channel in allChannels {
            if storageChannels.contains(where: { $0.id == channel.id }) {
                channel.isFavorite = true
            }
        }
        self.channels.send(allChannels)
    }
    
    func createFavorite(_ channel: TVChannel) {
            favoriteChannels.append(channel)
            storageService?.create(channel: channel)
    }
    
    func removeFavorite(_ channel: TVChannel) {
        guard let firstIndex = favoriteChannels.firstIndex(where: { $0.id == channel.id }) else { return }
        favoriteChannels.remove(at: firstIndex)
        storageService?.remove(with: channel.id)
    }
}

extension TVChannelsController: TVChannelViewActionsDelegate {
    func searchChannel(by text: String, on segment: TVChannelsModel.SegmentsElement) {
        if text == "" {
            channels.send(segment == .all ? allChannels : favoriteChannels)
        } else {
            
            let filteredChannels = (segment == .all ? allChannels : favoriteChannels).filter { channel in
                channel.name.contains(text)
            }
            channels.send(filteredChannels)
        }
    }
    
    func tapFavorite(on row: Int, on segment: TVChannelsModel.SegmentsElement) {
        switch segment {
        case .all:
            let channel = allChannels[row]
            if channel.isFavorite {
                removeFavorite(channel)
            } else {
                createFavorite(channel)
            }
            channel.isFavorite.toggle()
            channels.send(allChannels)
        case .favorites:
            let channel = favoriteChannels[row]
            removeFavorite(channel)
            allChannels.filter( { $0.id == channel.id } ).first?.isFavorite.toggle()
            channels.send(favoriteChannels)
        }
    }
    
    func didTap(on row: Int, on segment: TVChannelsModel.SegmentsElement) {
        switch segment {
            
        case .all:
            let channel = allChannels[row]
            coordinator?.pushToVideoPlayer(with: channel)
        case .favorites:
            let channel = favoriteChannels[row]
            removeFavorite(channel)
            allChannels.filter( { $0.id == channel.id } ).first?.isFavorite.toggle()
            channels.send(favoriteChannels)
        }
    }
    
    func segmentDidChange(to: TVChannelsModel.SegmentsElement) {
        switch to {
        case .all:
            channels.send(allChannels)
        case .favorites:
            channels.send(favoriteChannels)
        }
    }
}
