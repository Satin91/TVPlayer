//
//  TVChannelsController.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import UIKit

class TVChannelsController: UIViewController {
    let service = TVChannelService()
    
    private var tvView = TVChannelsView()
    
    private var allChannels = Observable<[TVChannel]>([])
    private var favoriteChannels: [TVChannel] {
        allChannels.value.filter { $0.isFavorite }
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
        channels.bind { [weak self] in self?.tvView.dynamicChannels.value = $0 }
    }
    
    func setupView() {
        self.view = tvView
        self.tvView.actionsDelegate = self
    }
    
    func loadChannels() {
        service.getChannels { channels in
            self.allChannels.value = channels
            self.channels.value = channels
        }
    }
}

extension TVChannelsController: TVChannelViewActionsDelegate {
    func didTap(on row: Int, on segment: TVChannelsView.SegmentsElement) {
        switch segment {
        case .all:
            break
        case .favorites:
            favoriteChannels[row].isFavorite.toggle()
            channels.send(favoriteChannels)
        }
    }
    
    func tapFavorite(on channel: TVChannel) {
        channel.isFavorite.toggle()
        tvView.reloadView()
    }
    
    func segmentDidChange(to: TVChannelsView.SegmentsElement) {
        switch to {
        case .all:
            channels.send(allChannels.value)
        case .favorites:
            channels.send(favoriteChannels)
        }
    }
}
