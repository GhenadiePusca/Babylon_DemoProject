//
//  AppCordinator.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import UIKit
import RxSwift

final public class AppCoordinator {
    private let navController: UINavigationController
    private let servicesProvider: ServicesProvider
    
    public init(navController: UINavigationController,
                servicesProvider: ServicesProvider) {
        self.navController = navController
        self.servicesProvider = servicesProvider
    }
    
    public func start() {
        servicesProvider.postsDataRepo.loadPosts()
        navController.setViewControllers([postsListViewController()], animated: true)
    }
    
    private func postsListViewController() -> UIViewController {
        let vm = postListViewModel()
        return PostsListViewController(viewModel: vm)
    }
    
    private func postListViewModel() -> PostsListViewModel {
        let viewModel = PostsListViewModel(dataLoader: servicesProvider.postsDataRepo.postItemsLoader)
        
        return viewModel
    }
}
