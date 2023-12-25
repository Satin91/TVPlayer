//
//  AppCoordinator.swift
//  TVPlayer
//
//  Created by Артур Кулик on 24.12.2023.
//

import UIKit
import AVKit

protocol CoordinatorBehavior: AnyObject {
    func dismiss()
    func pushToTv()
    func pushToVideoPlayer(with channel: TVChannel)
}

class AppCoordinator {
    var navigation: UINavigationController
    var root: UIViewController?
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
        self.navigation.navigationBar.isHidden = true
    }
    
    func start() {
        pushToTv()
    }
}

extension AppCoordinator: CoordinatorBehavior {
    func dismiss() {
        self.navigation.popToRootViewController(animated: true)
    }
    
    func pushToTv() {
        let vc = TVChannelsController()
        vc.coordinator = self
        self.navigation.pushViewController(vc, animated: true)
    }
    
    func pushToVideoPlayer(with channel: TVChannel) {
        let vc = TVPlayerController(tvChannel: channel)
        vc.coordinator = self
        self.navigation.pushViewController(vc, animated: true)
    }
}