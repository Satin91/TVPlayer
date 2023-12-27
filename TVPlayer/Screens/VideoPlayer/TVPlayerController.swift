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
    var model: TVPlayerModel!
    
    override func loadView() {
        super.loadView()
        self.view = presentedView
        presentedView.configure(with: model.tvChannel!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }
    
    func bind() {
        model.playerState.bind { [weak self] in self?.presentedView.playerState.send($0) }
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
        let previousState = model.playerState.value
        
        model.playerState.send(.loading)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.model.playerState.send(previousState)
        }
    }
    
    func playerTapped() {
        
        switch model.playerState.value {
        case .loading:
            break
        case .playing:
            model.playerState.send(.pause)
        case .pause:
            model.playerState.send(.playing)
        case .stop:
            break
        }
    }
    
    func navigationBackButtonTap() {
        model.playerState.send(.stop)
        coordinator?.dismiss()
    }
}
