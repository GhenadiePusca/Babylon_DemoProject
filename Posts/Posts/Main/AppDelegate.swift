//
//  AppDelegate.swift
//  Posts
//
//  Created by Pusca Ghenadie on 11/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private lazy var navController = UINavigationController()
    private lazy var appCoordinator = AppCoordinator(navController: navController)
    private lazy var factory = Factory()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        appCoordinator.start()

        return true
    }
}

