//
//  TVPlayerController.swift
//  TVPlayer
//
//  Created by Артур Кулик on 24.12.2023.
//

import UIKit


final class TVPlayerController: UIViewController {
    
    var coordinator: AppCoordinatorProtocol?
    var presentedView = TVPlayerView()
    
    var playerState = Observable(TVPlayerModel.PlayerState.playing)
    var tvChannel: TVChannel?
    
    convenience init(tvChannel: TVChannel) {
        self.init()
        self.tvChannel = tvChannel
    }
    
    override func loadView() {
        super.loadView()
        self.view = presentedView
        guard let tvChannel else { return }
        presentedView.configure(with: tvChannel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        subscribe()
    }
    
    func subscribe() {
        playerState.bind { [weak self] in self?.presentedView.playerState.send($0) }
    }
    
    func setupView() {
        presentedView.actionsDelegate = self
    }
}

extension TVPlayerController: TVPlayerViewActionsDelegate {
    func videoIsLoaded() {
        
    }
    
    func tapResolution(scale: String) {
        // imitation of resolution change
        let previousState = playerState.value
        playerState.send(.loading)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.playerState.send(previousState)
        }
    }
    
    func playerTapped() {
        switch playerState.value {
        case .loading:
            break
        case .playing:
            playerState.send(.pause)
        case .pause:
            playerState.send(.playing)
        case .stop:
            break
        }
    }
    
    func navigationBackButtonTap() {
        playerState.send(.stop)
        coordinator?.dismiss()
    }
}
