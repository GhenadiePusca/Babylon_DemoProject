//
//  PostDetailsViewController.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import UIKit

final class PostDetailsViewController: UIViewController {

    let viewModel: PostDetailViewModel
    lazy var detailView = PostDetailView(viewModel: viewModel)

    init(viewModel: PostDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Details"
        view.backgroundColor = .white

        view.addSubview(detailView)
        
        detailView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                detailView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
                detailView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
                detailView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
                ])
        }
    }
}
