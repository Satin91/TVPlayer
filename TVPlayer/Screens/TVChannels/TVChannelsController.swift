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
    var observers: [Observer] = []
    
    
    private var allChannels: [TVChannel] = [] {
        didSet {
            print("Что то поменялось")
        }
    }
    
    private var favoritesChannels: [TVChannel] {
        allChannels.filter { $0.isFavorite }
    }
    
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
        observers = allChannels.map { Observer(value: $0) }
        
        observers.forEach { observer in
            observer.observe { channel in
                print("new value on \(channel.name)")
            }
        }
    }
    
    func setupView() {
        self.view = tvView
        self.tvView.actionsDelegate = self
    }
    
    func loadChannels() {
        service.getChannels { channels in
            self.allChannels = channels
//            self.allChannels[2].isFavorite = true
            self.tvView.configure(with: self.allChannels)
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
            tvView.configure(with: allChannels)
        case .favorites:
            tvView.configure(with: favoritesChannels)
        }
    }
    
    func didTap(channel: TVChannel, on segment: TVChannelsView.SegmentsElement) {
        switch segment {
        case .all:
            break
        case .favorites:
            channel.isFavorite.toggle()
            tvView.reloadView()
        }
    }
}
