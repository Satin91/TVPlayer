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
        model.playerActions.bind { [weak self] in self?.presentedView.playerState.send($0) }
    }
    
    func setupView() {
        presentedView.actionsDelegate = self
    }
}

extension TVPlayerController: TVPlayerViewActionsDelegate {
    func playButtonTapped() {
        model.playerActions.send(.playVideo)
    }
    
    func pauseButtonTapped() {
        model.playerActions.send(.pauseVideo)
    }
    
    func completeLoading(success: Bool) {
        if success {
            model.playerActions.send(.playVideo)
        } else {
            model.playerActions.send(.showError)
        }
    }
    
    func outsideTapped() {
        
    }
    
    func tapResolution(scale: String) {
        // imitation of resolution change
        
        let previousAction = model.playerActions.value
        model.playerActions.send(.loadVideo)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.model.playerActions.send(previousAction)
        }
    }
    
    func playerTapped() {
        
    }
    
    func navigationBackButtonTap() {
        model.playerActions.send(.stopPlayer)
        coordinator?.dismiss()
    }
}
