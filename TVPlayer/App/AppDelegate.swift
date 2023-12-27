//
//  AppDelegate.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import UIKit

@main

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var container: DependencyContainer?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let navigation = UINavigationController()
        let coordinator = AppCoordinator(navigation: navigation)
        coordinator.start()
        window.rootViewController = navigation
        self.window = window
        window.makeKeyAndVisible()
        return true
    }
}

