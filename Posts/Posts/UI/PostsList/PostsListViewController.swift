//
//  PostsListViewController.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final public class PostsListViewController: UIViewController {
    
    struct Constants {
        static let standardSpacing: CGFloat = 8.0
    }

    private lazy var postsTableView = setupTableView()
    private let disposeBag = DisposeBag()

    let viewModel: PostsListViewModel
    
    init(viewModel: PostsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Posts"
        view.backgroundColor = .white
        setuLayout()

        bindToViewModel()
    }
    
    private func bindToViewModel() {
        postsTableView.rx.itemSelected.asDriver().drive(viewModel.onItemSelection).disposed(by: disposeBag)

        viewModel.postsModels
            .drive(postsTableView.rx.items(cellIdentifier: PostListItemTableViewCell.reuseIdentifier,
                                           cellType: PostListItemTableViewCell.self)) { _, vm, cell in
                cell.update(viewModel: vm)
            }.disposed(by: disposeBag)
        
        viewModel.isLoading.distinctUntilChanged().drive(onNext: handleLoadingStatus).disposed(by: disposeBag)
        viewModel.loadingFailed.distinctUntilChanged().drive(onNext: handleLoadFail).disposed(by: disposeBag)
    }
    
    private func handleLoadingStatus(isLoading: Bool) {
        isLoading ? self.setActivityIndicator() : self.removeActivityIndicator()
    }
    
    private func handleLoadFail(failed: Bool) {
        if failed {
            setErrorState()
        }
    }

    private func setErrorState() {
        postsTableView.isHidden = true
        
        let errorStateView = ErrorStateView()
        errorStateView.reloadButton.rx.tap
            .asDriver().do(onNext: {
                errorStateView.removeFromSuperview()
                self.postsTableView.isHidden = false
            }).map { true }.drive(viewModel.onReload).disposed(by: disposeBag)
        
        errorStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviewAligned(errorStateView)
    }

    private func setuLayout() {
        postsTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviewAligned(postsTableView)
    }
    
    private func setupTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.tableFooterView = UIView()
        tableView.register(PostListItemTableViewCell.self,
                           forCellReuseIdentifier: PostListItemTableViewCell.reuseIdentifier)

        return tableView
    }
}
