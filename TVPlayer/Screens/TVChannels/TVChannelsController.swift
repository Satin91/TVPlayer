//
//  TVChannelsController.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import UIKit

class TVChannelsController: UIViewController {
    
    var coordinator: AppCoordinatorProtocol?
    var service: TVChannelServiceProtocol?
    
    private var presentedView = TVChannelsView()
    
    private var allChannels: [TVChannel] = []
    
    private var favoriteChannels: [TVChannel] {
        allChannels.filter { $0.isFavorite }
    }
    
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
        service?.getChannels { channels in
            self.allChannels = channels
            self.channels.value = channels
        }
    }
}

extension TVChannelsController: TVChannelViewActionsDelegate {
    
    func tapFavorite(on row: Int, on segment: TVChannelsView.SegmentsElement) {
        switch segment {
        case .all:
            self.allChannels[row].isFavorite.toggle()
            channels.send(allChannels)
        case .favorites:
            self.favoriteChannels[row].isFavorite.toggle()
            channels.send(favoriteChannels)
        }
    }
    
    func didTap(on row: Int, on segment: TVChannelsView.SegmentsElement) {
        switch segment {
        case .all:
            let channel = allChannels[row]
            coordinator?.pushToVideoPlayer(with: channel)
        case .favorites:
            favoriteChannels[row].isFavorite.toggle()
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
