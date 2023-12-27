//
//  TVChannelsController.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import UIKit

class TVChannelsController: UIViewController {
    
    var coordinator: AppCoordinatorProtocol!
    
    private var presentedView = TVChannelsView()
    var model: TVChannelsModel!
    
    override func loadView() {
        super.loadView()
        setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.loadChannels()
        bind()
    }
    
    func bind() {
        model.channels.bind { [weak self] in self?.presentedView.dynamicChannels.value = $0 }
    }
    
    func setupView() {
        self.view = presentedView
        self.presentedView.actionsDelegate = self
    }
}

extension TVChannelsController: TVChannelViewActionsDelegate {
    func searchChannel(by text: String) {
        model.searchChannels(with: text)
    }
    
    func tapFavorite(channel: TVChannel) {
        model.changeFavoriteState(for: channel)
    }
    
    func didTap(on channel: TVChannel) {
        coordinator?.pushToVideoPlayer(with: channel)
    }
    
    func segmentDidChange(to: TVChannelsModel.SegmentsElement) {
        model.currentSegment.send(to)
    }
}
