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
        viewModel.postsModels
            .drive(postsTableView.rx.items(cellIdentifier: PostListItemTableViewCell.reuseIdentifier,
                                           cellType: PostListItemTableViewCell.self)) { _, vm, cell in
                cell.update(viewModel: vm)
            }
            .disposed(by: disposeBag)
    }
    
    private func setuLayout() {
        postsTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(postsTableView)
        
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                postsTableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
                postsTableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
                postsTableView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
                postsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
            
        } else {
            NSLayoutConstraint.activate([
                postsTableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
                postsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                postsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                postsTableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: Constants.standardSpacing)
                ])
        }
    }
    
    private func setupTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.tableFooterView = UIView()
        tableView.register(PostListItemTableViewCell.self,
                           forCellReuseIdentifier: PostListItemTableViewCell.reuseIdentifier)

        return tableView
    }
}
