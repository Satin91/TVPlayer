//
//  AppCoordinator.swift
//  TVPlayer
//
//  Created by Артур Кулик on 24.12.2023.
//

import UIKit

protocol CoordinatorBehavior: AnyObject {
    func dismiss()
    func pushToTv()
    func pushToVideoPlayer()
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
    
    func pushToVideoPlayer() {
        let vc = TVPlayerController()
        vc.coordinator = self
        self.navigation.pushViewController(vc, animated: true)
    }
}
