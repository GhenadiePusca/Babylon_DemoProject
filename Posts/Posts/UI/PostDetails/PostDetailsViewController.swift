//
//  PostDetailsViewController.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import UIKit

final class PostDetailsViewController: UIViewController {

    private let detailView: PostDetailView
    
    init(viewModel: PostDetailViewModel) {
        self.detailView = PostDetailView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Details"
        view.backgroundColor = .white
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(detailView)
        
        detailView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                detailView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
                detailView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
                detailView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
                ])
        } else {
            NSLayoutConstraint.activate([
                detailView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                detailView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                detailView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0),
                ])
        }
    }
}
