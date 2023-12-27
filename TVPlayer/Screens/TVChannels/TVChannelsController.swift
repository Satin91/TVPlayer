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
        let storageChannels = storageService?.fetchAll()
        favoriteChannels = storageChannels!
        networkService?.getChannels { [self] channels in
            
            self.channels.send(channels)
            
            print(favoriteChannels)
            self.allChannels = channels
        }
    }
}

extension TVChannelsController: TVChannelViewActionsDelegate {
    
    func tapFavorite(on row: Int, on segment: TVChannelsView.SegmentsElement) {
        switch segment {
        case .all:
            let object = allChannels[row]
            object.isFavorite.toggle()
            channels.send(allChannels)
            storageService?.create(channel: object)
            favoriteChannels.append(object)
        case .favorites:
            favoriteChannels.remove(at: row)
            channels.send(favoriteChannels)
        }
    }
    
    func didTap(on row: Int, on segment: TVChannelsView.SegmentsElement) {
        switch segment {
        case .all:
            let channel = allChannels[row]
            coordinator?.pushToVideoPlayer(with: channel)
        case .favorites:
            let object = favoriteChannels[row]
            storageService?.remove(with: object.id)
            favoriteChannels.remove(at: row)
            channels.send(favoriteChannels)
        }
    }
    
    func segmentDidChange(to: TVChannelsView.SegmentsElement) {
        switch to {
        case .all:
            channels.send(allChannels)
        case .favorites:
            channels.send(favoriteChannels)
        }
    }
}
