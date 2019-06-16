//
//  AppCordinator.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import UIKit

final public class AppCoordinator {
    private let navController: UINavigationController
    
    public init(navController: UINavigationController) {
        self.navController = navController
    }
    
    public func start() {
        navController.setViewControllers([postsListViewController()], animated: true)
    }
    
    private func postsListViewController() -> UIViewController {
        return PostsListViewController()
    }
}
