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
    
    private var allChannels: [Observer<TVChannel>] = []
    private var favoritesChannels: [Observer<TVChannel>] = []
    
    private var channels: ObservableArray<Observer<TVChannel>> = .init(value: [])
    
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
        channels.bind(to: &self.tvView.observers)
        channels.subscribe { [weak self] channels in
            self?.tvView.reloadView()
        }
        
        self.channels.value.forEach { elem in
            elem.observe(for: \.isFavorite) { channel, property in
                if property {
                    self.favoritesChannels.append(Observer(value: channel) )
                } else {
                    self.favoritesChannels.removeAll(where: { $0.value == channel } )
                }
            }
        }
    }
    
    func setupView() {
        self.view = tvView
        self.tvView.actionsDelegate = self
    }
    
    func loadChannels() {
        service.getChannels { channels in
            self.allChannels = channels.map({ Observer(value: $0) })
            self.channels.send(self.allChannels)
        }
    }
}

extension TVChannelsController: TVChannelViewActionsDelegate {
    func tapFavorite(on channel: TVChannel) {
        channel.isFavorite.toggle()
        tvView.reloadView()
    }
    
    func segmentDidChange(to: TVChannelsView.SegmentsElement) {
        switch to {
        case .all:
            channels.send(allChannels)
            tvView.reloadView()
        case .favorites:
            self.channels.send(favoritesChannels)
            tvView.reloadView()
        }
    }
    
    func didTap(channel: TVChannel, on segment: TVChannelsView.SegmentsElement) {
        switch segment {
        case .all:
            tvView.reloadView()
        case .favorites:
            channel.isFavorite.toggle()
//            tvView.reloadView()
        }
    }
}
