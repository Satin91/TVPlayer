//
//  TVChannelsController.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import UIKit

class TVChannelsController: UIViewController {
    
    var coordinator: AppCoordinatorProtocol!
    var model: TVChannelsModel!
    private var presentedView = TVChannelsView()
    
    override func loadView() {
        super.loadView()
        setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.loadChannels()
        bind()
    }
    
    func setupView() {
        self.view = presentedView
        self.presentedView.actionsDelegate = self
    }
    
    func bind() {
        model.channels.bind { [weak self] in self?.presentedView.dynamicChannels.value = $0 }
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
