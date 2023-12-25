//
//  TVPlayerController.swift
//  TVPlayer
//
//  Created by Артур Кулик on 24.12.2023.
//

import UIKit


final class TVPlayerController: UIViewController {
    
    var coordinator: CoordinatorBehavior?
    var presentedView = TVPlayerView()
    var tvChannel: TVChannel!
    
    convenience init(tvChannel: TVChannel) {
        self.init()
        self.tvChannel = tvChannel
    }
    
    override func loadView() {
        super.loadView()
        self.view = presentedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        presentedView.configure(with: tvChannel)
    }
    
    func setupView() {
        presentedView.actionsDelegate = self
    }
}

extension TVPlayerController: TVPlayerViewActionsDelegate {
    func navigationBackButtonTap() {
        coordinator?.dismiss()
    }
}
