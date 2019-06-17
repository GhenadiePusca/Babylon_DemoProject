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
    private let disposeBag = DisposeBag()
    private let onPostSelection = BehaviorRelay<IndexPath?>(value: nil)
    
    private let navController: UINavigationController
    private let servicesProvider: ServicesProvider
    
    public init(navController: UINavigationController,
                servicesProvider: ServicesProvider) {
        self.navController = navController
        self.servicesProvider = servicesProvider
        
        onPostSelection.asDriver().drive(onNext: navigateToPostDetails).disposed(by: disposeBag)
    }
    
    public func start() {
        servicesProvider.postsDataRepo.reloadBehavior.accept(true)
        navController.setViewControllers([postsListViewController()], animated: true)
    }
    
    private func postsListViewController() -> UIViewController {
        let vm = postListViewModel()
        return PostsListViewController(viewModel: vm)
    }
    
    private func postListViewModel() -> PostsListViewModel {
        let viewModel = PostsListViewModel(dataLoader: servicesProvider.postsDataRepo.postItemsLoader,
                                           onItemSelection: onPostSelection,
                                           onReload: servicesProvider.postsDataRepo.reloadBehavior)
        return viewModel
    }
    
    private lazy var navigateToPostDetails: (IndexPath?) -> Void = { [weak self] indexPath in
        guard let self = self, let indexPath = indexPath else {
            return
        }
        let dataModel = self.servicesProvider.postsDataRepo.postDetailModel(index: indexPath.row)
        let viewModel = PostDetailViewModel(model: dataModel)
        self.navController.pushViewController(PostDetailsViewController(viewModel: viewModel),
                                              animated: true)
    }
}
