//
//  AppCoordinator.swift
//  TVPlayer
//
//  Created by Артур Кулик on 24.12.2023.
//

import UIKit
import AVKit

protocol AppCoordinatorProtocol: AnyObject {
    func dismiss()
    func pushToTv()
    func pushToVideoPlayer(with channel: TVChannel)
}

class AppCoordinator {
    var navigation: UINavigationController
    var root: UIViewController?
    let container = DependencyContainer()
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
        self.navigation.navigationBar.isHidden = true
    }
    
    func start() {
        pushToTv()
    }
}

extension AppCoordinator: AppCoordinatorProtocol {
    func dismiss() {
        self.navigation.popToRootViewController(animated: true)
    }
    
    func pushToTv() {
        let vc = container.makeTvChannelsController(coordinator: self)
        self.navigation.pushViewController(vc, animated: true)
    }
    
    func pushToVideoPlayer(with channel: TVChannel) {
        let vc = container.makeTVPlayerController(coordinator: self, channel: channel)
        self.navigation.pushViewController(vc, animated: true)
    }
}
