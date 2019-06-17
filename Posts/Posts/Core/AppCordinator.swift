//
//  AppCordinator.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final public class AppCoordinator {
    private let navController: UINavigationController
    private let servicesProvider: ServicesProvider
    
    let disposeBag = DisposeBag()
    private let onPostSelection = BehaviorRelay<IndexPath?>(value: nil)
    
    public init(navController: UINavigationController,
                servicesProvider: ServicesProvider) {
        self.navController = navController
        self.servicesProvider = servicesProvider
        
        onPostSelection.asDriver().drive(onNext: navigateToPostDetails).disposed(by: disposeBag)
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
        let viewModel = PostsListViewModel(dataLoader: servicesProvider.postsDataRepo.postItemsLoader,
                                           onItemSelection: onPostSelection)
        return viewModel
    }
    
    private func navigateToPostDetails(selectedIndex: IndexPath?) {
        guard let index = selectedIndex else {
            return
        }
        let dataModel = servicesProvider.postsDataRepo.postDetailModel(index: index.row)
        let viewModel = PostDetailViewModel(model: dataModel)
        navController.pushViewController(PostDetailsViewController(viewModel: viewModel),
                                         animated: true)
    }
}
